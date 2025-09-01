# Build and Deploy Script for Webhook CronJob (PowerShell)

param(
    [string]$ImageTag = "latest",
    [string]$Namespace = "default",
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]"
    Write-Host "Options:"
    Write-Host "  -ImageTag TAG        Docker image tag (default: latest)"
    Write-Host "  -Namespace NS        Kubernetes namespace (default: default)"
    Write-Host "  -Help                Show this help message"
    exit 0
}

$ImageName = "webhook-cronjob"

Write-Host "Building and deploying Webhook CronJob" -ForegroundColor Green
Write-Host "Image: ${ImageName}:${ImageTag}" -ForegroundColor Yellow
Write-Host "Namespace: $Namespace" -ForegroundColor Yellow

# Step 1: Build Docker image
Write-Host "`nStep 1: Building Docker image..." -ForegroundColor Green
docker build -t "${ImageName}:${ImageTag}" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker image built successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to build Docker image" -ForegroundColor Red
    exit 1
}

# Step 2: Load image into kind cluster (if using kind)
$currentContext = kubectl config current-context
if ($currentContext -like "*kind*") {
    Write-Host "`nStep 2: Loading image into kind cluster..." -ForegroundColor Green
    kind load docker-image "${ImageName}:${ImageTag}"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Image loaded into kind cluster" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to load image into kind cluster" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nStep 2: Skipping kind load (not using kind cluster)" -ForegroundColor Yellow
}

# Step 3: Deploy with Helm
Write-Host "`nStep 3: Deploying with Helm..." -ForegroundColor Green

# Create namespace if it doesn't exist
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# Deploy with Helm
helm upgrade --install webhook-cronjob .\helm `
    --namespace $Namespace `
    --values helm\values.yaml `
    --set image.tag=$ImageTag `
    --wait `
    --timeout 300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Application deployed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to deploy application" -ForegroundColor Red
    exit 1
}

# Step 4: Show status
Write-Host "`nStep 4: Checking deployment status..." -ForegroundColor Green
kubectl get cronjob -n $Namespace
Write-Host ""
kubectl get pods -n $Namespace -l app.kubernetes.io/name=webhook-cronjob

Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
Write-Host "To view logs: kubectl logs -n $Namespace -l app.kubernetes.io/name=webhook-cronjob" -ForegroundColor Yellow
Write-Host "To view cronjob status: kubectl get cronjob -n $Namespace webhook-cronjob" -ForegroundColor Yellow
