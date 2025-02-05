import 'reflect-metadata';
import * as dotenv from 'dotenv';
dotenv.config();

import express from "express";
import cors from "cors";
import helmet from 'helmet';
import compression from 'compression'
import zlib from 'zlib'
import rateLimit from 'express-rate-limit'

import { container } from './application/di/container';
import AppRouter from './application/routers/appRouter';
import DataBaseController from './application/utils/databaseController';
import Logger from './application/utils/logger';
import ErrorHandler from './application/utils/errorHandler';

const logger = container.get<Logger>(Logger);

const app = express();
app.use(cors({origin: '*', methods: ["GET", "POST", "OPTIONS"], allowedHeaders: ["Content-Type", "Authorization", "Accept"]}));

// database connect
const databaseController = container.get<DataBaseController>(DataBaseController);
databaseController.connect();

// Register Body parser
app.use(express.json({limit: '5mb'}));
app.use(express.urlencoded({extended: true}));

// Register Security
app.use(helmet());

// Register compression
app.use(
    compression({
        strategy: zlib.constants.Z_RLE,
        level: zlib.constants.Z_BEST_COMPRESSION,
        memLevel: zlib.constants.Z_BEST_COMPRESSION
      })
)

// Register Rate limiter
app.use(
    rateLimit({
        windowMs: 15 * 60 * 1000, // 15 minutes
        limit: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes).
        standardHeaders: 'draft-8', // draft-6: `RateLimit-*` headers; draft-7 & draft-8: combined `RateLimit` header
        legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
    })
)

// Register App routes
const appRouter = container.get<AppRouter>(AppRouter);
appRouter.registerRoutes(app);

// Register error handler
const errorHandler = container.get<ErrorHandler>(ErrorHandler);
logger.info(`errorHandler ${errorHandler}`);

errorHandler.registerErrorHandler(app);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    // add logger
    logger.info(`Running Node.js version ${process.version}`);
    logger.info(`App environment: ${process.env.NODE_ENV}`);
    logger.info(`App secret: ${process.env.JWT_SECRET}`);
    logger.info(`App is running on port ${PORT}`);
});

// Shutdown
process.on('exit', () => {
    if (databaseController.isConnected()) {
        databaseController.disconnect();
    }
});