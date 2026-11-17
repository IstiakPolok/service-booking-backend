# API Documentation - Service Booking & Management

Base URL:
- Local Web: `http://localhost:5000/api`
- Android Emulator: `http://10.0.2.2:5000/api`
- Interactive Swagger UI: `http://localhost:5000/api/docs`

---

## 1. Authentication Endpoints (`/api/auth`)

### 1.1 User Registration
- **Endpoint**: `POST /auth/register`
- **Access**: Public
- **Request Body**:
```json
{
  "name": "Sarah Connor",
  "email": "sarah@example.com",
  "password": "Password123!",
  "phone": "+1 555-0123"
}
```
- **Response `201 Created`**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "name": "Sarah Connor",
      "email": "sarah@example.com",
      "phone": "+1 555-0123",
      "avatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80",
      "role": "user",
      "id": "6afcb88bbcdd4ec4c20a7d73"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 1.2 User Login
- **Endpoint**: `POST /auth/login`
- **Access**: Public
- **Request Body**:
```json
{
  "email": "john.doe@example.com",
  "password": "Password123!"
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phone": "+1 555-0199",
      "avatar": "https://images.unsplash.com/...",
      "role": "user",
      "id": "6afcb88bbcdd4ec4c20a7d73"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 1.3 Get Current Authenticated User
- **Endpoint**: `GET /auth/me`
- **Access**: Protected (`Authorization: Bearer <token>`)
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Authenticated user profile retrieved",
  "data": {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1 555-0199",
    "role": "user",
    "id": "6afcb88bbcdd4ec4c20a7d73"
  }
}
```

---

### 1.4 Change Password
- **Endpoint**: `PUT /auth/change-password`
- **Access**: Protected
- **Request Body**:
```json
{
  "currentPassword": "Password123!",
  "newPassword": "NewSecretPassword456!"
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## 2. User Management Endpoints (`/api/users`)

### 2.1 Get Profile
- **Endpoint**: `GET /users/profile`
- **Access**: Protected

### 2.2 Update Profile
- **Endpoint**: `PUT /users/profile`
- **Access**: Protected
- **Request Body**:
```json
{
  "name": "John Updated Doe",
  "phone": "+1 555-9988",
  "avatar": "https://images.unsplash.com/photo-..."
}
```

---

## 3. Service Management Endpoints (`/api/services`)

### 3.1 Get All Services (Search, Filter, Pagination)
- **Endpoint**: `GET /services`
- **Access**: Public
- **Query Parameters**:
  - `search` (e.g. `massage` or `facial`)
  - `category` (e.g. `Spa & Massage`)
  - `featured` (`true` or `false`)
  - `minPrice` / `maxPrice` (e.g. `minPrice=30&maxPrice=100`)
  - `sortBy` (`price`, `duration`, `rating`, `name`)
  - `order` (`asc`, `desc`)
  - `page` (default: `1`)
  - `limit` (default: `10`)
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Services retrieved successfully",
  "data": [
    {
      "id": "6afcb88bbcdd4ec4c20a7d7d",
      "name": "Deep Tissue Therapeutic Massage",
      "description": "Relieves chronic muscle tension and knots using slow strokes and deep finger pressure.",
      "price": 80,
      "duration": 60,
      "image": "https://images.unsplash.com/...",
      "category": "Spa & Massage",
      "rating": 4.95,
      "reviewCount": 142,
      "isFeatured": true,
      "isAvailable": true
    }
  ],
  "meta": {
    "total": 10,
    "page": 1,
    "limit": 10,
    "totalPages": 1,
    "hasNextPage": false,
    "hasPrevPage": false
  }
}
```

---

### 3.2 Get Featured Services (Home Screen)
- **Endpoint**: `GET /services/featured?limit=6`
- **Access**: Public

