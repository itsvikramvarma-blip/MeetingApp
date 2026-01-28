# MySQL Access Denied Error - Solution

## Error Message
```
MySQL said: Documentation
#1044 - Access denied for user 'u403094450_MeetingApp'@'127.0.0.1' to database 'meeting_app'
```

## What This Means
1. Your API tried to connect as: `u403094450_MeetingApp@127.0.0.1`
2. But database `meeting_app` doesn't exist (it's actually `u403094450_MeetingApp`)
3. OR the database host configuration is wrong

---

## Solution Steps

### Step 1: Verify Database Name ✅
**Already Fixed!** Updated `api/src/db.js` to use correct database name:
```javascript
database: process.env.DB_NAME || 'u403094450_MeetingApp'
```

### Step 2: Check Your Hostinger Database Host

**IMPORTANT:** Hostinger databases may NOT be accessible from `127.0.0.1`

**Find the correct host:**
1. Log in to Hostinger Control Panel
2. Go to **Databases** → **MySQL Databases**
3. Click on your database: `u403094450_MeetingApp`
4. Look for **Host** or **Server** field
5. It might be something like:
   - `mysql.hostinger.com`
   - `[your-username].mysql.hostinger.com`
   - OR it might actually be `vasavyavidyalayam.in`

**If the host is NOT `vasavyavidyalayam.in`, update it:**

Update your `.env` file:
```env
DB_HOST=mysql.hostinger.com  # Replace with your actual Hostinger host
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
```

### Step 3: Test Connection Locally

Before deploying to Hostinger, test the connection on your machine:

```bash
# Test MySQL connection with your credentials
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN -e "SELECT 1"

# Or if host is different:
mysql -h mysql.hostinger.com -u u403094450_MeetingApp -p5~pS4iVJ+*bN -e "SELECT 1"
```

If this works, the credentials are correct!

### Step 4: Verify Database Exists

```bash
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN -e "SHOW DATABASES;"
```

You should see: `u403094450_MeetingApp` in the list

### Step 5: Verify Tables Are Imported

```bash
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN u403094450_MeetingApp -e "SHOW TABLES;"
```

You should see tables like:
- meetings
- meeting_minutes
- users
- tasks
- etc.

---

## If Database Doesn't Exist

**Follow these steps to create it:**

1. Go to Hostinger Control Panel
2. **Databases** → Click "Create New Database"
3. Name: `u403094450_MeetingApp`
4. User: `u403094450_MeetingApp`
5. Password: `5~pS4iVJ+*bN`
6. Click Create
7. Then import the SQL schema

---

## If Tables Are Missing

**Import the database schema:**

1. Go to Hostinger Control Panel → **Databases**
2. Click on your database → **phpMyAdmin**
3. Select database: `u403094450_MeetingApp`
4. Go to **Import** tab
5. Choose file: `db/meeting_app.sql`
6. Click **Import**

---

## Updated Configuration

### Files Already Fixed:
✅ `api/src/db.js` - Now uses correct DB_NAME default
✅ `api/.env` - Has correct database name

### What You May Need to Fix:
❓ `DB_HOST` - Verify this is the correct Hostinger host

---

## Complete Correct Configuration

```env
# api/.env

DB_HOST=vasavyavidyalayam.in    # ← VERIFY THIS IS CORRECT
DB_PORT=3306
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp

JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
PORT=3000
NODE_ENV=production
```

---

## Quick Verification Checklist

- [ ] Database name: `u403094450_MeetingApp` ✅
- [ ] Database user: `u403094450_MeetingApp` ✅
- [ ] Database password: `5~pS4iVJ+*bN` ✅
- [ ] Database host: **VERIFY THIS** (should be in Hostinger panel)
- [ ] Database tables imported (SHOW TABLES shows results)
- [ ] `.env` file updated with correct values
- [ ] `db.js` updated with correct default database name ✅

---

## Test Connection After Updates

After updating configuration, test:

```bash
# From your local machine
cd d:\Vikramvarma\copilot\api

# Test with your credentials
mysql -h vasavyavidyalayam.in -u u403094450_MeetingApp -p5~pS4iVJ+*bN u403094450_MeetingApp -e "SELECT COUNT(*) FROM meetings;"
```

Should return a number (0 or more), not an error.

---

## Common Issues & Solutions

### Issue: "Host is not allowed to connect"
**Solution:** Hostinger only allows certain IP addresses. Check:
1. Hostinger Panel → Database → Host restrictions
2. May need to add your IP or enable remote access

### Issue: "Access denied for user 'root'@'...'
**Solution:** Using wrong username. Must be: `u403094450_MeetingApp`

### Issue: "No database selected"
**Solution:** Use `-u` and `database_name` in command, or check DB_NAME in .env

### Issue: "Connection timeout"
**Solution:** Hostinger host might be wrong. Check in control panel.

---

## Next Steps

1. **Find correct database host** in Hostinger Control Panel
2. **Update `.env`** if host is different
3. **Test connection** with mysql command
4. **Verify tables exist** with SHOW TABLES
5. **Restart API** on Hostinger: `pm2 restart meeting-api`

---

**Status:** 🔴 Waiting for database host verification

After you confirm the correct host from Hostinger, update `.env` and the issue will be resolved!
