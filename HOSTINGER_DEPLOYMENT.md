# Hostinger Deployment Guide

## Your Credentials Summary
- **Domain:** vasavyavidyalayam.in
- **Database:** u403094450_MeetingApp
- **DB User:** u403094450_MeetingApp
- **DB Password:** 5~pS4iVJ+*bN
- **DB Host:** vasavyavidyalayam.in

---

## Step 1: Import Database Schema

1. **Access Hostinger Control Panel:**
   - Log in to https://hpanel.hostinger.com/
   - Navigate to **Databases** → **MySQL Databases**
   - Find your database `u403094450_MeetingApp`

2. **Import SQL Schema:**
   - Click on your database → **phpMyAdmin**
   - Select the `u403094450_MeetingApp` database
   - Go to **Import** tab
   - Choose file: `d:\Vikramvarma\copilot\db\meeting_app.sql`
   - Click **Go** to import

---

## Step 2: Deploy Node.js API

### 2A. Using SSH (Recommended)

1. **SSH into your server:**
   ```bash
   ssh u403094450@vasavyavidyalayam.in
   ```

2. **Navigate to public directory:**
   ```bash
   cd public_html
   ```

3. **Clone or upload your API files:**
   ```bash
   # If you have git access
   git clone <your-repo-url> api
   cd api
   
   # Or upload via FTP then:
   cd api
   ```

4. **Install dependencies:**
   ```bash
   npm install
   ```

5. **The `.env` file is already configured with:**
   ```
   DB_HOST=vasavyavidyalayam.in
   DB_USER=u403094450_MeetingApp
   DB_PASSWORD=5~pS4iVJ+*bN
   DB_NAME=u403094450_MeetingApp
   ```

6. **Start the API with PM2:**
   ```bash
   npm install -g pm2
   pm2 start src/app.js --name "meeting-api"
   pm2 startup
   pm2 save
   ```

7. **Check status:**
   ```bash
   pm2 status
   pm2 logs meeting-api
   ```

### 2B. Using FTP (Alternative)

1. **Download FileZilla** or similar FTP client
2. **Connect to:**
   - Host: `vasavyavidyalayam.in` (or your FTP host)
   - Username: Your Hostinger username
   - Password: Your Hostinger password
3. **Upload the `api` folder** to `public_html/api`
4. **Then SSH in to run npm install and PM2**

---

## Step 3: Configure API Access

### Using cPanel/.htaccess (if Node.js proxy available)

Create `.htaccess` in `public_html/api`:
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP:Connection} Upgrade [NC]
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteRule ^/?(.*) "ws://localhost:3000/$1" [P,L]
    RewriteRule ^/?(.*) "http://localhost:3000/$1" [P,L]
</IfModule>
```

### Or use Nginx (if available)

Configure proxy to `localhost:3000`

---

## Step 4: Test API Connection

1. **Test endpoint from browser:**
   ```
   https://vasavyavidyalayam.in/api/auth/login
   ```
   Should show API is running (even if 400 error due to missing credentials)

2. **Check logs:**
   ```bash
   pm2 logs meeting-api
   ```

---

## Step 5: Update Flutter App

### Already Done:
- ✅ Created `lib/config/api_config.dart` with your domain
- ✅ Created `lib/services/auth_service_remote.dart`
- ✅ Created `lib/services/meeting_service_remote.dart`

### Next Steps:

1. **Add HTTP package to pubspec.yaml:**
   ```yaml
   dependencies:
     http: ^1.1.0
   ```
   Run: `flutter pub get`

2. **Update main.dart to use remote services:**
   Replace the providers in `main.dart`:
   ```dart
   providers: [
     ChangeNotifierProvider(create: (_) => AuthService()), // Your existing auth
     ChangeNotifierProvider(create: (_) => MeetingService()), // Switch to MeetingServiceRemote
   ],
   ```

3. **Or create a toggle for local/remote:**
   ```dart
   const bool USE_REMOTE_API = true; // Set to false for local testing
   
   ChangeNotifierProvider(
     create: (_) => USE_REMOTE_API 
       ? MeetingServiceRemote() 
       : MeetingService(),
   ),
   ```

---

## Step 6: Test the Connection

1. **Run Flutter app:**
   ```bash
   flutter run -d chrome  # or your device
   ```

2. **Try to login:**
   - You should see API calls to: `https://vasavyavidyalayam.in/api/auth/login`

3. **Check error messages:**
   - Look for network errors in Flutter console
   - Check PM2 logs on server: `pm2 logs meeting-api`

---

## Troubleshooting

### API Not Responding
```bash
# Check if Node.js is running
pm2 status

# Restart API
pm2 restart meeting-api

# Check logs
pm2 logs meeting-api
```

### Database Connection Error
```bash
# SSH into server and test connection
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p
# Enter password: 5~pS4iVJ+*bN
# Then: use u403094450_MeetingApp;
# Query: SELECT * FROM meetings;
```

### CORS Issues
Update `src/app.js` to allow Flutter app domain:
```javascript
app.use(cors({
  origin: ['https://vasavyavidyalayam.in', 'http://localhost:*'],
  credentials: true
}));
```

### SSL Certificate Error
Ensure Hostinger has active SSL certificate:
- Control Panel → Domains → Your domain → SSL → Enable Let's Encrypt

---

## Production Checklist

- [ ] Database imported successfully
- [ ] Node.js API deployed and running (PM2)
- [ ] Environment variables set in `.env`
- [ ] SSL certificate active
- [ ] Flutter app configured with correct API URL
- [ ] Login endpoint tested
- [ ] Meet data fetching working
- [ ] Error handling working

---

## Monitor Your API

**SSH Command to monitor:**
```bash
# Real-time logs
pm2 logs meeting-api

# View status
pm2 status

# Restart if needed
pm2 restart meeting-api

# Stop API
pm2 stop meeting-api

# Start API
pm2 start meeting-api
```

---

## Support Resources

- Hostinger Docs: https://support.hostinger.in/
- PM2 Docs: https://pm2.keymetrics.io/
- Node.js Docs: https://nodejs.org/docs/
- Flutter HTTP: https://pub.dev/packages/http

For issues, check:
1. PM2 logs: `pm2 logs meeting-api`
2. MySQL connection
3. .env file configuration
4. API endpoint URLs in Flutter