### 3.3 Get Service Categories
- **Endpoint**: `GET /services/categories`
- **Access**: Public
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [
    { "name": "Spa & Massage", "count": 2 },
    { "name": "Dental Care", "count": 2 },
    { "name": "Hair & Styling", "count": 1 }
  ]
}
```

### 3.4 Get Service By ID
- **Endpoint**: `GET /services/:id`
- **Access**: Public

---

## 4. Appointment Management Endpoints (`/api/appointments`)

### 4.1 Check Available Time Slots
- **Endpoint**: `GET /appointments/available-slots?serviceId=6afcb88bbcdd4ec4c20a7d7d&date=2026-11-20`
- **Access**: Public / Protected
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Available time slots retrieved successfully",
  "data": {
    "date": "2026-11-20",
    "slots": [
      { "timeSlot": "09:00 AM - 10:00 AM", "isAvailable": true },
      { "timeSlot": "10:00 AM - 11:00 AM", "isAvailable": false },
      { "timeSlot": "11:00 AM - 12:00 PM", "isAvailable": true }
    ]
  }
}
```

---

### 4.2 Book an Appointment
- **Endpoint**: `POST /appointments`
- **Access**: Protected
- **Request Body**:
```json
{
  "serviceId": "6afcb88bbcdd4ec4c20a7d7d",
  "date": "2026-11-25",
  "timeSlot": "10:00 AM - 11:00 AM",
  "notes": "First visit"
}
```
- **Response `201 Created`**:
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "data": {
    "id": "6afcba99bcdd4ec4c20a7d9e",
    "service": {
      "id": "6afcb88bbcdd4ec4c20a7d7d",
      "name": "Deep Tissue Therapeutic Massage",
      "price": 80,
      "duration": 60,
      "image": "https://..."
    },
    "date": "2026-11-25",
    "timeSlot": "10:00 AM - 11:00 AM",
    "status": "PENDING",
    "totalAmount": 80
  }
}
```
- **Response `409 Conflict` (If slot is already booked)**:
```json
{
  "success": false,
  "message": "The time slot \"10:00 AM - 11:00 AM\" on 2026-11-25 is already booked. Please choose another time slot."
}
```

---

### 4.3 Get User Bookings
- **Endpoint**: `GET /appointments?filter=upcoming`
- **Access**: Protected
- **Query Parameters**:
  - `filter`: `upcoming`, `previous`, or `all`
  - `status`: `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED`
  - `page`, `limit`

---

### 4.4 Cancel Appointment
- **Endpoint**: `PATCH /appointments/:id/cancel`
- **Access**: Protected
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "Appointment cancelled successfully",
  "data": {
    "id": "6afcba99bcdd4ec4c20a7d9e",
    "status": "CANCELLED"
  }
}
```

---

## 5. AI Assistant Endpoints (`/api/ai`)

### 5.1 Chat with AI Assistant
- **Endpoint**: `POST /ai/chat`
- **Access**: Public / Protected
- **Request Body**:
```json
{
  "message": "What massage services do you have under $80?",
  "history": []
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "AI assistant response generated",
  "data": {
    "reply": "Here are great options that match what you're looking for:\n\n• **Deep Tissue Therapeutic Massage** ($80, 60 mins): Relieves chronic muscle tension and knots.\n• **Swedish Relaxation Massage** ($65, 60 mins): Gentle, full-body Swedish massage.",
    "suggestedServices": [
      {
        "id": "6afcb88bbcdd4ec4c20a7d7d",
        "name": "Deep Tissue Therapeutic Massage",
        "price": 80,
        "duration": 60,
        "image": "https://...",
        "category": "Spa & Massage"
      }
    ],
    "provider": "gemini"
  }
}
```

---

### 5.2 Service Recommendation
- **Endpoint**: `POST /ai/recommend`
- **Access**: Public / Protected
- **Request Body**:
```json
{
  "preferences": "I have muscle soreness from heavy lifting and want deep pressure",
  "category": "Spa & Massage",
  "maxBudget": 100
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "message": "AI recommendations generated",
  "data": {
    "reply": "Based on your request, I recommend our Deep Tissue Therapeutic Massage...",
    "suggestedServices": [...]
  }
}
```
