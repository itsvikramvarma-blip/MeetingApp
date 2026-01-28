# PHP API - Documentation Index

## Quick Navigation

Choose what you need:

### 🚀 Getting Started
- **[PHP_API_SETUP.md](PHP_API_SETUP.md)** - Complete setup & deployment guide
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - What was created

### 📚 API Reference
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Full endpoint documentation
- **[PHP_API_ENDPOINTS.md](PHP_API_ENDPOINTS.md)** - Quick endpoint reference table

### 🔄 Comparison & Migration
- **[../API_COMPARISON.md](../API_COMPARISON.md)** - PHP vs Node.js comparison

---

## File Structure

```
api/php/
├── Documentation (You are here!)
│   ├── API_DOCUMENTATION.md       ← Full reference (2000+ lines)
│   ├── PHP_API_SETUP.md          ← Setup guide (500+ lines)
│   ├── PHP_API_ENDPOINTS.md      ← Quick reference (400+ lines)
│   ├── IMPLEMENTATION_SUMMARY.md ← What was created
│   └── INDEX.md                  ← Navigation (this file)
│
├── Source Code
│   ├── public/
│   │   ├── index.php             ← Entry point
│   │   └── .htaccess             ← URL rewriting
│   │
│   ├── src/
│   │   ├── Database.php          ← Database connection
│   │   ├── helpers.php           ← JWT & auth helpers
│   │   ├── AuthController.php    ← Auth (login/register)
│   │   ├── UsersController.php   ← User management
│   │   ├── MeetingsController.php ← Meetings CRUD
│   │   ├── TasksController.php   ← Tasks CRUD
│   │   ├── MeetingMinutesController.php ← Minutes CRUD
│   │   ├── ActionItemsController.php ← Action items CRUD
│   │   └── DecisionsController.php ← Decisions CRUD
│   │
│   └── routes.php                ← URL routing dispatcher
│
├── Configuration
│   ├── composer.json             ← PHP dependencies
│   ├── .env.example             ← Config template
│   └── .env                     ← Your config (with credentials)
│
└── Other
    └── README.md                ← Project info
```

---

## 30+ Endpoints at a Glance

### Authentication (No Auth Required)
```
POST /api/auth/register        - Register new user
POST /api/auth/login           - Get JWT token
```

### Users (Auth Required)
```
GET  /api/users/profile        - Get current user
PUT  /api/users/profile        - Update profile
POST /api/users/change-password - Change password
GET  /api/users                - List all users
GET  /api/users/{id}           - Get user by ID
```

### Meetings (Auth Required)
```
GET  /api/meetings             - List meetings
POST /api/meetings             - Create meeting
GET  /api/meetings/{id}        - Get meeting
PUT  /api/meetings/{id}        - Update meeting
DELETE /api/meetings/{id}      - Delete meeting
```

### Tasks (Auth Required)
```
GET  /api/tasks                - List tasks
POST /api/tasks                - Create task
GET  /api/tasks/{id}           - Get task
PUT  /api/tasks/{id}           - Update task
DELETE /api/tasks/{id}         - Delete task
```

### Meeting Minutes (Auth Required)
```
GET  /api/meeting-minutes?meeting_id={id}  - List minutes
POST /api/meeting-minutes                   - Create minutes
GET  /api/meeting-minutes/{id}              - Get minutes
PUT  /api/meeting-minutes/{id}              - Update minutes
DELETE /api/meeting-minutes/{id}            - Delete minutes
```

### Action Items (Auth Required)
```
GET  /api/action-items?minutes_id={id}  - List action items
POST /api/action-items                   - Create action item
GET  /api/action-items/{id}              - Get action item
PUT  /api/action-items/{id}              - Update action item
DELETE /api/action-items/{id}            - Delete action item
```

### Decisions (Auth Required)
```
GET  /api/decisions?minutes_id={id}  - List decisions
POST /api/decisions                   - Create decision
GET  /api/decisions/{id}              - Get decision
PUT  /api/decisions/{id}              - Update decision
DELETE /api/decisions/{id}            - Delete decision
```

### Health Check (No Auth Required)
```
GET  /api/health               - Check API status
```

---

## Quick Start Command

### Local Development (5 minutes)
```bash
# 1. Install
cd api/php
composer install

# 2. Configure
cp .env.example .env
# Edit .env with your database

# 3. Run
php -S 0.0.0.0:8080 -t public

# 4. Test
curl http://localhost:8080/api/health
```

### Production Deployment (10 minutes)
```bash
# 1. Upload to Hostinger
# - Copy api/php folder to ~/public_html/api/php
# - Via FTP or SSH

# 2. Install dependencies
ssh u403094450@vasavyavidyalayam.in
cd ~/public_html/api/php
composer install

# 3. Configure
cp .env.example .env
nano .env  # Add your database credentials

# 4. Test
curl https://vasavyavidyalayam.in/api/php/api/health
```

---

## What Each Document Contains

### API_DOCUMENTATION.md (Complete Reference)
- Full endpoint reference with examples
- Request/response examples for all 30+ endpoints
- Authentication flow
- Error handling
- Error codes and meanings
- cURL examples
- Production deployment guide
- Security notes

