<?php
namespace App;

use Firebase\JWT\JWT;

function jsonResponse($data, $status = 200)
{
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

function getJsonInput()
{
    $body = file_get_contents('php://input');
    return json_decode($body, true) ?: [];
}

function getBearerToken()
{
    $h = getallheaders();
    if (!isset($h['Authorization'])) return null;
    if (preg_match('/Bearer\s+(.*)$/i', $h['Authorization'], $matches)) {
        return $matches[1];
    }
    return null;
}

function requireAuth()
{
    $token = getBearerToken();
    if (!$token) {
        jsonResponse(['error' => 'Missing token'], 401);
    }
    $secret = getenv('JWT_SECRET') ?: 'secret';
    try {
        $payload = JWT::decode($token, $secret, ['HS256']);
        return (array)$payload;
    } catch (\Exception $e) {
        jsonResponse(['error' => 'Invalid token: ' . $e->getMessage()], 401);
    }
}
