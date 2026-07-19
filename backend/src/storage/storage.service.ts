import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as Minio from 'minio';
import { randomUUID } from 'crypto';
import { promises as fs } from 'fs';
import * as path from 'path';
import { withTimeout } from '../common/utils/timeout.util';

@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  private client!: Minio.Client;
  private bucket!: string;
  private publicBaseUrl!: string;
  private available = false;

  constructor(private config: ConfigService) {}

  async onModuleInit() {
    if (this.config.get<string>('MINIO_ENABLED', 'false') !== 'true') {
      this.logger.warn('MinIO disabled — uploads unavailable until MINIO_ENABLED=true');
      return;
    }

    try {
      const endpoint = this.config.get<string>('MINIO_ENDPOINT', 'localhost');
      const port = parseInt(this.config.get<string>('MINIO_PORT', '9000'), 10);
      const useSSL = this.config.get<string>('MINIO_USE_SSL', 'false') === 'true';
      const connectTimeoutMs = parseInt(
        this.config.get<string>('MINIO_CONNECT_TIMEOUT_MS', '1500'),
        10,
      );

      this.bucket = this.config.get<string>('MINIO_BUCKET', 'kiddy-link');
      this.publicBaseUrl = this.config.get<string>(
        'MINIO_PUBLIC_URL',
        `http://${endpoint}:${port}`,
      );

      this.client = new Minio.Client({
        endPoint: endpoint,
        port,
        useSSL,
        accessKey: this.config.get<string>('MINIO_ACCESS_KEY', 'minioadmin'),
        secretKey: this.config.get<string>('MINIO_SECRET_KEY', 'minioadmin123'),
      });

      const exists = await withTimeout(
        this.client.bucketExists(this.bucket),
        connectTimeoutMs,
        'MinIO bucketExists',
      );
      if (!exists) {
        await withTimeout(
          this.client.makeBucket(this.bucket),
          connectTimeoutMs,
          'MinIO makeBucket',
        );
      }
      this.available = true;
      this.logger.log('MinIO storage ready');
    } catch {
      this.available = false;
      this.logger.warn('MinIO unavailable — uploads disabled (start Docker/MinIO or set MINIO_ENABLED=false)');
    }
  }

  async upload(
    file: Express.Multer.File,
    folder: string,
  ): Promise<string> {
    const ext = file.originalname.split('.').pop() || 'jpg';
    const key = `${folder}/${randomUUID()}.${ext}`;

    if (!this.available) {
      return this.uploadLocal(file, key);
    }

    await this.client.putObject(
      this.bucket,
      key,
      file.buffer,
      file.size,
      { 'Content-Type': file.mimetype },
    );

    return `${this.publicBaseUrl}/${this.bucket}/${key}`;
  }

  private async uploadLocal(
    file: Express.Multer.File,
    key: string,
  ): Promise<string> {
    const uploadsRoot = path.join(process.cwd(), 'uploads');
    const filePath = path.join(uploadsRoot, key);
    await fs.mkdir(path.dirname(filePath), { recursive: true });
    await fs.writeFile(filePath, file.buffer);

    this.logger.log(`Local upload saved: ${key}`);
    return `/uploads/${key}`;
  }

  getPublicUrl(key: string): string {
    return `${this.publicBaseUrl}/${this.bucket}/${key}`;
  }
}
