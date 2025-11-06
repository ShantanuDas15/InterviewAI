# InterviewAI Deployment Guide

## 🎯 Pre-Deployment Checklist

### ✅ Security Verification

- [x] Sensitive files excluded via `.gitignore`
- [x] No API keys or passwords in repository
- [x] Environment variables configured for production
- [x] All changes committed and pushed to GitHub

### 📋 Required Services

1. **Backend (Spring Boot)**: PostgreSQL database + Java Runtime
2. **Frontend (Flutter Web)**: Static hosting service
3. **Database**: PostgreSQL (Supabase or self-hosted)
4. **External APIs**:
   - Google Gemini AI (for resume generation)
   - Supabase (for authentication & storage)

---

## 🚀 Deployment Options

### Option 1: Render (Recommended - Free Tier Available)

#### Backend Deployment on Render

1. **Create Render Account**

   - Go to https://render.com
   - Sign up with GitHub

2. **Deploy Backend Service**

   - Click "New +" → "Web Service"
   - Connect your GitHub repository: `ShantanuDas15/InterviewAI`
   - Configure:
     ```
     Name: interviewai-backend
     Region: Choose closest to your users
     Branch: main
     Root Directory: interviewai_backend
     Runtime: Java
     Build Command: ./mvnw clean package -DskipTests
     Start Command: java -jar target/interviewai_backend-0.0.1-SNAPSHOT.jar
     Instance Type: Free (or upgrade as needed)
     ```

3. **Set Environment Variables** (in Render dashboard):

   ```bash
   DB_URL=jdbc:postgresql://your-supabase-host:5432/postgres
   DB_USERNAME=postgres
   DB_PASSWORD=your_supabase_password
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_JWT_SECRET=your_jwt_secret_from_supabase
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   GEMINI_API_KEY=your_gemini_api_key
   GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models
   PORT=8080
   ```

4. **Deploy** - Click "Create Web Service"

#### Frontend Deployment on Render (or Netlify/Vercel)

1. **Build Flutter Web**

   ```bash
   cd interviewai_frontend
   flutter build web --release
   ```

2. **Deploy to Render**

   - Click "New +" → "Static Site"
   - Connect repository
   - Configure:
     ```
     Name: interviewai-frontend
     Branch: main
     Build Command: cd interviewai_frontend && flutter build web --release
     Publish Directory: interviewai_frontend/build/web
     ```

3. **Update API Constants**
   - Edit `interviewai_frontend/lib/constants/api_constants.dart`
   - Change `baseUrl` to your Render backend URL:
     ```dart
     static const String baseUrl = 'https://interviewai-backend.onrender.com';
     ```
   - Commit and push changes

---

### Option 2: Railway (Alternative - Free Tier)

#### Backend on Railway

1. **Create Railway Account**: https://railway.app
2. **New Project** → "Deploy from GitHub"
3. **Select Repository**: `ShantanuDas15/InterviewAI`
4. **Configure**:
   - Root Directory: `interviewai_backend`
   - Start Command: `./mvnw spring-boot:run`
5. **Add Environment Variables** (same as Render above)

---

### Option 3: Self-Hosted (VPS/Cloud)

#### Requirements

- Ubuntu 20.04+ or similar
- Java 21+
- PostgreSQL 12+
- Nginx (for frontend)

#### Backend Setup

```bash
# Install Java
sudo apt update
sudo apt install openjdk-21-jdk

# Clone repository
git clone https://github.com/ShantanuDas15/InterviewAI.git
cd InterviewAI/interviewai_backend

# Set environment variables
export DB_URL="jdbc:postgresql://localhost:5432/interviewai"
export DB_USERNAME="postgres"
export DB_PASSWORD="your_password"
# ... (set all other env vars)

# Build and run
./mvnw clean package -DskipTests
java -jar target/interviewai_backend-0.0.1-SNAPSHOT.jar
```

#### Frontend Setup

```bash
cd ../interviewai_frontend

# Build
flutter build web --release

# Serve with Nginx
sudo cp -r build/web/* /var/www/html/
```

---

## 🔧 Database Setup (Supabase - Recommended)

