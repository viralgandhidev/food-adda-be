export interface Category {
  id: string;
  name: string;
  description?: string;
  parent_id?: string;
  image_url?: string;
  display_order?: number;
  is_featured: boolean;
  is_active: boolean;
  created_at: Date;
  product_count?: number;
}
