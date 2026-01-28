const express = require('express');
const router = express.Router();
const controller = require('../controllers/meetingsController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = process.env.UPLOAD_DIR || path.join(__dirname, '..', '..', 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage });

// Meetings
router.get('/', controller.listMeetings);
router.get('/:id', controller.getMeeting);
router.post('/', controller.createMeeting);
router.put('/:id', controller.updateMeeting);
router.patch('/:id/complete', controller.markComplete);
router.delete('/:id', controller.deleteMeeting);

// Minutes
router.get('/:id/minutes', controller.getMeetingMinutes);
router.post('/:id/minutes', controller.createMeetingMinutes);

// Attachments (store file locally and save metadata)
router.post('/:id/attachments', upload.single('file'), controller.addAttachment);

module.exports = router;
