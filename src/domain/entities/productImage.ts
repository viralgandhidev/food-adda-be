export interface ProductImage {
  id: string;
  product_id: string;
  image_url: string;
  order: number;
  created_at: Date;
  updated_at: Date;
}

export interface CreateProductImageDTO {
  id?: string;
  image_url?: string;
  order: number;
}
