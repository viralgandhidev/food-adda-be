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
import {ErrorHandler} from './application/middleware/errorHandler';
import {DatabaseController} from './application/utils/databaseController';

import {container} from './application/di/container';

@injectable()
export class App {
  private app: express.Application;
  private errorHandlerInstance: express.ErrorRequestHandler;

  constructor(
    @inject(TYPES.AppRouter) private router: AppRouter,
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.ErrorHandler) private errorHandler: ErrorHandler,
    @inject(TYPES.DatabaseController)
    private databaseController: DatabaseController,
  ) {
    this.app = express();
    this.errorHandlerInstance = this.errorHandler.handleError.bind(
      this.errorHandler,
    );
    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
    this.initializeDatabase();
    this.setupGracefulShutdown();
    this.setupUncaughtErrorHandlers();
  }

  private initializeMiddlewares(): void {
    this.app.use(express.json({limit: '5mb'}));
    this.app.use(express.urlencoded({extended: true}));
    this.app.use(cors());
    this.app.use(helmet());
    this.app.use(
      compression({
        strategy: zlib.constants.Z_RLE,
        level: zlib.constants.Z_BEST_COMPRESSION,
        memLevel: zlib.constants.Z_BEST_COMPRESSION,
      }),
    );
    this.app.use(
      rateLimit({
        windowMs: 15 * 60 * 1000, // 15 minutes
        limit: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes).
        standardHeaders: 'draft-8', // draft-6: `RateLimit-*` headers; draft-7 & draft-8: combined `RateLimit` header
        legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
      }),
    );
  }

  private initializeRoutes(): void {
    this.router.registerRoutes(this.app);
  }

  private initializeErrorHandling(): void {
    // Handle 404
    this.app.use((req, res) => {
      res.status(404).json({
        success: false,
        message: 'Route not found',
      });
    });

    // Handle errors
    this.app.use(this.errorHandlerInstance);
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
