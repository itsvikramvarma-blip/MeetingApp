# System Architecture - Meeting App with Hostinger

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter Mobile/Web App                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  lib/config/api_config.dart                              │   │
│  │  BaseURL: https://vasavyavidyalayam.in/api               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓ HTTP                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  lib/services/auth_service_remote.dart                   │   │
│  │  - Login/Register                                        │   │
│  │  - Token Management                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  lib/services/meeting_service_remote.dart                │   │
│  │  - Fetch Meetings                                        │   │
│  │  - Create/Update/Delete                                  │   │
│  │  - Meeting Minutes                                       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    HTTPS (Port 443)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              Hostinger Server (vasavyavidyalayam.in)             │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Node.js API (PM2 Process on Port 3000)                  │   │
│  │  ├── src/app.js                                          │   │
│  │  ├── src/routes/auth.js                                  │   │
│  │  ├── src/routes/meetings.js                              │   │
│  │  ├── src/middleware/auth.js                              │   │
│  │  └── src/controllers/meetingsController.js               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         ↓ (TCP Port 3306)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         MySQL Database (u403094450_MeetingApp)            │   │
│  │  ├── meetings table                                      │   │
│  │  ├── meeting_minutes table                               │   │
│  │  ├── decisions table                                     │   │
│  │  ├── action_items table                                  │   │
│  │  ├── users table                                         │   │
│  │  └── tasks table                                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. User Login Flow
```
Flutter App
    ↓
[User enters email/password]
    ↓
POST /api/auth/login
    ↓
Node.js API
    ├─ Validates credentials
    ├─ Queries MySQL users table
    ├─ Generates JWT token
    ↓
Returns: { token, user }
    ↓
Flutter
    ├─ Stores token
    ├─ Updates AuthService
    ↓
Navigates to Dashboard
```

### 2. Fetch Meetings Flow
```
Flutter App Dashboard
    ↓
[Page loads / User navigates to Meetings]
    ↓
GET /api/meetings
  (Header: Authorization: Bearer <token>)
    ↓
Node.js API
    ├─ Verifies JWT token
    ├─ Queries MySQL meetings table
    ↓
Returns: [{ meeting1 }, { meeting2 }, ...]
    ↓
Flutter
    ├─ Updates MeetingService
    ├─ Rebuilds UI
    ↓
Displays meetings list
```

### 3. Create Meeting Flow
```
Flutter App [Create Meeting Screen]
    ↓
[User fills form and clicks "Save"]
    ↓
POST /api/meetings
  Body: { title, description, start_time, ... }
  Header: Authorization: Bearer <token>
    ↓
Node.js API
    ├─ Verifies JWT token
    ├─ Validates data
    ├─ Inserts into MySQL meetings table
    ↓
Returns: { id, status: "created" }
    ↓
Flutter
    ├─ Refreshes meetings list
    ├─ Shows success message
    ↓
Navigates back to meetings list
```

## Deployment Architecture

```
┌────────────────────────────────────────────────────────┐
│           Your Development Machine                      │
│                                                        │
│  ├── lib/services/meeting_service_remote.dart          │
│  ├── lib/services/auth_service_remote.dart             │
│  ├── lib/config/api_config.dart                        │
│  ├── pubspec.yaml                                      │
│  └── api/                                              │
│      ├── .env (credentials)                            │
│      ├── src/                                          │
│      └── package.json                                  │
└────────────────────────────────────────────────────────┘
        ↓ (Upload API folder)
┌────────────────────────────────────────────────────────┐
│         Hostinger Server (Shared Hosting)              │
│                                                        │
│  public_html/                                          │
│  └── api/                                              │
│      ├── .env (your credentials here)                  │
│      ├── node_modules/ (npm install)                   │
│      ├── src/app.js                                    │
│      └── package.json                                  │
│                                                        │
│  ┌──────────────────────────────────────────────┐      │
│  │ PM2 Running: meeting-api                     │      │
│  │ Status: Running on port 3000                 │      │
│  │ Command: pm2 start src/app.js                │      │
│  └──────────────────────────────────────────────┘      │
└────────────────────────────────────────────────────────┘
        ↓ (MySQL connection - localhost)
┌────────────────────────────────────────────────────────┐
│     Hostinger MySQL Database Server                    │
│                                                        │
│  Database: u403094450_MeetingApp                       │
│  User: u403094450_MeetingApp                           │
│  Host: vasavyavidyalayam.in                            │
│  Port: 3306                                            │
│                                                        │
│  Tables:                                               │
│  ├── meetings                                          │
│  ├── meeting_minutes                                   │
│  ├── users                                             │
│  ├── tasks                                             │
│  └── ...                                               │
└────────────────────────────────────────────────────────┘
```

