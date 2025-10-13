# Hello World Argo - CronJob

Uma aplicação simples em Bun que executa como cronjob no Kubernetes, fazendo chamadas POST para um webhook.

## Funcionalidades

- Aplicação em TypeScript com Bun
- CronJob no Kubernetes via Helm
- Chamadas HTTP POST
- CI/CD com GitHub Actions
- Deploy automático com ArgoCD

## Como funciona

1. Faça um commit na branch `master`
2. GitHub Actions constrói a imagem e atualiza o Helm chart
3. ArgoCD detecta a mudança e sincroniza no k3s

## Deploy

Certifique-se de que o ArgoCD está configurado com auto sync e apontando para este repositório.
