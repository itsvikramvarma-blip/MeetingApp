# Meeting App - Hostinger Setup Quick Reference

## Database Credentials
```
Host: vasavyavidyalayam.in
Database: u403094450_MeetingApp
Username: u403094450_MeetingApp
Password: 5~pS4iVJ+*bN
Port: 3306
```

## API Configuration
```
Base URL: https://vasavyavidyalayam.in/api
API Location: /public_html/api (on Hostinger server)
```

## Files Created/Updated

### New Configuration Files
- `lib/config/api_config.dart` - API configuration with your domain
- `HOSTINGER_DEPLOYMENT.md` - Complete deployment guide

### New Service Files (Remote API versions)
- `lib/services/auth_service_remote.dart` - Remote authentication
- `lib/services/meeting_service_remote.dart` - Remote data access

### Updated Files
- `.env` - Updated with Hostinger credentials
- `pubspec.yaml` - Added http package

## Next Steps (In Order)

### 1. Upload Database to Hostinger
```
1. Go to Hostinger Control Panel → Databases
2. Open phpMyAdmin for u403094450_MeetingApp
3. Import: db/meeting_app.sql
```

### 2. Upload Node.js API
```bash
# Via SSH:
ssh u403094450@vasavyavidyalayam.in
cd public_html
# Upload api folder
cd api
npm install
npm install -g pm2
pm2 start src/app.js --name "meeting-api"
pm2 startup
pm2 save
```

### 3. Verify API is Running
```
Visit: https://vasavyavidyalayam.in/api/health
(Should show API is running)
```

### 4. Update Flutter App
```bash
# Add HTTP package
flutter pub get

# Update main.dart to use remote services
# Option: Use MeetingServiceRemote instead of MeetingService
```

### 5. Test Connection
```bash
# Run app
flutter run -d chrome

# Try logging in
# Check server logs: pm2 logs meeting-api
```

## Important URLs

| Purpose | URL |
|---------|-----|
| API Base | https://vasavyavidyalayam.in/api |
| Login Endpoint | https://vasavyavidyalayam.in/api/auth/login |
| Register Endpoint | https://vasavyavidyalayam.in/api/auth/register |
| Meetings Endpoint | https://vasavyavidyalayam.in/api/meetings |
| Database Host | vasavyavidyalayam.in:3306 |

## Environment Variables (.env on Server)
```
DB_HOST=vasavyavidyalayam.in
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
PORT=3000
NODE_ENV=production
```

## Testing Commands

### Check Node.js API
```bash
pm2 status
pm2 logs meeting-api
curl -X GET https://vasavyavidyalayam.in/api/health
```

### Test Database
```bash
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p
# Password: 5~pS4iVJ+*bN
use u403094450_MeetingApp;
SHOW TABLES;
```

### Test Flutter Connection
```dart
// In Flutter app
import 'package:http/http.dart' as http;
import 'lib/config/api_config.dart';

// Test API
final response = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/meetings'),
  headers: {'Authorization': 'Bearer YOUR_TOKEN'},
);
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

## Troubleshooting

### API Won't Start
```bash
# Check Node.js version (should be ≥18)
node --version

# Check for port 3000 already in use
lsof -i :3000

# Check logs
pm2 logs meeting-api
```

### Database Connection Failed
```bash
# Test connection directly
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN -e "SELECT 1"

# Check if tables exist
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN u403094450_MeetingApp -e "SHOW TABLES"
```

### Flutter App Can't Connect to API
1. Check API URL in `lib/config/api_config.dart`
2. Verify SSL certificate is valid
3. Check CORS settings in API
4. Check PM2 logs for errors

## Support Documentation

- Full deployment guide: `HOSTINGER_DEPLOYMENT.md`
- API Configuration: `lib/config/api_config.dart`
- Remote Auth Service: `lib/services/auth_service_remote.dart`
- Remote Meeting Service: `lib/services/meeting_service_remote.dart`
