# Setup CI/CD com GitHub Actions

Este guia mostra como configurar o deploy automatizado para sua VM na Magalu Cloud usando GitHub Actions, K3s e ArgoCD.

## 📋 Pré-requisitos

- VM Ubuntu na Magalu Cloud com K3s instalado
- ArgoCD instalado no cluster
- Acesso SSH à VM
- Repositório GitHub configurado

## 🚀 Configuração Passo a Passo

### 1. Na sua VM (Magalu Cloud)

Conecte-se via SSH à sua VM e execute:

```bash
# Clone o repositório
git clone git@github.com:juninmd/hello-world-argo.git
cd hello-world-argo

# Torne o script executável
chmod +x scripts/setup-vm.sh

# Execute o script de configuração
./scripts/setup-vm.sh
```

Este script irá:
- ✅ Criar um ServiceAccount para GitHub Actions
- ✅ Gerar kubeconfig com permissões adequadas
- ✅ Configurar ArgoCD (se não estiver instalado)
- ✅ Aplicar a Application do ArgoCD
- ✅ Mostrar os secrets necessários para o GitHub

### 2. No GitHub Repository

Vá para **Settings > Secrets and variables > Actions** e adicione:

#### **Secrets Obrigatórios:**
```
KUBE_CONFIG: <valor gerado pelo script>
```

#### **Secrets para ArgoCD (opcional, mas recomendado):**
```
ARGOCD_SERVER: <IP ou hostname da VM>
ARGOCD_USERNAME: admin
ARGOCD_PASSWORD: <senha gerada pelo script>
```

### 3. Configuração da Imagem Docker

O workflow usa GitHub Container Registry (ghcr.io). As imagens serão:
```
ghcr.io/juninmd/hello-world-argo:latest
ghcr.io/juninmd/hello-world-argo:main-<commit-sha>
```

### 4. Workflows Disponíveis

Escolha um dos workflows criados:

#### **A) Deploy Direto (`.github/workflows/deploy.yml`)**
- ✅ Build da imagem Docker
- ✅ Push para GitHub Container Registry
- ✅ Deploy direto via Helm
- ✅ Sincronização opcional com ArgoCD

#### **B) Deploy via ArgoCD (`.github/workflows/deploy-argocd.yml`)**
- ✅ Build da imagem Docker
- ✅ Atualiza `values.yaml` com nova tag
- ✅ Commit automático da atualização
- ✅ Sincronização via ArgoCD CLI

**Recomendado:** Use o workflow B para aproveitar melhor o ArgoCD.

## 🔧 Configurações Avançadas

### Acesso ao ArgoCD

Para acessar a interface do ArgoCD:

```bash
# Na VM, faça port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Ou configure um LoadBalancer/Ingress para acesso externo
```

### Customizar o Webhook URL

Para usar um webhook específico, edite `helm/values.yaml`:

```yaml
cronjob:
  webhookUrl: "https://seu-webhook-aqui.com"
  schedule: "*/5 * * * *"  # A cada 5 minutos
```

### Configurar Diferentes Ambientes

Se quiser separar dev/prod, crie Applications diferentes no ArgoCD:

```yaml
# argocd/application-dev.yaml
metadata:
  name: webhook-cronjob-dev
spec:
  destination:
    namespace: development
  source:
    helm:
      parameters:
        - name: cronjob.schedule
          value: "*/1 * * * *"  # Mais frequente em dev
```

## 🔍 Monitoramento

### Verificar o Deploy

```bash
# Status do CronJob
kubectl get cronjob webhook-cronjob

# Pods executados
kubectl get pods -l app.kubernetes.io/name=webhook-cronjob

# Logs da aplicação
kubectl logs -l app.kubernetes.io/name=webhook-cronjob --tail=50

# Status no ArgoCD
kubectl get application webhook-cronjob -n argocd
```

### Logs do GitHub Actions

1. Vá para **Actions** no GitHub
2. Selecione o workflow executado
3. Monitore cada step do job

## 🛠️ Troubleshooting

### Erro de Permissão no Kubernetes

```bash
# Verificar se o ServiceAccount existe
kubectl get serviceaccount github-actions

# Verificar permissões
kubectl auth can-i "*" "*" --as=system:serviceaccount:default:github-actions
```

### ArgoCD não sincroniza

```bash
# Verificar status da application
argocd app get webhook-cronjob

# Forçar sincronização
argocd app sync webhook-cronjob --force
```

### Imagem não encontrada

Verifique se:
1. O build do Docker foi bem-sucedido
2. A imagem foi publicada no ghcr.io
3. O K3s consegue fazer pull de imagens públicas

### Webhook não recebe requisições

```bash
# Verificar logs do cronjob
kubectl logs -l app.kubernetes.io/name=webhook-cronjob

# Verificar se o pod tem conectividade
kubectl exec -it <pod-name> -- curl -I https://webhook.site
```

## 🔐 Segurança

### Recomendações:

1. **Use secrets** para informações sensíveis
2. **Rotacione tokens** periodicamente
3. **Monitore acessos** ao cluster
4. **Use namespaces** para isolamento
5. **Configure RBAC** específico para cada aplicação

### Exemplo de RBAC mais restritivo:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: webhook-cronjob-deployer
  namespace: default
rules:
- apiGroups: ["batch", "apps", ""]
  resources: ["cronjobs", "deployments", "pods", "services"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
```

## 📈 Próximos Passos

1. **Configurar alertas** para falhas no deploy
2. **Implementar testes** automatizados
3. **Configurar monitoring** com Prometheus/Grafana
4. **Adicionar healthchecks** mais robustos
5. **Implementar rollback** automático

## 🔗 Links Úteis

- [K3s Documentation](https://docs.k3s.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Helm Documentation](https://helm.sh/docs/)
