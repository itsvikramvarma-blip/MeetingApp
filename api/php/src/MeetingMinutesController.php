<?php
namespace App;

use App\Database;

class MeetingMinutesController
{
    public static function listByMeeting($meetingId)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('
            SELECT id, meeting_id, created_at, last_updated_at, created_by, discussion_points, general_notes, attendee_notes
            FROM meeting_minutes
            WHERE meeting_id = ?
            ORDER BY created_at DESC
        ');
        $stmt->execute([$meetingId]);
        $rows = $stmt->fetchAll();
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM meeting_minutes WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        
        if (!$row) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        // Decode JSON fields
        $row['discussion_points'] = json_decode($row['discussion_points'], true) ?: [];
        
        jsonResponse($row);
    }

    public static function create()
    {
        $input = getJsonInput();
        
        if (empty($input['meeting_id'])) {
            jsonResponse(['error' => 'meeting_id is required'], 400);
        }
        
        $pdo = Database::getConnection();
        
        // Verify meeting exists
        $stmt = $pdo->prepare('SELECT id FROM meetings WHERE id = ?');
        $stmt->execute([$input['meeting_id']]);
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Meeting not found'], 404);
        }
        
        $id = bin2hex(random_bytes(8));
        $discussionPoints = isset($input['discussion_points']) ? json_encode($input['discussion_points']) : '[]';
        
        $stmt = $pdo->prepare('
            INSERT INTO meeting_minutes (id, meeting_id, created_at, created_by, discussion_points, general_notes, attendee_notes)
            VALUES (?, ?, NOW(), ?, ?, ?, ?)
        ');
        
        $stmt->execute([
            $id,
            $input['meeting_id'],
            $input['created_by'] ?? null,
            $discussionPoints,
            $input['general_notes'] ?? null,
            $input['attendee_notes'] ?? null,
        ]);
        
        jsonResponse(['id' => $id, 'message' => 'Meeting minutes created'], 201);
    }

    public static function update($id)
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM meeting_minutes WHERE id = ?');
        $stmt->execute([$id]);
        $minutes = $stmt->fetch();
        
        if (!$minutes) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $discussionPoints = isset($input['discussion_points']) 
            ? json_encode($input['discussion_points']) 
            : $minutes['discussion_points'];
        
        $stmt = $pdo->prepare('
            UPDATE meeting_minutes
            SET discussion_points = ?, general_notes = ?, attendee_notes = ?, last_updated_at = NOW()
            WHERE id = ?
        ');
        
        $stmt->execute([
            $discussionPoints,
            $input['general_notes'] ?? $minutes['general_notes'],
            $input['attendee_notes'] ?? $minutes['attendee_notes'],
            $id
        ]);
        
        jsonResponse(['success' => true, 'message' => 'Meeting minutes updated']);
    }

    public static function delete($id)
    {
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM meeting_minutes WHERE id = ?');
        $stmt->execute([$id]);
        
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stmt = $pdo->prepare('DELETE FROM meeting_minutes WHERE id = ?');
        $stmt->execute([$id]);
        
        jsonResponse(['success' => true, 'message' => 'Meeting minutes deleted'], 200);
    }
}
?>
