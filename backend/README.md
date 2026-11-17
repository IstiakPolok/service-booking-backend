# Service Booking & Management Backend API

Production-grade RESTful API backend engineered with **Node.js, Express.js, TypeScript, MongoDB (Mongoose), JWT Authentication, Zod Validation, and Google Gemini AI**. Built to power the cross-platform Flutter Service Booking & Management Mobile Application.

---

## 🌟 Key Highlights & Engineering Features

- **Professional Layered Architecture**: Strict Separation of Concerns (Routes → Controllers → Services → Models → Middlewares → Validators).
- **Zero-Setup Database Out-of-the-Box**:
  - Automatically connects to `MONGODB_URI` (local or MongoDB Atlas).
  - **Embedded Fallback**: If no MongoDB server is running on the machine, the backend automatically spins up an in-memory MongoDB instance and auto-populates demo services, users, and appointments—allowing developers and evaluators to run the project immediately with zero configuration!
- **Strict Booking Conflict Prevention**:
  - Validates time slot availability.
  - Compound indexes prevent double booking of the same slot for a service.
  - Prevents a user from booking overlapping appointments.
- **Dynamic AI Service Assistant**:
  - Grounded directly in live database service catalog (names, prices, durations, descriptions).
  - Powered by **Google Gemini API** (`@google/generative-ai`).
  - Includes an intelligent rule-based knowledge engine fallback that works seamlessly even before setting an API key.
- **Enterprise-Grade Validation & Security**:
  - Type-safe schema validation using **Zod**.
  - Rate limiting on authentication routes to mitigate brute-force attacks.
  - Security HTTP headers using **Helmet**.
  - Passwords hashed using **Bcrypt** with salt rounds = 10.
  - Safe JWT authentication tokens.
- **Interactive Documentation**:
  - **Swagger UI** live at `http://localhost:5000/api/docs`.
  - Exported **Postman Collection** ready to import from `./postman/Service_Booking_API.postman_collection.json`.

---

## 🛠 Tech Stack

| Component | Technology |
|---|---|
| Runtime | Node.js (v18+) |
| Language | TypeScript 5.7+ |
| Web Framework | Express.js 4.21+ |
| Database / ODM | MongoDB + Mongoose 8+ (with `mongodb-memory-server` dev fallback) |
| Validation | Zod |
| Authentication | JSON Web Token (`jsonwebtoken`) + Bcrypt.js |
| AI Integration | Google Gemini API (`@google/generative-ai`) |
| API Docs | Swagger UI Express + OpenAPI 3.0 |
| Security | Helmet, CORS, Express-Rate-Limit |

---

## 📁 Project Directory Structure

```
backend/
├── docs/
│   ├── DATABASE_SCHEMA.md      # Detailed ER diagram & collection schemas
│   └── API_DOCUMENTATION.md    # Endpoint reference with request/response payloads
├── postman/
│   └── Service_Booking_API.postman_collection.json  # Importable Postman collection
├── src/
│   ├── config/
│   │   ├── database.ts         # MongoDB connection with zero-setup memory fallback
│   │   └── env.ts              # Type-safe environment variable loader
│   ├── constants/
│   │   └── index.ts            # Statuses, Roles, Categories, Time Slots
│   ├── controllers/
│   │   ├── ai.controller.ts
│   │   ├── appointment.controller.ts
│   │   ├── auth.controller.ts
│   │   ├── service.controller.ts
│   │   └── user.controller.ts
│   ├── middlewares/
│   │   ├── auth.middleware.ts        # JWT verification & role guard
│   │   ├── error.middleware.ts       # Global error & 404 handler
│   │   ├── rateLimiter.ts            # Auth brute-force protection
│   │   └── validation.middleware.ts  # Zod schema validation
│   ├── models/
│   │   ├── appointment.model.ts      # Compound indexes for conflict prevention
│   │   ├── service.model.ts          # Search text index, categories, pricing
│   │   └── user.model.ts             # Bcrypt hashing & password exclusion
│   ├── routes/
│   │   ├── ai.routes.ts
│   │   ├── appointment.routes.ts
│   │   ├── auth.routes.ts
│   │   ├── index.ts                  # Health check & router aggregation
│   │   ├── service.routes.ts
│   │   └── user.routes.ts
│   ├── scripts/
│   │   └── seed.ts                   # Realistic database seeder
│   ├── services/
│   │   ├── ai.service.ts             # Gemini integration + grounded fallback
│   │   ├── appointment.service.ts    # Conflict validation & slot availability
│   │   ├── auth.service.ts           # Login, registration, JWT issuance
│   │   └── service.service.ts        # Filtering, text search, pagination
│   ├── swagger/
│   │   └── swagger.json              # OpenAPI 3.0 specification
│   ├── utils/
│   │   ├── apiError.ts               # Custom operational errors
│   │   ├── apiResponse.ts            # Standardized JSON response format
│   │   ├── asyncHandler.ts          # Promise exception wrapper
│   │   └── logger.ts                 # Clean formatted console logger
│   ├── app.ts                        # Express application configuration
│   └── server.ts                     # HTTP listener & graceful shutdown
├── .env                              # Environment configuration
├── .env.example                      # Template environment variables
├── package.json
└── tsconfig.json
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js** v18 or higher (`node -v`)
- **npm** v9 or higher

### 2. Installation
Open your terminal in the `backend` folder and run:
```bash
npm install
```

### 3. Environment Setup
A `.env` file is already created for you. You can inspect or tweak settings in `.env`:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/service_booking
JWT_SECRET=super_secret_jwt_key_service_booking_app_2026_dev_secure
JWT_EXPIRES_IN=7d
GEMINI_API_KEY=
CORS_ORIGIN=*
```

