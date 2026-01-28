/**
 * Small seed helper to create a user from the command line.
 * Usage: node src/seed/create_user.js email password [name]
 */
const db = require('../../src/db');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

dotenv.config();

async function run() {
  const args = process.argv.slice(2);
  const email = args[0] || 'admin@example.com';
  const password = args[1] || 'password123';
  const name = args[2] || 'Admin User';

  const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10', 10);
  const hash = await bcrypt.hash(password, SALT_ROUNDS);

  try {
    const [exists] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (exists.length) {
      console.log('User already exists:', email);
      process.exit(0);
    }

    const [result] = await db.query('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [name, email, hash]);
    console.log('Created user id=', result.insertId, 'email=', email);
    process.exit(0);
  } catch (err) {
    console.error('Error creating user', err);
    process.exit(1);
  }
}

run();
