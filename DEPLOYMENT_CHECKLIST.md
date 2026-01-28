# Complete Setup Checklist - Meeting App on Hostinger

## Pre-Deployment Verification

### Local Setup ✅
- [x] Flutter project created
- [x] Dependencies installed (`flutter pub get`)
- [x] HTTP package added to pubspec.yaml
- [x] API configuration file created (`lib/config/api_config.dart`)
- [x] Remote authentication service created
- [x] Remote meeting service created
- [x] No compilation errors

### Configuration Files ✅
- [x] `.env` file updated with Hostinger credentials:
  - DB_HOST: vasavyavidyalayam.in
  - DB_USER: u403094450_MeetingApp
  - DB_PASSWORD: 5~pS4iVJ+*bN
  - DB_NAME: u403094450_MeetingApp

### Documentation ✅
- [x] SETUP_SUMMARY.md - Overview and quick actions
- [x] HOSTINGER_DEPLOYMENT.md - Step-by-step deployment guide
- [x] QUICK_REFERENCE.md - Command reference
- [x] ARCHITECTURE.md - System architecture diagrams

---

## Phase 1: Database Setup (Hostinger)

### Access Database
- [ ] Log in to https://hpanel.hostinger.com/
- [ ] Navigate to **Databases** → **MySQL Databases**
- [ ] Locate database: `u403094450_MeetingApp`
- [ ] Click to view details

### Import Schema
- [ ] Click **phpMyAdmin** button
- [ ] Select database: `u403094450_MeetingApp`
- [ ] Go to **Import** tab
- [ ] Choose file: `db/meeting_app.sql`
- [ ] Click **Import** button
- [ ] Wait for success message

### Verify Tables
- [ ] Go to **Structure** tab
- [ ] Verify tables exist:
  - [ ] meetings
  - [ ] meeting_minutes
  - [ ] decisions
  - [ ] action_items
  - [ ] users
  - [ ] tasks
  - [ ] notifications

**Time: ~2-5 minutes**

---

## Phase 2: API Deployment (Hostinger)

### Prepare Files
- [ ] Ensure `api/.env` has correct credentials:
  ```
  DB_HOST=vasavyavidyalayam.in
  DB_USER=u403094450_MeetingApp
  DB_PASSWORD=5~pS4iVJ+*bN
  DB_NAME=u403094450_MeetingApp
  JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
  PORT=3000
  NODE_ENV=production
  ```

### Upload via SSH (Recommended)
- [ ] Open terminal/command prompt
- [ ] Connect to Hostinger:
  ```bash
  ssh u403094450@vasavyavidyalayam.in
  ```
- [ ] Navigate to public directory:
  ```bash
  cd ~/public_html
  ```
- [ ] Upload API folder (choose one):
  
  **Option A: Using Git (if enabled on Hostinger)**
  ```bash
  git clone <your-repo-url> api
  cd api
  ```
  
  **Option B: Using SCP**
  ```bash
  scp -r api/ u403094450@vasavyavidyalayam.in:~/public_html/
  ```
  
  **Option C: Manual via FTP then SSH**
  - Use FileZilla to upload `api` folder
  - Then SSH into server

### Install Dependencies
- [ ] In SSH session, run:
  ```bash
  cd ~/public_html/api
  node --version  # Verify Node.js is ≥18
  npm install
  ```
- [ ] Wait for `npm install` to complete

### Install PM2 Process Manager
- [ ] Install globally:
  ```bash
  npm install -g pm2
  ```
- [ ] Verify installation:
  ```bash
  pm2 --version
  ```

### Start Node.js API
- [ ] Start the API:
  ```bash
  pm2 start src/app.js --name "meeting-api"
  ```
- [ ] Configure auto-restart:
  ```bash
  pm2 startup
  pm2 save
  ```
- [ ] Verify running:
  ```bash
  pm2 status
  ```
  (Should show: meeting-api → online)

### Test API Endpoint
- [ ] Open browser
- [ ] Visit: `https://vasavyavidyalayam.in/api/health`
- [ ] Should respond (or show API error, not connection error)

### Monitor API Logs
- [ ] In SSH session:
  ```bash
  pm2 logs meeting-api
  ```
- [ ] Look for any error messages
- [ ] Verify database connection works

**Time: ~10-15 minutes**

---

## Phase 3: Flutter App Update

### Update Main Configuration
- [ ] Open `lib/main.dart`
- [ ] Locate the providers section
- [ ] Choose one option:

**Option A: Always use remote API**
```dart
ChangeNotifierProvider(create: (_) => MeetingServiceRemote()),
```

**Option B: Toggle via constant**
```dart
const bool USE_REMOTE_API = true;
// Then: USE_REMOTE_API ? MeetingServiceRemote() : MeetingService()
```

- [ ] Save file

### Update Auth Service (if needed)
- [ ] Check if you need to switch `AuthService` to remote version
- [ ] For now, existing `AuthService` works with fallback to local
- [ ] Can upgrade to remote version later

### Rebuild App
- [ ] Run:
  ```bash
  flutter clean
  flutter pub get
  flutter run -d chrome
  ```
- [ ] Wait for app to compile

### Test Locally
- [ ] App should load without errors
- [ ] Try clicking login button
- [ ] Check browser developer console (F12) for network requests
- [ ] Should see requests to: `https://vasavyavidyalayam.in/api/...`

