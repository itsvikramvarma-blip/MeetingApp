# Meeting App API (Node.js Express)

Minimal Node.js Express API for the Meeting App. It uses MySQL (use the SQL in `db/meeting_app_no_create.sql` or `db/meeting_app.sql`) and provides endpoints for meetings, meeting minutes, and attachments.

## Quick start (Linux server)

1. Copy the `api` folder to your server (e.g. `/var/www/meeting-app-api`).
2. Install Node (>=18) and npm.
3. In the `api` folder, run:

```bash
cp .env.example .env
# edit .env with correct DB credentials and upload dir
npm install
npm run start
```

4. Import the MySQL schema into your database (if you haven't already) using phpMyAdmin or the mysql CLI. If your user cannot create databases, use `db/meeting_app_no_create.sql` and import into an existing database.

5. The API will be available at `http://0.0.0.0:3000` (or the PORT in `.env`).

## Endpoints (minimal)
- GET /api/meetings
- GET /api/meetings/:id
- POST /api/meetings
- PUT /api/meetings/:id
- PATCH /api/meetings/:id/complete
- DELETE /api/meetings/:id
- GET /api/meetings/:id/minutes
- POST /api/meetings/:id/minutes
- POST /api/meetings/:id/attachments (multipart/form-data, field `file`)

## Authentication

This API now includes simple JWT-based authentication. Endpoints under `/api/meetings` are protected and require a valid Bearer token.

Available auth endpoints:
- POST /api/auth/register  { name?, email, password }
- POST /api/auth/login     { email, password } -> returns { token, user }

How to create an initial user:
- Preferred: run the seed helper which will hash the password and insert the user into the DB:

```bash
cp .env.example .env
# edit .env with DB credentials and JWT_SECRET
npm install
node src/seed/create_user.js admin@example.com password123 "Admin User"
```

After creating a user, call `/api/auth/login` to obtain a JWT and send it as an Authorization header for subsequent requests:

Authorization: Bearer <token>

If you prefer SQL-only, see `db/users.sql` (note: password must be a bcrypt hash; prefer using the seed script).

Database migration:
- If you've already imported the main dump (`db/meeting_app.sql`) the API now expects an additional `organizer_id` column on `meetings`.
- Run the migration at `db/migrations/20251110_add_organizer_id.sql` to add `organizer_id`, backfill values from `users` (if present), and add a foreign key.


## Attachments
Files uploaded with `/api/meetings/:id/attachments` are stored in the folder defined by `UPLOAD_DIR` in `.env` (default `uploads`). The DB `meetings.attachments` column stores a JSON array of metadata.

## Production (systemd example)
Create a systemd service unit (example in `deploy/meeting-app.service`) and run under a process manager (systemd or PM2). Make sure to set NODE_ENV=production and a proper reverse proxy (nginx) in front.
