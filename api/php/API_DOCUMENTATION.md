# Meeting App PHP API - Complete Documentation

## Overview
This is a complete PHP API for the Meeting App built with:
- **Framework**: Vanilla PHP with custom routing
- **Database**: MySQL with PDO
- **Authentication**: JWT tokens (Firebase/JWT)
- **Features**: Meetings, Tasks, Meeting Minutes, Action Items, Decisions, User Management

---

## Setup

### Prerequisites
- PHP 8.0+
- Composer
- MySQL database

### Installation

```bash
cd api/php

# Install dependencies
composer install

# Copy and configure environment
cp .env.example .env
# Edit .env with your database credentials
```

### Running the API

**Development (Using PHP Built-in Server):**
```bash
php -S 0.0.0.0:8080 -t public
# API available at http://localhost:8080/api
```

**Production (Using Apache/Nginx):**
- Point document root to `api/php/public`
- Ensure `.htaccess` is enabled (Apache)
- Use HTTPS only

---

## Authentication

### Register User
**POST** `/api/auth/register`

Request:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword123"
}
```

Response (201):
```json
{
  "id": "12345",
  "email": "john@example.com"
}
```

### Login
**POST** `/api/auth/login`

Request:
```json
{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

Response (200):
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "12345",
    "email": "john@example.com",
    "name": "John Doe",
    "exp": 1705776000
  }
}
```

### Using Token
All protected endpoints require:
```
Authorization: Bearer <token>
```

---

## User Management

### Get Current User Profile
**GET** `/api/users/profile`

Response (200):
```json
{
  "id": "12345",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user",
  "created_at": "2025-01-13 10:00:00"
}
```

### Update Profile
**PUT** `/api/users/profile`

Request:
```json
{
  "name": "John Updated"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Profile updated"
}
```

### Change Password
**POST** `/api/users/change-password`

Request:
```json
{
  "old_password": "oldpass123",
  "new_password": "newpass456"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Password changed"
}
```

### List All Users
**GET** `/api/users`

Response (200):
```json
[
  {
    "id": "12345",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "created_at": "2025-01-13 10:00:00"
  },
  ...
]
```

### Get User by ID
**GET** `/api/users/{id}`

Response (200):
```json
{
  "id": "12345",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user",
  "created_at": "2025-01-13 10:00:00"
}
```

---

## Meetings

### List All Meetings
**GET** `/api/meetings`

Response (200):
```json
[
  {
    "id": "meeting1",
    "title": "Weekly Sync",
    "description": "Team sync-up",
    "start_time": "2025-09-20 10:00:00",
    "end_time": "2025-09-20 10:30:00",
    "organizer": "john@example.com",
    "participants": "[\"john@example.com\", \"jane@example.com\"]",
    "meeting_room": "Conference Room A",
    "status": "scheduled"
  },
  ...
]
```

### Create Meeting
**POST** `/api/meetings`

Request:
```json
{
  "title": "Team Meeting",
  "description": "Quarterly review",
  "start_time": "2025-09-25 14:00:00",
  "end_time": "2025-09-25 15:00:00",
  "organizer": "john@example.com",
  "participants": ["john@example.com", "jane@example.com"],
  "meeting_room": "Conference Room A",
  "agenda": ["Review", "Planning"]
}
```

Response (201):
```json
{
  "id": "meeting123",
  "message": "Meeting created"
}
```

### Get Meeting
**GET** `/api/meetings/{id}`

Response (200):
```json
{
  "id": "meeting1",
  "title": "Weekly Sync",
  "description": "Team sync-up",
  "start_time": "2025-09-20 10:00:00",
  "end_time": "2025-09-20 10:30:00",
  "organizer": "john@example.com",
  "participants": "[\"john@example.com\", \"jane@example.com\"]",
  "meeting_room": "Conference Room A",
  "status": "scheduled",
  "created_at": "2025-01-13 10:00:00",
  "updated_at": "2025-01-13 10:00:00"
}
```

### Update Meeting
**PUT** `/api/meetings/{id}`

Request:
```json
{
  "status": "inProgress",
  "title": "Updated Title"
}
```

Response (200):
```json
{
  "success": true
}
```

### Delete Meeting
**DELETE** `/api/meetings/{id}`

Response (200):
```json
{
  "success": true,
  "message": "Meeting deleted"
}
```

---

## Tasks

### List All Tasks
**GET** `/api/tasks`

Response (200):
```json
[
  {
    "id": "task1",
    "title": "Prepare slides",
    "description": "Prepare presentation slides",
    "due_date": "2025-09-25",
    "priority": "high",
    "status": "pending",
    "assigned_to": "john@example.com",
    "assigned_by": "admin@example.com",
    "created_at": "2025-01-13 10:00:00"
  },
  ...
]
```

### Create Task
**POST** `/api/tasks`

Request:
```json
{
  "title": "Review proposal",
  "description": "Review client proposal",
  "due_date": "2025-09-20",
  "priority": "high",
  "assigned_to": "jane@example.com",
  "meeting_id": "meeting1"
}
```

Response (201):
```json
{
  "id": "task123",
  "message": "Task created"
}
```

### Update Task
**PUT** `/api/tasks/{id}`

Request:
```json
{
  "status": "completed",
  "priority": "medium"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Task updated"
}
```

### Delete Task
**DELETE** `/api/tasks/{id}`

Response (200):
```json
{
  "success": true,
  "message": "Task deleted"
}
```

---

## Meeting Minutes

### List Minutes by Meeting
**GET** `/api/meeting-minutes?meeting_id={meetingId}`

Response (200):
```json
[
  {
    "id": "minutes1",
    "meeting_id": "meeting1",
    "created_at": "2025-09-20 10:30:00",
    "created_by": "john@example.com",
    "discussion_points": "[\"Point 1\", \"Point 2\"]",
    "general_notes": "Good discussion"
  },
  ...
]
```

### Create Meeting Minutes
**POST** `/api/meeting-minutes`

Request:
```json
{
  "meeting_id": "meeting1",
  "created_by": "john@example.com",
  "discussion_points": ["Q1 Results", "Q2 Planning", "Team Updates"],
  "general_notes": "Very productive meeting",
  "attendee_notes": "Jane was late"
}
```

Response (201):
```json
{
  "id": "minutes123",
  "message": "Meeting minutes created"
}
```

### Get Meeting Minutes
**GET** `/api/meeting-minutes/{id}`

Response (200):
```json
{
  "id": "minutes1",
  "meeting_id": "meeting1",
  "created_at": "2025-09-20 10:30:00",
  "created_by": "john@example.com",
  "discussion_points": ["Point 1", "Point 2"],
  "general_notes": "Good discussion",
  "attendee_notes": null
}
```

### Update Meeting Minutes
**PUT** `/api/meeting-minutes/{id}`

Request:
```json
{
  "general_notes": "Updated notes",
  "discussion_points": ["Updated Point 1", "Updated Point 2"]
}
```

Response (200):
```json
{
  "success": true,
  "message": "Meeting minutes updated"
}
```

### Delete Meeting Minutes
**DELETE** `/api/meeting-minutes/{id}`

Response (200):
```json
{
  "success": true,
  "message": "Meeting minutes deleted"
}
```

---

## Action Items

### List Action Items by Minutes
**GET** `/api/action-items?minutes_id={minutesId}`

Response (200):
```json
[
  {
    "id": "action1",
    "meeting_minutes_id": "minutes1",
    "description": "Send report",
    "details": "Send Q1 report to stakeholders",
    "assigned_to": "jane@example.com",
    "due_date": "2025-09-27",
    "status": "pending",
    "priority": "high",
    "created_at": "2025-01-13 10:00:00"
  },
  ...
]
```

### Create Action Item
**POST** `/api/action-items`

Request:
```json
{
  "meeting_minutes_id": "minutes1",
  "description": "Follow up with client",
  "assigned_to": "john@example.com",
  "due_date": "2025-09-22",
  "priority": "high"
}
```

Response (201):
```json
{
  "id": "action123",
  "message": "Action item created"
}
```

### Update Action Item
**PUT** `/api/action-items/{id}`

Request:
```json
{
  "status": "completed",
  "priority": "medium"
}
```

Response (200):
```json
{
  "success": true,
  "message": "Action item updated"
}
```

### Delete Action Item
**DELETE** `/api/action-items/{id}`

Response (200):
```json
{
  "success": true,
  "message": "Action item deleted"
}
```

---

## Decisions

### List Decisions by Minutes
**GET** `/api/decisions?minutes_id={minutesId}`

Response (200):
```json
[
  {
    "id": "decision1",
    "meeting_minutes_id": "minutes1",
    "description": "Approved new strategy",
    "details": "Moving forward with Q4 strategy",
    "stakeholders": "[\"john@example.com\", \"jane@example.com\"]",
    "created_at": "2025-01-13 10:00:00"
  },
  ...
]
```

### Create Decision
**POST** `/api/decisions`

Request:
```json
{
  "meeting_minutes_id": "minutes1",
  "description": "Budget approved",
  "details": "$50,000 approved for Q2",
  "stakeholders": ["john@example.com", "finance@example.com"]
}
```

Response (201):
```json
{
  "id": "decision123",
  "message": "Decision created"
}
```

### Update Decision
**PUT** `/api/decisions/{id}`

Request:
```json
{
  "description": "Updated decision",
  "stakeholders": ["john@example.com", "jane@example.com"]
}
```

Response (200):
```json
{
  "success": true,
  "message": "Decision updated"
}
```

### Delete Decision
**DELETE** `/api/decisions/{id}`

Response (200):
```json
{
  "success": true,
  "message": "Decision deleted"
}
```

---

## Health Check

### Check API Status
**GET** `/api/health`

Response (200):
```json
{
  "status": "OK",
  "timestamp": "2025-01-13 10:00:00"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required field"
}
```

### 401 Unauthorized
```json
{
  "error": "Missing token"
}
```

### 404 Not Found
```json
{
  "error": "Not found"
}
```

### 409 Conflict
```json
{
  "error": "User exists"
}
```

### 500 Server Error
```json
{
  "error": "Database error"
}
```

---

## Environment Configuration (.env)

```env
# Database
DB_HOST=vasavyavidyalayam.in
DB_PORT=3306
DB_USER=u403094450_MeetingApp
DB_PASSWORD=5~pS4iVJ+*bN
DB_NAME=u403094450_MeetingApp

