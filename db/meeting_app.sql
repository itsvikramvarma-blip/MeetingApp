-- Meeting App SQL dump
-- Database: meeting_app
-- Created for phpMyAdmin import

CREATE DATABASE IF NOT EXISTS `meeting_app` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `meeting_app`;

-- Table structure for table `meetings`
DROP TABLE IF EXISTS `meetings`;
CREATE TABLE `meetings` (
  `id` VARCHAR(50) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `organizer` VARCHAR(255) NOT NULL,
  `participants` TEXT, -- JSON array stored as text
  `meeting_room` VARCHAR(255),
  `meeting_link` VARCHAR(255),
  `status` ENUM('scheduled','inProgress','completed','cancelled','pending') NOT NULL DEFAULT 'scheduled',
  `agenda` TEXT, -- JSON array stored as text
  `attachments` TEXT, -- JSON array stored as text
  `notes` TEXT,
  `is_recurring` TINYINT(1) DEFAULT 0,
  `recurrence_pattern` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `meeting_minutes`
DROP TABLE IF EXISTS `meeting_minutes`;
CREATE TABLE `meeting_minutes` (
  `id` VARCHAR(50) NOT NULL,
  `meeting_id` VARCHAR(50) NOT NULL,
  `created_at` DATETIME NOT NULL,
  `last_updated_at` DATETIME,
  `created_by` VARCHAR(255) NOT NULL,
  `discussion_points` TEXT, -- JSON array stored as text
  `general_notes` TEXT,
  `attendee_notes` TEXT,
  PRIMARY KEY (`id`),
  KEY `fk_minutes_meeting` (`meeting_id`),
  CONSTRAINT `fk_minutes_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `decisions`
DROP TABLE IF EXISTS `decisions`;
CREATE TABLE `decisions` (
  `id` VARCHAR(50) NOT NULL,
  `meeting_minutes_id` VARCHAR(50) NOT NULL,
  `description` TEXT NOT NULL,
  `details` TEXT,
  `stakeholders` TEXT, -- JSON array stored as text
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_decisions_minutes` (`meeting_minutes_id`),
  CONSTRAINT `fk_decisions_minutes` FOREIGN KEY (`meeting_minutes_id`) REFERENCES `meeting_minutes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `action_items`
DROP TABLE IF EXISTS `action_items`;
CREATE TABLE `action_items` (
  `id` VARCHAR(50) NOT NULL,
  `meeting_minutes_id` VARCHAR(50) NOT NULL,
  `description` TEXT NOT NULL,
  `details` TEXT,
  `assigned_to` VARCHAR(255),
  `due_date` DATE,
  `status` ENUM('pending','in_progress','completed','blocked') DEFAULT 'pending',
  `priority` ENUM('low','medium','high') DEFAULT 'medium',
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_action_minutes` (`meeting_minutes_id`),
  CONSTRAINT `fk_action_minutes` FOREIGN KEY (`meeting_minutes_id`) REFERENCES `meeting_minutes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table structure for table `tasks` (app tasks, not necessarily meeting minutes action items)
DROP TABLE IF EXISTS `tasks`;
CREATE TABLE `tasks` (
  `id` VARCHAR(50) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `due_date` DATE,
  `priority` ENUM('low','medium','high') DEFAULT 'medium',
  `status` ENUM('pending','in_progress','completed') DEFAULT 'pending',
  `assigned_to` VARCHAR(255),
  `assigned_by` VARCHAR(255),
  `meeting_id` VARCHAR(50),
  `attachments` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `completed_at` DATETIME,
  PRIMARY KEY (`id`),
  KEY `fk_tasks_meeting` (`meeting_id`),
  CONSTRAINT `fk_tasks_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data: meetings
INSERT INTO `meetings` (`id`, `title`, `description`, `start_time`, `end_time`, `organizer`, `participants`, `meeting_room`, `status`, `agenda`, `attachments`, `notes`, `is_recurring`) VALUES
('1', 'Weekly Sync', 'Team weekly sync-up', '2025-09-20 10:00:00', '2025-09-20 10:30:00', 'jane.smith@company.com', '["jane.smith@company.com","dev1@company.com"]', 'Conference Room A', 'scheduled', '["Updates","Blockers"]', '[]', 'No notes', 0),
('2', 'Client Review Meeting', 'Quarterly business review with key client', '2025-09-22 14:00:00', '2025-09-22 15:30:00', 'jane.smith@company.com', '["jane.smith@company.com","client@customer.com","manager@company.com","sales@company.com"]', 'Executive Boardroom', 'completed', '["Project status update","Budget review","Next quarter planning","Q&A session"]', '[]', 'Client is pleased with progress', 0),
('3', 'Project Planning Session', 'Planning session for the new mobile app project', '2025-09-22 16:30:00', '2025-09-22 18:00:00', 'mike.wilson@company.com', '["mike.wilson@company.com","dev1@company.com","dev2@company.com","designer@company.com","pm@company.com"]', 'Conference Room B', 'scheduled', '["Requirements review","Technical architecture","Timeline estimation"]', '[]', NULL, 0);

-- Sample meeting minutes for meeting id '2'
INSERT INTO `meeting_minutes` (`id`, `meeting_id`, `created_at`, `last_updated_at`, `created_by`, `discussion_points`, `general_notes`) VALUES
('mm-2','2','2025-09-23 10:00:00','2025-09-23 10:00:00','jane.smith@company.com','["Reviewed Q3 project deliverables and milestones","Client expressed satisfaction with current progress","Discussed budget utilization and remaining allocation","Identified opportunities for Q4 expansion","Addressed client concerns about timeline delays"]','Excellent meeting with positive client feedback. All stakeholders aligned on project direction and next steps. Client is eager to move forward with proposed enhancements.');

-- Decisions for meeting minutes mm-2
INSERT INTO `decisions` (`id`, `meeting_minutes_id`, `description`, `details`, `stakeholders`, `created_at`) VALUES
('d-1','mm-2','Approve additional budget for Q4 feature development','Additional 25% budget approved for advanced features','["client@customer.com","manager@company.com"]','2025-09-23 14:30:00'),
('d-2','mm-2','Extend project timeline by 2 weeks for additional testing','Extra testing phase to ensure quality standards','["manager@company.com","jane.smith@company.com"]','2025-09-23 14:45:00'),
('d-3','mm-2','Implement weekly progress review meetings',NULL,'["jane.smith@company.com","client@customer.com"]','2025-09-23 15:00:00');

-- Action items for meeting minutes mm-2
INSERT INTO `action_items` (`id`, `meeting_minutes_id`, `description`, `details`, `assigned_to`, `due_date`, `status`, `priority`, `created_at`) VALUES
('a-1','mm-2','Prepare detailed Q4 project roadmap','Include feature specifications, timelines, and resource requirements','jane.smith@company.com','2025-09-30','pending','high','2025-09-23 10:05:00'),
('a-2','mm-2','Schedule weekly review meetings with client',NULL,'manager@company.com','2025-09-25','pending','medium','2025-09-23 10:10:00'),
('a-3','mm-2','Finalize budget proposal for additional features','Include detailed cost breakdown and ROI analysis','sales@company.com','2025-09-28','pending','high','2025-09-23 10:15:00');

-- Sample tasks (app-level)
INSERT INTO `tasks` (`id`,`title`,`description`,`due_date`,`priority`,`status`,`assigned_to`,`assigned_by`,`meeting_id`,`attachments`) VALUES
('t-1','Update project documentation','Update the technical documentation based on recent changes','2025-09-24','medium','pending','john.doe@company.com','jane.smith@company.com','1','[]'),
('t-2','Prepare testing plan','Create a detailed testing plan for upcoming release','2025-09-29','high','pending','qa@company.com','manager@company.com','2','[]');

-- End of dump