1. **Create Supabase Project**

   - Go to https://supabase.com
   - Create new project

2. **Get Database Credentials**

   - Go to Settings → Database
   - Copy connection string
   - Format: `postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-REF].supabase.co:5432/postgres`

3. **Get Authentication Keys**

   - Go to Settings → API
   - Copy:
     - `anon` key (for frontend)
     - `service_role` key (for backend)
     - JWT Secret

4. **Run Migrations** (if needed)
   - Your Spring Boot app will auto-create tables with `spring.jpa.hibernate.ddl-auto=update`

---

## 🔑 Environment Variables Reference

### Backend Required Variables

```bash
# Database (Supabase or PostgreSQL)
DB_URL=jdbc:postgresql://db.project.supabase.co:5432/postgres
DB_USERNAME=postgres
DB_PASSWORD=your_supabase_db_password

# Supabase Authentication
SUPABASE_URL=https://project.supabase.co
SUPABASE_JWT_SECRET=your-jwt-secret-from-supabase-api-settings
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Google Gemini AI
GEMINI_API_KEY=your-gemini-api-key-from-google-ai-studio
GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models

# Optional - Server Port
PORT=8080
```

### Frontend Configuration

Update `interviewai_frontend/lib/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-backend-url.onrender.com';
  static const String supabaseUrl = 'https://project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

---

## 🧪 Testing Deployment

### Backend Health Check

```bash
curl https://your-backend-url.onrender.com/actuator/health
```

### Frontend Verification

- Visit your frontend URL
- Try to:
  1. Register/Login
  2. Create a resume
  3. View generated resume
  4. Take a mock interview

---

## 📊 Monitoring & Logs

### Render

- View logs in Render dashboard
- Set up alerts for downtime

### Railway

- Built-in logging dashboard
- Metrics included

### Self-Hosted

```bash
# View backend logs
tail -f /var/log/interviewai/backend.log

# View Nginx logs
tail -f /var/log/nginx/access.log
```

---

## 🐛 Troubleshooting

### Backend Won't Start

1. Check environment variables are set correctly
2. Verify database connection:
   ```bash
   psql "postgresql://postgres:password@host:5432/postgres"
   ```
3. Check Java version: `java --version` (must be 21+)

### Frontend Can't Connect to Backend

1. Update `api_constants.dart` with correct backend URL
2. Rebuild: `flutter build web --release`
3. Check CORS settings in backend

### Database Connection Issues

1. Verify Supabase project is active
2. Check connection pooling mode (use Transaction mode)
3. Ensure password is correct

---

## 🔄 Continuous Deployment

### Setup Auto-Deploy on Push

Both Render and Railway support automatic deployment:

1. Connect GitHub repository
2. Enable auto-deploy on main branch
3. Every push to `main` triggers deployment

---

## 💰 Cost Estimation

### Free Tier Setup

- **Backend**: Render Free (sleeps after 15 min inactivity)
- **Frontend**: Netlify/Vercel Free (unlimited bandwidth)
- **Database**: Supabase Free (500MB storage, 2GB bandwidth)
- **Gemini API**: Free tier (60 requests/min)

**Total Monthly Cost**: $0

### Production Setup

- **Backend**: Render Starter ($7/month)
- **Frontend**: Netlify Pro ($19/month) or Vercel Pro ($20/month)
- **Database**: Supabase Pro ($25/month)
- **Gemini API**: Pay-as-you-go (varies)

**Estimated Monthly Cost**: $50-100

---

## 📞 Support

For deployment issues:

1. Check GitHub Issues
2. Review Render/Railway documentation
3. Contact: [your-email@example.com]

---

## ✅ Post-Deployment Checklist

- [ ] Backend accessible via HTTPS
- [ ] Frontend loads correctly
- [ ] User registration works
- [ ] Resume builder generates resumes
- [ ] Mock interview functionality works
- [ ] Database persistence verified
- [ ] Set up monitoring/alerts
- [ ] Document custom domain setup (if applicable)
- [ ] Configure backups (database)
- [ ] Set up CI/CD pipeline

---

**Last Updated**: November 6, 2025
**Version**: 1.0.0
