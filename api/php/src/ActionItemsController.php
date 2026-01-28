<?php
namespace App;

use App\Database;

class ActionItemsController
{
    public static function listByMinutes($minutesId)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('
            SELECT id, meeting_minutes_id, description, details, assigned_to, due_date, status, priority, created_at
            FROM action_items
            WHERE meeting_minutes_id = ?
            ORDER BY due_date ASC, priority DESC
        ');
        $stmt->execute([$minutesId]);
        $rows = $stmt->fetchAll();
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM action_items WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        
        if (!$row) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
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
        
        $stmt = $pdo->prepare('
            INSERT INTO action_items (id, meeting_minutes_id, description, details, assigned_to, due_date, status, priority, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ');
        
        $stmt->execute([
            $id,
            $input['meeting_minutes_id'],
            $input['description'],
            $input['details'] ?? null,
            $input['assigned_to'] ?? null,
            $input['due_date'] ?? null,
            $input['status'] ?? 'pending',
            $input['priority'] ?? 'medium',
        ]);
        
        jsonResponse(['id' => $id, 'message' => 'Action item created'], 201);
    }

    public static function update($id)
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM action_items WHERE id = ?');
        $stmt->execute([$id]);
        $item = $stmt->fetch();
        
        if (!$item) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stmt = $pdo->prepare('
            UPDATE action_items
            SET description = ?, details = ?, assigned_to = ?, due_date = ?, status = ?, priority = ?
            WHERE id = ?
        ');
        
        $stmt->execute([
            $input['description'] ?? $item['description'],
            $input['details'] ?? $item['details'],
            $input['assigned_to'] ?? $item['assigned_to'],
            $input['due_date'] ?? $item['due_date'],
            $input['status'] ?? $item['status'],
            $input['priority'] ?? $item['priority'],
            $id
        ]);
        
        jsonResponse(['success' => true, 'message' => 'Action item updated']);
    }

    public static function delete($id)
    {
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM action_items WHERE id = ?');
        $stmt->execute([$id]);
        
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stmt = $pdo->prepare('DELETE FROM action_items WHERE id = ?');
        $stmt->execute([$id]);
        
        jsonResponse(['success' => true, 'message' => 'Action item deleted'], 200);
    }
}
?>
