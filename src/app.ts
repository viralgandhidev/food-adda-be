import 'reflect-metadata';
import * as dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import zlib from 'zlib';
import rateLimit from 'express-rate-limit';
import {inject, injectable} from 'inversify';
import {TYPES} from './application/di/types';
import {AppRouter} from './application/routers/appRouter';
import {Logger} from './application/utils/logger';
import {ErrorHandler} from './application/utils/errorHandler';
import {DatabaseController} from './application/utils/databaseController';
import path from 'path';
import config from './application/config';

import {container} from './application/di/container';

@injectable()
export class App {
  private app: express.Application;

  constructor(
    @inject(TYPES.AppRouter) private router: AppRouter,
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.ErrorHandler) private errorHandler: ErrorHandler,
    @inject(TYPES.DatabaseController)
    private databaseController: DatabaseController,
  ) {
    this.app = express();
    this.initializeMiddlewares();
    this.initializeErrorHandling();
    this.initializeRoutes();
    this.initializeDatabase();
    this.setupGracefulShutdown();
    this.setupUncaughtErrorHandlers();
  }

  private initializeMiddlewares(): void {
    this.app.use(express.json({limit: '5mb'}));
    this.app.use(express.urlencoded({extended: true}));
    this.app.use(cors());
    this.app.use(helmet());
    // If behind a proxy (e.g., Render/Heroku/Nginx), trust proxy for correct IP rate limiting
    this.app.set('trust proxy', 1);
    this.app.use(
      compression({
        strategy: zlib.constants.Z_RLE,
        level: zlib.constants.Z_BEST_COMPRESSION,
        memLevel: zlib.constants.Z_BEST_COMPRESSION,
      }),
    );
    // Log API requests (method, route, status, duration) for backend API only
    this.app.use((req, res, next) => {
      if (req.originalUrl.startsWith(config.apiPrefix)) {
        const startedAtMs = Date.now();
        res.on('finish', () => {
          const durationMs = Date.now() - startedAtMs;
          // Keep this as a simple console log per request
          console.log(
            `[API] ${req.method} ${req.originalUrl} -> ${res.statusCode} ${durationMs}ms`,
          );
        });
      }
      next();
    });
    // Serve uploaded images statically before rate limiting
    this.app.use(
      '/uploads',
      express.static(path.join(__dirname, '../uploads')),
    );

    // Rate limiting
    const isProduction = process.env.NODE_ENV === 'production';

    // Strict limiter for auth login to protect from brute-force
    const authLimiter = rateLimit({
      windowMs: 60 * 1000,
      limit: isProduction ? 10 : 100, // higher in non-prod to avoid dev friction
      standardHeaders: 'draft-8',
      legacyHeaders: false,
      handler: (req, res) => {
        res.status(429).json({
          success: false,
          message: 'Too many login attempts. Please try again later.',
        });
      },
    });
    // Apply only to login endpoint
    this.app.use(`${config.apiPrefix}/auth/login`, authLimiter);

    // General API limiter: enabled only in production to avoid 429s during development
    if (isProduction) {
      const apiLimiter = rateLimit({
        windowMs: 15 * 60 * 1000,
        limit: 1000, // more generous overall API limit in production
        standardHeaders: 'draft-8',
        legacyHeaders: false,
        handler: (req, res) => {
          res.status(429).json({
            success: false,
            message: 'Too many requests. Please slow down and try again.',
          });
        },
      });
      this.app.use(apiLimiter);
    }
  }

  private initializeRoutes(): void {
    this.router.registerRoutes(this.app);
  }

  private initializeErrorHandling(): void {
    // Register error handler
    this.errorHandler.registerErrorHandler(this.app);
  }

  private async initializeDatabase(): Promise<void> {
    try {
      await this.databaseController.connect();
      this.logger.info('Database initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize database');
      process.exit(1);
    }
  }

  private setupGracefulShutdown(): void {
    process.on('SIGTERM', async () => {
      await this.shutdown();
    });

    process.on('SIGINT', async () => {
      await this.shutdown();
    });
  }

  private setupUncaughtErrorHandlers(): void {
    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason: Error) => {
      this.logger.error('Unhandled Promise Rejection:', reason);
      // Don't exit the process, just log it
    });

    // Handle uncaught exceptions
    process.on('uncaughtException', (error: Error) => {
      this.logger.error('Uncaught Exception:', error);
      // Don't exit the process, just log it
    });
  }

  private async shutdown(): Promise<void> {
    this.logger.info('Shutting down server...');

    if (this.databaseController.isConnected()) {
      await this.databaseController.disconnect();
      this.logger.info('Database disconnected');
    }

    process.exit(0);
  }

  public listen(): void {
    const port = process.env.PORT || 3000;
    this.app.listen(port, () => {
      this.logger.info(`Server is running on port ${port}`);
    });
  }
}