# JWT
JWT_SECRET=K9r7b3fXyZp!qL1sV2mN
JWT_EXPIRY=3600

# API
PORT=8080
DEBUG=false
```

---

## File Structure

```
api/php/
├── public/
│   ├── index.php          ← Entry point
│   └── .htaccess
├── src/
│   ├── Database.php       ← DB connection
│   ├── helpers.php        ← Utility functions
│   ├── AuthController.php
│   ├── MeetingsController.php
│   ├── TasksController.php
│   ├── MeetingMinutesController.php
│   ├── ActionItemsController.php
│   ├── DecisionsController.php
│   └── UsersController.php
├── routes.php             ← Routing logic
├── composer.json
├── .env
└── .env.example
```

---

## Usage Examples

### Using cURL

**Login:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"pass123"}'
```

**Create Meeting:**
```bash
curl -X POST http://localhost:8080/api/meetings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title":"Team Meeting",
    "start_time":"2025-09-25 14:00:00",
    "end_time":"2025-09-25 15:00:00"
  }'
```

**Get Meetings:**
```bash
curl -X GET http://localhost:8080/api/meetings \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Production Deployment

### Using Apache

1. Copy all files to document root
2. Ensure `.htaccess` is enabled
3. Configure virtual host to point to `public/` directory
4. Enable mod_rewrite

### Using Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name vasavyavidyalayam.in;
    root /home/u403094450/public_html/api/php/public;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

---

## Security Notes

- Always use HTTPS in production
- Store JWT_SECRET securely
- Validate all input data
- Use prepared statements (already done)
- Implement rate limiting
- Add CORS headers as needed
- Keep dependencies updated

