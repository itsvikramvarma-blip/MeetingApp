-- Seed a dummy user for the Meeting App API
-- Replace <BCRYPT_HASH_HERE> with a bcrypt hash of your chosen password (example: "password123").
-- You can generate the hash locally with the Node one-liner shown below.

-- Example: after generating HASH replace and run this SQL in your database:
-- INSERT INTO users (name, email, password, role, created_at) VALUES ('Dummy User','dummy@example.com','<BCRYPT_HASH_HERE>','user', NOW());

-- To generate a bcrypt hash locally (from the repo root):
-- PowerShell:
-- cd d:\Vikramvarma\copilot\api
-- node -e "const b=require('bcryptjs'); b.hash('password123',10).then(h=>console.log(h)).catch(e=>console.error(e))"

-- After replacing <BCRYPT_HASH_HERE> run (example):
-- mysql -u u403094450_MeetingApp -p -h 127.0.0.1 u403094450_MeetingApp < db/seed_dummy_user.sql

-- The SQL below is a template; replace the placeholder before running.
INSERT INTO users (name, email, password, role, created_at) VALUES ('Dummy User','dummy@example.com','$2a$10$I8Y3A97unNVQR4I.lrqgteOg7BQdGfQgXzUfe3T4aqnDWC51amxh6','user', NOW());
