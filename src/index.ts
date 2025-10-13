import axios from 'axios';
import * as cron from 'node-cron';

interface WebhookPayload {
  status: string;
}

class WebhookCronJob {
  private readonly webhookUrl: string;
  private readonly payload: WebhookPayload;
  private readonly cronExpression: string;

  constructor() {
    this.webhookUrl = process.env.WEBHOOK_URL!;
    this.payload = { status: 'deu certo' };
    // Por padrão executa a cada 5 minutos, mas pode ser configurado via env var
    this.cronExpression = process.env.CRON_EXPRESSION || '*/5 * * * *';
  }

  async sendWebhookRequest(): Promise<void> {
    try {
      console.log(`[${new Date().toISOString()}] Enviando requisição para webhook...`);

      const response = await axios.post(this.webhookUrl, this.payload, {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'webhook-cronjob/1.0.0'
        },
        timeout: 10000 // 10 segundos de timeout
      });

      console.log(`[${new Date().toISOString()}] Requisição enviada com sucesso! Status: ${response.status}`);
      console.log(`[${new Date().toISOString()}] Response: ${JSON.stringify(response.data)}`);

    } catch (error) {
      if (axios.isAxiosError(error)) {
        console.error(`[${new Date().toISOString()}] Erro na requisição:`, {
          message: error.message,
          status: error.response?.status,
          statusText: error.response?.statusText,
          data: error.response?.data
        });
      } else {
        console.error(`[${new Date().toISOString()}] Erro inesperado:`, error);
      }
    }
  }

  start(): void {
    console.log(`[${new Date().toISOString()}] Iniciando cronjob com expressão: ${this.cronExpression}`);
    console.log(`[${new Date().toISOString()}] URL do webhook: ${this.webhookUrl}`);
    console.log(`[${new Date().toISOString()}] Payload: ${JSON.stringify(this.payload)}`);

    // Valida a expressão cron
    if (!cron.validate(this.cronExpression)) {
      throw new Error(`Expressão cron inválida: ${this.cronExpression}`);
    }

    // Agenda o job
    cron.schedule(this.cronExpression, async () => {
      await this.sendWebhookRequest();
    }, {
      scheduled: true,
      timezone: "America/Sao_Paulo"
    });

    console.log(`[${new Date().toISOString()}] Cronjob agendado com sucesso!`);

    // Mantém o processo rodando
    process.on('SIGINT', () => {
      console.log(`[${new Date().toISOString()}] Recebido SIGINT. Finalizando aplicação...`);
      process.exit(0);
    });

    process.on('SIGTERM', () => {
      console.log(`[${new Date().toISOString()}] Recebido SIGTERM. Finalizando aplicação...`);
      process.exit(0);
    });
  }
}

// Função principal
async function main() {
  try {
    const cronJob = new WebhookCronJob();
    cronJob.start();

    // Mantém o processo vivo
    process.stdin.resume();

  } catch (error) {
    console.error(`[${new Date().toISOString()}] Erro ao iniciar aplicação:`, error);
    process.exit(1);
  }
}

// Executa apenas se for o arquivo principal
if (require.main === module) {
  main();
}

export { WebhookCronJob };
