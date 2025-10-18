export interface Keyword {
  id: string;
  name: string;
  main_category_id: string;
  sub_category_id?: string | null;
  is_active: boolean;
  created_at: Date;
}



