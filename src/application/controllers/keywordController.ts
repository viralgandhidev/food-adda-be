import {Router, Request, Response} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';
import {KeywordRepository} from '../../domain/repositories/keywordRepository';

@injectable()
export class KeywordController {
  private router: Router;

  constructor(
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.KeywordRepository)
    private keywordRepository: KeywordRepository,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get('/', asyncHandler(this.getKeywords.bind(this)));
    this.router.get('/all', asyncHandler(this.getAllKeywords.bind(this)));
  }

  private async getKeywords(req: Request, res: Response): Promise<void> {
    const mainCategoryId = (req.query.mainCategoryId as string) || '';
    const subCategoryId = (req.query.subCategoryId as string) || undefined;
    if (!mainCategoryId) {
      res
        .status(400)
        .json({success: false, message: 'mainCategoryId is required'});
      return;
    }
    const items = await this.keywordRepository.findByCategory(
      mainCategoryId,
      subCategoryId,
    );
    res
      .status(200)
      .json({success: true, data: items, meta: {total: items.length}});
  }

  private async getAllKeywords(req: Request, res: Response): Promise<void> {
    const items = await this.keywordRepository.findAll();
    res
      .status(200)
      .json({success: true, data: items, meta: {total: items.length}});
  }

  public getRouter(): Router {
    return this.router;
  }
}
