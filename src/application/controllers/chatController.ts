import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {DatabaseController} from '../utils/databaseController';
import {AuthMiddleware} from '../middleware/authenticate';
import {asyncHandler} from '../utils/asyncHandler';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

@injectable()
export class ChatController {
  private router: Router;
  private upload: multer.Multer;

  constructor(
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.AuthMiddleware) private authMiddleware: AuthMiddleware,
  ) {
    this.router = Router();
    // Setup multer for file uploads
    const storage = multer.diskStorage({
      destination: (req, file, cb) => {
        const dest = path.join(process.cwd(), 'uploads', 'chat');
        if (!fs.existsSync(dest)) {
          fs.mkdirSync(dest, {recursive: true});
        }
        cb(null, dest);
      },
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + '-' + file.originalname);
      },
    });
    this.upload = multer({
      storage,
      limits: {fileSize: 10 * 1024 * 1024}, // 10MB limit
    });
    console.log('ChatController: About to initialize routes');
    this.initializeRoutes();
    console.log('ChatController: Routes initialized');
  }

  private initializeRoutes(): void {
    // All chat routes require authentication
    // Subscription check only for consumers (not suppliers)
    console.log('initializeRoutes: Starting route registration');
    this.logger.info('Initializing chat routes...');

    this.router.get(
      '/',
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscriptionOrSupplier),
      asyncHandler(this.getChats.bind(this)),
    );
    this.router.get(
      '/unread-count',
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscriptionOrSupplier),
      asyncHandler(this.getUnreadCount.bind(this)),
    );
    this.router.get(
      '/:chatId/messages',
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscriptionOrSupplier),
      asyncHandler(this.getMessages.bind(this)),
    );
    // POST route for sending messages with optional file attachment
    this.router.post(
      '/:chatId/messages',
      (req, res, next) => {
        console.log(
          `[ROUTE MATCH] POST /chat/:chatId/messages - chatId: ${req.params.chatId}, path: ${req.path}, originalUrl: ${req.originalUrl}`,
        );
        this.logger.info(
          `[ROUTE] POST /chat/:chatId/messages matched - chatId: ${req.params.chatId}`,
        );
        next();
      },
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscriptionOrSupplier),
      this.upload.single('attachment'),
      asyncHandler(this.sendMessage.bind(this)),
    );
    this.router.post(
      '/',
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscription),
      asyncHandler(this.createChat.bind(this)),
    );
    this.router.post(
      '/:chatId/read',
      this.authMiddleware.authenticate,
      asyncHandler(this.checkSubscriptionOrSupplier),
      asyncHandler(this.markChatAsRead.bind(this)),
    );

    // Debug: Catch-all route to see if requests reach this router
    this.router.all('*', (req, res, next) => {
      console.log(
        `[CHAT ROUTER CATCH-ALL] ${req.method} ${req.path} - originalUrl: ${req.originalUrl}`,
      );
      next();
    });

    console.log('initializeRoutes: All routes registered');
    this.logger.info('Chat routes initialized');
  }

  // Middleware to check if user has active subscription (required for consumers)
  private checkSubscription = async (
    req: Request,
    res: Response,
    next: any,
  ): Promise<void> => {
    const userId = (req as any).user?.id as string;
    if (!userId) {
      res.status(401).json({success: false, message: 'Unauthorized'});
      return;
    }

    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT id FROM subscriptions
         WHERE user_id = ? AND status = 'ACTIVE'
         ORDER BY created_at DESC LIMIT 1`,
        [userId],
      );
      const subscription = (rows as any[])[0];
      if (!subscription) {
        res.status(403).json({
          success: false,
          message: 'Active subscription required to use chat',
        });
        return;
      }
      next();
    } catch (error) {
      next(error);
    } finally {
      connection.release();
    }
  };

  // Middleware to check subscription OR if user is a supplier
  private checkSubscriptionOrSupplier = async (
    req: Request,
    res: Response,
    next: any,
  ): Promise<void> => {
    const userId = (req as any).user?.id as string;
    const userType = (req as any).user?.user_type as string;
    if (!userId) {
      res.status(401).json({success: false, message: 'Unauthorized'});
      return;
    }

    // Suppliers don't need subscription to view/reply to chats
    if (userType === 'SELLER') {
      next();
      return;
    }

    // For consumers, check subscription
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT id FROM subscriptions
         WHERE user_id = ? AND status = 'ACTIVE'
         ORDER BY created_at DESC LIMIT 1`,
        [userId],
      );
      const subscription = (rows as any[])[0];
      if (!subscription) {
        res.status(403).json({
          success: false,
          message: 'Active subscription required to use chat',
        });
        return;
      }
      next();
    } catch (error) {
      next(error);
    } finally {
      connection.release();
    }
  };

  // Get all chats for the authenticated user (as consumer or supplier)
  private async getChats(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const userType = (req as any).user?.user_type as string;
    const connection = await this.db.getConnection();

    try {
      let chats: any[];

      if (userType === 'SELLER') {
        // For suppliers: get chats where they are the supplier (join with user to get consumer info)
        const [chatRows] = await connection.execute(
          `SELECT 
            c.id,
            c.user_id,
            c.supplier_id,
            u.first_name,
            u.last_name,
            u.company_name,
            u.profile_image_url,
            c.updated_at,
            (SELECT message_text FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message,
            (SELECT created_at FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message_time,
            (SELECT sender_id FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message_sender_id,
            (SELECT COUNT(*) 
             FROM messages m
             LEFT JOIN chat_read_status crs ON crs.chat_id = c.id AND crs.user_id = ?
             WHERE m.chat_id = c.id 
             AND m.sender_id != ?
             AND (crs.last_read_message_id IS NULL OR m.id > crs.last_read_message_id)
            ) as unread_count
          FROM chats c
          JOIN users u ON c.user_id = u.id
          WHERE c.supplier_id = ?
          ORDER BY c.updated_at DESC`,
          [userId, userId, userId],
        );
        chats = chatRows as any[];
      } else {
        // For consumers: get chats where they are the user (join with supplier to get supplier info)
        const [chatRows] = await connection.execute(
          `SELECT 
            c.id,
            c.user_id,
            c.supplier_id,
            u.first_name,
            u.last_name,
            u.company_name,
            u.profile_image_url,
            c.updated_at,
            (SELECT message_text FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message,
            (SELECT created_at FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message_time,
            (SELECT sender_id FROM messages 
             WHERE chat_id = c.id 
             ORDER BY created_at DESC 
             LIMIT 1) as last_message_sender_id,
            (SELECT COUNT(*) 
             FROM messages m
             LEFT JOIN chat_read_status crs ON crs.chat_id = c.id AND crs.user_id = ?
             WHERE m.chat_id = c.id 
             AND m.sender_id != ?
             AND (crs.last_read_message_id IS NULL OR m.id > crs.last_read_message_id)
            ) as unread_count
          FROM chats c
          JOIN users u ON c.supplier_id = u.id
          WHERE c.user_id = ?
          ORDER BY c.updated_at DESC`,
          [userId, userId, userId],
        );
        chats = chatRows as any[];
      }

      res.json({success: true, data: chats});
    } catch (error) {
      this.logger.error('Error fetching chats', error);
      res.status(500).json({success: false, message: 'Failed to fetch chats'});
    } finally {
      connection.release();
    }
  }

  // Get messages for a specific chat
  private async getMessages(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const chatId = req.params.chatId;
    const connection = await this.db.getConnection();

    try {
      // Verify user is part of this chat (either user_id or supplier_id)
      const [chatRows] = await connection.execute(
        'SELECT id, user_id, supplier_id FROM chats WHERE id = ? AND (user_id = ? OR supplier_id = ?)',
        [chatId, userId, userId],
      );

      if ((chatRows as any[]).length === 0) {
        res.status(404).json({success: false, message: 'Chat not found'});
        return;
      }

      // Get messages - optionally filter by last_message_id to fetch only new messages
      const lastMessageId = req.query.last_message_id as string | undefined;
      
      // Check if attachment columns exist first
      const [columnCheck] = await connection.execute(
        `SELECT COUNT(*) as count
         FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE()
         AND TABLE_NAME = 'messages'
         AND COLUMN_NAME IN ('attachment_url', 'attachment_type')`,
      );
      const hasAttachmentColumns =
        ((columnCheck as any[])[0]?.count || 0) === 2;

      let query: string;
      let params: any[];
      
      if (hasAttachmentColumns) {
        if (lastMessageId) {
          query = `SELECT 
            id,
            sender_id,
            message_text,
            attachment_url,
            attachment_type,
            created_at
          FROM messages
          WHERE chat_id = ? AND id > ?
          ORDER BY created_at ASC`;
          params = [chatId, lastMessageId];
        } else {
          query = `SELECT 
            id,
            sender_id,
            message_text,
            attachment_url,
            attachment_type,
            created_at
          FROM messages
          WHERE chat_id = ?
          ORDER BY created_at ASC`;
          params = [chatId];
        }
      } else {
        if (lastMessageId) {
          query = `SELECT 
            id,
            sender_id,
            message_text,
            created_at
          FROM messages
          WHERE chat_id = ? AND id > ?
          ORDER BY created_at ASC`;
          params = [chatId, lastMessageId];
        } else {
          query = `SELECT 
            id,
            sender_id,
            message_text,
            created_at
          FROM messages
          WHERE chat_id = ?
          ORDER BY created_at ASC`;
          params = [chatId];
        }
      }

      const [messageRows] = await connection.execute(query, params);
      const messages = (messageRows as any[]).map((msg: any) => ({
        ...msg,
        attachment_url: msg.attachment_url || null,
        attachment_type: msg.attachment_type || null,
      }));
      res.json({success: true, data: messages});
    } catch (error) {
      this.logger.error('Error fetching messages', error);
      res
        .status(500)
        .json({success: false, message: 'Failed to fetch messages'});
    } finally {
      connection.release();
    }
  }

  // Send a message in a chat
  private async sendMessage(req: Request, res: Response): Promise<void> {
    this.logger.info('sendMessage handler called');
    const userId = (req as any).user?.id as string;
    const chatId = req.params.chatId;

    this.logger.info(`Sending message to chat ${chatId} by user ${userId}`);

    if (!chatId) {
      res.status(400).json({success: false, message: 'Chat ID is required'});
      return;
    }

    const {message_text, attachment_type} = req.body;
    const file = (req as any).file;

    this.logger.info(
      `Message data: text=${message_text}, attachment_type=${attachment_type}, file=${
        file ? file.originalname : 'none'
      }`,
    );

    // Message text is optional if there's an attachment
    if ((!message_text || !message_text.trim()) && !file) {
      res.status(400).json({
        success: false,
        message: 'Message text or attachment is required',
      });
      return;
    }

    const connection = await this.db.getConnection();

    try {
      // Verify user is part of this chat (either user_id or supplier_id)
      const [chatRows] = await connection.execute(
        'SELECT id, user_id, supplier_id FROM chats WHERE id = ? AND (user_id = ? OR supplier_id = ?)',
        [chatId, userId, userId],
      );

      if ((chatRows as any[]).length === 0) {
        this.logger.warn(
          `Chat ${chatId} not found or user ${userId} doesn't have access`,
        );
        res.status(404).json({
          success: false,
          message: 'Chat not found or you do not have access to this chat',
          chatId: chatId,
          userId: userId,
        });
        return;
      }

      // Handle file upload
      let attachmentUrl = null;
      let finalAttachmentType = attachment_type || null;
      if (file) {
        attachmentUrl = `/uploads/chat/${file.filename}`;
        // Determine attachment type from mime type
        if (!finalAttachmentType) {
          if (file.mimetype.startsWith('image/')) {
            finalAttachmentType = 'image';
          } else if (file.mimetype.startsWith('audio/')) {
            finalAttachmentType = 'voice';
          } else {
            finalAttachmentType = 'file';
          }
        }
      }

      // Insert message
      const messageText = message_text ? message_text.trim() : null;
      const [result] = await connection.execute(
        'INSERT INTO messages (chat_id, sender_id, message_text, attachment_url, attachment_type) VALUES (?, ?, ?, ?, ?)',
        [chatId, userId, messageText, attachmentUrl, finalAttachmentType],
      );

      const messageId = (result as any).insertId;

      // Update chat updated_at timestamp
      await connection.execute(
        'UPDATE chats SET updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [chatId],
      );

      // Get the created message
      const [messageRows] = await connection.execute(
        'SELECT id, sender_id, message_text, attachment_url, attachment_type, created_at FROM messages WHERE id = ?',
        [messageId],
      );

      res.json({success: true, data: (messageRows as any[])[0]});
    } catch (error) {
      this.logger.error('Error sending message', error);
      res.status(500).json({success: false, message: 'Failed to send message'});
    } finally {
      connection.release();
    }
  }

  // Mark chat as read (update last_read_message_id to the latest message in the chat)
  private async markChatAsRead(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const chatId = req.params.chatId;
    const connection = await this.db.getConnection();

    try {
      // Verify user is part of this chat (either user_id or supplier_id)
      const [chatRows] = await connection.execute(
        'SELECT id FROM chats WHERE id = ? AND (user_id = ? OR supplier_id = ?)',
        [chatId, userId, userId],
      );

      if ((chatRows as any[]).length === 0) {
        res.status(404).json({
          success: false,
          message: 'Chat not found or you do not have access to this chat',
        });
        return;
      }

      // Get the latest message ID in this chat
      const [messageRows] = await connection.execute(
        'SELECT id FROM messages WHERE chat_id = ? ORDER BY created_at DESC LIMIT 1',
        [chatId],
      );

      if ((messageRows as any[]).length === 0) {
        // No messages in chat, nothing to mark as read
        res.json({success: true, data: {message: 'Chat marked as read'}});
        return;
      }

      const latestMessageId = (messageRows as any[])[0].id;

      // Insert or update chat_read_status
      await connection.execute(
        `INSERT INTO chat_read_status (chat_id, user_id, last_read_message_id)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE
         last_read_message_id = ?,
         updated_at = CURRENT_TIMESTAMP`,
        [chatId, userId, latestMessageId, latestMessageId],
      );

      res.json({success: true, data: {message: 'Chat marked as read'}});
    } catch (error) {
      this.logger.error('Error marking chat as read', error);
      res.status(500).json({success: false, message: 'Failed to mark chat as read'});
    } finally {
      connection.release();
    }
  }

  // Get unread message count (chats with unread messages based on read status)
  private async getUnreadCount(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const userType = (req as any).user?.user_type as string;
    const connection = await this.db.getConnection();

    try {
      let count = 0;

      if (userType === 'SELLER') {
        // Count chats with unread messages (messages from other person after last read)
        const [countRows] = await connection.execute(
          `SELECT COUNT(DISTINCT c.id) as unread_count
           FROM chats c
           INNER JOIN messages m ON m.chat_id = c.id
           LEFT JOIN chat_read_status crs ON crs.chat_id = c.id AND crs.user_id = ?
           WHERE c.supplier_id = ?
           AND m.sender_id != ?
           AND (crs.last_read_message_id IS NULL OR m.id > crs.last_read_message_id)`,
          [userId, userId, userId],
        );
        count = (countRows as any[])[0]?.unread_count || 0;
      } else {
        // Count chats with unread messages (messages from other person after last read)
        const [countRows] = await connection.execute(
          `SELECT COUNT(DISTINCT c.id) as unread_count
           FROM chats c
           INNER JOIN messages m ON m.chat_id = c.id
           LEFT JOIN chat_read_status crs ON crs.chat_id = c.id AND crs.user_id = ?
           WHERE c.user_id = ?
           AND m.sender_id != ?
           AND (crs.last_read_message_id IS NULL OR m.id > crs.last_read_message_id)`,
          [userId, userId, userId],
        );
        count = (countRows as any[])[0]?.unread_count || 0;
      }

      res.json({success: true, data: {count}});
    } catch (error) {
      this.logger.error('Error fetching unread count', error);
      res
        .status(500)
        .json({success: false, message: 'Failed to fetch unread count'});
    } finally {
      connection.release();
    }
  }

  // Create a new chat with a supplier
  private async createChat(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const {supplier_id} = req.body;

    if (!supplier_id) {
      res
        .status(400)
        .json({success: false, message: 'Supplier ID is required'});
      return;
    }

    const connection = await this.db.getConnection();

    try {
      // Verify supplier exists
      const [supplierRows] = await connection.execute(
        'SELECT id FROM users WHERE id = ?',
        [supplier_id],
      );

      if ((supplierRows as any[]).length === 0) {
        res.status(404).json({success: false, message: 'Supplier not found'});
        return;
      }

      // Check if chat already exists
      const [existingChats] = await connection.execute(
        'SELECT id FROM chats WHERE user_id = ? AND supplier_id = ?',
        [userId, supplier_id],
      );

      if ((existingChats as any[]).length > 0) {
        const existingChat = (existingChats as any[])[0];
        res.json({success: true, data: {chat_id: existingChat.id}});
        return;
      }

      // Create new chat
      const [result] = await connection.execute(
        'INSERT INTO chats (user_id, supplier_id) VALUES (?, ?)',
        [userId, supplier_id],
      );

      const chatId = (result as any).insertId;

      res.status(201).json({success: true, data: {chat_id: chatId}});
    } catch (error) {
      this.logger.error('Error creating chat', error);
      res.status(500).json({success: false, message: 'Failed to create chat'});
    } finally {
      connection.release();
    }
  }

  public getRouter(): Router {
    return this.router;
  }
}
