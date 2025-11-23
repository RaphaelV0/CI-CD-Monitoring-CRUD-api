const mysql = require('mysql2/promise');

async function migrate() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        console.log('Connected to database');
        console.log('Creating users table if not exists...');

        await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        uuid VARCHAR(36) PRIMARY KEY,
        fullname VARCHAR(255) NOT NULL,
        study_level VARCHAR(255) NOT NULL,
        age INT NOT NULL
      )
    `);

        console.log('✅ Migration completed successfully!');
        await connection.end();
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error);
        process.exit(1);
    }
}

migrate();