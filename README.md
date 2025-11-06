# InterviewAI

An AI-powered interview preparation platform built with Flutter and Spring Boot.

## 🔒 Security First

**IMPORTANT**: This project uses environment variables to secure sensitive credentials. Before running the application, you must set up your environment configuration.

👉 **Read the [SECURITY.md](SECURITY.md) guide** for complete setup instructions.

## 🚀 Quick Start

### Prerequisites

- Java 21+
- Flutter SDK 3.8.1+
- PostgreSQL (via Supabase)
- Google Gemini API access
- VAPI account

### Setup

#### 1. Clone the repository

```bash
git clone https://github.com/yourusername/InterviewAI.git
cd InterviewAI
```

#### 2. Backend Setup

```bash
cd interviewai_backend
copy .env.example .env
# Edit .env with your credentials (see SECURITY.md)
./mvnw spring-boot:run
```

#### 3. Frontend Setup

```bash
cd interviewai_frontend
copy .env.example .env
# Edit .env with your credentials (see SECURITY.md)
flutter pub get
flutter run -d chrome
```

## 📁 Project Structure

```
InterviewAI/
├── interviewai_backend/      # Spring Boot backend
│   ├── .env.example          # Environment template
│   └── src/
├── interviewai_frontend/     # Flutter frontend
│   ├── .env.example          # Environment template
│   └── lib/
├── SECURITY.md               # Security setup guide
└── README.md
```

## 🛡️ Security Notes

- ⚠️ Never commit `.env` files
- ✅ Always use `.env.example` as a template
- 🔑 Rotate credentials regularly
- 📚 Read [SECURITY.md](SECURITY.md) for detailed instructions

## 📋 Features

- 🎤 Voice-based mock interviews with VAPI
- 📝 Resume parsing and analysis
- 🤖 AI-powered interview question generation
- 📊 Performance feedback and analytics
- 🔐 Secure authentication with Supabase

## 🔧 Tech Stack

### Backend

- Spring Boot 3.5.7
- PostgreSQL (Supabase)
- Spring Security with JWT
- Google Gemini API

### Frontend

- Flutter 3.8.1+
- Riverpod for state management
- GoRouter for navigation
- Supabase Auth
- VAPI for voice calls

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Never commit credentials
4. Follow the security guidelines
5. Submit a pull request

## 📄 License

[Your License Here]

## 📞 Support

For security-related questions, see [SECURITY.md](SECURITY.md).

---

**Note**: This is a secure repository. All sensitive credentials are managed through environment variables. See `SECURITY.md` for setup instructions.
