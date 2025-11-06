# Deploy Spring Boot Backend to Google Cloud Run

## Prerequisites

- Google Cloud account (Free tier: 2 million requests/month)
- gcloud CLI installed

## Quick Deployment Steps

### Step 1: Install Google Cloud CLI (if not installed)

**Windows:**

```powershell
# Download and run the installer
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe
```

**Or download from:** https://cloud.google.com/sdk/docs/install

### Step 2: Initialize gcloud

```bash
# Login to Google Cloud
gcloud auth login

# Create new project or use existing
gcloud projects create interviewai-backend --name="InterviewAI Backend"

# Set project
gcloud config set project interviewai-backend

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 3: Configure Secrets (for environment variables)

```bash
# Create secrets in Secret Manager
gcloud services enable secretmanager.googleapis.com

# Add your secrets
echo "jdbc:postgresql://YOUR_SUPABASE_HOST:5432/postgres?sslmode=require" | gcloud secrets create db-url --data-file=-
echo "postgres" | gcloud secrets create db-username --data-file=-
echo "YOUR_SUPABASE_PASSWORD" | gcloud secrets create db-password --data-file=-
echo "YOUR_SUPABASE_URL" | gcloud secrets create supabase-url --data-file=-
echo "YOUR_JWT_SECRET" | gcloud secrets create supabase-jwt-secret --data-file=-
echo "YOUR_SERVICE_ROLE_KEY" | gcloud secrets create supabase-service-role-key --data-file=-
echo "YOUR_GEMINI_KEY" | gcloud secrets create gemini-api-key --data-file=-
```

### Step 4: Deploy to Cloud Run (from project root)

```bash
cd "C:\Java Projects\InterviewAI\interviewai_backend"

# Build and deploy
gcloud run deploy interviewai-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models" \
  --set-secrets="DB_URL=db-url:latest,DB_USERNAME=db-username:latest,DB_PASSWORD=db-password:latest,SUPABASE_URL=supabase-url:latest,SUPABASE_JWT_SECRET=supabase-jwt-secret:latest,SUPABASE_SERVICE_ROLE_KEY=supabase-service-role-key:latest,GEMINI_API_KEY=gemini-api-key:latest" \
  --memory 1Gi \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10
```

### Step 5: Get Your Service URL

After deployment completes, you'll get a URL like:

```
https://interviewai-backend-xxxxx-uc.a.run.app
```

Copy this URL to update your Flutter frontend!

---

## Alternative: Deploy via Console UI

1. Go to https://console.cloud.google.com/run
2. Click **"Create Service"**
3. Select **"Continuously deploy from a repository"**
4. Connect your GitHub: `ShantanuDas15/InterviewAI`
5. Configure:
   - **Branch**: main
   - **Build type**: Dockerfile
   - **Source location**: `/interviewai_backend/Dockerfile`
6. Set environment variables in the UI
7. Click **"Create"**

---

## Cost Estimate

**Free Tier (Monthly):**

- 2 million requests
- 360,000 GB-seconds of memory
- 180,000 vCPU-seconds

**After Free Tier:**

- $0.00002400 per request
- $0.00000250 per GB-second
- $0.00001000 per vCPU-second

**Typical Usage:** Usually stays in free tier for small apps!

---

## Troubleshooting

### Build Fails

```bash
# Check logs
gcloud run services logs read interviewai-backend --limit 50
```

### Update Service

```bash
# Redeploy after changes
gcloud run deploy interviewai-backend --source .
```

### View Service Details

```bash
gcloud run services describe interviewai-backend --region us-central1
```

---

## Benefits of Cloud Run vs Render

✅ **More generous free tier**
✅ **Auto-scales to zero (no cold starts like Render free)**
✅ **Better performance**
✅ **Built-in SSL certificates**
✅ **Automatic CI/CD with GitHub**
✅ **99.95% SLA**

---

## Next Steps

After backend is deployed:

1. Copy your Cloud Run URL
2. Update `interviewai_frontend/lib/constants/api_constants.dart`
3. Deploy frontend to Netlify/Vercel
4. Test everything!
