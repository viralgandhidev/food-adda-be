import {CreateProductImageDTO, ProductImage} from './productImage';

export interface ProductMetric {
  id: string;
  product_id: string;
  key: string;
  value: string;
}

export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  category_id: string;
  seller_id: string;
  image_url?: string;
  is_veg: boolean;
  is_available: boolean;
  preparation_time: number;
  created_at: Date;
  updated_at: Date;
  category_name?: string;
  seller_first_name?: string;
  seller_last_name?: string;
  images?: ProductImage[];
  brand?: string;
  metrics?: ProductMetric[];
}

export interface CreateProductDTO {
  name: string;
  description: string;
  price: number;
  category_id: string;
  image_url?: string;
  is_veg: boolean;
  preparation_time: number;
  images?: CreateProductImageDTO[];
  metrics?: {key: string; value: string}[];
}

export interface UpdateProductDTO extends Partial<CreateProductDTO> {
  is_available?: boolean;
  metrics?: {key: string; value: string}[];
}
