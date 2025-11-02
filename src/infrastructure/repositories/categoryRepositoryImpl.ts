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
        `SELECT * FROM (
            SELECT 
              mc.id,
              mc.name,
              mc.description,
              mc.image_url,
              mc.display_order,
              mc.is_active,
              COALESCE(pm.cnt, 0) AS product_count,
              NULL AS parent_id
            FROM main_categories mc
            LEFT JOIN (
              SELECT main_category_id AS id, COUNT(*) AS cnt
              FROM products p
              WHERE p.is_available = 1
              GROUP BY main_category_id
            ) pm ON pm.id = mc.id
            WHERE mc.is_active = 1
            UNION ALL
            SELECT 
              sc.id,
              sc.name,
              sc.description,
              sc.image_url,
              sc.display_order,
              sc.is_active,
              COALESCE(ps.cnt, 0) AS product_count,
              sc.main_category_id AS parent_id
            FROM sub_categories sc
            LEFT JOIN (
              SELECT sub_category_id AS id, COUNT(*) AS cnt
              FROM products p
              WHERE p.is_available = 1
              GROUP BY sub_category_id
            ) ps ON ps.id = sc.id
            WHERE sc.is_active = 1
         ) t
         ORDER BY (parent_id IS NULL) DESC, display_order ASC, name ASC`,
      );
      return rows as any as Category[];
    } catch (error) {
      this.logger.error('Error fetching categories:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findTree(): Promise<Array<Category & {children: Category[]}>> {
    const connection = await this.db.getConnection();
    try {
      // Build from main_categories + sub_categories
      const [mains] = await connection.execute(
        `SELECT mc.id, mc.name, mc.description, mc.image_url, mc.display_order, mc.is_active,
                COALESCE(pm.cnt, 0) AS product_count
         FROM main_categories mc
         LEFT JOIN (
           SELECT main_category_id AS id, COUNT(*) AS cnt
           FROM products p WHERE p.is_available = 1
           GROUP BY main_category_id
         ) pm ON pm.id = mc.id
         WHERE mc.is_active = 1
         ORDER BY mc.display_order ASC, mc.name ASC`,
      );
      const [subs] = await connection.execute(
        `SELECT sc.id, sc.main_category_id as parent_id, sc.name, sc.description, sc.image_url,
                sc.display_order, sc.is_active, COALESCE(ps.cnt, 0) AS product_count
         FROM sub_categories sc
         LEFT JOIN (
           SELECT sub_category_id AS id, COUNT(*) AS cnt
           FROM products p WHERE p.is_available = 1
           GROUP BY sub_category_id
         ) ps ON ps.id = sc.id
         WHERE sc.is_active = 1
         ORDER BY sc.display_order ASC, sc.name ASC`,
      );
      const cats = (
        [...((mains as any[]) || [])].map(m => ({
          ...m,
          parent_id: null,
        })) as any[]
      ).concat((subs as any[]) || []) as Category[];
      const byId = new Map<string, Category & {children: Category[]}>();
      const roots: Array<Category & {children: Category[]}> = [];
      for (const c of cats) {
        byId.set(c.id, {...c, children: []});
      }
      for (const c of cats) {
        const node = byId.get(c.id)!;
        if (c.parent_id) {
          const parent = byId.get(c.parent_id);
          if (parent) parent.children.push(node);
          else roots.push(node); // fallback if parent missing
        } else {
          roots.push(node);
        }
      }
      return roots;
    } catch (error) {
      this.logger.error('Error fetching category tree:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
}
