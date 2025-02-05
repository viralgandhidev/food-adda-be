import { inject, injectable } from "inversify";
import Logger from "./logger";

@injectable()
class DataBaseController {
    private password: string;
    private user: string;
    private dbName: string;
    private database: Object;
    private logger: Logger;

    constructor(@inject(Logger) logger: Logger) {
        this.dbName = process.env.DB_NAME;
        this.password = process.env.DB_PASSWORD;
        this.user = process.env.DB_USER_NAME;
        this.logger = logger;
    }

    public async connect(): Promise<void> {
        if (this.isConnected()) {
            this.logger.info("Database is already connected");
        }

        if (!this.dbName) {
            throw new Error("Database Name not found");
        }

        if (!this.user) {
            throw new Error("Database Use Name not found");
        }

        if (!this.password) {
            throw new Error("Database Password not found");
        }

        // TODO: DB connect
        this.database = {execute: () => {}};
        this.logger.info("Databse conncted");
    }

    public async disconnect(): Promise<void> {
        // TODO: database disconnect
        this.database = null;
        this.logger.info("Databse disconncted");
    }

    public isConnected(): Boolean {
        // TODO: database connection check
        return Boolean(this.database);
    }
}

export default DataBaseController;