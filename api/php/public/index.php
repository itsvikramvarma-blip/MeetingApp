<?php
require __DIR__ . '/../vendor/autoload.php';

use Dotenv\Dotenv;

// load env
$dotenv = Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->safeLoad();

// basic router
require __DIR__ . '/../routes.php';
