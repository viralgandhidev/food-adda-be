import dotenv from 'dotenv';
dotenv.config();

export default {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'local',

  // Database
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'Rickandmorty@123',
    database: process.env.DB_NAME || 'foodadda',
  },

  // JWT
  jwtSecret: process.env.JWT_SECRET || 'secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',

  // Logging
  logLevel: process.env.LOG_LEVEL || 'info',

  // API
  apiPrefix: '/api/v1',
};
