#!/usr/bin/env node
/**
 * Database Migration Runner
 * 
 * This script runs all SQL migration files in order from the migrations directory.
 * It tracks which migrations have been run using a migrations_log table.
 */

import mysql from 'mysql2/promise';
import * as fs from 'fs';
import * as path from 'path';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const MIGRATIONS_DIR = path.join(__dirname, 'migrations');

interface MigrationRecord {
  id: number;
  filename: string;
  executed_at: Date;
}

class MigrationRunner {
  private connection: mysql.Connection | null = null;

  constructor(
    private config: {
      host: string;
      port: number;
      user: string;
      password: string;
      database: string;
    }
  ) {}

  async connect(): Promise<void> {
    try {
      this.connection = await mysql.createConnection({
        ...this.config,
        multipleStatements: true, // Allow multiple SQL statements
      });
      console.log('✓ Connected to database');
    } catch (error) {
      console.error('✗ Failed to connect to database:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    if (this.connection) {
      await this.connection.end();
      this.connection = null;
      console.log('✓ Disconnected from database');
    }
  }

  async ensureMigrationsTable(): Promise<void> {
    if (!this.connection) {
      throw new Error('Database connection not established');
    }

    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS migrations_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        filename VARCHAR(255) NOT NULL UNIQUE,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_filename (filename)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `;

    await this.connection.query(createTableSQL);
    console.log('✓ Migrations log table ensured');
  }

  async getExecutedMigrations(): Promise<Set<string>> {
    if (!this.connection) {
      throw new Error('Database connection not established');
    }

    const [rows] = await this.connection.query<mysql.RowDataPacket[]>(
      'SELECT filename FROM migrations_log ORDER BY id'
    );

    return new Set(rows.map(row => row.filename));
  }

  async getMigrationFiles(): Promise<string[]> {
    const files = fs.readdirSync(MIGRATIONS_DIR)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Sort alphabetically (files should be numbered like 001_, 002_, etc.)

    return files.map(file => path.join(MIGRATIONS_DIR, file));
  }

  async executeMigration(filename: string, sql: string): Promise<void> {
    if (!this.connection) {
      throw new Error('Database connection not established');
    }

    const basename = path.basename(filename);

    try {
      console.log(`  → Executing: ${basename}`);
      
      // Execute the SQL (may contain multiple statements)
      await this.connection.query(sql);

      // Log the migration
      await this.connection.query(
        'INSERT INTO migrations_log (filename) VALUES (?)',
        [basename]
      );

      console.log(`  ✓ Completed: ${basename}`);
    } catch (error) {
      console.error(`  ✗ Failed: ${basename}`);
      console.error(`  Error:`, error);
      throw error;
    }
  }

  async run(): Promise<void> {
    try {
      await this.connect();
      await this.ensureMigrationsTable();

      const executedMigrations = await this.getExecutedMigrations();
      const migrationFiles = await this.getMigrationFiles();

      console.log(`\nFound ${migrationFiles.length} migration files`);
      console.log(`Already executed: ${executedMigrations.size}`);

      let executedCount = 0;

      for (const filepath of migrationFiles) {
        const basename = path.basename(filepath);

        if (executedMigrations.has(basename)) {
          console.log(`  ⊘ Skipped (already executed): ${basename}`);
          continue;
        }

        const sql = fs.readFileSync(filepath, 'utf-8');

        if (sql.trim().length === 0) {
          console.log(`  ⊘ Skipped (empty file): ${basename}`);
          continue;
        }

        await this.executeMigration(filepath, sql);
        executedCount++;
      }

      console.log(`\n✓ Migration complete! Executed ${executedCount} new migration(s)`);
    } catch (error) {
      console.error('\n✗ Migration failed:', error);
      process.exit(1);
    } finally {
      await this.disconnect();
    }
  }
}

// Main execution
async function main() {
  const config = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'foodadda',
  };

  // Validate required environment variables
  if (!config.password) {
    console.error('✗ Error: DB_PASSWORD environment variable is required');
    process.exit(1);
  }

  if (!config.user) {
    console.error('✗ Error: DB_USER environment variable is required');
    process.exit(1);
  }

  console.log(`\n🚀 Starting database migrations...`);
  console.log(`   Database: ${config.database}`);
  console.log(`   Host: ${config.host}:${config.port}`);
  console.log(`   User: ${config.user}\n`);

  const runner = new MigrationRunner(config);
  await runner.run();
}

// Run if executed directly
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export default MigrationRunner;

