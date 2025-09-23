// Lightweight migration runner without TypeORM
export interface QueryRunner {
  query: (sql: string) => Promise<any>;
}

export interface MigrationInterface {
  up(queryRunner: QueryRunner): Promise<void>;
  down(queryRunner: QueryRunner): Promise<void>;
}

export class AddFullTextIndexes implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add FULLTEXT index for products
    await queryRunner.query(`
            ALTER TABLE products 
            ADD FULLTEXT INDEX product_search_idx (name, description)
        `);

    // Add FULLTEXT index for categories
    await queryRunner.query(`
            ALTER TABLE categories 
            ADD FULLTEXT INDEX category_search_idx (name, description)
        `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove FULLTEXT indexes
    await queryRunner.query(`
            ALTER TABLE products 
            DROP INDEX product_search_idx
        `);

    await queryRunner.query(`
            ALTER TABLE categories 
            DROP INDEX category_search_idx
        `);
  }
}
