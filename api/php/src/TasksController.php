<?php
namespace App;

use App\Database;

class TasksController
{
    public static function list()
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT id, title, description, due_date, priority, status, assigned_to, assigned_by, meeting_id, created_at, completed_at FROM tasks ORDER BY due_date ASC');
        $rows = $stmt->fetchAll();
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM tasks WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) jsonResponse(['error' => 'Not found'], 404);
        jsonResponse($row);
    }

    public static function create()
    {
        $input = getJsonInput();
        if (empty($input['title'])) {
            jsonResponse(['error' => 'title is required'], 400);
        }
        
        $pdo = Database::getConnection();
        $id = bin2hex(random_bytes(8));
        
        $stmt = $pdo->prepare('
            INSERT INTO tasks (id, title, description, due_date, priority, status, assigned_to, assigned_by, meeting_id, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ');
        
        $stmt->execute([
            $id,
            $input['title'],
            $input['description'] ?? null,
            $input['due_date'] ?? null,
            $input['priority'] ?? 'medium',
            $input['status'] ?? 'pending',
            $input['assigned_to'] ?? null,
            $input['assigned_by'] ?? null,
            $input['meeting_id'] ?? null,
        ]);
        
        jsonResponse(['id' => $id, 'message' => 'Task created'], 201);
    }

    public static function update($id)
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM tasks WHERE id = ?');
        $stmt->execute([$id]);
        $task = $stmt->fetch();
        
        if (!$task) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $completed_at = null;
        if (($input['status'] ?? $task['status']) === 'completed' && $task['status'] !== 'completed') {
            $completed_at = date('Y-m-d H:i:s');
        }
        
        $stmt = $pdo->prepare('
            UPDATE tasks 
            SET title = ?, description = ?, due_date = ?, priority = ?, status = ?, assigned_to = ?, completed_at = ?
            WHERE id = ?
        ');
        
        $stmt->execute([
            $input['title'] ?? $task['title'],
            $input['description'] ?? $task['description'],
            $input['due_date'] ?? $task['due_date'],
            $input['priority'] ?? $task['priority'],
            $input['status'] ?? $task['status'],
            $input['assigned_to'] ?? $task['assigned_to'],
            $completed_at ?? $task['completed_at'],
            $id
        ]);
        
        jsonResponse(['success' => true, 'message' => 'Task updated']);
    }

    public static function delete($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM tasks WHERE id = ?');
        $stmt->execute([$id]);
        
        if (!$stmt->fetch()) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        $stmt = $pdo->prepare('DELETE FROM tasks WHERE id = ?');
        $stmt->execute([$id]);
        
        jsonResponse(['success' => true, 'message' => 'Task deleted'], 200);
    }
}
?>
