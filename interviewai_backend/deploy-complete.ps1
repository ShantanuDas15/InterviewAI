#!/usr/bin/env pwsh
# InterviewAI Backend - Cloud Run Deployment Script
# Handles special characters in passwords properly

param(
    [switch]$SkipBuild = $false,
    [switch]$CheckLogs = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$PROJECT_ID = "interviewai-backend-sd-123"
$SERVICE_NAME = "interviewai-backend"
$REGION = "us-central1"

# Supabase Configuration
$DB_HOST = "aws-1-ap-southeast-2.pooler.supabase.com"
$DB_PORT = "5432"
$DB_NAME = "postgres"
$DB_USER = "postgres.ymnoeizgsmwgswswcpea"
$DB_PASSWORD = "ShantanuDas#8013"  # Password with special characters
$SUPABASE_URL = "https://ymnoeizgsmwgswswcpea.supabase.co"
$SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inltbm9laXpnc213Z3N3c3djcGVhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjA2OTg5OSwiZXhwIjoyMDc3NjQ1ODk5fQ.f8wTWqHvwkdUVAMEhJd9GXNaH0lJTRZVD0yII-UC24g"
$SUPABASE_JWT_SECRET = "HgOSUF8geCoQEXljhTUHhQz3JDnKyHv0G2Z50NX4XfHcEO3Rd+Z9WzxYxSx0OkCIhkGZxTGLo3F+Tzf5Sxz1Rg=="

# Gemini Configuration
$GEMINI_API_KEY = "AIzaSyAP3mnXDQ-QsyI5HE8nzKfqYy9K4G-V_H8"
$GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

function Write-Header {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Navigate to backend directory
Set-Location "C:\Java Projects\InterviewAI\interviewai_backend"

Write-Header "INTERVIEWAI BACKEND - CLOUD RUN DEPLOYMENT"

# Display configuration
Write-Info "Configuration:"
Write-Host "  Project ID: $PROJECT_ID" -ForegroundColor White
Write-Host "  Service: $SERVICE_NAME" -ForegroundColor White
Write-Host "  Region: $REGION" -ForegroundColor White
Write-Host "  Database: $DB_HOST`:$DB_PORT/$DB_NAME" -ForegroundColor White
Write-Host "  DB User: $DB_USER" -ForegroundColor White
Write-Host "  Password: [MASKED - Contains # character]" -ForegroundColor White

# Check if we should just view logs
if ($CheckLogs) {
    Write-Header "CHECKING RECENT LOGS"
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" `
        --project $PROJECT_ID `
        --limit 50 `
        --format "table(timestamp,textPayload)"
    exit 0
}

# Build locally first (optional)
if (-not $SkipBuild) {
    Write-Header "BUILDING APPLICATION LOCALLY"
    Write-Info "Running Maven build..."
    
    if (Test-Path ".\mvnw.cmd") {
        .\mvnw.cmd clean package -DskipTests
    } else {
        mvn clean package -DskipTests
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Maven build failed!"
        exit 1
    }
    Write-Success "Local build completed"
}

# Deploy to Cloud Run
Write-Header "DEPLOYING TO CLOUD RUN"
Write-Info "This will build a container and deploy..."

# Using individual --update-env-vars to properly handle special characters
$deployCmd = @(
    "gcloud", "run", "deploy", $SERVICE_NAME,
    "--source", ".",
    "--region", $REGION,
    "--allow-unauthenticated",
    "--project=$PROJECT_ID",
    "--platform=managed",
    "--timeout=300",
    "--memory=1Gi",
    "--cpu=1",
    "--min-instances=0",
    "--max-instances=10",
    "--update-env-vars", "SPRING_DATASOURCE_URL=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}",
    "--update-env-vars", "SPRING_DATASOURCE_USERNAME=$DB_USER",
    "--update-env-vars", "SPRING_DATASOURCE_PASSWORD=$DB_PASSWORD",
    "--update-env-vars", "SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver",
    "--update-env-vars", "SUPABASE_URL=$SUPABASE_URL",
    "--update-env-vars", "SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_KEY",
    "--update-env-vars", "SUPABASE_JWT_SECRET=$SUPABASE_JWT_SECRET",
    "--update-env-vars", "GEMINI_API_KEY=$GEMINI_API_KEY",
    "--update-env-vars", "GEMINI_API_URL=$GEMINI_API_URL"
)

# Execute deployment
& $deployCmd[0] $deployCmd[1..($deployCmd.Length-1)]

if ($LASTEXITCODE -eq 0) {
    Write-Header "DEPLOYMENT SUCCESSFUL"
    
    # Get service URL
    $serviceUrl = gcloud run services describe $SERVICE_NAME --region=$REGION --project=$PROJECT_ID --format="value(status.url)"
    
    Write-Success "Service deployed successfully!"
    Write-Host "`nService URL: $serviceUrl" -ForegroundColor Cyan
    Write-Host "`nTest endpoints:" -ForegroundColor Yellow
    Write-Host "  Health: $serviceUrl/actuator/health" -ForegroundColor White
    Write-Host "  API: $serviceUrl/api/v1/..." -ForegroundColor White
    
    # Test health endpoint
    Write-Info "`nTesting health endpoint..."
    Start-Sleep -Seconds 5
    try {
        $response = Invoke-WebRequest -Uri "$serviceUrl/actuator/health" -Method GET -TimeoutSec 10
        Write-Success "Health check passed: $($response.StatusCode)"
    } catch {
        Write-Warning-Message "Health check failed - service may still be starting"
    }
    
} else {
    Write-Header "DEPLOYMENT FAILED"
    Write-Error-Message "Check the logs above for details"
    
    Write-Info "`nTo check logs, run:"
    Write-Host "  .\deploy-complete.ps1 -CheckLogs" -ForegroundColor Gray
    
    Write-Info "`nOr view in console:"
    $logsUrl = "https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME/logs?project=$PROJECT_ID"
    Write-Host "  $logsUrl" -ForegroundColor Gray
    
    exit 1
}

Write-Host ""