**When to use:** You need exact request/response format

### PHP_API_SETUP.md (Setup Guide)
- Local development setup
- FTP deployment steps
- SSH deployment steps
- Apache/Nginx configuration
- Environment variables guide
- Verification checklist
- Troubleshooting
- Hostinger-specific instructions

**When to use:** You're deploying for the first time

### PHP_API_ENDPOINTS.md (Quick Reference)
- All 30+ endpoints in table format
- Controllers and their methods
- File structure overview
- Database tables supported
- Quick test commands
- Deployment checklist
- PHP vs Node.js comparison

**When to use:** Quick lookup during development

### IMPLEMENTATION_SUMMARY.md (What Was Created)
- 7 controllers created
- 30+ endpoints implemented
- New files created
- Features implemented
- Database support
- Performance characteristics
- Next steps

**When to use:** Understanding what's available

### API_COMPARISON.md (PHP vs Node.js)
- Architecture comparison
- Dependency comparison
- Database comparison
- Performance comparison
- Cost comparison
- When to use each
- Migration path
- Deployment paths

**When to use:** Deciding between PHP and Node.js APIs

---

## Database Configuration

### Your Hostinger Credentials (Already Configured)
```
DB_HOST=vasavyavidyalayam.in
DB_PORT=3306
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
```

### Tables Supported
- `users` - User accounts
- `meetings` - Meeting data
- `tasks` - Tasks & todos
- `meeting_minutes` - Meeting notes
- `action_items` - Follow-up actions
- `decisions` - Meeting decisions

---

## Testing the API

### Using cURL
```bash
# Test health
curl http://localhost:8080/api/health

# Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","password":"pass123"}'

# Login
LOGIN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}')

# Extract token and use it
TOKEN=$(echo $LOGIN | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Get meetings (authenticated)
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/meetings
```

### Using Postman
1. Import the endpoints from `API_DOCUMENTATION.md`
2. Get JWT token from login endpoint
3. Add token to Authorization header in other requests
4. Start testing!

### Using JavaScript (Flutter compatible)
```dart
// This is exactly what Flutter does
final response = await http.post(
  Uri.parse('https://vasavyavidyalayam.in/api/php/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);

final data = jsonDecode(response.body);
final token = data['token'];

// Use token in next requests
final meetings = await http.get(
  Uri.parse('https://vasavyavidyalayam.in/api/php/api/meetings'),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

## Deployment Decision

### Use PHP API If:
✅ You have Hostinger shared hosting
✅ You want fast, simple deployment
✅ You prefer no server management
✅ You want lower hosting costs
✅ Standard REST API is enough

**Recommended for:** Startups, small-medium apps

### Use Node.js API If:
✅ You have a VPS or cloud server
✅ You need advanced performance
✅ You want horizontal scaling
✅ Real-time features matter
✅ You have DevOps expertise

**Recommended for:** Enterprise apps, high-scale projects

---

## Integration with Flutter

Update your Flutter app to use PHP API:

```dart
// In lib/config/api_config.dart
const String apiBaseUrl = 'https://vasavyavidyalayam.in/api/php/api';
const String apiLoginEndpoint = '$apiBaseUrl/auth/login';
const String apiMeetingsEndpoint = '$apiBaseUrl/meetings';
// ... etc

// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => MeetingServiceRemote()),
    // Both services already configured for HTTP API
  ],
)
```

---

## Troubleshooting Guide

### Issue: "Connection refused"
→ See **PHP_API_SETUP.md** → Troubleshooting → "Connection refused"

### Issue: "Database error"
→ See **PHP_API_SETUP.md** → Troubleshooting → "Database connection error"

### Issue: "Invalid token"
→ See **API_DOCUMENTATION.md** → Error Responses → "401 Unauthorized"

### Issue: "404 Not Found"
→ See **PHP_API_SETUP.md** → Troubleshooting → "404 on endpoints"

---

## Files to Deploy

### Minimum Files Required
```
api/php/
├── public/
│   ├── index.php
│   └── .htaccess
├── src/
│   ├── *.php (all 7 controllers)
├── routes.php
├── composer.json
├── .env (your config)
└── vendor/ (generated by composer install)
```

### Don't Deploy
```
❌ .env.example (keep local only)
❌ node_modules/ (not needed)
❌ .git (unnecessary)
❌ This documentation (optional on server)
```

---

## Support & Resources

### Official Docs
- [PHP Official](https://php.net)
- [PDO Database](https://www.php.net/manual/en/book.pdo.php)
- [Firebase/JWT](https://github.com/firebase/php-jwt)

### This Project Docs
- API_DOCUMENTATION.md
- PHP_API_SETUP.md
- PHP_API_ENDPOINTS.md
- IMPLEMENTATION_SUMMARY.md
- API_COMPARISON.md

---

## Status

✅ **7 Controllers Implemented**
✅ **30+ Endpoints Ready**
✅ **Full Documentation Complete**
✅ **Ready for Production Deployment**

**Choose any document above to get started!** 🚀

