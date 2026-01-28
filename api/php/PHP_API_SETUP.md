# PHP API Setup & Deployment Guide

## Quick Start (Local Development)

### 1. Install Dependencies
```bash
cd api/php
composer install
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` with your Hostinger database credentials:
```env
DB_HOST=vasavyavidyalayam.in
DB_PORT=3306
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
JWT_EXPIRY=3600
```

### 3. Run the API
```bash
php -S 0.0.0.0:8080 -t public
```

API is now available at: `http://localhost:8080/api`

### 4. Test the API
```bash
# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Get token from response, then:
# List meetings (replace TOKEN)
curl -H "Authorization: Bearer TOKEN" http://localhost:8080/api/meetings
```

---

## Deploy to Hostinger

### Option 1: FTP Upload (Simple)

1. **Upload files via FTP:**
   - Connect to FTP: `ftp.vasavyavidyalayam.in`
   - User: `u403094450`
   - Upload entire `api/php` folder to `/public_html/api/php`

2. **Set permissions:**
   ```bash
   chmod 755 public
   chmod 644 public/index.php
   chmod 644 public/.htaccess
   ```

3. **Test:**
   ```
   https://vasavyavidyalayam.in/api/php/health
   ```

### Option 2: SSH Upload + Install (Recommended)

```bash
# 1. SSH into server
ssh u403094450@vasavyavidyalayam.in

# 2. Navigate to web root
cd ~/public_html

# 3. Clone or upload your repo
git clone <your-repo-url> api-php
cd api-php/api/php

# 4. Install composer dependencies
composer install --no-dev

# 5. Copy env file
cp .env.example .env

# 6. Edit .env with database credentials
nano .env

# 7. Set permissions
chmod 755 public
chmod 644 public/.htaccess

# 8. Test
curl https://vasavyavidyalayam.in/api-php/api/health
```

### Option 3: Using Hostinger File Manager

1. Log in to Hostinger Control Panel
2. Go to File Manager
3. Navigate to `public_html`
4. Extract uploaded `api-php.zip`
5. Create `.env` file with your configuration

---

## Configure Apache Virtual Host

If using Apache, ensure `.htaccess` is enabled and has this content:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /api/php/
    
    # Remove index.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php/$1 [L]
</IfModule>
```

File: `api/php/public/.htaccess` (already included)

---

## Configure Nginx Virtual Host

If using Nginx, add to server config:

```nginx
server {
    listen 443 ssl http2;
    server_name vasavyavidyalayam.in;
    root /home/u403094450/public_html/api/php/public;
    
    ssl_certificate /path/to/certificate;
    ssl_certificate_key /path/to/key;
    
    # Enable GZIP
    gzip on;
    gzip_types application/json;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
    
    # Deny access to sensitive files
    location ~ /\.env {
        deny all;
    }
    location ~ /composer.json {
        deny all;
    }
}
```

---

## Environment Variables Explained

| Variable | Example | Purpose |
|----------|---------|---------|
| `DB_HOST` | `vasavyavidyalayam.in` | Database server address |
| `DB_PORT` | `3306` | MySQL port |
| `DB_USER` | `u403094450_MeetingApp` | Database username |
| `DB_PASSWORD` | `5~pS4iVJ+*bN` | Database password |
| `DB_NAME` | `u403094450_MeetingApp` | Database name |
| `JWT_SECRET` | `K9r7b3fXyZp!qL1sV2mN` | Secret for signing tokens |
| `JWT_EXPIRY` | `3600` | Token expiry in seconds |

---

## Verify Installation

Test all endpoints:

```bash
# 1. Health check
curl https://vasavyavidyalayam.in/api/php/api/health

# 2. Register user
TOKEN_RESPONSE=$(curl -X POST https://vasavyavidyalayam.in/api/php/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Admin","email":"admin@example.com","password":"admin123"}')

# 3. Login
LOGIN=$(curl -X POST https://vasavyavidyalayam.in/api/php/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

# Extract token (parse JSON)
TOKEN=$(echo $LOGIN | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

# 4. Test meetings endpoint
curl -H "Authorization: Bearer $TOKEN" https://vasavyavidyalayam.in/api/php/api/meetings

# 5. Test other endpoints
curl -H "Authorization: Bearer $TOKEN" https://vasavyavidyalayam.in/api/php/api/tasks
curl -H "Authorization: Bearer $TOKEN" https://vasavyavidyalayam.in/api/php/api/users/profile
```

---

## Troubleshooting

### Issue: "Missing database" error
**Solution:** Ensure database `u403094450_MeetingApp` exists and tables are imported

### Issue: "Invalid token" error
**Solution:** 
- Check `JWT_SECRET` in `.env` matches on all servers
- Verify token hasn't expired
- Ensure Bearer token format is correct

### Issue: 404 on endpoints
**Solution:**
- Check `.htaccess` is enabled (Apache)
- Verify `mod_rewrite` is enabled
- Check document root points to `public` folder

### Issue: Connection refused
**Solution:**
- Check Hostinger firewall allows port 3306 for database
- Verify database host is accessible from your IP
- Test: `mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p`

### Issue: CORS errors
**Solution:** Add CORS headers in `public/index.php`:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

---

## Comparison: Node.js vs PHP API

| Aspect | Node.js API | PHP API |
|--------|-----------|----------|
| **File** | `api/src/server.js` | `api/php/public/index.php` |
| **Port** | 3000 | 80/443 (Apache/Nginx) |
| **Process Manager** | PM2 | Built into web server |
| **Setup** | `npm install` | `composer install` |
| **Performance** | Faster for async | Good for CRUD |
| **Best for** | Real-time features | Traditional REST API |
| **Scaling** | Horizontal | Vertical (easier) |

---

## Next Steps

1. ✅ Upload PHP files to Hostinger
2. ✅ Install dependencies via composer
3. ✅ Configure `.env` file
4. ✅ Test API endpoints
5. Update Flutter app to use PHP API instead of Node.js:
   - Update `API_BASE_URL` in `lib/config/api_config.dart`
   - Point to: `https://vasavyavidyalayam.in/api/php/api`

---

## File Locations

**Local:** `d:\Vikramvarma\copilot\api\php`

**Hostinger:** `/home/u403094450/public_html/api/php`

**API URL:** `https://vasavyavidyalayam.in/api/php/api`

---

## Support

For issues, check:
- `API_DOCUMENTATION.md` - Endpoint reference
- `.env.example` - Configuration template
- `src/helpers.php` - Utility functions
- `routes.php` - Routing logic

