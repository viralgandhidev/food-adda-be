export interface ProductImage {
  id: string;
  product_id: string;
  image_url: string;
  created_at: Date;
  updated_at: Date;
}

export interface CreateProductImageDTO {
  image_url: string;
}
