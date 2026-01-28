<?php
namespace App;

use App\Database;

class MeetingsController
{
    public static function list()
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT id, title, description, start_time, end_time, organizer, participants, meeting_room, status FROM meetings');
        $rows = $stmt->fetchAll();
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM meetings WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) jsonResponse(['error' => 'Not found'], 404);
        jsonResponse($row);
    }

    public static function create()
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        $id = bin2hex(random_bytes(8));
        $organizer = $input['organizer'] ?? null;
        $participants = isset($input['participants']) ? json_encode($input['participants']) : '[]';
        $stmt = $pdo->prepare('INSERT INTO meetings (id, title, description, start_time, end_time, organizer, participants, meeting_room, status, agenda) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([$id, $input['title'] ?? '', $input['description'] ?? null, $input['start_time'] ?? null, $input['end_time'] ?? null, $organizer, $participants, $input['meeting_room'] ?? null, 'scheduled', json_encode($input['agenda'] ?? [])]);
        jsonResponse(['id' => $id], 201);
    }

    public static function update($id)
    {
        $input = getJsonInput();
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM meetings WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) jsonResponse(['error' => 'Not found'], 404);
        if ($row['status'] === 'completed') jsonResponse(['error' => 'Completed meetings cannot be edited'], 403);
        $participants = isset($input['participants']) ? json_encode($input['participants']) : $row['participants'];
        $stmt = $pdo->prepare('UPDATE meetings SET title=?, description=?, start_time=?, end_time=?, organizer=?, participants=?, meeting_room=?, agenda=? WHERE id = ?');
        $stmt->execute([$input['title'] ?? $row['title'], $input['description'] ?? $row['description'], $input['start_time'] ?? $row['start_time'], $input['end_time'] ?? $row['end_time'], $input['organizer'] ?? $row['organizer'], $participants, $input['meeting_room'] ?? $row['meeting_room'], json_encode($input['agenda'] ?? json_decode($row['agenda'], true) ?: []), $id]);
        jsonResponse(['success' => true]);
    }

    public static function delete($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT status FROM meetings WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) jsonResponse(['error' => 'Not found'], 404);
        if ($row['status'] === 'completed') jsonResponse(['error' => 'Cannot delete completed meeting'], 403);
        $stmt = $pdo->prepare('DELETE FROM meetings WHERE id = ?');
        $stmt->execute([$id]);
        jsonResponse([], 204);
    }
}
