import {Product, CreateProductDTO, UpdateProductDTO} from '../entities/product';
import {ProductImage, CreateProductImageDTO} from '../entities/productImage';
import {SearchFilters, SearchResult} from '../entities/search';

export interface ProductRepository {
  create(product: CreateProductDTO, sellerId: string): Promise<Product>;
  findById(id: string): Promise<Product | null>;
  findAll(limit?: number, offset?: number): Promise<Product[]>;
  findBySeller(sellerId: string): Promise<Product[]>;
  update(
    id: string,
    sellerId: string,
    product: UpdateProductDTO,
  ): Promise<Product>;
  delete(id: string, sellerId: string): Promise<void>;
  findByCategory(categoryId: string): Promise<Product[]>;

  // New methods for product images
  addProductImages(
    productId: string,
    images: CreateProductImageDTO[],
  ): Promise<ProductImage[]>;
  deleteProductImage(imageId: string, sellerId: string): Promise<void>;
  getProductImages(productId: string): Promise<ProductImage[]>;

  search(filters: SearchFilters): Promise<SearchResult>;

  findLatest(limit?: number): Promise<Product[]>;
  getTotalCount(): Promise<number>;

  findWithFilters(
    filters: SearchFilters,
  ): Promise<{items: Product[]; total: number}>;

  // New: find unique suppliers (users) whose products satisfy filters
  findSuppliersWithFilters(
    filters: SearchFilters,
  ): Promise<{
    items: Array<{
      id: string;
      first_name: string;
      last_name: string;
      email?: string;
      company_name?: string;
      total_products: number;
    }>;
    total: number;
  }>;
}
