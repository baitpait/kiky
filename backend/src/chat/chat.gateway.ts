import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Server, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import * as url from 'url';
import { ChatService } from './chat.service';
import { UserRole } from '@prisma/client';

interface AuthenticatedSocket extends WebSocket {
  userId?: number;
  role?: UserRole;
  isAlive?: boolean;
}

@WebSocketGateway({ path: '/ws/chat' })
export class ChatGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(ChatGateway.name);
  private readonly clients = new Map<WebSocket, { userId: number; role: UserRole }>();

  constructor(
    private chatService: ChatService,
    private jwtService: JwtService,
    private config: ConfigService,
  ) {}

  handleConnection(client: AuthenticatedSocket, req: IncomingMessage) {
    try {
      const parsed = url.parse(req.url || '', true);
      const token = parsed.query.token as string;
      if (!token) throw new UnauthorizedException();

      const payload = this.jwtService.verify(token, {
        secret: this.config.get<string>('JWT_ACCESS_SECRET'),
      }) as { sub: number; role: UserRole };

      if (
        payload.role !== UserRole.teacher &&
        payload.role !== UserRole.parent &&
        payload.role !== UserRole.admin
      ) {
        client.close(4003, 'Chat not allowed for this role');
        return;
      }

      client.userId = payload.sub;
      client.role = payload.role;
      client.isAlive = true;
      this.clients.set(client, {
        userId: payload.sub,
        role: payload.role,
      });

      this.logger.debug(`WS connected: user=${payload.sub} role=${payload.role}`);
    } catch {
      client.close(4001, 'Unauthorized');
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    this.clients.delete(client);
  }

  @SubscribeMessage('join')
  async handleJoin(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { conversationId: number },
  ) {
    if (!client.userId || !client.role) return { error: 'Unauthorized' };

    try {
      await this.chatService.getMessages(
        data.conversationId,
        client.userId,
        client.role,
      );
      (client as unknown as { rooms?: Set<number> }).rooms ??= new Set();
      ((client as unknown as { rooms: Set<number> }).rooms).add(
        data.conversationId,
      );
      return { joined: data.conversationId };
    } catch (e) {
      return { error: (e as Error).message };
    }
  }

  @SubscribeMessage('send')
  async handleSend(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { conversationId: number; body: string },
  ) {
    if (!client.userId || !client.role) return { error: 'Unauthorized' };

    try {
      const message = await this.chatService.sendMessage(
        data.conversationId,
        client.userId,
        client.role,
        data.body,
      );

      this.broadcastToConversation(data.conversationId, {
        event: 'new_message',
        data: message,
      });

      return { ok: true, message };
    } catch (e) {
      return { error: (e as Error).message };
    }
  }

  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: AuthenticatedSocket) {
    client.isAlive = true;
    return { event: 'pong' };
  }

  broadcastToConversation(conversationId: number, payload: object) {
    const encoded = JSON.stringify(payload);
    this.clients.forEach((meta, ws) => {
      const rooms = (ws as unknown as { rooms?: Set<number> }).rooms;
      if (rooms?.has(conversationId) && ws.readyState === ws.OPEN) {
        ws.send(encoded);
      }
    });
  }

  broadcastMessage(conversationId: number, message: object) {
    this.broadcastToConversation(conversationId, {
      event: 'new_message',
      data: message,
    });
  }
}
