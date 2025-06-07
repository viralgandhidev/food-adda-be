import {injectable} from 'inversify';
import mysql from 'mysql2/promise';
import {Logger} from './logger';
import {inject} from 'inversify';
import {TYPES} from '../di/types';

@injectable()
export class DatabaseController {
  private pool: mysql.Pool;
  private isConnectedFlag: boolean = false;

  constructor(@inject(TYPES.Logger) private logger: Logger) {
    const config = {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '3306'),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    };

    this.logger.info(
      `Attempting to connect to database with config: ${JSON.stringify({
        ...config,
        password: '****', // Hide password in logs
      })}`,
    );

    this.pool = mysql.createPool(config);
  }

  public async connect(): Promise<void> {
    try {
      // Test the connection
      const connection = await this.pool.getConnection();
      connection.release();
      this.isConnectedFlag = true;
      this.logger.info('Database connected successfully');
    } catch (error) {
      const err = error as Error;
      this.logger.error(`Database connection failed: ${err.message}`);
      this.logger.error(`Stack trace: ${err.stack}`);

      // Log environment variables (excluding sensitive data)
      this.logger.error('Environment variables check:', {
        DB_HOST: process.env.DB_HOST || 'not set',
        DB_PORT: process.env.DB_PORT || 'not set',
        DB_USER: process.env.DB_USER || 'not set',
        DB_NAME: process.env.DB_NAME || 'not set',
        // Don't log DB_PASSWORD
      });

      throw error;
    }
  }

  public async disconnect(): Promise<void> {
    try {
      await this.pool.end();
      this.isConnectedFlag = false;
      this.logger.info('Database disconnected successfully');
    } catch (error) {
      const err = error as Error;
      this.logger.error(`Database disconnection failed: ${err.message}`);
      this.logger.error(`Stack trace: ${err.stack}`);
      throw error;
    }
  }

  public async getConnection(): Promise<mysql.PoolConnection> {
    if (!this.isConnectedFlag) {
      this.logger.error(
        'Attempting to get connection before database is connected',
      );
      throw new Error('Database is not connected');
    }
    return await this.pool.getConnection();
  }

  public isConnected(): boolean {
    return this.isConnectedFlag;
  }
}
