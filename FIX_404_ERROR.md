# Fixing 404 Error - Complete Guide

## The Problem
Your Flutter app is getting a **404 Not Found** error when trying to reach the API at `https://www.vasavyavidyalayam.in/meeting_api`

---

## Root Cause Analysis

A 404 error means one of these:

| Issue | How to Check | Fix |
|-------|-------------|-----|
| **API folder not uploaded** | SSH to server, check `public_html/` | Upload `api/php/` folder |
| **Wrong folder path** | Check actual server path | Update API base URL |
| **.htaccess missing/broken** | Check `meeting_api/.htaccess` exists | Create/fix `.htaccess` |
| **Rewrite rules disabled** | Ask hosting support | Enable mod_rewrite |
| **Database issue** | Check error logs | Import database schema |

---

## Quick Fix Guide (5 Minutes)

### Step 1: Check Server Access
```bash
# Test if domain works
curl https://www.vasavyavidyalayam.in/

# If you get a website/response: ✅ Domain works
# If you get Connection refused: ❌ Server down
```

### Step 2: Check API Folder Location
```bash
# SSH to server
ssh u403094450@vasavyavidyalayam.in

# Check what's in public_html
ls -la ~/public_html/

# Look for "meeting_api" folder
# If it doesn't exist: UPLOAD IT

# If it exists, check contents
ls -la ~/public_html/meeting_api/

# Should see: public/, src/, routes.php, .htaccess, etc.
```

### Step 3: Verify .htaccess Exists
```bash
# Check if .htaccess exists
cat ~/public_html/meeting_api/.htaccess

# Should contain rewrite rules
# If missing, create it with content below
```

### Step 4: Test API
```bash
# Test if API responds
curl -i https://www.vasavyavidyalayam.in/meeting_api/

# Expected responses:
# - 200 OK (with JSON)
# - 404 (API not found) - means folder missing
# - 403 Forbidden - means permissions issue
# - 500 Internal Error - means code/database issue
```

---

## The .htaccess File

Create `public_html/meeting_api/.htaccess` with this content:

```apache
RewriteEngine On
RewriteBase /meeting_api/

# Remove index.php from URL
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php/$1 [L]

# Allow direct file access
<FilesMatch "\.(jpg|jpeg|png|gif|ico|css|js)$">
    Allow from all
</FilesMatch>
```

---

## Complete Deployment Steps

If API folder is missing, follow these steps:

### Via FTP/SFTP (Hostinger File Manager):

1. **Create folder**: `public_html/meeting_api/`

2. **Upload files** from `d:\Vikramvarma\copilot\api\php\`:
   ```
   api/php/
   ├── public/
   │   └── index.php
   ├── src/
   │   ├── AuthController.php
   │   ├── MeetingsController.php
   │   └── ... (all controllers)
   ├── routes.php
   ├── composer.json
   └── .htaccess
   ```

3. **Create .htaccess** with content above

4. **Set permissions**: 755 for folders, 644 for files

5. **Test**: Visit `https://www.vasavyavidyalayam.in/meeting_api/`

### Via SSH (Command Line):

```bash
# SSH to server
ssh u403094450@vasavyavidyalayam.in

# Create directory
mkdir -p ~/public_html/meeting_api

# Upload files (from local machine, not from server)
# Use SCP or SFTP to upload api/php/* files

# After files are uploaded to server:
cd ~/public_html/meeting_api

# Install dependencies
composer install

# Set permissions
chmod -R 755 .
chmod 644 .htaccess

# Test
curl https://www.vasavyavidyalayam.in/meeting_api/
```

---

## Alternative: Try Different Paths

If `/meeting_api` doesn't work, try these alternatives:

### Option 1: Deploy to Root
```dart
// In lib/config/api_config.dart
static const String baseUrl = 'https://www.vasavyavidyalayam.in';
```

Upload PHP files directly to `public_html/` instead of `public_html/meeting_api/`

### Option 2: Use Subdomain
```dart
// In lib/config/api_config.dart
static const String baseUrl = 'https://api.vasavyavidyalayam.in';
```

Create subdomain `api.vasavyavidyalayam.in` in Hostinger panel pointing to `public_html/api/`

### Option 3: Use Node.js API
```dart
// In lib/config/api_config.dart
static const String baseUrl = 'https://www.vasavyavidyalayam.in/api';
```

Deploy Node.js version from `api/src/` instead of PHP

---

## Debugging Checklist

Run these commands and share results:

```bash
# 1. Can you reach the domain?
curl -i https://www.vasavyavidyalayam.in/

# 2. Check server folder structure
ssh u403094450@vasavyavidyalayam.in
ls -la ~/public_html/
ls -la ~/public_html/meeting_api/

# 3. Check .htaccess
cat ~/public_html/meeting_api/.htaccess

# 4. Check error logs
tail -f ~/logs/error.log
tail -f ../error.log

# 5. Test API directly
curl -i https://www.vasavyavidyalayam.in/meeting_api/
curl -i https://www.vasavyavidyalayam.in/meeting_api/auth/login

# 6. Check permissions
ls -la ~/public_html/meeting_api/public/
```

---

## Common Errors & Solutions

### Error 1: `404 Not Found`
**Cause**: API folder missing or wrong path
**Solution**: 
- Upload `api/php/` to `public_html/meeting_api/`
- Or update API base URL if folder is elsewhere

### Error 2: `403 Forbidden`
**Cause**: File permissions too restrictive
**Solution**: 
```bash
chmod -R 755 ~/public_html/meeting_api/
chmod 644 ~/public_html/meeting_api/.htaccess
chmod 644 ~/public_html/meeting_api/routes.php
```

### Error 3: `500 Internal Server Error`
**Cause**: PHP error or database issue
**Solution**:
```bash
# Check error log
tail -f ~/logs/error.log

# Verify database connection in .env
cat ~/public_html/meeting_api/.env

# Check if database exists
mysql -u u403094450_MeetingApp -p
SHOW DATABASES;
USE u403094450_MeetingApp;
SHOW TABLES;
```

### Error 4: `Connection timeout`
**Cause**: Server not responding or firewall issue
**Solution**:
- Check if domain is up: ping vasavyavidyalayam.in
- Contact Hostinger support if domain is down

---

## Next Steps

1. **SSH to server** and verify folder structure
2. **Upload PHP files** if missing
3. **Create/fix .htaccess** file
4. **Test with curl** from command line
5. **Check error logs** for detailed errors
6. **Update Flutter app** with correct base URL

Once API is responding with correct HTTP status (200, 401, etc instead of 404):
- Login should work ✅
- Meetings should load ✅
- All app features will function ✅

---

## Support

If you're still getting 404 after these steps:

1. Check Hostinger control panel:
   - Verify domain DNS points to server
   - Check file manager for `public_html/meeting_api/`
   - Enable mod_rewrite if available

2. Use diagnostic script:
   ```dart
   // Add to lib/main.dart
   await APIDiagnostics.runDiagnostics();
   ```

3. Share results of:
   ```bash
   curl -i https://www.vasavyavidyalayam.in/meeting_api/
   ssh u403094450@vasavyavidyalayam.in
   ls -la ~/public_html/
   cat ~/logs/error.log
   ```
