<?php
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/src/helpers.php';

use App\AuthController;
use App\MeetingsController;
use App\TasksController;
use App\MeetingMinutesController;
use App\ActionItemsController;
use App\DecisionsController;
use App\UsersController;

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// ============ AUTH ROUTES (NO AUTH REQUIRED) ============
if ($uri === '/api/auth/register' && $method === 'POST') {
    AuthController::register();
}

if ($uri === '/api/auth/login' && $method === 'POST') {
    AuthController::login();
}

// ============ ALL OTHER ROUTES (AUTH REQUIRED) ============
$user = null;
$requiresAuth = !($uri === '/api/auth/register' && $method === 'POST') && 
                !($uri === '/api/auth/login' && $method === 'POST');

if ($requiresAuth) {
    $user = requireAuth(); // returns payload or responds 401
    $GLOBALS['current_user'] = $user;
}

// ============ MEETINGS ROUTES ============
if (strpos($uri, '/api/meetings') === 0) {
    // list
    if ($uri === '/api/meetings' && $method === 'GET') {
        MeetingsController::list();
    }
    // create
    if ($uri === '/api/meetings' && $method === 'POST') {
        MeetingsController::create();
    }
    // match /api/meetings/{id}
    if (preg_match('#^/api/meetings/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($method === 'GET') MeetingsController::get($id);
        if ($method === 'PUT' || $method === 'PATCH') MeetingsController::update($id);
        if ($method === 'DELETE') MeetingsController::delete($id);
    }
}

// ============ TASKS ROUTES ============
if (strpos($uri, '/api/tasks') === 0) {
    // list
    if ($uri === '/api/tasks' && $method === 'GET') {
        TasksController::list();
    }
    // create
    if ($uri === '/api/tasks' && $method === 'POST') {
        TasksController::create();
    }
    // match /api/tasks/{id}
    if (preg_match('#^/api/tasks/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($method === 'GET') TasksController::get($id);
        if ($method === 'PUT' || $method === 'PATCH') TasksController::update($id);
        if ($method === 'DELETE') TasksController::delete($id);
    }
}

// ============ MEETING MINUTES ROUTES ============
if (strpos($uri, '/api/meeting-minutes') === 0) {
    // list by meeting
    if (preg_match('#^/api/meeting-minutes\?meeting_id=([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $meetingId = $m[1];
        if ($method === 'GET') MeetingMinutesController::listByMeeting($meetingId);
    }
    // create
    if ($uri === '/api/meeting-minutes' && $method === 'POST') {
        MeetingMinutesController::create();
    }
    // get/update/delete {id}
    if (preg_match('#^/api/meeting-minutes/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($method === 'GET') MeetingMinutesController::get($id);
        if ($method === 'PUT' || $method === 'PATCH') MeetingMinutesController::update($id);
        if ($method === 'DELETE') MeetingMinutesController::delete($id);
    }
}

// ============ ACTION ITEMS ROUTES ============
if (strpos($uri, '/api/action-items') === 0) {
    // list by minutes
    if (preg_match('#^/api/action-items\?minutes_id=([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $minutesId = $m[1];
        if ($method === 'GET') ActionItemsController::listByMinutes($minutesId);
    }
    // create
    if ($uri === '/api/action-items' && $method === 'POST') {
        ActionItemsController::create();
    }
    // get/update/delete {id}
    if (preg_match('#^/api/action-items/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($method === 'GET') ActionItemsController::get($id);
        if ($method === 'PUT' || $method === 'PATCH') ActionItemsController::update($id);
        if ($method === 'DELETE') ActionItemsController::delete($id);
    }
}

// ============ DECISIONS ROUTES ============
if (strpos($uri, '/api/decisions') === 0) {
    // list by minutes
    if (preg_match('#^/api/decisions\?minutes_id=([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $minutesId = $m[1];
        if ($method === 'GET') DecisionsController::listByMinutes($minutesId);
    }
    // create
    if ($uri === '/api/decisions' && $method === 'POST') {
        DecisionsController::create();
    }
    // get/update/delete {id}
    if (preg_match('#^/api/decisions/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($method === 'GET') DecisionsController::get($id);
        if ($method === 'PUT' || $method === 'PATCH') DecisionsController::update($id);
        if ($method === 'DELETE') DecisionsController::delete($id);
    }
}

// ============ USERS ROUTES ============
if (strpos($uri, '/api/users') === 0) {
    // current user profile
    if ($uri === '/api/users/profile' && $method === 'GET') {
        UsersController::profile($user);
    }
    // update current user profile
    if ($uri === '/api/users/profile' && $method === 'PUT') {
        UsersController::updateProfile();
    }
    // change password
    if ($uri === '/api/users/change-password' && $method === 'POST') {
        UsersController::changePassword();
    }
    // list users (admin)
    if ($uri === '/api/users' && $method === 'GET') {
        UsersController::list();
    }
    // get user by id
    if (preg_match('#^/api/users/([a-zA-Z0-9\-]+)$#', $uri, $m)) {
        $id = $m[1];
        if ($id !== 'profile' && $id !== 'change-password' && $method === 'GET') {
            UsersController::get($id);
        }
    }
}

// ============ HEALTH CHECK ============
if ($uri === '/api/health' && $method === 'GET') {
    jsonResponse(['status' => 'OK', 'timestamp' => date('Y-m-d H:i:s')]);
}

// ============ FALLBACK ============
http_response_code(404);
header('Content-Type: application/json');
echo json_encode(['error' => 'Not found']);