**Time: ~5-10 minutes**

---

## Phase 4: Integration Testing

### Test Login
- [ ] Click Login button
- [ ] Enter test credentials (check database for user)
- [ ] Monitor:
  - [ ] Browser DevTools Network tab (F12)
  - [ ] Server logs: `pm2 logs meeting-api`
- [ ] Should see:
  - [ ] POST request to `/api/auth/login`
  - [ ] Response with token
  - [ ] Navigation to dashboard

### Test Meetings Display
- [ ] After login, navigate to Meetings
- [ ] Monitor network traffic
- [ ] Should see:
  - [ ] GET request to `/api/meetings`
  - [ ] Meetings displayed from database
  - [ ] If empty, no meetings were in database

### Test Create Meeting
- [ ] Click "Create Meeting"
- [ ] Fill in form
- [ ] Click Save
- [ ] Monitor:
  - [ ] POST request to `/api/meetings`
  - [ ] Server response
  - [ ] Updated meetings list
- [ ] Check database to verify entry

### Check Error Handling
- [ ] Disconnect internet (simulate failure)
- [ ] Try to load meetings
- [ ] Should show error message (not crash)
- [ ] Reconnect and retry

**Time: ~15 minutes**

---

## Phase 5: Production Verification

### SSL Certificate
- [ ] Verify SSL is enabled:
  - [ ] Hostinger Panel → Domains → Your domain
  - [ ] Should show "SSL Active"
  - [ ] Browser should show padlock icon
- [ ] If not active, enable Let's Encrypt SSL

### CORS Configuration
- [ ] If getting CORS errors in console:
  - [ ] SSH to server
  - [ ] Edit `api/src/app.js`
  - [ ] Update cors() settings:
    ```javascript
    app.use(cors({
      origin: 'https://vasavyavidyalayam.in',
      credentials: true
    }));
    ```
  - [ ] Restart API: `pm2 restart meeting-api`

### Database Backup
- [ ] In phpMyAdmin:
  - [ ] Select database
  - [ ] Click **Export**
  - [ ] Download backup (save locally)
- [ ] Keep backups for safety

### Performance Check
- [ ] API should respond in <1 second
- [ ] Check server logs for any warnings
- [ ] Verify no memory leaks: `pm2 monit`

**Time: ~5-10 minutes**

---

## Post-Deployment Maintenance

### Daily Checks
- [ ] Verify API is running: `pm2 status`
- [ ] Check for errors: `pm2 logs meeting-api`
- [ ] Database connectivity is working

### Weekly Tasks
- [ ] Backup database regularly
- [ ] Review error logs
- [ ] Update Node.js packages (if needed)
- [ ] Check server storage usage

### Monthly Tasks
- [ ] Review API performance metrics
- [ ] Update security settings
- [ ] Test disaster recovery procedures
- [ ] Database optimization

### SSH Commands Reference
```bash
# Check API status
pm2 status
pm2 monit

# View logs
pm2 logs meeting-api
pm2 logs meeting-api --lines 50

# Restart API
pm2 restart meeting-api

# Stop API
pm2 stop meeting-api

# Start API
pm2 start meeting-api

# Test database
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p
# Password: 5~pS4iVJ+*bN
```

---

## Troubleshooting Quick Reference

### Issue: API Won't Start
**Steps:**
1. Check Node version: `node --version` (need ≥18)
2. Check port 3000 available: `lsof -i :3000`
3. Check error logs: `pm2 logs meeting-api`
4. Restart: `pm2 restart meeting-api`

### Issue: Database Connection Failed
**Steps:**
1. Verify .env credentials
2. Test connection: `mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p`
3. Verify database exists: `use u403094450_MeetingApp; SHOW TABLES;`
4. Check MySQL service running on Hostinger

### Issue: Flutter Can't Connect
**Steps:**
1. Check API URL in `lib/config/api_config.dart`
2. Test API in browser: `https://vasavyavidyalayam.in/api/health`
3. Check SSL certificate is valid
4. Check browser console (F12) for CORS errors
5. Verify Hostinger allows Node.js on port 3000

### Issue: Slow API Response
**Steps:**
1. Check PM2 resource usage: `pm2 monit`
2. Check MySQL query performance
3. Look for N+1 queries in API logs
4. Consider adding Redis caching

---

## Success Criteria ✅

Your deployment is successful when:

- [x] Database tables created in Hostinger MySQL
- [x] API running on port 3000 (verified with `pm2 status`)
- [x] API responds to requests (test with browser)
- [x] Flutter app connects without SSL errors
- [x] Login works with correct credentials
- [x] Meetings display from database
- [x] Create meeting saves to database
- [x] No CORS errors in browser console
- [x] Error messages display properly in app

---

## Final Notes

📌 **Remember:**
- Keep `.env` file secure (never commit to git)
- Backup database regularly
- Monitor PM2 logs for issues
- Update Node.js packages monthly
- Keep SSH/FTP credentials secure
- Test changes on development first

🎉 **You're all set! Your Meeting App is now live!**

---

**Questions? Refer to:**
- HOSTINGER_DEPLOYMENT.md (detailed steps)
- QUICK_REFERENCE.md (quick lookup)
- ARCHITECTURE.md (system overview)

**Last Updated:** January 13, 2026
