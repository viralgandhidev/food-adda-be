import {injectable, inject} from 'inversify';
import {TYPES} from '../../application/di/types';
import {KeywordRepository} from '../../domain/repositories/keywordRepository';
import {DatabaseController} from '../../application/utils/databaseController';
import {Logger} from '../../application/utils/logger';
import {Keyword} from '../../domain/entities/keyword';

@injectable()
export class KeywordRepositoryImpl implements KeywordRepository {
  async findAll(): Promise<Keyword[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT * FROM keywords WHERE is_active = 1 ORDER BY name ASC`,
      );
      return rows as Keyword[];
    } catch (error) {
      this.logger.error('Error fetching all keywords:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
  constructor(
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.Logger) private logger: Logger,
  ) {}

  async findByCategory(
    mainCategoryId: string,
    subCategoryId?: string,
  ): Promise<Keyword[]> {
    const connection = await this.db.getConnection();
    try {
      let sql = `SELECT * FROM keywords WHERE is_active = 1 AND main_category_id = ?`;
      const params: any[] = [mainCategoryId];
      if (subCategoryId) {
        sql += ` AND sub_category_id = ?`;
        params.push(subCategoryId);
      }
      sql += ` ORDER BY name ASC`;
      const [rows] = await connection.execute(sql, params);
      return rows as Keyword[];
    } catch (error) {
      this.logger.error('Error fetching keywords:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findByQuery(q: string, limit: number): Promise<Keyword[]> {
    const connection = await this.db.getConnection();
    try {
      const like = `%${q}%`;
      const lim = Math.max(1, Math.min(20, limit));
      // Some MySQL setups reject bound parameters for LIMIT; inline sanitized integer
      const [rows] = await connection.query(
        `SELECT id, name FROM keywords
         WHERE is_active = 1 AND name LIKE ?
         ORDER BY name ASC
         LIMIT ${lim}`,
        [like],
      );
      return rows as Keyword[];
    } catch (error) {
      this.logger.error('Error searching keywords:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
}
