# Instruções para Deploy com ArgoCD

Este documento contém instruções específicas para fazer o deploy da aplicação Webhook CronJob usando ArgoCD.

## Pré-requisitos

1. Cluster Kubernetes funcionando
2. ArgoCD instalado no cluster
3. Imagem Docker da aplicação disponível em um registry
4. Repositório Git com o código

## Passos para Deploy

### 1. Preparar o Repositório

Primeiro, faça o push do código para um repositório Git:

```bash
git init
git add .
git commit -m "Initial commit: Webhook CronJob application"
git remote add origin git@github.com:juninmd/hello-world-argo.git
git push -u origin main
```

### 2. Build e Push da Imagem Docker

```bash
# Build da imagem
docker build -t your-registry/webhook-cronjob:v1.0.0 .

# Push para o registry
docker push your-registry/webhook-cronjob:v1.0.0
```

### 3. Atualizar Configurações

O arquivo `argocd/application.yaml` já está configurado com o repositório correto:

```yaml
spec:
  source:
    repoURL: git@github.com:juninmd/hello-world-argo.git
    targetRevision: HEAD
    path: helm
```

Edite o arquivo `helm/values.yaml` e atualize:

```yaml
image:
  repository: your-registry/webhook-cronjob  # Sua imagem
  tag: "v1.0.0"
```

### 4. Aplicar a Application no ArgoCD

```bash
# Aplicar a configuração
kubectl apply -f argocd/application.yaml

# Verificar se foi criada
kubectl get applications -n argocd
```

### 5. Sincronizar via ArgoCD UI

1. Acesse a interface web do ArgoCD
2. Encontre a application `webhook-cronjob`
3. Clique em "Sync" para fazer o deploy

### 6. Verificar o Deploy

```bash
# Verificar o CronJob
kubectl get cronjob

# Verificar pods criados pelos jobs
kubectl get pods -l app.kubernetes.io/name=webhook-cronjob

# Ver logs
kubectl logs -l app.kubernetes.io/name=webhook-cronjob --tail=50
```

## Monitoramento

### Verificar Status da Application

```bash
# Status da application
kubectl get application webhook-cronjob -n argocd -o yaml

# Logs do ArgoCD
kubectl logs -n argocd deployment/argocd-application-controller
```

### Verificar Execuções do CronJob

```bash
# Jobs executados
kubectl get jobs -l app.kubernetes.io/name=webhook-cronjob

# Histórico de execuções
kubectl describe cronjob webhook-cronjob
```

## Troubleshooting

### Application não sincroniza

1. Verifique se o repositório está acessível
2. Confirme se o path do Helm chart está correto
3. Valide a sintaxe dos templates Helm:

```bash
helm template webhook-cronjob ./helm --debug
```

### CronJob não executa

1. Verifique se a expressão cron está correta
2. Confirme se a imagem está disponível
3. Verifique os logs do controller:

```bash
kubectl logs -n kube-system deployment/cronjob-controller
```

### Webhook não recebe requisições

1. Verifique se a URL do webhook está correta
2. Confirme se o pod tem acesso à internet
3. Verifique os logs da aplicação:

```bash
kubectl logs -l app.kubernetes.io/name=webhook-cronjob --tail=100
```

## Atualizações

Para atualizar a aplicação:

1. Faça as alterações no código
2. Build e push da nova imagem
3. Atualize a tag no `values.yaml`
4. Commit e push das alterações
5. Sincronize via ArgoCD UI ou CLI:

```bash
argocd app sync webhook-cronjob
```
