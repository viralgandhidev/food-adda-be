import { inject, injectable } from "inversify";
import UserController from "../../infrastructure/controllers/user/UserController";
import { Application } from "express";

@injectable()
class AppRouter {
    private userController: UserController;

    constructor(@inject(UserController) userController: UserController) {
        this.userController = userController;
    }

    public registerRoutes(app: Application) {
        app.use('/api/users', this.userController.getRouter());
    }
}

export default AppRouter;