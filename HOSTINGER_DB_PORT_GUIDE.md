# How to Find Database Port in Hostinger

## Step-by-Step Guide

### Method 1: Via Hostinger Control Panel (Easiest)

1. **Log in to Hostinger Control Panel**
   - Go to: https://hpanel.hostinger.com
   - Login with your credentials

2. **Navigate to Databases**
   - Click on **Databases** in the left sidebar
   - Or look for **MySQL Databases** option

3. **Find Your Database**
   - Look for your database: `u403094450_MeetingApp`
   - Click on it or the info icon next to it

4. **View Connection Details**
   - You'll see a panel with:
     - **Host**: vasavyavidyalayam.in
     - **Port**: Usually **3306** (default MySQL port)
     - **Username**: u403094450_MeetingApp
     - **Password**: (your database password)
     - **Database Name**: u403094450_MeetingApp

---

## Method 2: Via phpMyAdmin

1. **Go to Hostinger Control Panel**
   - Databases section

2. **Click "Manage" or phpMyAdmin**
   - Opens phpMyAdmin interface

3. **Look at the URL**
   - The URL structure shows: `/phpmyadmin/`
   - Connected to the default port (3306)

4. **Or check Server Info**
   - In phpMyAdmin, go to **Server** tab
   - Shows connection details including port

---

## Method 3: Via SSH (Command Line)

```bash
# SSH into your Hostinger server
ssh u403094450@vasavyavidyalayam.in

# Check MySQL port (usually 3306)
sudo netstat -tlnp | grep mysql

# Or check MySQL configuration
cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep port
```

**Output should show:**
```
port            = 3306
```

---

## Your Current Configuration

### What You Already Have
```env
DB_HOST=vasavyavidyalayam.in
DB_PORT=3306                    ← This is the port
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp
```

---

## Common Database Ports

| Database | Default Port | Status |
|----------|--------------|--------|
| MySQL | **3306** | ✅ Standard (Hostinger uses this) |
| PostgreSQL | 5432 | Not applicable |
| MongoDB | 27017 | Not applicable |
| MariaDB | 3306 | Same as MySQL |

**Hostinger uses MySQL with port 3306 by default**

---

## How to Verify Your Port Connection

### Test Connection Locally

```bash
# Test if you can connect to Hostinger MySQL
mysql -h vasavyavidyalayam.in -P 3306 -u u403094450_MeetingApp -p5~pS4iVJ+*bN

# Or specify port explicitly
mysql --host=vasavyavidyalayam.in --port=3306 --user=u403094450_MeetingApp --password=5~pS4iVJ+*bN
```

**If connection works, you'll see:**
```
Welcome to the MySQL monitor. Commands end with ; or \g.
```

### Test with PHP

```php
<?php
$connection = new mysqli(
    "vasavyavidyalayam.in",    // Host
    "u403094450_MeetingApp",   // User
    "5~pS4iVJ+*bN",           // Password
    "u403094450_MeetingApp",   // Database
    3306                        // Port
);

if ($connection->connect_error) {
    echo "Connection failed: " . $connection->connect_error;
} else {
    echo "Connected successfully on port 3306!";
}
?>
```

### Test with Node.js

```javascript
const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: 'vasavyavidyalayam.in',
    port: 3306,                    // Port here
    user: 'u403094450_MeetingApp',
    password: '5~pS4iVJ+*bN',
    database: 'u403094450_MeetingApp'
});

connection.connect(function(err) {
    if (err) {
        console.error('Connection error: ' + err.stack);
        return;
    }
    console.log('Connected on port 3306!');
});
```

---

## Troubleshooting

### If Port is Different

**Check these locations:**

1. **Hostinger Control Panel → Databases**
   - Look for "Connection Details" or "Server Info"
   - Check the exact port number

2. **Check if Firewall is Blocking**
   - Hostinger Control Panel → Security
   - Ensure port 3306 is not blocked

3. **Check if Remote Access is Enabled**
   - Hostinger Control Panel → Databases
   - Look for "Host Restrictions" or "Remote Access"
   - May need to add your IP address

### Common Issues

| Problem | Solution |
|---------|----------|
| Connection timeout | Verify port is accessible from your network |
| Permission denied | Check username/password and host |
| Host not found | Verify hostname: vasavyavidyalayam.in |
| Port not responding | Check firewall settings in Hostinger |

---

## Your Configuration Summary

```
Connection Details:
├─ Host: vasavyavidyalayam.in
├─ Port: 3306 ← This is what you need
├─ User: u403094450_MeetingApp
├─ Password: 5~pS4iVJ+*bN
└─ Database: u403094450_MeetingApp

All configured in:
├─ api/.env (Node.js)
├─ api/php/.env (PHP)
└─ Automatically used by APIs
```

---

## Quick Answer

**The database port is: `3306`**

This is the standard MySQL port that Hostinger uses for all databases. It's already configured in your `.env` files:

```env
DB_PORT=3306
```

You don't need to change it unless Hostinger specifically assigned you a different port (which would be shown in your Hostinger Control Panel under Databases).

---

## Next Steps

1. ✅ Verify port is 3306 in Hostinger Control Panel
2. ✅ Test connection with mysql command
3. ✅ If it works, your API is ready to deploy!

