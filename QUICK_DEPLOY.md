# Quick Deployment Steps for InterviewAI

## 🚀 Deploy to Render (Fastest & Free)

### Step 1: Setup Supabase Database (5 minutes)

1. Go to https://supabase.com and create account
2. Create new project
3. Go to **Settings → Database** and copy:
   - Host: `db.xxxxxxxxxxxxx.supabase.co`
   - Database password
4. Go to **Settings → API** and copy:
   - Project URL
   - `anon` public key
   - `service_role` secret key
   - JWT Secret

### Step 2: Setup Gemini AI API (3 minutes)

1. Go to https://aistudio.google.com/app/apikey
2. Create new API key
3. Copy the key

### Step 3: Deploy Backend to Render (10 minutes)

**IMPORTANT**: Render will auto-detect the Java project from `render.yaml` file.

1. Go to **https://render.com** and sign in with GitHub
2. Click **"New +" → "Blueprint"** (NOT Web Service)
3. Connect repository: `ShantanuDas15/InterviewAI`
4. Render will automatically detect `render.yaml`
5. Click **"Apply"**

**Alternative Method (Manual Setup):**

If Blueprint doesn't work, use this method:

1. Click **"New +" → "Web Service"**
2. Connect repository: `ShantanuDas15/InterviewAI`
3. Configure:
   - **Name**: `interviewai-backend`
   - **Environment**: Select **"Docker"** (not Java - we'll configure it)
   - **Root Directory**: `interviewai_backend`
   - **Branch**: `main`
   - **Build Command**: `./mvnw clean package -DskipTests`
   - **Start Command**: `java -Dserver.port=$PORT -jar target/interviewai_backend-0.0.1-SNAPSHOT.jar`
   - **Instance Type**: Free

4. **Add Environment Variables** (click "Advanced" → "Add Environment Variable"):
   ```
   JAVA_VERSION = 21
   DB_URL = jdbc:postgresql://[YOUR-SUPABASE-HOST]:5432/postgres?sslmode=require
   DB_USERNAME = postgres
   DB_PASSWORD = [YOUR-SUPABASE-PASSWORD]
   SUPABASE_URL = [YOUR-SUPABASE-PROJECT-URL]
   SUPABASE_JWT_SECRET = [FROM-SUPABASE]
   SUPABASE_SERVICE_ROLE_KEY = [FROM-SUPABASE]
   GEMINI_API_KEY = [YOUR-GEMINI-KEY]
   GEMINI_API_URL = https://generativelanguage.googleapis.com/v1beta/models
   ```

5. Click **"Create Web Service"**

**Note**: First build may take 5-10 minutes. Render will automatically install Java 21.
7. Copy your backend URL: `https://interviewai-backend.onrender.com`

### Step 4: Update Frontend Configuration (2 minutes)

1. Open `interviewai_frontend/lib/constants/api_constants.dart`
2. Update these values:
   ```dart
   static const String baseUrl = 'https://interviewai-backend.onrender.com';
   static const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
   static const String supabaseAnonKey = '[your-anon-key-from-supabase]';
   ```
3. Save and commit:
   ```bash
   git add .
   git commit -m "chore: Update API URLs for production"
   git push
   ```

### Step 5: Deploy Frontend to Render (8 minutes)

**Option A: Render (Recommended)**

1. Click **New +** → **Static Site**
2. Connect same repository
3. Configure:
   ```
   Name: interviewai-frontend
   Branch: main
   Build Command: cd interviewai_frontend && flutter build web --release --web-renderer html
   Publish Directory: interviewai_frontend/build/web
   ```
4. Click **Create Static Site**

**Option B: Netlify (Alternative - Better for Flutter)**

1. Go to https://app.netlify.com
2. Drag and drop `interviewai_frontend/build/web` folder
3. Or connect GitHub and auto-deploy

**Option C: Vercel (Alternative)**

1. Go to https://vercel.com
2. Import repository
3. Set:
   - Framework: Other
   - Build Command: `cd interviewai_frontend && flutter build web --release`
   - Output Directory: `interviewai_frontend/build/web`

### Step 6: Test Your Deployment (5 minutes)

1. Visit your frontend URL
2. Create account
3. Try these features:
   - ✅ Resume Builder
   - ✅ Mock Interview
   - ✅ Resume Analysis
4. Check backend logs in Render dashboard

---

## 🎉 You're Live!

**Your URLs:**

- Frontend: `https://interviewai-frontend.onrender.com` (or Netlify/Vercel URL)
- Backend: `https://interviewai-backend.onrender.com`

---

## ⚠️ Important Notes

### Free Tier Limitations

- **Render Free**: Services sleep after 15 min inactivity
  - First request after sleep takes 30-60 seconds
  - Upgrade to Starter ($7/mo) for always-on
- **Supabase Free**: 500MB storage, 2GB bandwidth/month
- **Gemini Free**: 60 requests/minute

### Performance Tips

1. **Backend Cold Starts**: Consider pinging your backend every 10 minutes to keep it awake
2. **Database Pooling**: Already configured in your Spring Boot app
3. **Frontend CDN**: Netlify/Vercel have better CDN than Render for static sites

---

## 🔧 Troubleshooting

### Backend Not Starting

```bash
# Check logs in Render dashboard
# Common issues:
# 1. Wrong Java version - Ensure Java 21
# 2. Environment variables missing
# 3. Database connection failed
```

### Frontend Can't Connect

1. Verify `api_constants.dart` has correct backend URL
2. Check CORS settings (already configured in backend)
3. Rebuild: `flutter build web --release`

### Database Errors

```bash
# Test connection from local:
psql "postgresql://postgres:[PASSWORD]@db.[REF].supabase.co:5432/postgres"

# Check Supabase project status
```

---

## 🚀 Next Steps (Optional)

1. **Custom Domain**:

   - Add your domain in Render/Netlify settings
   - Update DNS records

2. **Monitoring**:

   - Set up UptimeRobot (free monitoring)
   - Enable Render email alerts

3. **CI/CD**:

   - Already enabled with GitHub integration
   - Every push to `main` auto-deploys

4. **Analytics**:
   - Add Google Analytics to Flutter app
   - Monitor API usage in Supabase dashboard

---

## 💰 Cost Breakdown

**Current Setup (Free)**: $0/month

- Render Free: Web Service (sleeps)
- Netlify/Vercel Free: Static hosting
- Supabase Free: Database
- Gemini Free: AI API

**Recommended Production**: ~$50/month

- Render Starter: $7/month (always-on backend)
- Netlify Pro: $19/month (better CDN, analytics)
- Supabase Pro: $25/month (better performance)

---

## 📞 Need Help?

1. Check DEPLOYMENT.md for detailed docs
2. Review Render logs for errors
3. Test API endpoints: `https://your-backend.onrender.com/actuator/health`

---

**Total Time**: ~30 minutes
**Skill Level**: Beginner-friendly
**Cost**: $0 (Free tier)
