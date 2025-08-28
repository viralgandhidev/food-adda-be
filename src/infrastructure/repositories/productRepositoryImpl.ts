import {injectable, inject} from 'inversify';
import {TYPES} from '../../application/di/types';
import {
  Product,
  CreateProductDTO,
  UpdateProductDTO,
} from '../../domain/entities/product';
import {ProductRepository} from '../../domain/repositories/productRepository';
import {DatabaseController} from '../../application/utils/databaseController';
import {Logger} from '../../application/utils/logger';
import {
  NotFoundError,
  UnauthorizedError,
} from '../../application/utils/appErrors';
import {
  ProductImage,
  CreateProductImageDTO,
} from '../../domain/entities/productImage';
import {SearchFilters, SearchResult} from '../../domain/entities/search';

@injectable()
export class ProductRepositoryImpl implements ProductRepository {
  constructor(
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.Logger) private logger: Logger,
  ) {}

  async create(product: CreateProductDTO, sellerId: string): Promise<Product> {
    const connection = await this.db.getConnection();
    try {
      await connection.beginTransaction();

      // Generate UUID for the product
      const [uuidResult] = await connection.execute('SELECT UUID() as uuid');
      const productId = (uuidResult as any[])[0].uuid;

      // Helper to ensure no undefined values
      const safe = (v: any) => (v === undefined ? null : v);

      // Insert main product with the generated UUID
      await connection.execute(
        `INSERT INTO products (
                    id, name, description, price, category_id, seller_id,
                    image_url, is_veg, is_available, preparation_time
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, true, ?)`,
        [
          productId,
          safe(product.name),
          safe(product.description),
          safe(product.price),
          safe(product.category_id),
          safe(sellerId),
          safe(product.image_url),
          safe(product.is_veg) ? 1 : 0,
          safe(product.preparation_time),
        ],
      );

      // Insert product images if provided
      if (product.images && product.images.length > 0) {
        const values = product.images.map(() => '(UUID(), ?, ?, ?)').join(',');
        const params = product.images.reduce(
          (acc, img) => [...acc, productId, img.image_url, img.order],
          [] as any[],
        );

        await connection.execute(
          `INSERT INTO product_images (id, product_id, image_url, \`order\`) VALUES ${values}`,
          params,
        );
      }

      // Insert product metrics if provided
      if (product.metrics && product.metrics.length > 0) {
        await this.insertProductMetrics(connection, productId, product.metrics);
      }

      await connection.commit();
      return this.findById(productId) as Promise<Product>;
    } catch (error) {
      await connection.rollback();
      this.logger.error('Error creating product:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findById(id: string): Promise<Product | null> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, 
                    c.name as category_name,
                    u.first_name as seller_first_name,
                    u.last_name as seller_last_name
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.id
                LEFT JOIN users u ON p.seller_id = u.id
                WHERE p.id = ?`,
        [id],
      );
      const products = rows as any[];
      if (products.length === 0) return null;

      const product = products[0] as Product;
      // Fetch images for the product
      product.images = await this.getProductImages(id);
      product.brand = (
        (product.seller_first_name || '') +
        ' ' +
        (product.seller_last_name || '')
      ).trim();
      // Fetch metrics for the product
      product.metrics = await this.getProductMetrics(connection, id);
      return product;
    } catch (error) {
      this.logger.error('Error finding product:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findAll(limit?: number, offset?: number): Promise<Product[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, 
                c.name as category_name,
                u.first_name as seller_first_name,
                u.last_name as seller_last_name
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN users u ON p.seller_id = u.id
            WHERE p.is_available = 1
            ORDER BY p.name ASC
            ${limit ? `LIMIT ${limit}` : ''}
            ${offset ? `OFFSET ${offset}` : ''}`,
      );

      // Fetch images for all products
      const products = rows as Product[];
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }

      return products;
    } catch (error) {
      this.logger.error('Error fetching products:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findBySeller(sellerId: string): Promise<Product[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, 
                    c.name as category_name,
                    u.first_name as seller_first_name,
                    u.last_name as seller_last_name
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.id
                LEFT JOIN users u ON p.seller_id = u.id
                WHERE p.seller_id = ?
                ORDER BY p.name ASC`,
        [sellerId],
      );

      // Fetch images for all products
      const products = rows as Product[];
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }

      return products;
    } catch (error) {
      this.logger.error('Error fetching seller products:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findByCategory(categoryId: string): Promise<Product[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, 
                    c.name as category_name,
                    u.first_name as seller_first_name,
                    u.last_name as seller_last_name
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.id
                LEFT JOIN users u ON p.seller_id = u.id
                WHERE p.category_id = ? AND p.is_available = 1
                ORDER BY p.name ASC`,
        [categoryId],
      );

      // Fetch images for all products
      const products = rows as Product[];
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }

      return products;
    } catch (error) {
      this.logger.error('Error fetching products by category:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async update(
    id: string,
    sellerId: string,
    product: UpdateProductDTO,
  ): Promise<Product> {
    const connection = await this.db.getConnection();
    try {
      await connection.beginTransaction();

      const existingProduct = await this.findById(id);
      if (!existingProduct) {
        throw new NotFoundError('Product not found');
      }
      if (existingProduct.seller_id !== sellerId) {
        throw new UnauthorizedError('Not authorized to update this product');
      }

      // Separate images and metrics from other product data
      const {images, metrics, ...productData} = product;
      // Remove 'order' if present
      if ('order' in productData) {
        delete (productData as any).order;
      }

      // Only update product fields if there are any changes
      if (Object.keys(productData).length > 0) {
        const updates = Object.entries(productData)
          .filter(([_, value]) => value !== undefined)
          .map(([key, _]) => `${key === 'order' ? '`order`' : key} = ?`)
          .join(', ');

        const values = Object.entries(productData)
          .filter(([_, value]) => value !== undefined)
          .map(([_, value]) =>
            value === true ? 1 : value === false ? 0 : value,
          );

        if (updates.length > 0) {
          await connection.execute(
            `UPDATE products SET ${updates} WHERE id = ? AND seller_id = ?`,
            [...values, id, sellerId],
          );
        }
      }

      // Handle image updates if provided
      if (images) {
        // Update order for existing images if order is provided
        for (const img of images) {
          if (img.id) {
            if (img.order !== undefined) {
              await connection.execute(
                'UPDATE product_images SET `order` = ? WHERE id = ? AND product_id = ?',
                [img.order, img.id, id],
              );
            }
          }
        }
        // Add new images
        const newImages = images.filter(img => !img.id && img.image_url);
        if (newImages.length > 0) {
          const values = newImages.map(() => '(UUID(), ?, ?, ?)').join(',');
          const params = newImages.reduce(
            (acc, img) => [...acc, id, img.image_url, img.order ?? 0],
            [] as any[],
          );
          await connection.execute(
            `INSERT INTO product_images (id, product_id, image_url, \`order\`) VALUES ${values}`,
            params,
          );
        }
      }

      // Handle metrics update
      if (metrics) {
        await this.deleteProductMetrics(connection, id);
        if (metrics.length > 0) {
          await this.insertProductMetrics(connection, id, metrics);
        }
      }

      await connection.commit();
      return this.findById(id) as Promise<Product>;
    } catch (error) {
      await connection.rollback();
      this.logger.error('Error updating product:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async delete(id: string, sellerId: string): Promise<void> {
    const connection = await this.db.getConnection();
    try {
      await connection.beginTransaction();

      const existingProduct = await this.findById(id);
      if (!existingProduct) {
        throw new NotFoundError('Product not found');
      }
      if (existingProduct.seller_id !== sellerId) {
        throw new UnauthorizedError('Not authorized to delete this product');
      }

      // Delete all product metrics first
      await this.deleteProductMetrics(connection, id);

      // Delete all product images first
      await connection.execute(
        'DELETE FROM product_images WHERE product_id = ?',
        [id],
      );

      // Then delete the product
      await connection.execute(
        'DELETE FROM products WHERE id = ? AND seller_id = ?',
        [id, sellerId],
      );

      await connection.commit();
    } catch (error) {
      await connection.rollback();
      this.logger.error('Error deleting product:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async getProductImages(productId: string): Promise<ProductImage[]> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT * FROM product_images WHERE product_id = ? ORDER BY \`order\` ASC`,
        [productId],
      );
      return rows as ProductImage[];
    } catch (error) {
      this.logger.error('Error fetching product images:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async addProductImages(
    productId: string,
    images: CreateProductImageDTO[],
  ): Promise<ProductImage[]> {
    const connection = await this.db.getConnection();
    try {
      const values = images.map(() => '(UUID(), ?, ?, ?)').join(',');
      const params = images.reduce(
        (acc, img) => [...acc, productId, img.image_url, img.order],
        [] as any[],
      );

      await connection.execute(
        `INSERT INTO product_images (id, product_id, image_url, \`order\`) VALUES ${values}`,
        params,
      );

      return this.getProductImages(productId);
    } catch (error) {
      this.logger.error('Error adding product images:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async deleteProductImage(imageId: string, sellerId: string): Promise<void> {
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        `DELETE pi FROM product_images pi
        JOIN products p ON pi.product_id = p.id
        WHERE pi.id = ? AND p.seller_id = ?`,
        [imageId, sellerId],
      );
    } catch (error) {
      this.logger.error('Error deleting product image:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async search(filters: SearchFilters): Promise<SearchResult> {
    const connection = await this.db.getConnection();
    try {
      const query = filters.query?.trim();
      const page = filters.page && filters.page > 0 ? filters.page : 1;
      const limit = filters.limit && filters.limit > 0 ? filters.limit : 20;
      const offset = (page - 1) * limit;

      // Build product search query and params
      let productQuery = `
        SELECT 
          p.*,
          c.name as category_name
          ${
            query
              ? ', MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE) as relevance_score'
              : ''
          }
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_available = 1
      `;
      let countQuery = `
        SELECT COUNT(*) as total
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_available = 1
      `;
      const params: (string | number | boolean)[] = [];
      const countParams: (string | number | boolean)[] = [];

      if (query) {
        // If MATCH is in SELECT, push query for SELECT (with * for prefix search)
        params.push(query + '*');
        // If MATCH is in WHERE, push query for WHERE (with * for prefix search)
        productQuery += ` AND MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE)`;
        countQuery += ` AND MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE)`;
        params.push(query + '*');
        countParams.push(query + '*');
      }
      if (
        filters.categoryId !== undefined &&
        filters.categoryId !== null &&
        filters.categoryId !== ''
      ) {
        productQuery += ` AND p.category_id = ?`;
        countQuery += ` AND p.category_id = ?`;
        params.push(filters.categoryId);
        countParams.push(filters.categoryId);
      }
      if (filters.isVeg !== undefined && filters.isVeg !== null) {
        productQuery += ` AND p.is_veg = ?`;
        countQuery += ` AND p.is_veg = ?`;
        params.push(filters.isVeg ? 1 : 0);
        countParams.push(filters.isVeg ? 1 : 0);
      }
      if (filters.minPrice !== undefined && filters.minPrice !== null) {
        productQuery += ` AND p.price >= ?`;
        countQuery += ` AND p.price >= ?`;
        params.push(filters.minPrice);
        countParams.push(filters.minPrice);
      }
      if (filters.maxPrice !== undefined && filters.maxPrice !== null) {
        productQuery += ` AND p.price <= ?`;
        countQuery += ` AND p.price <= ?`;
        params.push(filters.maxPrice);
        countParams.push(filters.maxPrice);
      }
      // Add sorting
      if (filters.sortBy) {
        const sortOrder =
          filters.sortOrder?.toUpperCase() === 'DESC' ? 'DESC' : 'ASC';
        switch (filters.sortBy) {
          case 'price':
            productQuery += ` ORDER BY p.price ${sortOrder}`;
            break;
          case 'name':
            productQuery += ` ORDER BY p.name ${sortOrder}`;
            break;
          case 'preparation_time':
            productQuery += ` ORDER BY p.preparation_time ${sortOrder}`;
            break;
          default:
            if (query) {
              productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
            } else {
              productQuery += ` ORDER BY p.name ASC`;
            }
        }
      } else if (query) {
        productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
      } else {
        productQuery += ` ORDER BY p.name ASC`;
      }
      // Add pagination (directly in SQL, not as params)
      productQuery += ` LIMIT ${Number(limit)} OFFSET ${Number(offset)}`;

      // Execute product search
      const [productRows] = await connection.execute(productQuery, params);
      const [countRows] = await connection.execute(countQuery, countParams);
      const total = (countRows as any[])[0]?.total || 0;
      const products = productRows as any[];
      // Fetch images for products
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }
      // Build category search query (unchanged)
      const categoryQuery = `
        SELECT 
          c.*,
          COUNT(p.id) as product_count,
          MATCH(c.name, c.description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance_score
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id AND p.is_available = 1
        WHERE c.is_active = 1
        ${
          query
            ? 'AND MATCH(c.name, c.description) AGAINST(? IN NATURAL LANGUAGE MODE)'
            : ''
        }
        GROUP BY c.id
        ORDER BY ${query ? 'relevance_score DESC,' : ''} c.name ASC
      `;
      // Execute category search
      const [categoryRows] = await connection.execute(
        categoryQuery,
        query ? [query, query] : [query],
      );
      return {
        products: {
          items: products,
          total,
        },
        categories: {
          items: categoryRows as any[],
          total: (categoryRows as any[]).length,
        },
      };
    } catch (error) {
      this.logger.error('Error searching:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findLatest(limit: number = 20): Promise<Product[]> {
    const connection = await this.db.getConnection();
    try {
      const safeLimit = Math.max(1, Math.min(Number(limit) || 20, 100));
      const [rows] = await connection.execute(
        `SELECT p.*, 
                c.name as category_name,
                u.first_name as seller_first_name,
                u.last_name as seller_last_name
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN users u ON p.seller_id = u.id
            WHERE p.is_available = 1
            ORDER BY p.updated_at DESC
            LIMIT ${safeLimit}`,
      );
      const products = rows as Product[];
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }
      return products;
    } catch (error) {
      this.logger.error('Error fetching latest products:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async getTotalCount(): Promise<number> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT COUNT(*) as total
         FROM products p
         WHERE p.is_available = 1`,
      );
      return (rows as any[])[0].total;
    } catch (error) {
      this.logger.error('Error getting total product count:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findWithFilters(
    filters: SearchFilters,
  ): Promise<{items: Product[]; total: number}> {
    const connection = await this.db.getConnection();
    try {
      const query = filters.query?.trim();
      const page = filters.page && filters.page > 0 ? filters.page : 1;
      const limit = filters.limit && filters.limit > 0 ? filters.limit : 20;
      const offset = (page - 1) * limit;

      let productQuery = `
        SELECT 
          p.*,
          c.name as category_name
          ${
            query
              ? ', MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE) as relevance_score'
              : ''
          }
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_available = 1
      `;
      let countQuery = `
        SELECT COUNT(*) as total
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.is_available = 1
      `;
      const params: (string | number | boolean)[] = [];
      const countParams: (string | number | boolean)[] = [];

      if (query) {
        // If MATCH is in SELECT, push query for SELECT (with * for prefix search)
        params.push(query + '*');
        // If MATCH is in WHERE, push query for WHERE (with * for prefix search)
        productQuery += ` AND MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE)`;
        countQuery += ` AND MATCH(p.name, p.description) AGAINST(? IN BOOLEAN MODE)`;
        params.push(query + '*');
        countParams.push(query + '*');
      }
      if (
        filters.categoryId !== undefined &&
        filters.categoryId !== null &&
        filters.categoryId !== ''
      ) {
        productQuery += ` AND p.category_id = ?`;
        countQuery += ` AND p.category_id = ?`;
        params.push(filters.categoryId);
        countParams.push(filters.categoryId);
      }
      if (filters.isVeg !== undefined && filters.isVeg !== null) {
        productQuery += ` AND p.is_veg = ?`;
        countQuery += ` AND p.is_veg = ?`;
        params.push(filters.isVeg ? 1 : 0);
        countParams.push(filters.isVeg ? 1 : 0);
      }
      if (filters.minPrice !== undefined && filters.minPrice !== null) {
        productQuery += ` AND p.price >= ?`;
        countQuery += ` AND p.price >= ?`;
        params.push(filters.minPrice);
        countParams.push(filters.minPrice);
      }
      if (filters.maxPrice !== undefined && filters.maxPrice !== null) {
        productQuery += ` AND p.price <= ?`;
        countQuery += ` AND p.price <= ?`;
        params.push(filters.maxPrice);
        countParams.push(filters.maxPrice);
      }
      // Add sorting
      if (filters.sortBy) {
        const sortOrder =
          filters.sortOrder?.toUpperCase() === 'DESC' ? 'DESC' : 'ASC';
        switch (filters.sortBy) {
          case 'price':
            productQuery += ` ORDER BY p.price ${sortOrder}`;
            break;
          case 'name':
            productQuery += ` ORDER BY p.name ${sortOrder}`;
            break;
          case 'preparation_time':
            productQuery += ` ORDER BY p.preparation_time ${sortOrder}`;
            break;
          default:
            if (query) {
              productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
            } else {
              productQuery += ` ORDER BY p.name ASC`;
            }
        }
      } else if (query) {
        productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
      } else {
        productQuery += ` ORDER BY p.name ASC`;
      }
      // Add pagination
      productQuery += ` LIMIT ${Number(limit)} OFFSET ${Number(offset)}`;

      // Execute product search
      const [productRows] = await connection.execute(productQuery, params);
      const [countRows] = await connection.execute(countQuery, countParams);
      const total = (countRows as any[])[0]?.total || 0;
      const products = productRows as any[];
      // Fetch images for products
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }
      return {items: products, total};
    } catch (error) {
      this.logger.error('Error searching:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  // Add helper methods for metrics
  async insertProductMetrics(
    connection: any,
    productId: string,
    metrics: {key: string; value: string}[],
  ) {
    if (!metrics || metrics.length === 0) return;
    const values = metrics.map(() => '(UUID(), ?, ?, ?)').join(',');
    const params = metrics.flatMap(m => [productId, m.key, m.value]);
    await connection.execute(
      `INSERT INTO product_metrics (id, product_id, \`key\`, \`value\`) VALUES ${values}`,
      params,
    );
  }

  async getProductMetrics(connection: any, productId: string) {
    const [rows] = await connection.execute(
      'SELECT id, product_id, `key`, `value` FROM product_metrics WHERE product_id = ?',
      [productId],
    );
    return rows;
  }

  async deleteProductMetrics(connection: any, productId: string) {
    await connection.execute(
      'DELETE FROM product_metrics WHERE product_id = ?',
      [productId],
    );
  }
}
