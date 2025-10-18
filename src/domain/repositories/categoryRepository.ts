import {Category} from '../entities/category';

export interface CategoryRepository {
  findAll(): Promise<Category[]>;
  findTree(): Promise<Array<Category & {children: Category[]}>>;
}
