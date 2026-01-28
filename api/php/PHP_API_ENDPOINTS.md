# PHP API - Complete Endpoints Reference

## Summary
Your PHP API now has **30+ endpoints** across 7 controllers for complete meeting management.

---

## Authentication Endpoints (No Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login & get JWT token |

---

## User Management Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/users/profile` | Get current user profile |
| PUT | `/api/users/profile` | Update current user profile |
| POST | `/api/users/change-password` | Change password |
| GET | `/api/users` | List all users |
| GET | `/api/users/{id}` | Get user by ID |

---

## Meetings Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/meetings` | List all meetings |
| POST | `/api/meetings` | Create new meeting |
| GET | `/api/meetings/{id}` | Get meeting details |
| PUT | `/api/meetings/{id}` | Update meeting |
| DELETE | `/api/meetings/{id}` | Delete meeting |

---

## Tasks Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/tasks` | List all tasks |
| POST | `/api/tasks` | Create new task |
| GET | `/api/tasks/{id}` | Get task details |
| PUT | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |

---

## Meeting Minutes Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/meeting-minutes?meeting_id={id}` | List minutes for meeting |
| POST | `/api/meeting-minutes` | Create meeting minutes |
| GET | `/api/meeting-minutes/{id}` | Get minutes details |
| PUT | `/api/meeting-minutes/{id}` | Update minutes |
| DELETE | `/api/meeting-minutes/{id}` | Delete minutes |

---

## Action Items Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/action-items?minutes_id={id}` | List action items for minutes |
| POST | `/api/action-items` | Create action item |
| GET | `/api/action-items/{id}` | Get action item details |
| PUT | `/api/action-items/{id}` | Update action item |
| DELETE | `/api/action-items/{id}` | Delete action item |

---

## Decisions Endpoints (Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/decisions?minutes_id={id}` | List decisions for minutes |
| POST | `/api/decisions` | Create decision |
| GET | `/api/decisions/{id}` | Get decision details |
| PUT | `/api/decisions/{id}` | Update decision |
| DELETE | `/api/decisions/{id}` | Delete decision |

---

## Health Check Endpoint (No Auth Required)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health` | Check API status |

---

## Controllers Created

| Controller | File | Methods | Purpose |
|-----------|------|---------|---------|
| AuthController | `src/AuthController.php` | register(), login() | Authentication |
| MeetingsController | `src/MeetingsController.php` | list(), get(), create(), update(), delete() | Meeting CRUD |
| TasksController | `src/TasksController.php` | list(), get(), create(), update(), delete() | Task CRUD |
| MeetingMinutesController | `src/MeetingMinutesController.php` | listByMeeting(), get(), create(), update(), delete() | Minutes CRUD |
| ActionItemsController | `src/ActionItemsController.php` | listByMinutes(), get(), create(), update(), delete() | Action Items CRUD |
| DecisionsController | `src/DecisionsController.php` | listByMinutes(), get(), create(), update(), delete() | Decisions CRUD |
| UsersController | `src/UsersController.php` | profile(), updateProfile(), changePassword(), list(), get() | User Management |

---

## Files in PHP API

```
api/php/
├── public/
│   ├── index.php              ← Entry point (loads environment & routes)
│   └── .htaccess              ← Apache URL rewriting
├── src/
│   ├── Database.php           ← PDO MySQL connection
│   ├── helpers.php            ← JWT, JSON, auth helpers
│   ├── AuthController.php     ← Login/Register
│   ├── MeetingsController.php ← Meeting CRUD
│   ├── TasksController.php    ← Task CRUD (NEW)
│   ├── MeetingMinutesController.php ← Minutes CRUD (NEW)
│   ├── ActionItemsController.php ← Action Items CRUD (NEW)
│   ├── DecisionsController.php ← Decisions CRUD (NEW)
│   └── UsersController.php    ← User Management (NEW)
├── routes.php                 ← URL routing & dispatcher
├── composer.json              ← Dependencies (updated)
├── .env.example               ← Template configuration
├── .env                       ← Your configuration
├── API_DOCUMENTATION.md       ← Full endpoint docs (NEW)
├── PHP_API_SETUP.md          ← Setup guide (NEW)
└── README.md                  ← Project info
```

---

## Database Tables Supported

Your PHP API works with these MySQL tables:

1. **users** - User accounts & authentication
2. **meetings** - Meeting information
3. **tasks** - Todo items & tasks
4. **meeting_minutes** - Minutes from meetings
5. **action_items** - Action items from meetings
6. **decisions** - Decisions made in meetings

All tables are defined in: `db/meeting_app.sql`

---

## Key Features

✅ **JWT Authentication** - Secure token-based auth
✅ **CRUD Operations** - Full Create, Read, Update, Delete for all entities
✅ **Error Handling** - Proper HTTP status codes & error messages
✅ **JSON Support** - All responses are JSON
✅ **Database Abstraction** - PDO for database queries
✅ **Environment Configuration** - .env file support
✅ **URL Routing** - Custom router with regex patterns
✅ **Security** - Prepared statements, password hashing (bcrypt)

---

## Quick Test Commands

### Test via Terminal/cURL

**1. Register:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}'
```

**2. Login:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**3. Get Token (from login response)**
```
token: "eyJ0eXAiOiJKV1QiLCJhbGc..."
```

**4. List Meetings (authenticated):**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8080/api/meetings
```

**5. Create Task:**
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title":"New Task",
    "description":"Task description",
    "due_date":"2025-09-25",
    "priority":"high"
  }'
```

---

## Deployment Checklist

- [ ] Upload `api/php` folder to Hostinger
- [ ] Run `composer install` on server
- [ ] Create `.env` file with database credentials
- [ ] Test all endpoints with curl or Postman
- [ ] Configure Apache/Nginx if needed
- [ ] Enable HTTPS/SSL
- [ ] Update Flutter app to use this PHP API
- [ ] Point `API_BASE_URL` to `https://vasavyavidyalayam.in/api/php/api`

---

## Comparison: PHP API vs Node.js API

| Feature | PHP API | Node.js API |
|---------|---------|------------|
| **Location** | `/api/php` | `/api/src` |
| **Entry Point** | `public/index.php` | `src/server.js` |
| **Dependencies** | Composer | npm |
| **Database** | PDO (MySQL) | mysql2 (MySQL) |
| **Authentication** | JWT (Firebase) | JWT (jsonwebtoken) |
| **Process Manager** | Apache/Nginx | PM2 |
| **Performance** | Good for CRUD | Better for async |
| **Endpoints** | 30+ | Similar coverage |
| **Recommended** | Production API | Real-time features |

---

## Use This API When:

✅ You need a stable, proven PHP API
✅ Your hosting has PHP built-in (shared hosting like Hostinger)
✅ You want simpler deployment (no PM2 needed)
✅ You prefer Apache/Nginx over Node.js
✅ You already have PHP expertise

---

## Next Steps

1. **Deploy to Hostinger:**
   - Follow `PHP_API_SETUP.md` guide

2. **Test the API:**
   - Use the commands in `API_DOCUMENTATION.md`

3. **Update Flutter App:**
   - Change `API_BASE_URL` in `lib/config/api_config.dart`
   - Point to: `https://vasavyavidyalayam.in/api/php/api`

4. **Choose Primary API:**
   - Use PHP or Node.js (or both in parallel)
   - Recommend: PHP for easier deployment on shared hosting

---

**Status: ✅ Complete PHP API Ready for Deployment**

All 7 controllers implemented with full CRUD operations and proper error handling!

