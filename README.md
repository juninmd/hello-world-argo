# Webhook CronJob

Uma aplicação em Bun que executa como cronjob no Kubernetes, fazendo chamadas POST para um webhook específico.

## Funcionalidades

- ✅ Aplicação desenvolvida em TypeScript com Bun
- ✅ Execução como CronJob no Kubernetes
- ✅ Chamadas HTTP POST usando axios
- ✅ Dockerfile otimizado para produção
- ✅ Charts Helm para deploy
- ✅ Configuração para ArgoCD
- ✅ Logging estruturado
- ✅ Configurações via variáveis de ambiente
- ✅ Healthcheck
- ✅ Security best practices

## Estrutura do Projeto

```
.
├── src/
│   └── index.ts          # Aplicação principal
├── helm/                 # Charts Helm
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── cronjob.yaml
│       └── serviceaccount.yaml
├── argocd/
│   └── application.yaml  # Application ArgoCD
├── scripts/              # Scripts de deploy
│   ├── deploy.sh
│   └── deploy.ps1
├── Dockerfile
├── package.json
└── tsconfig.json
```

## Desenvolvimento Local

### Pré-requisitos

- [Bun](https://bun.sh) >= 1.0.0
- Docker (opcional)

### Instalação

```bash
# Instalar dependências
bun install

# Executar em modo desenvolvimento
bun run dev

# Executar em produção
bun start
```

### Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `WEBHOOK_URL` | URL do webhook para fazer as chamadas | `https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704` |
| `CRON_EXPRESSION` | Expressão cron para agendamento | `*/5 * * * *` (a cada 5 minutos) |
| `NODE_ENV` | Ambiente de execução | `development` |

## Testes

### Teste Local

```bash
# Com Node.js
npm run build
npm start

# Com Bun (se instalado)
bun run build:bun
bun run start:bun

# Com variáveis de ambiente customizadas
WEBHOOK_URL="https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704" CRON_EXPRESSION="*/1 * * * *" npm start
```

### Verificação no Webhook.site

1. Acesse https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704
2. Você deve ver as requisições POST chegando com o payload `{"status": "deu certo"}`

## Build da Imagem Docker

```bash
# Build da imagem
docker build -t webhook-cronjob:latest .

# Executar localmente
docker run -e WEBHOOK_URL="https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704" webhook-cronjob:latest
```

## Deploy no Kubernetes

### Usando Helm diretamente

```bash
# Instalar o chart
helm install webhook-cronjob ./helm

# Upgrade
helm upgrade webhook-cronjob ./helm

# Desinstalar
helm uninstall webhook-cronjob
```

### Usando Scripts de Deploy

```bash
# Linux/Mac
./scripts/deploy.sh -t latest

# Windows
.\scripts\deploy.ps1 -ImageTag latest
```

### Usando ArgoCD

1. Faça o commit do código em um repositório Git
2. Atualize a `repoURL` em `argocd/application.yaml`
3. Aplique a Application no ArgoCD:

```bash
kubectl apply -f argocd/application.yaml
```

## Configurações do Helm

### Valores Principais

```yaml
# Configuração do cronjob
cronjob:
  schedule: "*/5 * * * *"
  webhookUrl: "https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704"
  timezone: "America/Sao_Paulo"

# Configuração da imagem
image:
  repository: webhook-cronjob
  tag: "latest"
  pullPolicy: IfNotPresent

# Recursos
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

## Payload

A aplicação envia o seguinte payload via POST:

```json
{
  "status": "deu certo"
}
```

## Logs

A aplicação gera logs estruturados com timestamp:

```
[2024-01-15T10:00:00.000Z] Iniciando cronjob com expressão: */5 * * * *
[2024-01-15T10:00:00.000Z] URL do webhook: https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704
[2024-01-15T10:00:00.000Z] Payload: {"status":"deu certo"}
[2024-01-15T10:00:00.000Z] Cronjob agendado com sucesso!
[2024-01-15T10:05:00.000Z] Enviando requisição para webhook...
[2024-01-15T10:05:00.100Z] Requisição enviada com sucesso! Status: 200
```

## Monitoramento

- Health check integrado no Dockerfile
- Logs estruturados para observabilidade
- Suporte a ServiceMonitor (Prometheus) em produção

## Segurança

- Execução como usuário não-root
- Filesystem read-only
- Capabilities DROP ALL
- Security contexts apropriados
- Imagem baseada em Alpine Linux
