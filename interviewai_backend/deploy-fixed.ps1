#!/usr/bin/env pwsh
# Fixed deployment script with proper password handling

Write-Host "`n=== DEPLOYING INTERVIEWAI BACKEND TO CLOUD RUN ===" -ForegroundColor Green
Write-Host "Handling special characters in password properly`n" -ForegroundColor Yellow

# The actual password from Supabase
$password = "ShantanuDas#8013"

# URL encode the password to handle special characters
# Note: We don't URL-encode for environment variables in Cloud Run
# They are passed as-is to the container

# Build the environment variables string
# Each variable should be properly quoted
$envVars = @(
    "SPRING_DATASOURCE_URL=jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres",
    "SPRING_DATASOURCE_USERNAME=postgres.ymnoeizgsmwgswswcpea",
    "SPRING_DATASOURCE_PASSWORD=$password",
    "SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver",
    "SUPABASE_URL=https://ymnoeizgsmwgswswcpea.supabase.co",
    "SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inltbm9laXpnc213Z3N3c3djcGVhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjA2OTg5OSwiZXhwIjoyMDc3NjQ1ODk5fQ.f8wTWqHvwkdUVAMEhJd9GXNaH0lJTRZVD0yII-UC24g",
    "SUPABASE_JWT_SECRET=HgOSUF8geCoQEXljhTUHhQz3JDnKyHv0G2Z50NX4XfHcEO3Rd+Z9WzxYxSx0OkCIhkGZxTGLo3F+Tzf5Sxz1Rg==",
    "GEMINI_API_KEY=AIzaSyAP3mnXDQ-QsyI5HE8nzKfqYy9K4G-V_H8",
    "GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
)

# Join with commas for gcloud
$envVarsString = $envVars -join ","

Write-Host "Deploying with environment variables..." -ForegroundColor Cyan
Write-Host "Database: aws-1-ap-southeast-2.pooler.supabase.com:5432" -ForegroundColor White
Write-Host "Username: postgres.ymnoeizgsmwgswswcpea" -ForegroundColor White
Write-Host "Password: [MASKED]`n" -ForegroundColor White

# Deploy to Cloud Run
gcloud run deploy interviewai-backend `
    --source . `
    --region us-central1 `
    --allow-unauthenticated `
    --project=interviewai-backend-sd-123 `
    --set-env-vars $envVarsString `
    --timeout=300 `
    --memory=1Gi `
    --cpu=1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== DEPLOYMENT SUCCESSFUL ===" -ForegroundColor Green
    Write-Host "Service URL: https://interviewai-backend-iy27n6gvpq-uc.a.run.app`n" -ForegroundColor Cyan
} else {
    Write-Host "`n=== DEPLOYMENT FAILED ===" -ForegroundColor Red
    Write-Host "Check the logs above for details.`n" -ForegroundColor Yellow
}
