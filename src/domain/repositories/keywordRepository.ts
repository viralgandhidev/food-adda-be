import {Keyword} from '../entities/keyword';

export interface KeywordRepository {
  findAll(): Promise<Keyword[]>;
  findByCategory(
    mainCategoryId: string,
    subCategoryId?: string,
  ): Promise<Keyword[]>;
}