> [!NOTE]
> If you don't have MongoDB installed locally, **no worries!** The server will automatically start an in-memory database and seed it with demo services and users.

### 4. Running the Server

#### Development Mode (with hot-reload):
```bash
npm run dev
```

#### Production Build & Start:
```bash
npm run build
npm start
```

#### Re-seeding Data manually:
```bash
npm run seed
```

---

## 📱 Connecting from Flutter

When developing the Flutter mobile application, use the appropriate base URL based on your target device:

| Target Device | Base URL |
|---|---|
| **Android Emulator** | `http://10.0.2.2:5000/api` |
| **iOS Simulator** | `http://localhost:5000/api` |
| **Physical Phone (via Wi-Fi)** | `http://<YOUR_COMPUTER_LAN_IP>:5000/api` (e.g. `http://192.168.1.15:5000/api`) |
| **Flutter Web** | `http://localhost:5000/api` |

### Sample Flutter API Service Setup (Dart):
```dart
class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator/web
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
```

---

## 🔑 Pre-Seeded Test Credentials

| Role | Email | Password |
|---|---|---|
| **Standard User** | `john.doe@example.com` | `Password123!` |
| **Admin User** | `admin@example.com` | `Password123!` |

---

## 🤖 AI Assistant Configuration

The AI Service Assistant feature fulfills **Section 4 of the Technical Assessment**.

1. **Grounded in Database**: The AI assistant dynamically reads active services from the database. It answers questions regarding pricing, duration, recommendations, and preparation based on actual catalog data.
2. **Google Gemini Integration**:
   - To use Gemini, get a free API key at [Google AI Studio](https://aistudio.google.com/).
   - Add it to `.env`:
     ```env
     GEMINI_API_KEY=AIzaSy...
     ```
3. **Smart Rule-Based Fallback**:
   - If `GEMINI_API_KEY` is not provided, the API automatically activates the built-in intelligent recommendation engine so that the Flutter app can be tested end-to-end without any external API dependencies!

---

## 📑 API Endpoints Summary

| Method | Endpoint | Description | Access |
|---|---|---|---|
| `GET` | `/api/health` | Health check & system status | Public |
| `POST` | `/api/auth/register` | Register new user account | Public |
| `POST` | `/api/auth/login` | Authenticate user & get JWT | Public |
| `GET` | `/api/auth/me` | Get current user profile | Protected |
| `PUT` | `/api/auth/change-password` | Change user password | Protected |
| `GET` | `/api/users/profile` | Retrieve user profile | Protected |
| `PUT` | `/api/users/profile` | Update profile information | Protected |
| `GET` | `/api/services` | Search, filter & list services | Public |
| `GET` | `/api/services/featured` | Get featured services (Home screen) | Public |
| `GET` | `/api/services/categories` | Get category list with counts | Public |
| `GET` | `/api/services/:id` | Get single service details | Public |
| `GET` | `/api/appointments/available-slots` | Check available slots for a date | Public/Protected |
| `POST` | `/api/appointments` | Book appointment (Conflict prevented) | Protected |
| `GET` | `/api/appointments` | Get user appointments (Upcoming/Past) | Protected |
| `GET` | `/api/appointments/:id` | Get appointment details | Protected |
| `PATCH`| `/api/appointments/:id/cancel` | Cancel an appointment | Protected |
| `POST` | `/api/ai/chat` | Chat with AI Service Assistant | Public/Protected |
| `POST` | `/api/ai/recommend` | Get AI curated recommendations | Public/Protected |

For full request/response schemas, view [API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md) or open `http://localhost:5000/api/docs`.
