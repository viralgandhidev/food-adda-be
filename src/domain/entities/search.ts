export interface SearchFilters {
  query?: string;
  categoryId?: string;
  mainCategoryId?: string;
  subCategoryId?: string;
  sellerId?: string;
  keywordId?: string;
  keywordIds?: string[];
  minPrice?: number;
  maxPrice?: number;
  isVeg?: boolean;
  sortBy?: 'price' | 'name' | 'preparation_time';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  limit?: number;
}

export interface SearchResult {
  products: {
    items: Array<{
      id: string;
      name: string;
      description: string;
      price: number;
      category_id: string;
      category_name: string;
      is_veg: boolean;
      preparation_time: number;
      image_url?: string;
      images?: Array<{id: string; image_url: string}>;
      relevance_score?: number;
    }>;
    total: number;
  };
  categories: {
    items: Array<{
      id: string;
      name: string;
      description?: string;
      image_url?: string;
      product_count: number;
      relevance_score?: number;
    }>;
    total: number;
  };
}
