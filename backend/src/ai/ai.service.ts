import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { StickerAssignedBy } from '@prisma/client';

export interface AiAnalysisResult {
  sticker_id: number;
  reason: string;
  confidence: number;
}

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
  ) {}

  async analyzeHomework(
    homeworkId: number,
    submissionId: number,
  ): Promise<AiAnalysisResult> {
    const homework = await this.prisma.homework.findUnique({
      where: { id: homeworkId },
      include: { student: true },
    });
    const submission = await this.prisma.homeworkSubmission.findUnique({
      where: { id: submissionId },
    });

    if (!homework || !submission) {
      throw new NotFoundException('Homework or submission not found');
    }

    const stickers = await this.prisma.sticker.findMany({
      where: { isActive: true, level: { isActive: true } },
      include: { level: true },
    });

    if (stickers.length === 0) {
      throw new BadRequestException('No active stickers available');
    }

    const apiKey = this.config.get<string>('OPENAI_API_KEY');
    let result: AiAnalysisResult;

    if (apiKey) {
      try {
        result = await this.callOpenAI(
          homework.title,
          homework.description,
          submission.teacherGrade ?? '',
          submission.teacherNote ?? '',
          stickers,
          apiKey,
        );
      } catch (e) {
        this.logger.warn(`OpenAI failed, using fallback: ${e}`);
        result = this.fallbackPick(stickers, submission.teacherGrade ?? '');
      }
    } else {
      this.logger.debug('OPENAI_API_KEY missing — using rule-based picker');
      result = this.fallbackPick(stickers, submission.teacherGrade ?? '');
    }

    const validSticker = stickers.find((s) => s.id === result.sticker_id);
    if (!validSticker) {
      result.sticker_id = stickers[0].id;
    }

    await this.prisma.homeworkSubmission.update({
      where: { id: submissionId },
      data: { aiAnalysis: result as object },
    });

    const existing = await this.prisma.studentSticker.findFirst({
      where: { homeworkId, studentId: homework.studentId },
    });

    if (existing) {
      await this.prisma.studentSticker.update({
        where: { id: existing.id },
        data: {
          stickerId: result.sticker_id,
          assignedBy: StickerAssignedBy.ai,
          note: result.reason,
        },
      });
    } else {
      await this.prisma.studentSticker.create({
        data: {
          studentId: homework.studentId,
          stickerId: result.sticker_id,
          homeworkId,
          assignedBy: StickerAssignedBy.ai,
          note: result.reason,
        },
      });
    }

    return result;
  }

  private async callOpenAI(
    title: string,
    description: string,
    grade: string,
    note: string,
    stickers: Array<{
      id: number;
      name: string;
      description: string | null;
      level: { name: string; sortOrder: number };
    }>,
    apiKey: string,
  ): Promise<AiAnalysisResult> {
    const stickerList = stickers
      .map(
        (s) =>
          `- id:${s.id} name:"${s.name}" level:"${s.level.name}" (order:${s.level.sortOrder}) desc:"${s.description ?? ''}"`,
      )
      .join('\n');

    const prompt = `أنت مساعد تعليمي لروضة أطفال. حلّل الواجب واختر ملصقاً واحداً فقط من القائمة.

الواجب: ${title}
الوصف: ${description}
درجة المعلمة: ${grade}
ملاحظة المعلمة: ${note}

الملصقات المتاحة (اختر sticker_id واحد فقط من هذه القائمة):
${stickerList}

أجب بـ JSON فقط بهذا الشكل:
{"sticker_id": <number>, "reason": "<سبب بالعربية>", "confidence": <0-1>}`;

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: this.config.get('OPENAI_MODEL', 'gpt-4o-mini'),
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        response_format: { type: 'json_object' },
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.status}`);
    }

    const data = (await response.json()) as {
      choices: Array<{ message: { content: string } }>;
    };
    const content = data.choices[0]?.message?.content ?? '{}';
    const parsed = JSON.parse(content) as AiAnalysisResult;
    return {
      sticker_id: Number(parsed.sticker_id),
      reason: parsed.reason || 'أداء جيد',
      confidence: Number(parsed.confidence) || 0.8,
    };
  }

  private fallbackPick(
    stickers: Array<{
      id: number;
      level: { name: string; sortOrder: number };
    }>,
    grade: string,
  ): AiAnalysisResult {
    const g = grade.toLowerCase();
    let targetOrder = 1;
    if (g.includes('ممتاز') || g.includes('Excellent') || g.includes('10')) {
      targetOrder = 3;
    } else if (g.includes('جيد') || g.includes('Good') || g.includes('8')) {
      targetOrder = 2;
    }

    const byLevel = stickers.filter((s) => s.level.sortOrder === targetOrder);
    const pool = byLevel.length > 0 ? byLevel : stickers;
    const picked = pool[Math.floor(Math.random() * pool.length)];

    return {
      sticker_id: picked.id,
      reason: `ملصق تلقائي بناءً على الدرجة: ${grade}`,
      confidence: 0.6,
    };
  }
}
