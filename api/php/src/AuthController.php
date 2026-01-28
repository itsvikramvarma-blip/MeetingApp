<?php
namespace App;

use App\Database;
use Firebase\JWT\JWT;

class AuthController
{
    public static function register()
    {
        $input = getJsonInput();
        if (empty($input['email']) || empty($input['password'])) {
            jsonResponse(['error' => 'email and password required'], 400);
        }
        $pdo = Database::getConnection();
        // check exists
        $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ?');
        $stmt->execute([$input['email']]);
        if ($stmt->fetch()) {
            jsonResponse(['error' => 'User exists'], 409);
        }
        $hash = password_hash($input['password'], PASSWORD_DEFAULT);
        $stmt = $pdo->prepare('INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)');
        $stmt->execute([$input['name'] ?? null, $input['email'], $hash, 'user']);
        jsonResponse(['id' => $pdo->lastInsertId(), 'email' => $input['email']], 201);
    }

    public static function login()
    {
        $input = getJsonInput();
        if (empty($input['email']) || empty($input['password'])) {
            jsonResponse(['error' => 'email and password required'], 400);
        }
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id, name, email, password, role FROM users WHERE email = ?');
        $stmt->execute([$input['email']]);
        $user = $stmt->fetch();
        if (!$user) jsonResponse(['error' => 'Invalid credentials'], 401);
        if (!password_verify($input['password'], $user['password'])) jsonResponse(['error' => 'Invalid credentials'], 401);
        $secret = getenv('JWT_SECRET') ?: 'secret';
        $expiry = time() + (int)(getenv('JWT_EXPIRY') ?: 3600);
        $payload = [
            'id' => $user['id'],
            'email' => $user['email'],
            'name' => $user['name'],
            'exp' => $expiry,
        ];
        $token = JWT::encode($payload, $secret, 'HS256');
        jsonResponse(['token' => $token, 'user' => $payload]);
    }
}
