const fs = require('fs');
const path = require('path');
const db = require('../db');

async function run() {
  try {
    const sqlPath = path.resolve(__dirname, '../../../db/users.sql');
    console.log('Reading SQL from', sqlPath);
    const sql = fs.readFileSync(sqlPath, 'utf8');

    // Naively split statements on semicolon. Skip comments and empty statements.
    const stmts = sql
      .split(/;\s*\n/)
      .map(s => s.trim())
      .filter(s => s && !s.startsWith('--'));

    for (const stmt of stmts) {
      try {
        console.log('Executing statement (truncated):', stmt.slice(0, 80).replace(/\n/g, ' '));
        await db.query(stmt);
      } catch (err) {
        // Log and continue for idempotency (e.g., table exists)
        console.error('Statement error:', err.code || err.message);
      }
    }

    console.log('Finished running users.sql (check DB to confirm).');
    process.exit(0);
  } catch (err) {
    console.error('Fatal error:', err.message);
    console.error(err.stack);
    process.exit(1);
  }
}

run();
