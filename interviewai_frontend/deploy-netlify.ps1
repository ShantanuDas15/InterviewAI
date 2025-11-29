# deploy-netlify.ps1

Write-Host "=== InterviewAI Frontend - Netlify Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Check if Netlify CLI is installed
if (-not (Get-Command netlify -ErrorAction SilentlyContinue)) {
    Write-Host "Netlify CLI not found." -ForegroundColor Yellow
    Write-Host "Attempting to install Netlify CLI via npm..."
    
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g netlify-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install Netlify CLI." -ForegroundColor Red
            Write-Host "Please install Node.js and run 'npm install -g netlify-cli' manually."
            exit 1
        }
    } else {
        Write-Host "npm is not installed. Please install Node.js to use Netlify CLI." -ForegroundColor Red
        exit 1
    }
}

# Build Flutter Web
Write-Host "Building Flutter Web App..." -ForegroundColor Cyan
# Using html renderer for better compatibility with some libraries, or canvaskit for performance. 
# Auto is usually best but sometimes has CORS issues with images from other domains if not configured.
# Let's stick to default (auto) or specify if needed. The user didn't specify.
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful." -ForegroundColor Green
Write-Host ""

# Deploy to Netlify
Write-Host "Deploying to Netlify..." -ForegroundColor Cyan
Write-Host "Note: If this is your first time, you may be asked to link this folder to a site." -ForegroundColor Yellow

# Deploy to production
netlify deploy --prod --dir=build/web

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Deployment Successful! ===" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "=== Deployment Failed ===" -ForegroundColor Red
}
