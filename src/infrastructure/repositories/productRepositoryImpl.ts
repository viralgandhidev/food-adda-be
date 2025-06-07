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

      // Insert main product with the generated UUID
      await connection.execute(
        `INSERT INTO products (
                    id, name, description, price, category_id, seller_id,
                    image_url, is_veg, is_available, preparation_time
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, true, ?)`,
        [
          productId,
          product.name,
          product.description,
          product.price,
          product.category_id,
          sellerId,
          product.image_url,
          product.is_veg ? 1 : 0,
          product.preparation_time,
        ],
      );

      // Insert product images if provided
      if (product.images && product.images.length > 0) {
        const values = product.images.map(() => '(UUID(), ?, ?)').join(',');
        const params = product.images.reduce(
          (acc, img) => [...acc, productId, img.image_url],
          [] as any[],
        );

        await connection.execute(
          `INSERT INTO product_images (id, product_id, image_url) VALUES ${values}`,
          params,
        );
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
      return product;
    } catch (error) {
      this.logger.error('Error finding product:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findAll(): Promise<Product[]> {
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
                ORDER BY p.name ASC`,
      );

      // Fetch images for all products
      const products = rows as Product[];
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
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

      // Separate images from other product data
      const {images, ...productData} = product;

      // Only update product fields if there are any changes
      if (Object.keys(productData).length > 0) {
        const updates = Object.entries(productData)
          .filter(([_, value]) => value !== undefined)
          .map(([key, _]) => `${key} = ?`)
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
        // Delete existing images
        await connection.execute(
          'DELETE FROM product_images WHERE product_id = ?',
          [id],
        );

        // Add new images
        if (images.length > 0) {
          const values = images.map(() => '(UUID(), ?, ?)').join(',');
          const params = images.reduce(
            (acc, img) => [...acc, id, img.image_url],
            [] as any[],
          );

          await connection.execute(
            `INSERT INTO product_images (id, product_id, image_url) VALUES ${values}`,
            params,
          );
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
        'SELECT * FROM product_images WHERE product_id = ? ORDER BY created_at ASC',
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
      const values = images.map(() => '(UUID(), ?, ?)').join(',');
      const params = images.reduce(
        (acc, img) => [...acc, productId, img.image_url],
        [] as any[],
      );

      await connection.execute(
        `INSERT INTO product_images (id, product_id, image_url) VALUES ${values}`,
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
      const query = filters.query?.trim() || '';
      const searchTerms = `%${query}%`;

      // Build product search query
      let productQuery = `
          SELECT 
              p.*,
              c.name as category_name,
              MATCH(p.name, p.description) AGAINST(? IN NATURAL LANGUAGE MODE) as relevance_score
          FROM products p
          LEFT JOIN categories c ON p.category_id = c.id
          WHERE p.is_available = 1
      `;

      let params: any[] = [query];

      if (query) {
        productQuery += ` AND MATCH(p.name, p.description) AGAINST(? IN NATURAL LANGUAGE MODE)`;
        params.push(query);
      }

      if (filters.categoryId) {
        productQuery += ` AND p.category_id = ?`;
        params.push(filters.categoryId);
      }

      if (filters.isVeg !== undefined) {
        productQuery += ` AND p.is_veg = ?`;
        params.push(filters.isVeg ? 1 : 0);
      }

      if (filters.minPrice !== undefined) {
        productQuery += ` AND p.price >= ?`;
        params.push(filters.minPrice);
      }

      if (filters.maxPrice !== undefined) {
        productQuery += ` AND p.price <= ?`;
        params.push(filters.maxPrice);
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
            productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
        }
      } else if (query) {
        productQuery += ` ORDER BY relevance_score DESC, p.name ASC`;
      } else {
        productQuery += ` ORDER BY p.name ASC`;
      }

      // Execute product search
      const [productRows] = await connection.execute(productQuery, params);
      const products = productRows as any[];

      // Fetch images for products
      for (const product of products) {
        product.images = await this.getProductImages(product.id);
      }

      // Build category search query
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
          total: products.length,
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
}
