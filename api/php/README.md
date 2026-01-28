# Meeting App PHP API

Minimal PHP API for the Meeting App. Provides JWT auth (register/login) and basic meetings endpoints.

Prerequisites
- PHP 8.0+
- Composer
- MySQL database (use the SQL in `../../db/meeting_app_no_create.sql` or `../../db/meeting_app.sql`)

Install

```bash
cd api/php
composer install
cp .env.example .env
# edit .env with DB and JWT_SECRET values
```

Run (built-in PHP server)

```bash
cd api/php
php -S 0.0.0.0:8080 -t public
```

Endpoints (minimal)
- POST /api/auth/register {name?, email, password}
- POST /api/auth/login {email, password} -> {token, user}
- GET /api/meetings (requires Authorization: Bearer <token>)
- POST /api/meetings (JSON, requires auth)
- GET /api/meetings/{id}
- PUT /api/meetings/{id}
- DELETE /api/meetings/{id}

Notes
- This is a minimal scaffold. For production use, run behind nginx/apache, use HTTPS, and harden configuration.
