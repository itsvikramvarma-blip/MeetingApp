// Diagnostic script: attempts a simple query using api/src/db.js and prints full error info
const db = require('../db');
const dotenv = require('dotenv');
dotenv.config();

async function run() {
  console.log('Using DB host=%s user=%s database=%s', process.env.DB_HOST, process.env.DB_USER, process.env.DB_NAME);
  try {
    const [rows] = await db.query('SELECT 1 as ok');
    console.log('DB CONNECT OK:', rows);
    process.exit(0);
  } catch (err) {
    console.error('DB CONNECT ERROR:');
    console.error('name:', err.name);
    console.error('code:', err.code);
    console.error('errno:', err.errno);
    console.error('sqlState:', err.sqlState);
    console.error('message:', err.message);
    console.error('stack:', err.stack);
    process.exit(1);
  }
}

run();
