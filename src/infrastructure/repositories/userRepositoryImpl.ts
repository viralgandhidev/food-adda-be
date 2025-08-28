import {injectable, inject} from 'inversify';
import {User, UserSignUpDTO, UserStatus} from '../../domain/entities';
import {UserRepository} from '../../domain/repositories/userRepository';
import {DatabaseController} from '../../application/utils/databaseController';
import {TYPES} from '../../application/di/types';
import {Logger} from '../../application/utils/logger';
import bcrypt from 'bcrypt';

@injectable()
export class UserRepositoryImpl implements UserRepository {
  constructor(
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.Logger) private logger: Logger,
  ) {}

  async create(user: UserSignUpDTO): Promise<User> {
    const connection = await this.db.getConnection();
    try {
      await connection.beginTransaction();

      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(user.password, salt);

      const [result] = await connection.execute(
        `INSERT INTO users (
          email, password_hash, first_name, last_name, 
          phone_number, user_type, status, address,
          company_name, company_description,
          preferred_language, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
        [
          user.email,
          passwordHash,
          user.first_name,
          user.last_name,
          user.phone_number,
          user.user_type,
          UserStatus.ACTIVE,
          user.address || null,
          user.company_name || null,
          user.company_description || null,
          'English',
        ],
      );

      const insertId = (result as any).insertId;

      const [users] = await connection.execute(
        'SELECT * FROM users WHERE id = ?',
        [insertId],
      );

      await connection.commit();

      const createdUser = (users as any)[0];
      if (!createdUser) {
        throw new Error('User was not created successfully');
      }

      this.logger.info(`User created with ID: ${createdUser.id}`);
      return createdUser;
    } catch (error) {
      await connection.rollback();
      this.logger.error('Error creating user:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findByEmail(email: string): Promise<User | null> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        'SELECT * FROM users WHERE email = ?',
        [email],
      );
      return (rows as any)[0] || null;
    } catch (error) {
      this.logger.error('Error finding user by email:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async findById(id: string): Promise<User | null> {
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        'SELECT * FROM users WHERE id = ?',
        [id],
      );
      return (rows as any)[0] || null;
    } catch (error) {
      this.logger.error('Error finding user by id:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async updateLastLogin(userId: string): Promise<void> {
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        'UPDATE users SET last_login = NOW() WHERE id = ?',
        [userId],
      );
    } catch (error) {
      this.logger.error('Error updating last login:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  async updateProfile(
    userId: string,
    updateData: Partial<User>,
  ): Promise<User> {
    const connection = await this.db.getConnection();
    try {
      // Build dynamic SQL for only provided fields
      const fields = Object.keys(updateData).filter(
        key => updateData[key] !== undefined,
      );
      if (fields.length === 0) {
        throw new Error('No fields to update');
      }
      const setClause = fields.map(field => `${field} = ?`).join(', ');
      const values = fields.map(field => updateData[field]);
      values.push(userId);
      await connection.execute(
        `UPDATE users SET ${setClause}, updated_at = NOW() WHERE id = ?`,
        values,
      );
      const [rows] = await connection.execute(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );
      return (rows as any)[0];
    } catch (error) {
      this.logger.error('Error updating user profile:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
}
