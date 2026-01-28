-- Migration: add organizer_id FK to meetings
-- Run this against your database after importing the main schema.

ALTER TABLE `meetings` 
  ADD COLUMN `organizer_id` INT NULL AFTER `organizer`;

-- If you already have a users table, backfill organizer_id by matching emails
-- This will set organizer_id where users.email matches meetings.organizer
UPDATE `meetings` m
  JOIN `users` u ON u.email = m.organizer
  SET m.organizer_id = u.id
  WHERE u.id IS NOT NULL;

-- Add foreign key constraint if users table exists
ALTER TABLE `meetings`
  ADD CONSTRAINT `fk_meetings_users` FOREIGN KEY (`organizer_id`) REFERENCES `users`(`id`) ON DELETE SET NULL;
