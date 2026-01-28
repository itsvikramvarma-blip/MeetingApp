const db = require('../db');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

// Helper to check if the authenticated user is the organizer
function isOrganizer(meeting, user) {
  if (!user) return false;
  // prefer organizer_id if present
  if (meeting.organizer_id && Number(meeting.organizer_id) === Number(user.id)) return true;
  if (meeting.organizer && user.email && meeting.organizer === user.email) return true;
  return false;
}

// List meetings with optional status filter
exports.listMeetings = async (req, res, next) => {
  try {
    const { status } = req.query;
    let sql = 'SELECT id, title, description, start_time, end_time, organizer, organizer_id, participants, meeting_room, status FROM meetings';
    const params = [];
    if (status) {
      sql += ' WHERE status = ?';
      params.push(status);
    }
    const [rows] = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

exports.getMeeting = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Meeting not found' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.createMeeting = async (req, res, next) => {
  try {
    const { title, description, start_time, end_time, participants, meeting_room, agenda } = req.body;
    const id = uuidv4();
    // Use authenticated user as organizer when available
    const organizerEmail = req.user && req.user.email ? req.user.email : null;
    const organizerId = req.user && req.user.id ? req.user.id : null;
    await db.query(
      `INSERT INTO meetings (id, title, description, start_time, end_time, organizer, organizer_id, participants, meeting_room, status, agenda) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'scheduled', ?)`,
      [id, title, description, start_time, end_time, organizerEmail, organizerId, JSON.stringify(participants || []), meeting_room, JSON.stringify(agenda || [])]
    );
    const [rows] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.updateMeeting = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [existing] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    if (!existing.length) return res.status(404).json({ error: 'Meeting not found' });
    const meeting = existing[0];
    // Only organizer may update meetings
    if (!isOrganizer(meeting, req.user)) {
      return res.status(403).json({ error: 'Only the organizer may update this meeting' });
    }
    // If meeting is completed, disallow editing core fields
    if (meeting.status === 'completed') {
      return res.status(403).json({ error: 'Completed meetings cannot be edited (except attachments/minutes)' });
    }
    const { title, description, start_time, end_time, organizer, participants, meeting_room, agenda } = req.body;
    await db.query(
      `UPDATE meetings SET title=?, description=?, start_time=?, end_time=?, organizer=?, participants=?, meeting_room=?, agenda=? WHERE id = ?`,
      [title, description, start_time, end_time, organizer, JSON.stringify(participants || []), meeting_room, JSON.stringify(agenda || []), id]
    );
    const [rows] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.markComplete = async (req, res, next) => {
  try {
    const { id } = req.params;
    // Ensure only organizer may mark complete
    const [existing] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    if (!existing.length) return res.status(404).json({ error: 'Meeting not found' });
    if (!isOrganizer(existing[0], req.user)) return res.status(403).json({ error: 'Only the organizer may mark this meeting complete' });
    await db.query('UPDATE meetings SET status = ? WHERE id = ?', ['completed', id]);
    const [rows] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

exports.deleteMeeting = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [existing] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    if (!existing.length) return res.status(404).json({ error: 'Meeting not found' });
    // Only organizer may delete and cannot delete completed meetings
    if (!isOrganizer(existing[0], req.user)) return res.status(403).json({ error: 'Only the organizer may delete this meeting' });
    if (existing[0].status === 'completed') return res.status(403).json({ error: 'Cannot delete completed meeting' });
    await db.query('DELETE FROM meetings WHERE id = ?', [id]);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};

// Minutes
exports.getMeetingMinutes = async (req, res, next) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query('SELECT * FROM meeting_minutes WHERE meeting_id = ?', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Meeting minutes not found' });
    const minutes = rows[0];
    const [decisions] = await db.query('SELECT * FROM decisions WHERE meeting_minutes_id = ?', [minutes.id]);
    const [actions] = await db.query('SELECT * FROM action_items WHERE meeting_minutes_id = ?', [minutes.id]);
    res.json({ ...minutes, decisions, actionItems: actions });
  } catch (err) {
    next(err);
  }
};

exports.createMeetingMinutes = async (req, res, next) => {
  try {
    const { id } = req.params; // meeting id
    // Ensure meeting exists and is completed
    const [meetings] = await db.query('SELECT * FROM meetings WHERE id = ?', [id]);
    if (!meetings.length) return res.status(404).json({ error: 'Meeting not found' });
    if (meetings[0].status !== 'completed') return res.status(403).json({ error: 'Meeting must be completed before adding minutes' });

    const mid = uuidv4();
    const { created_by, discussion_points, general_notes } = req.body;
    await db.query(
      `INSERT INTO meeting_minutes (id, meeting_id, created_at, last_updated_at, created_by, discussion_points, general_notes) VALUES (?, ?, NOW(), NOW(), ?, ?, ?)`,
      [mid, id, created_by, JSON.stringify(discussion_points || []), general_notes || null]
    );
    const [rows] = await db.query('SELECT * FROM meeting_minutes WHERE id = ?', [mid]);
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// Attachments: store file and persist metadata in attachments column as simple JSON array in meetings.attachments
exports.addAttachment = async (req, res, next) => {
  try {
    const { id } = req.params; // meeting id
    if (!req.file) return res.status(400).json({ error: 'File is required' });
    const fileMeta = {
      id: uuidv4(),
      fileName: req.file.filename,
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      url: `/uploads/${req.file.filename}`,
      uploadedAt: new Date()
    };
    const [rows] = await db.query('SELECT attachments FROM meetings WHERE id = ?', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Meeting not found' });
    let attachments = [];
    try { attachments = JSON.parse(rows[0].attachments || '[]'); } catch(e){ attachments = []; }
    attachments.push(fileMeta);
    await db.query('UPDATE meetings SET attachments = ? WHERE id = ?', [JSON.stringify(attachments), id]);
    res.status(201).json(fileMeta);
  } catch (err) {
    next(err);
  }
};
