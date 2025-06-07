import {Category} from '../entities/category';

export interface CategoryRepository {
  findAll(): Promise<Category[]>;
}
