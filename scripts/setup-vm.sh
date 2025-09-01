#!/bin/bash

# Script para configurar o ambiente na VM Magalu Cloud
# Execute este script na sua VM Ubuntu com K3s

echo "🚀 Configurando ambiente para GitHub Actions CI/CD"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verifica se está rodando como root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Este script não deve ser executado como root${NC}"
   exit 1
fi

echo -e "${GREEN}1. Gerando kubeconfig para GitHub Actions...${NC}"

# Cria um service account para GitHub Actions
kubectl create serviceaccount github-actions -n default --dry-run=client -o yaml | kubectl apply -f -

# Cria ClusterRoleBinding com permissões necessárias
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: github-actions-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: github-actions
  namespace: default
EOF

# Obter o token do service account
echo -e "${GREEN}2. Extraindo token e configurando kubeconfig...${NC}"

# Para K3s (Kubernetes 1.24+), precisamos criar um token manualmente
kubectl create token github-actions --duration=8760h > /tmp/github-actions-token

# Obter informações do cluster
CLUSTER_NAME=$(kubectl config current-context)
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
TOKEN=$(cat /tmp/github-actions-token)

# Criar kubeconfig para GitHub Actions
cat > /tmp/github-actions-kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: github-actions
  name: github-actions-context
current-context: github-actions-context
users:
- name: github-actions
  user:
    token: ${TOKEN}
EOF

echo -e "${GREEN}3. Kubeconfig gerado em /tmp/github-actions-kubeconfig${NC}"

# Codificar em base64 para uso no GitHub Secrets
KUBE_CONFIG_B64=$(base64 -w 0 /tmp/github-actions-kubeconfig)

echo -e "${YELLOW}4. Configure os seguintes secrets no GitHub:${NC}"
echo ""
echo -e "${YELLOW}KUBE_CONFIG:${NC}"
echo "$KUBE_CONFIG_B64"
echo ""

# Se ArgoCD estiver instalado, configurar também
if kubectl get namespace argocd >/dev/null 2>&1; then
    echo -e "${GREEN}5. ArgoCD detectado! Configurando acesso...${NC}"

    # Obter servidor ArgoCD
    ARGOCD_SERVER=$(kubectl get service argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -z "$ARGOCD_SERVER" ]; then
        ARGOCD_SERVER=$(kubectl get service argocd-server -n argocd -o jsonpath='{.spec.clusterIP}')
    fi

    # Obter senha inicial do admin
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "admin")

    echo -e "${YELLOW}Configure também estes secrets para ArgoCD:${NC}"
    echo -e "${YELLOW}ARGOCD_SERVER:${NC} $ARGOCD_SERVER"
    echo -e "${YELLOW}ARGOCD_USERNAME:${NC} admin"
    echo -e "${YELLOW}ARGOCD_PASSWORD:${NC} $ARGOCD_PASSWORD"
    echo ""
else
    echo -e "${YELLOW}5. ArgoCD não detectado. Instalando...${NC}"

    # Instalar ArgoCD
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    echo -e "${GREEN}ArgoCD instalado! Aguarde alguns minutos para que os pods iniciem.${NC}"
    echo -e "${YELLOW}Para acessar o ArgoCD:${NC}"
    echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "Username: admin"
    echo "Password: \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d)"
fi

echo -e "${GREEN}6. Aplicando Application do ArgoCD...${NC}"

# Aplicar a application se o arquivo existir
if [ -f "argocd/application.yaml" ]; then
    kubectl apply -f argocd/application.yaml
    echo -e "${GREEN}✅ ArgoCD Application aplicada!${NC}"
else
    echo -e "${YELLOW}⚠️  Arquivo argocd/application.yaml não encontrado${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Configuração concluída!${NC}"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "1. Configure os secrets no GitHub Repository Settings > Secrets and variables > Actions"
echo "2. Faça um push para testar o CI/CD"
echo "3. Monitore o workflow em GitHub Actions"
echo ""
echo -e "${YELLOW}Para monitorar o ArgoCD:${NC}"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Acesse: https://localhost:8080"

# Limpar arquivos temporários
rm -f /tmp/github-actions-token /tmp/github-actions-kubeconfig

echo -e "${GREEN}✅ Script finalizado!${NC}"
