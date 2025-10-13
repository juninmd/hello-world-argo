import express, { Request, Response } from 'express';
import axios from 'axios';

const app = express();
const port = process.env.PORT || 3000;

interface WebhookPayload {
  status: string;
}

app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'OK' });
});

async function sendWebhook() {
  const webhookUrl = process.env.WEBHOOK_URL!;
  const payload: WebhookPayload = { status: 'deu certo' };

  try {
    const response = await axios.post(webhookUrl, payload, {
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'webhook-cronjob/1.0.0'
      },
    });

    console.log(`[${new Date().toISOString()}] Webhook enviado com sucesso: ${response.status}`);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Erro ao enviar webhook:`, error);
    process.exit(1);
  }
}

// If run as cronjob, send webhook; else start server
if (process.env.RUN_AS_CRONJOB === 'true') {
  sendWebhook();
} else {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}
