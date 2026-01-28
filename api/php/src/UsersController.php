<?php
namespace App;

use App\Database;

class UsersController
{
    public static function profile($user)
    {
        // Returns current user's profile based on JWT token
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id, name, email, role, created_at FROM users WHERE id = ? OR email = ?');
        $stmt->execute([$user['id'] ?? null, $user['email'] ?? null]);
        $userRecord = $stmt->fetch();
        
        if (!$userRecord) {
            jsonResponse(['error' => 'User not found'], 404);
        }
        
        jsonResponse($userRecord);
    }

    public static function updateProfile()
    {
        $user = $GLOBALS['current_user'] ?? null;
        if (!$user) {
            jsonResponse(['error' => 'Not authenticated'], 401);
        }
        
        $input = getJsonInput();
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute([$user['id']]);
        $userRecord = $stmt->fetch();
        
        if (!$userRecord) {
            jsonResponse(['error' => 'User not found'], 404);
        }
        
        $stmt = $pdo->prepare('UPDATE users SET name = ? WHERE id = ?');
        $stmt->execute([
            $input['name'] ?? $userRecord['name'],
            $user['id']
        ]);
        
        jsonResponse(['success' => true, 'message' => 'Profile updated']);
    }

    public static function changePassword()
    {
        $user = $GLOBALS['current_user'] ?? null;
        if (!$user) {
            jsonResponse(['error' => 'Not authenticated'], 401);
        }
        
        $input = getJsonInput();
        
        if (empty($input['old_password']) || empty($input['new_password'])) {
            jsonResponse(['error' => 'old_password and new_password are required'], 400);
        }
        
        $pdo = Database::getConnection();
        
        $stmt = $pdo->prepare('SELECT password FROM users WHERE id = ?');
        $stmt->execute([$user['id']]);
        $userRecord = $stmt->fetch();
        
        if (!$userRecord || !password_verify($input['old_password'], $userRecord['password'])) {
            jsonResponse(['error' => 'Invalid old password'], 401);
        }
        
        $hash = password_hash($input['new_password'], PASSWORD_DEFAULT);
        $stmt = $pdo->prepare('UPDATE users SET password = ? WHERE id = ?');
        $stmt->execute([$hash, $user['id']]);
        
        jsonResponse(['success' => true, 'message' => 'Password changed']);
    }

    public static function list()
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT id, name, email, role, created_at FROM users ORDER BY created_at DESC');
        $rows = $stmt->fetchAll();
        jsonResponse($rows);
    }

    public static function get($id)
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id, name, email, role, created_at FROM users WHERE id = ?');
        $stmt->execute([$id]);
        $user = $stmt->fetch();
        
        if (!$user) {
            jsonResponse(['error' => 'Not found'], 404);
        }
        
        jsonResponse($user);
    }
}
?>
