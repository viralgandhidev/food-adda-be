import { injectable } from 'inversify';
import { createLogger, format, Logger as WinstonLogger, transports } from 'winston'
import { ConsoleTransportInstance } from 'winston/lib/winston/transports';

@injectable()
class Logger {
    private logger: WinstonLogger;
    private consoleTransaport: ConsoleTransportInstance;

    constructor() {
        const { combine, label, timestamp, printf } = format;
        const logFormat = printf(({ level, message, label: logLabel, timestamp: logTimestamp }) => {
            return `${logTimestamp} [${logLabel}] ${level} ${message}`;
        });
        this.consoleTransaport = new transports.Console()
        this.logger = createLogger({ level: process.env.LOG_LEVEL || "info", format: combine(label({ label: process.env.NODE_ENV }), timestamp(), logFormat), transports: [this.consoleTransaport] });
    }

    public debug(message: string) {
        this.logger.debug(message);
    }

    public info(message: string) {
        this.logger.info(message);
    }

    public error(message: string, ...args) {
        this.logger.error(message, ...args);
    }
}

export default Logger;