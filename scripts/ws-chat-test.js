/**
 * Quick WebSocket chat test for Phase 4.
 * Usage: node scripts/ws-chat-test.js <token> <conversationId> <message>
 */
const WebSocket = require('../backend/node_modules/ws');

const token = process.argv[2];
const conversationId = parseInt(process.argv[3], 10);
const message = process.argv[4] || 'ws test message';

if (!token || !conversationId) {
  console.error('Usage: node scripts/ws-chat-test.js <token> <conversationId> [message]');
  process.exit(1);
}

const ws = new WebSocket(`ws://localhost:3000/ws/chat?token=${token}`);

let received = false;
const timeout = setTimeout(() => {
  console.error('WS timeout');
  ws.close();
  process.exit(1);
}, 8000);

ws.on('open', () => {
  ws.send(JSON.stringify({ event: 'join', data: { conversationId } }));
  setTimeout(() => {
    ws.send(JSON.stringify({
      event: 'send',
      data: { conversationId, body: message },
    }));
  }, 300);
});

ws.on('message', (raw) => {
  try {
    const data = JSON.parse(raw.toString());
    if (data.event === 'new_message' && data.data?.body === message) {
      received = true;
      clearTimeout(timeout);
      console.log('OK');
      ws.close();
      process.exit(0);
    }
  } catch (_) {}
});

ws.on('error', (err) => {
  clearTimeout(timeout);
  console.error(err.message);
  process.exit(1);
});

ws.on('close', () => {
  if (!received) {
    clearTimeout(timeout);
    process.exit(1);
  }
});
