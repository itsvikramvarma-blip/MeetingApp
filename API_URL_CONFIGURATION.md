# API Base URL - Updated Configuration

## New Base URL

```
https://www.vasavyavidyalayam.in/meeting_api
```

---

## Files Updated

### 1. Flutter Configuration ✅
**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Production API base URL
  static const String baseUrl = 'https://www.vasavyavidyalayam.in/meeting_api';
  
  // All endpoints automatically use this base URL
  static const String authLogin = '$baseUrl/auth/login';
  static const String authRegister = '$baseUrl/auth/register';
  static const String meetingsEndpoint = '$baseUrl/meetings';
  static const String tasksEndpoint = '$baseUrl/tasks';
  static const String minutesEndpoint = '$baseUrl/meetings';
}
```

### 2. Node.js API Configuration ✅
**File:** `api/.env`

```env
API_URL=https://www.vasavyavidyalayam.in/meeting_api
CORS_ORIGIN=https://www.vasavyavidyalayam.in
```

### 3. PHP API Configuration ✅
**File:** `api/php/.env` (newly created)

```env
DB_HOST=vasavyavidyalayam.in
DB_PORT=3306
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
JWT_EXPIRY=3600
API_URL=https://www.vasavyavidyalayam.in/meeting_api
DEBUG=false
```

---

## API Endpoints

All endpoints now use the new base URL:

### Authentication
```
POST   https://www.vasavyavidyalayam.in/meeting_api/auth/login
POST   https://www.vasavyavidyalayam.in/meeting_api/auth/register
```

### Meetings
```
GET    https://www.vasavyavidyalayam.in/meeting_api/meetings
POST   https://www.vasavyavidyalayam.in/meeting_api/meetings
GET    https://www.vasavyavidyalayam.in/meeting_api/meetings/{id}
PUT    https://www.vasavyavidyalayam.in/meeting_api/meetings/{id}
DELETE https://www.vasavyavidyalayam.in/meeting_api/meetings/{id}
```

### Tasks
```
GET    https://www.vasavyavidyalayam.in/meeting_api/tasks
POST   https://www.vasavyavidyalayam.in/meeting_api/tasks
GET    https://www.vasavyavidyalayam.in/meeting_api/tasks/{id}
PUT    https://www.vasavyavidyalayam.in/meeting_api/tasks/{id}
DELETE https://www.vasavyavidyalayam.in/meeting_api/tasks/{id}
```

---

## Testing the API

### Test Health Check
```bash
curl https://www.vasavyavidyalayam.in/meeting_api/health
```

### Test Login
```bash
curl -X POST https://www.vasavyavidyalayam.in/meeting_api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

---

## Configuration Summary

| Component | Old URL | New URL |
|-----------|---------|---------|
| **Flutter App** | vasavyavidyalayam.in/api | www.vasavyavidyalayam.in/meeting_api |
| **Node.js API** | vasavyavidyalayam.in/api | www.vasavyavidyalayam.in/meeting_api |
| **PHP API** | vasavyavidyalayam.in/api/php | www.vasavyavidyalayam.in/meeting_api |

---

## What to Do Next

1. **Verify Flutter App**
   - App will now connect to: `https://www.vasavyavidyalayam.in/meeting_api`
   - All HTTP requests will use the new base URL

2. **Verify Node.js API**
   - Update server configuration if needed
   - Restart API: `pm2 restart meeting-api`

3. **Verify PHP API**
   - Use new `.env` file
   - All requests will use the new base URL

4. **Test All Endpoints**
   - Try login endpoint
   - Try meetings endpoint
   - Verify JWT tokens work

---

## Key Points

✅ Base URL changed from `/api` to `/meeting_api`
✅ Now uses `www.` subdomain
✅ All endpoints automatically updated
✅ Flutter app ready to use new URL
✅ Node.js and PHP APIs configured

**Everything is now configured to use the new API base URL!** 🚀

