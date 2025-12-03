import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Telegraf, Context } from 'telegraf';
import { Message as TelegramMessage } from 'telegraf/typings/core/types/typegram';
import { Bot } from '../entities/Bot.entity';
import { Chat, ChatType } from '../entities/Chat.entity';
import { User } from '../entities/User.entity';
import { Message, MessageType } from '../entities/Message.entity';

@Injectable()
export class TelegramService implements OnModuleInit {
  private readonly logger = new Logger(TelegramService.name);
  private bots: Map<string, Telegraf> = new Map();

  constructor(
    @InjectRepository(Bot)
    private botRepository: Repository<Bot>,
    @InjectRepository(Chat)
    private chatRepository: Repository<Chat>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
  ) {}

  async onModuleInit() {
    await this.initializeBots();
  }

  async initializeBots() {
    this.logger.log('Инициализация Telegram ботов...');
    const activeBots = await this.botRepository.find({ where: { isActive: true } });

    for (const bot of activeBots) {
      try {
        await this.createBot(bot.token, bot.id);
        this.logger.log(`Бот ${bot.username || bot.id} успешно запущен`);
      } catch (error) {
        this.logger.error(`Ошибка при запуске бота ${bot.id}:`, error);
      }
    }
  }

  async createBot(token: string, botId?: string): Promise<Bot> {
    try {
      const telegrafBot = new Telegraf(token);

      // Получаем информацию о боте с timeout
      const botInfo = await Promise.race([
        telegrafBot.telegram.getMe(),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout getting bot info')), 10000)
        )
      ]) as any;

      // Сохраняем бота в БД, если его еще нет
      let bot: Bot;
      if (botId) {
        bot = await this.botRepository.findOne({ where: { id: botId } });
        if (bot) {
          // Обновляем информацию о боте
          bot.username = botInfo.username;
          bot.firstName = botInfo.first_name;
          await this.botRepository.save(bot);
        }
      } else {
        bot = await this.botRepository.findOne({ where: { token } });
        if (!bot) {
          bot = this.botRepository.create({
            token,
            username: botInfo.username,
            firstName: botInfo.first_name,
            isActive: true,
          });
          bot = await this.botRepository.save(bot);
        }
      }

      // Настраиваем обработчики
      this.setupHandlers(telegrafBot, bot.id);

      // Запускаем бота асинхронно
      telegrafBot.launch().then(() => {
        this.logger.log(`Бот @${botInfo.username} (${bot.id}) запущен и готов принимать сообщения`);
      }).catch((error) => {
        this.logger.error(`Ошибка при запуске бота ${bot.id}:`, error);
      });
      
      this.bots.set(bot.id, telegrafBot);

      this.logger.log(`Бот @${botInfo.username} (${bot.id}) инициализирован`);

      return bot;
    } catch (error) {
      this.logger.error(`Ошибка при создании бота:`, error);
      throw error;
    }
  }

  private setupHandlers(telegrafBot: Telegraf, botId: string) {
    // Обработка текстовых сообщений
    telegrafBot.on('text', async (ctx) => {
      await this.handleTextMessage(ctx, botId);
    });

    // Обработка фото
    telegrafBot.on('photo', async (ctx) => {
      await this.handlePhotoMessage(ctx, botId);
    });

    // Обработка видео
    telegrafBot.on('video', async (ctx) => {
      await this.handleVideoMessage(ctx, botId);
    });

    // Обработка голосовых сообщений
    telegrafBot.on('voice', async (ctx) => {
      await this.handleVoiceMessage(ctx, botId);
    });

    // Обработка документов
    telegrafBot.on('document', async (ctx) => {
      await this.handleDocumentMessage(ctx, botId);
    });

    // Обработка аудио
    telegrafBot.on('audio', async (ctx) => {
      await this.handleAudioMessage(ctx, botId);
    });

    // Обработка стикеров
    telegrafBot.on('sticker', async (ctx) => {
      await this.handleStickerMessage(ctx, botId);
    });

    // Обработка видео-заметок
    telegrafBot.on('video_note', async (ctx) => {
      await this.handleVideoNoteMessage(ctx, botId);
    });

    // Обработка GIF анимаций
    telegrafBot.on('animation', async (ctx) => {
      await this.handleAnimationMessage(ctx, botId);
    });
  }

  private async handleTextMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.TextMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;

      // Получить или создать пользователя
      const user = await this.getOrCreateUser(from);

      // Получить или создать чат
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Создать сообщение
      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.text,
        messageType: MessageType.TEXT,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      // Обновить последнее сообщение в чате
      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получено текстовое сообщение от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке текстового сообщения:', error);
    }
  }

  async getFileUrl(botId: string, fileId: string): Promise<string | null> {
    try {
      const bot = this.bots.get(botId);
      if (!bot) {
        this.logger.error(`Бот ${botId} не найден`);
        return null;
      }

      const file = await bot.telegram.getFile(fileId);
      if (file.file_path) {
        const token = (bot as any).token;
        return `https://api.telegram.org/file/bot${token}/${file.file_path}`;
      }
      return null;
    } catch (error) {
      this.logger.error(`Ошибка при получении URL файла ${fileId}:`, error);
      return null;
    }
  }

  private async handlePhotoMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.PhotoMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const photo = telegramMessage.photo[telegramMessage.photo.length - 1]; // Берем фото наибольшего размера

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, photo.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.caption || null,
        caption: telegramMessage.caption || null,
        messageType: MessageType.PHOTO,
        fileId: photo.file_id,
        fileUniqueId: photo.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получено фото от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке фото:', error);
    }
  }

  private async handleVideoMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.VideoMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const video = telegramMessage.video;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, video.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.caption || null,
        caption: telegramMessage.caption || null,
        messageType: MessageType.VIDEO,
        fileId: video.file_id,
        fileUniqueId: video.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получено видео от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке видео:', error);
    }
  }

  private async handleVoiceMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.VoiceMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const voice = telegramMessage.voice;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, voice.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        messageType: MessageType.VOICE,
        fileId: voice.file_id,
        fileUniqueId: voice.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получено голосовое сообщение от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке голосового сообщения:', error);
    }
  }

  private async handleDocumentMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.DocumentMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const document = telegramMessage.document;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, document.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.caption || null,
        caption: telegramMessage.caption || null,
        messageType: MessageType.DOCUMENT,
        fileId: document.file_id,
        fileUniqueId: document.file_unique_id,
        fileUrl,
        fileName: document.file_name || 'document',
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получен документ от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке документа:', error);
    }
  }

  private async handleAudioMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.AudioMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const audio = telegramMessage.audio;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, audio.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.caption || null,
        caption: telegramMessage.caption || null,
        messageType: MessageType.AUDIO,
        fileId: audio.file_id,
        fileUniqueId: audio.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получено аудио от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке аудио:', error);
    }
  }

  private async handleStickerMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.StickerMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const sticker = telegramMessage.sticker;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Для анимированных стикеров (.tgs) используем thumbnail, если есть
      let fileIdToUse = sticker.file_id;
      if (sticker.is_animated && sticker.thumbnail) {
        fileIdToUse = sticker.thumbnail.file_id;
      }

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, fileIdToUse);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        messageType: MessageType.STICKER,
        fileId: sticker.file_id,
        fileUniqueId: sticker.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получен стикер от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке стикера:', error);
    }
  }

  private async handleVideoNoteMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.VideoNoteMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const videoNote = telegramMessage.video_note;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, videoNote.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        messageType: MessageType.VIDEO_NOTE,
        fileId: videoNote.file_id,
        fileUniqueId: videoNote.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получена видео-заметка от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке видео-заметки:', error);
    }
  }

  private async handleAnimationMessage(ctx: Context, botId: string) {
    try {
      const telegramMessage = ctx.message as TelegramMessage.AnimationMessage;
      const from = telegramMessage.from;
      const chatId = telegramMessage.chat.id;
      const animation = telegramMessage.animation;

      const user = await this.getOrCreateUser(from);
      const chat = await this.getOrCreateChat(chatId, botId, user.id, telegramMessage.chat);

      // Получаем URL файла
      const fileUrl = await this.getFileUrl(botId, animation.file_id);

      const message = this.messageRepository.create({
        chatId: chat.id,
        botId,
        senderId: user.id,
        telegramMessageId: telegramMessage.message_id,
        text: telegramMessage.caption || null,
        caption: telegramMessage.caption || null,
        messageType: MessageType.ANIMATION,
        fileId: animation.file_id,
        fileUniqueId: animation.file_unique_id,
        fileUrl,
        isFromAdmin: false,
      });

      const savedMessage = await this.messageRepository.save(message);

      await this.chatRepository.update(chat.id, {
        lastMessageId: savedMessage.id,
        lastMessageAt: new Date(),
      });

      // Пометить все предыдущие сообщения от админа как прочитанные
      await this.markMessagesAsRead(chat.id);

      this.logger.log(`Получена анимация от ${user.firstName} в чате ${chat.id}`);
    } catch (error) {
      this.logger.error('Ошибка при обработке анимации:', error);
    }
  }

  private async getOrCreateUser(from: any): Promise<User> {
    let user = await this.userRepository.findOne({
      where: { telegramId: from.id },
    });

    if (!user) {
      user = this.userRepository.create({
        telegramId: from.id,
        username: from.username || null,
        firstName: from.first_name,
        lastName: from.last_name || null,
        languageCode: from.language_code || null,
        isBot: from.is_bot || false,
      });
      user = await this.userRepository.save(user);
      this.logger.log(`Создан новый пользователь: ${user.firstName} (${user.telegramId})`);
    }

    return user;
  }

  private async getOrCreateChat(
    telegramChatId: number,
    botId: string,
    userId: string,
    telegramChat: any,
  ): Promise<Chat> {
    let chat = await this.chatRepository.findOne({
      where: { telegramChatId, botId },
    });

    if (!chat) {
      const chatType = this.mapChatType(telegramChat.type);
      chat = this.chatRepository.create({
        telegramChatId,
        botId,
        userId,
        chatType,
        title: telegramChat.title || null,
      });
      chat = await this.chatRepository.save(chat);
      this.logger.log(`Создан новый чат: ${chat.id} (${telegramChatId})`);
    }

    return chat;
  }

  private mapChatType(telegramType: string): ChatType {
    switch (telegramType) {
      case 'private':
        return ChatType.PRIVATE;
      case 'group':
        return ChatType.GROUP;
      case 'supergroup':
        return ChatType.SUPERGROUP;
      case 'channel':
        return ChatType.CHANNEL;
      default:
        return ChatType.PRIVATE;
    }
  }

  // Методы для отправки сообщений от админа
  async sendMessage(botId: string, telegramChatId: number, text: string, replyToMessageId?: number): Promise<TelegramMessage.TextMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const sentMessage = await bot.telegram.sendMessage(
      telegramChatId, 
      text,
      replyToMessageId ? { reply_parameters: { message_id: replyToMessageId } } : undefined
    );
    return sentMessage as TelegramMessage.TextMessage;
  }

  async sendPhoto(
    botId: string,
    telegramChatId: number,
    photo: string,
    caption?: string,
    replyToMessageId?: number,
  ): Promise<TelegramMessage.PhotoMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = { caption };
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendPhoto(telegramChatId, photo, options);
    return sentMessage as TelegramMessage.PhotoMessage;
  }

  async sendVideo(
    botId: string,
    telegramChatId: number,
    video: string,
    caption?: string,
    replyToMessageId?: number,
  ): Promise<TelegramMessage.VideoMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = { caption };
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendVideo(telegramChatId, video, options);
    return sentMessage as TelegramMessage.VideoMessage;
  }

  async sendVoice(botId: string, telegramChatId: number, voice: string, replyToMessageId?: number): Promise<TelegramMessage.VoiceMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = {};
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendVoice(telegramChatId, voice, options);
    return sentMessage as TelegramMessage.VoiceMessage;
  }

  async sendDocument(
    botId: string,
    telegramChatId: number,
    document: string,
    caption?: string,
    replyToMessageId?: number,
  ): Promise<TelegramMessage.DocumentMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = { caption };
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendDocument(telegramChatId, document, options);
    return sentMessage as TelegramMessage.DocumentMessage;
  }

  async sendAudio(
    botId: string,
    telegramChatId: number,
    audio: string,
    caption?: string,
    replyToMessageId?: number,
  ): Promise<TelegramMessage.AudioMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = { caption };
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendAudio(telegramChatId, audio, options);
    return sentMessage as TelegramMessage.AudioMessage;
  }

  async sendAnimation(
    botId: string,
    telegramChatId: number,
    animation: string,
    caption?: string,
    replyToMessageId?: number,
  ): Promise<TelegramMessage.AnimationMessage> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    const options: any = { caption };
    if (replyToMessageId) {
      options.reply_parameters = { message_id: replyToMessageId };
    }

    const sentMessage = await bot.telegram.sendAnimation(telegramChatId, animation, options);
    return sentMessage as TelegramMessage.AnimationMessage;
  }

  async getBotInfo(botId: string) {
    const bot = await this.botRepository.findOne({ where: { id: botId } });
    return bot;
  }

  async getAllBots() {
    return this.botRepository.find({ order: { createdAt: 'DESC' } });
  }

  async getBotStatistics(botId: string) {
    const totalUsers = await this.chatRepository.count({ where: { botId } });
    const totalMessages = await this.messageRepository.count({ where: { botId } });
    const activeUsers = await this.chatRepository.count({ 
      where: { botId, isBotBlocked: false } 
    });
    const blockedUsers = await this.chatRepository.count({ 
      where: { botId, isBotBlocked: true } 
    });

    return {
      totalUsers,
      totalMessages,
      activeUsers,
      blockedUsers,
    };
  }

  /**
   * Помечает все непрочитанные сообщения от админа как прочитанные
   * когда пользователь отправляет новое сообщение
   */
  private async markMessagesAsRead(chatId: string) {
    try {
      await this.messageRepository
        .createQueryBuilder()
        .update()
        .set({ isRead: true })
        .where('chatId = :chatId', { chatId })
        .andWhere('isFromAdmin = :isFromAdmin', { isFromAdmin: true })
        .andWhere('isRead = :isRead', { isRead: false })
        .execute();
    } catch (error) {
      this.logger.error('Ошибка при отметке сообщений как прочитанных:', error);
    }
  }

  async deleteMessage(botId: string, telegramChatId: number, messageId: number): Promise<boolean> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    try {
      await bot.telegram.deleteMessage(telegramChatId, messageId);
      this.logger.log(`Сообщение ${messageId} удалено из чата ${telegramChatId}`);
      return true;
    } catch (error) {
      this.logger.error(`Ошибка при удалении сообщения ${messageId}:`, error);
      return false;
    }
  }

  async toggleBotStatus(botId: string) {
    const bot = await this.botRepository.findOne({ where: { id: botId } });
    if (!bot) {
      throw new Error('Бот не найден');
    }

    const newStatus = !bot.isActive;
    bot.isActive = newStatus;
    await this.botRepository.save(bot);

    if (newStatus) {
      // Включаем бота
      await this.createBot(bot.token, bot.id);
      this.logger.log(`Бот ${bot.username} (${botId}) активирован`);
    } else {
      // Отключаем бота
      const telegrafBot = this.bots.get(botId);
      if (telegrafBot) {
        await telegrafBot.stop();
        this.bots.delete(botId);
      }
      this.logger.log(`Бот ${bot.username} (${botId}) деактивирован`);
    }

    return bot;
  }

  async deleteBot(botId: string) {
    const bot = this.bots.get(botId);
    if (bot) {
      await bot.stop();
      this.bots.delete(botId);
    }

    await this.botRepository.delete(botId);
    this.logger.log(`Бот ${botId} удален`);
  }

  async setMessageReaction(
    botId: string, 
    telegramChatId: number, 
    messageId: number, 
    reactions: Array<{ type: 'emoji'; emoji: string }>
  ): Promise<boolean> {
    const bot = this.bots.get(botId);
    if (!bot) {
      throw new Error(`Бот с ID ${botId} не найден`);
    }

    try {
      // Telegram API требует пустой массив для удаления реакций
      // или массив с одной реакцией для установки
      await bot.telegram.setMessageReaction(telegramChatId, messageId, reactions as any);
      this.logger.log(
        `Реакция установлена для сообщения ${messageId} в чате ${telegramChatId}: ${reactions.map(r => r.emoji).join(', ')}`
      );
      return true;
    } catch (error) {
      this.logger.error(`Ошибка при установке реакции для сообщения ${messageId}:`, error);
      return false;
    }
  }
}

