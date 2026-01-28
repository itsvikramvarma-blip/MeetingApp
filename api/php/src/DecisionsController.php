<?php
namespace App;

use App\Database;

class DecisionsController
{
    public static function listByMinutes($minutesId)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('
            SELECT id, meeting_minutes_id, description, details, stakeholders, created_at
            FROM decisions
            WHERE meeting_minutes_id = ?
            ORDER BY created_at DESC
        ');
        $stmt->execute([$minutesId]);
        $rows = $stmt->fetchAll();
        
        // Decode JSON fields
        foreach ($rows as &$row) {
            $row['stakeholders'] = json_decode($row['stakeholders'], true) ?: [];
        }
        
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM decisions WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        
        if (!$row) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $row['stakeholders'] = json_decode($row['stakeholders'], true) ?: [];
        jsonResponse($row);
    }

    public static function create()
    {
        $input = getJsonInput();
        
        if (empty($input['meeting_minutes_id']) || empty($input['description'])) {
            jsonResponse(['error' => 'meeting_minutes_id and description are required'], 400);
        }
        
        $pdo = Database::getConnection();
        
        // Verify meeting minutes exist
        $stmt = $pdo->prepare('SELECT id FROM meeting_minutes WHERE id = ?');
        $stmt->execute([$input['meeting_minutes_id']]);
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Meeting minutes not found'], 404);
        }
        
        $id = bin2hex(random_bytes(8));
        $stakeholders = isset($input['stakeholders']) ? json_encode($input['stakeholders']) : '[]';
        
        $stmt = $pdo->prepare('
            INSERT INTO decisions (id, meeting_minutes_id, description, details, stakeholders, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())
        ');
        
        $stmt->execute([
            $id,
            $input['meeting_minutes_id'],
            $input['description'],
            $input['details'] ?? null,
            $stakeholders,
        ]);
        
        jsonResponse(['id' => $id, 'message' => 'Decision created'], 201);
    }

    public static function update($id)
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM decisions WHERE id = ?');
        $stmt->execute([$id]);
        $decision = $stmt->fetch();
        
        if (!$decision) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stakeholders = isset($input['stakeholders']) ? json_encode($input['stakeholders']) : $decision['stakeholders'];
        
        $stmt = $pdo->prepare('
            UPDATE decisions
            SET description = ?, details = ?, stakeholders = ?
            WHERE id = ?
        ');
        
        $stmt->execute([
            $input['description'] ?? $decision['description'],
            $input['details'] ?? $decision['details'],
            $stakeholders,
            $id
        ]);
        
        jsonResponse(['success' => true, 'message' => 'Decision updated']);
    }

    public static function delete($id)
    {
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM decisions WHERE id = ?');
        $stmt->execute([$id]);
        
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stmt = $pdo->prepare('DELETE FROM decisions WHERE id = ?');
        $stmt->execute([$id]);
        
        jsonResponse(['success' => true, 'message' => 'Decision deleted'], 200);
    }
}
?>
