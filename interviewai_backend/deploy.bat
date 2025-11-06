@echo off
echo ========================================
echo  InterviewAI Backend Deployment
echo  Google Cloud Run
echo ========================================
echo.

REM Prompt for credentials
set /p DB_HOST="Enter Supabase Database Host (e.g., db.xxx.supabase.co): "
set /p DB_PASSWORD="Enter Supabase Database Password: "
set /p SUPABASE_URL="Enter Supabase Project URL (e.g., https://xxx.supabase.co): "
set /p SUPABASE_JWT_SECRET="Enter Supabase JWT Secret: "
set /p SUPABASE_SERVICE_ROLE_KEY="Enter Supabase Service Role Key: "
set /p GEMINI_API_KEY="Enter Google Gemini API Key: "

echo.
echo Creating environment variables file...

REM Create .env.yaml for deployment
(
echo DB_URL: "jdbc:postgresql://%DB_HOST%:5432/postgres?sslmode=require"
echo DB_USERNAME: "postgres"
echo DB_PASSWORD: "%DB_PASSWORD%"
echo SUPABASE_URL: "%SUPABASE_URL%"
echo SUPABASE_JWT_SECRET: "%SUPABASE_JWT_SECRET%"
echo SUPABASE_SERVICE_ROLE_KEY: "%SUPABASE_SERVICE_ROLE_KEY%"
echo GEMINI_API_KEY: "%GEMINI_API_KEY%"
echo GEMINI_API_URL: "https://generativelanguage.googleapis.com/v1beta/models"
) > .env.yaml

echo.
echo Deploying to Cloud Run...
echo This will take 5-10 minutes...
echo.

gcloud run deploy interviewai-backend ^
  --source . ^
  --platform managed ^
  --region us-central1 ^
  --allow-unauthenticated ^
  --env-vars-file .env.yaml ^
  --memory 1Gi ^
  --cpu 1 ^
  --timeout 300 ^
  --min-instances 0 ^
  --max-instances 10

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  Deployment Successful!
    echo ========================================
    echo.
    echo Getting service URL...
    gcloud run services describe interviewai-backend --region us-central1 --format="value(status.url)"
    echo.
    echo Next steps:
    echo 1. Copy the URL above
    echo 2. Update frontend api_constants.dart
    echo 3. Deploy frontend to Netlify
) else (
    echo.
    echo ========================================
    echo  Deployment Failed!
    echo ========================================
    echo Check the errors above
)

REM Clean up env file
del .env.yaml

pause
