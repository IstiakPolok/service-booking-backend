# Service Booking & Management App (Flutter Frontend)

A cross-platform mobile application built with **Flutter 3**, **Dart**, and **Provider** for state management, featuring a Clean Layered Architecture, robust REST API integration, conflict-proof appointment booking, and an in-app **AI Service Concierge**.

---

## 📱 Features Overview

### 1. Authentication (`/views/auth`)
- **User Registration**: Register with Full Name, Email, Password, and optional Phone number.
- **Secure Login & Logout**: JWT-based session with secure token persistence via `SharedPreferences`.
- **Form Validation**: Strict client-side validation for email patterns, required fields, and password lengths.
- **Quick Demo Fill**: One-tap demo account fill button (`john.doe@example.com` / `Password123!`) for instant evaluator testing.
- **Auto-Login / Session Restore**: Splash screen checks stored token and restores user session automatically.

### 2. Home Screen (`/views/home`)
- **Live Search**: Instant keyword search matching service name, description, and category.
- **Category Filter Chips**: Dynamic categories filter (`All`, `Hair & Styling`, `Spa & Massage`, `Dental Care`, `Fitness`, etc.).
- **Featured Services Carousel**: Horizontal scrollable carousel highlighting top-rated and featured services.
- **Service Cards**: Displays service photo, title, duration badge, rating chip, category tag, and pricing.
- **Pull-to-Refresh**: Seamless data refresh with loading indicators.

### 3. Service Details (`/views/service_details`)
- **Full-Width Hero Image**: High-definition imagery with graceful error and loading fallbacks.
- **Service Specs**: Pricing, estimated duration, rating, and total review count.
- **What's Included Checklist**: Clear breakdown of service consultation, vetted professionals, and sanitary supplies.
- **Floating Booking Bar**: Sticky bottom CTA button navigating directly to appointment booking.

### 4. Appointment Booking (`/views/booking`)
- **Interactive Date Picker**: Calendar picker restricted to present and future dates (prevents booking past dates).
- **Dynamic Slot Availability**: Calls the backend API (`/api/appointments/available-slots`) to check real-time availability.
- **Unavailable Slot Prevention**: Booked or passed time slots are visually crossed out, disabled, and cannot be tapped.
- **Special Requests / Notes**: Optional customer instructions field.
- **Conflict Prevention**: Catches HTTP `409 Conflict` if another customer booked the slot simultaneously, re-synchronizing slot availability.
- **Booking Confirmation Modal**: Elegant confirmation dialog showing booked service, date, time slot, and total fee.

### 5. My Bookings (`/views/my_bookings`)
- **Tabbed Interface**: Organized into **Upcoming** and **Previous / Past** bookings.
- **Status Badges**: Color-coded badges for `Pending` (amber), `Confirmed` (emerald), `Cancelled` (coral), and `Completed` (blue).
- **Booking Details Modal**: Bottom sheet showing full appointment information, duration, and customer notes.
- **Cancellation Flow**: Cancel pending or confirmed appointments with a confirmation dialog.

### 6. AI Service Assistant (`/views/ai_assistant`)
- **AI Chat Concierge**: Conversational assistant grounded in the live service catalog.
- **Quick Prompts**: One-tap query chips (e.g., *"What services are under \$60?"*, *"Recommend a relaxing massage"*).
- **Interactive In-Chat Service Cards**: When the AI recommends services, it embeds interactive service cards with a direct **Book** button inside the chat!

### 7. User Profile (`/views/profile`)
- **Profile Display**: Avatar, Full Name, Email, Phone, and Account Role.
- **Edit Profile**: Update Name, Phone, and Avatar URL.
- **Change Password**: In-app secure password update with confirmation check.
- **Runtime API Base URL Config**: In-app server setting dialog allowing you to change the backend IP (e.g., when testing on a physical phone via Wi-Fi) without recompiling!
- **Logout**: Clears persisted JWT session and returns to login.

---

## 🏛 Architecture & Folder Structure

The application follows **Clean Layered Architecture** with strict Separation of Concerns:

```
frontend/lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart    # Configurable base URL with platform auto-detection
│   │   ├── app_colors.dart       # Modern Material 3 palette
│   │   └── app_theme.dart        # Typography, elevated button, card & input decoration theme
│   ├── network/
│   │   ├── api_client.dart       # HTTP wrapper with timeout, token injection, and response parsing
│   │   └── api_exception.dart    # Typed exceptions (ConflictException, UnauthorizedException, etc.)
│   ├── storage/
│   │   └── token_storage.dart    # Persistent token & user profile storage (SharedPreferences)
│   └── utils/
│       ├── formatters.dart       # Currency, date, and duration formatting
│       └── validators.dart       # Form validation logic
├── models/
│   ├── ai_message_model.dart     # AI message & recommendations DTO
│   ├── appointment_model.dart    # Appointment DTO with populated service/user
│   ├── service_model.dart        # Service catalog DTO
│   ├── time_slot_model.dart      # Time slot availability DTO
│   └── user_model.dart           # User profile DTO
├── providers/
│   ├── ai_chat_provider.dart     # AI conversation state & message history
│   ├── appointment_provider.dart # Booking actions, upcoming/previous state, slot check
│   ├── auth_provider.dart        # Session state, login, register, profile update, logout
│   └── service_provider.dart     # Service catalog, category filters, live search
├── services/
│   ├── ai_service.dart           # AI Chat and Recommend API calls
│   ├── appointment_service.dart  # Booking and cancellation API calls
│   ├── auth_service.dart         # Authentication API calls
│   └── service_service.dart      # Service catalog API calls
├── views/
│   ├── ai_assistant/             # AI Concierge Chat screen
│   ├── auth/                     # Login and Register screens
│   ├── booking/                  # Appointment booking screen & time slot grid
│   ├── home/                     # Home screen, featured carousel, category chips, service card
│   ├── my_bookings/              # Upcoming and previous bookings with cancellation
│   ├── profile/                  # Profile view, edit profile, change password, API URL settings
│   ├── service_details/          # Detailed service view with Hero image and booking CTA
│   ├── splash/                   # App boot & session verification
│   └── main_navigation_view.dart # Bottom navigation bar connecting all core tabs
├── widgets/                      # Reusable components (buttons, text fields, badges, error/empty states)
└── main.dart                     # Entry point & MultiProvider registration
```

---

## 🚀 How to Run the Flutter App

### 1. Prerequisites
- **Flutter SDK**: v3.19+ (Dart 3+)
- Backend server running (from `backend` folder via `npm run dev`)

### 2. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 3. Verify Code Quality
```bash
flutter analyze
```
*(Zero issues found!)*

### 4. Run the App

#### On Android Emulator:
```bash
flutter run -d emulator
```
*(The app automatically points to `http://10.0.2.2:5000/api` on Android emulators).*

#### On Chrome / Web:
```bash
flutter run -d chrome
```

#### On Physical Phone (via Wi-Fi):
1. Find your computer's local IP address (e.g., `192.168.1.15`).
2. Run `flutter run`.
3. Open the **Profile tab → Backend API Endpoint** and enter `http://192.168.1.15:5000/api`.

---

## 🔑 Demo Login Credentials

For quick evaluation, tap the **"Fill Demo Account"** button on the Login screen, or enter:

- **Email**: `john.doe@example.com`
- **Password**: `Password123!`
