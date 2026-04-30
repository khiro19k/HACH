# 🌟 Rafiq AI - رفيق الذكي 🇩🇿

**Rafiq AI** is an advanced, production-grade Flutter application designed to revolutionize diabetes management in Algeria. By blending cutting-edge AI (Google Gemini) with real-time health monitoring, Rafiq serves as a constant, intelligent companion for patients, their families, and their doctors.

---

## 🎯 The Vision / الرؤية
"Rafiq" is more than just a tracker; it's a **Healthcare Ecosystem**. It bridges the gap between patients, caregivers, and medical professionals.
- **Patient**: Real-time AI advice, food analysis, and emergency triggers.
- **Doctor**: Clinical dashboard for data-driven triage and patient management.
- **Family**: Peace of mind through real-time status updates and SOS alerts.

---

## 🚀 Key Features / المميزات الأساسية

### 🤖 AI Health Assistant (Assistant Médical Intelligent)
- Specialized in the Algerian dialect (Darja/Franco).
- Understands local medical terms and cultural nuances.
- Provides dietary advice and symptom analysis using Gemini Pro.

### 📸 AI Food Scanner (Analyse des Repas)
- Powered by Gemini Vision API.
- Instant identification of Algerian dishes.
- Estimated carb count and glucose impact analysis.

### 🚨 SOS & Safety Shield
- Persistent SOS banner on the home screen during emergencies.
- Real-time notification to family and doctors via Supabase.
- Location tracking for rapid assistance.

### 💊 Medication & Glucose Management
- Real-time sync with Supabase backend.
- Automated reminders for medications.
- Interactive health summary and "Time in Range" (TIR) metrics.

---

## 🛠️ Technology Stack / التقنيات المستخدمة
- **Framework**: Flutter (Multi-platform)
- **Backend**: Supabase (Auth, Real-time Database, Storage)
- **AI Engine**: Google Gemini (Pro & Vision)
- **State Management**: Riverpod (Reactive state)
- **Navigation**: GoRouter (Shell routes for persistent UI)
- **Design**: Premium Glassmorphism & Modern UI/UX

---

## 📦 Project Structure
```text
lib/
├── core/           # Routing, Theme, Constants
├── data/           # Repositories & External Services (Supabase, Gemini)
├── domain/         # Business Logic Entities & Models
└── presentation/   # UI Screens, Widgets, & State Providers
```

---

## 🚀 How to Run / كيفية التشغيل
1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **API Setup**:
   - Update `lib/core/constants/constants.dart` with your **Gemini API Key**.
   - Update `lib/core/network/supabase_config.dart` with your **Supabase URL and Anon Key**.
4. **Run**:
   ```bash
   flutter run
   ```

---

## 🔒 Security Note
> [!WARNING]
> Please ensure you do not commit your production API keys to public repositories. Use `.env` files or secure secret management for production builds.

---

*Built with ❤️ for the health of our community.*
*تطوير "رفيق" من أجل صحة مجتمعنا.*