## API Endpoints Reference

```
Authentication:
  POST   /api/auth/login              → { token, user }
  POST   /api/auth/register           → { token, user }
  POST   /api/auth/phone-login        → { token, user }

Meetings:
  GET    /api/meetings                → [ meetings ]
  GET    /api/meetings/:id            → { meeting }
  POST   /api/meetings                → { meeting }
  PUT    /api/meetings/:id            → { meeting }
  DELETE /api/meetings/:id            → { status: "deleted" }

Meeting Minutes:
  GET    /api/meetings/:id/minutes    → { minutes }
  POST   /api/meetings/:id/minutes    → { minutes }

Tasks:
  GET    /api/tasks                   → [ tasks ]
  POST   /api/tasks                   → { task }
```

## Security Architecture

```
┌─────────────────────────────────────────┐
│  Flutter App                            │
│  (No sensitive data stored locally)     │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  HTTPS/SSL Encryption                   │
│  (End-to-end encrypted)                 │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  Node.js API (Hostinger)                │
│  ├── JWT Token Verification             │
│  ├── CORS Headers                       │
│  ├── Request Validation                 │
│  └── Error Handling                     │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  MySQL Database                         │
│  ├── Password: Hashed (bcrypt)          │
│  ├── User Permissions: Limited          │
│  └── Encrypted Connections              │
└─────────────────────────────────────────┘
```

## File Organization

```
Project Root: d:\Vikramvarma\copilot
│
├── lib/
│   ├── config/
│   │   └── api_config.dart .................. ← API URLs
│   │
│   ├── services/
│   │   ├── auth_service.dart ............... (Local/Mock)
│   │   ├── auth_service_remote.dart ........ ← Remote Auth
│   │   ├── meeting_service.dart ............ (Local/Mock)
│   │   └── meeting_service_remote.dart ..... ← Remote Meetings
│   │
│   ├── screens/ ............................ (UI Components)
│   ├── models/ ............................ (Data Models)
│   └── main.dart .......................... (App Entry Point)
│
├── api/
│   ├── src/
│   │   ├── app.js ......................... (Express App)
│   │   ├── db.js .......................... (MySQL Connection)
│   │   ├── routes/ ........................ (API Routes)
│   │   ├── controllers/ ................... (Business Logic)
│   │   └── middleware/ .................... (Auth, CORS)
│   │
│   ├── .env ............................... ← Configuration
│   ├── package.json ....................... (Dependencies)
│   └── README.md .......................... (API Docs)
│
├── db/
│   ├── meeting_app.sql .................... ← Database Schema
│   ├── migrations/ ........................ (Schema Changes)
│   └── seed_dummy_user.sql ................ (Test Data)
│
├── pubspec.yaml ........................... (Flutter Dependencies)
├── SETUP_SUMMARY.md ....................... (This Guide)
├── HOSTINGER_DEPLOYMENT.md ................ (Deployment Steps)
└── QUICK_REFERENCE.md ..................... (Quick Lookup)
```

## Environment Configuration

```
Development (.env.development):
  DB_HOST=localhost
  NODE_ENV=development
  API_URL=http://localhost:3000/api

Production (.env - Hostinger):
  DB_HOST=vasavyavidyalayam.in
  DB_USER=u403094450_MeetingApp
  DB_PASSWORD=5~pS4iVJ+*bN
  DB_NAME=u403094450_MeetingApp
  NODE_ENV=production
  API_URL=https://vasavyavidyalayam.in/api
  PORT=3000
```

## Scalability Path

```
Current Setup:
  Shared Hosting (Hostinger)
    ├── Single Node.js process
    └── Single MySQL database

Growth Path:
  1. Load Balancer (multiple API instances)
  2. Database Replication (read replicas)
  3. CDN (static content caching)
  4. Redis Cache (session/data caching)
  5. Microservices (separate services)
  6. Kubernetes (container orchestration)
```
