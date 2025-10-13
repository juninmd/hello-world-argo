import axios from 'axios';

interface WebhookPayload {
  status: string;
}

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

// Executa a função
sendWebhook();
