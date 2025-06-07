import {injectable, inject} from 'inversify';
import {TYPES} from '../../application/di/types';
import {Category} from '../../domain/entities/category';
import {CategoryRepository} from '../../domain/repositories/categoryRepository';
import {DatabaseController} from '../../application/utils/databaseController';
import {Logger} from '../../application/utils/logger';

@injectable()
export class CategoryRepositoryImpl implements CategoryRepository {
  constructor(
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.Logger) private logger: Logger,
  ) {}

  async findAll(): Promise<Category[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT c.*, 
          COUNT(p.id) as product_count
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id AND p.is_available = 1
        WHERE c.is_active = 1
        GROUP BY c.id
        ORDER BY c.display_order ASC, c.name ASC`,
      );
      return rows as Category[];
    } catch (error) {
      this.logger.error('Error fetching categories:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
}
