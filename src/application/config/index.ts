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

  // Payments
  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID || '',
    keySecret: process.env.RAZORPAY_KEY_SECRET || '',
    silverPlanId: process.env.RAZORPAY_SILVER_PLAN_ID || '',
    goldPlanId: process.env.RAZORPAY_GOLD_PLAN_ID || '',
    webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET || '',
  },

  // Email
  email: {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',
    user: process.env.SMTP_USER || '',
    password: process.env.SMTP_PASSWORD || '',
    to: process.env.CONTACT_EMAIL || process.env.SMTP_USER || '',
  },
};
