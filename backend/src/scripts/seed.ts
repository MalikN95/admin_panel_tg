import 'reflect-metadata';
import { config } from 'dotenv';
import { DataSource } from 'typeorm';
import { databaseConfig } from '../config/database.config';
import { User } from '../entities/User.entity';
import { Chat } from '../entities/Chat.entity';
import { Message, MessageType } from '../entities/Message.entity';
import { ChatType } from '../entities/Chat.entity';
import { MessageRead } from '../entities/MessageRead.entity';
import { ChatUnreadCount } from '../entities/ChatUnreadCount.entity';

config();

const messages = [
  'Привет! Как дела?',
  'Отлично, спасибо! А у тебя?',
  'Тоже хорошо, работаю над проектом',
  'Интересно, расскажи подробнее',
  'Разрабатываю админ-панель для Telegram бота',
  'Звучит интересно! Какие функции?',
  'Управление чатами, отправка сообщений, просмотр истории',
  'Круто! Когда планируешь запустить?',
  'Скоро, уже почти готово',
  'Удачи с проектом!',
  'Спасибо!',
  'Пожалуйста',
  'Можешь помочь с одним вопросом?',
  'Конечно, в чем дело?',
  'Как лучше организовать структуру базы данных?',
  'Зависит от требований, но обычно используют нормализованную структуру',
  'Понял, спасибо за совет',
  'Не за что, обращайся если что',
  'Хорошо, буду иметь в виду',
  'Увидимся!',
];

const firstNames = [
  'Иван', 'Мария', 'Александр', 'Елена', 'Дмитрий', 'Анна', 'Сергей', 'Ольга',
  'Андрей', 'Наталья', 'Михаил', 'Татьяна', 'Алексей', 'Екатерина', 'Владимир',
  'Юлия', 'Николай', 'Ирина', 'Павел', 'Светлана',
];

const lastNames = [
  'Иванов', 'Петров', 'Сидоров', 'Смирнов', 'Кузнецов', 'Попов', 'Васильев',
  'Соколов', 'Михайлов', 'Новиков', 'Федоров', 'Морозов', 'Волков', 'Алексеев',
  'Лебедев', 'Семенов', 'Егоров', 'Павлов', 'Козлов', 'Степанов',
];

function getRandomElement<T>(array: T[]): T {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomDate(start: Date, end: Date): Date {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

async function seed() {
  const dataSource = new DataSource({
    ...databaseConfig,
    type: 'postgres',
  } as any);

  try {
    await dataSource.initialize();
    console.log('✅ Подключение к базе данных установлено');

    const userRepository = dataSource.getRepository(User);
    const chatRepository = dataSource.getRepository(Chat);
    const messageRepository = dataSource.getRepository(Message);
    const messageReadRepository = dataSource.getRepository(MessageRead);
    const chatUnreadCountRepository = dataSource.getRepository(ChatUnreadCount);

    // Очистка существующих данных (используем CASCADE для обхода внешних ключей)
    console.log('🗑️  Очистка существующих данных...');
    await dataSource.query('TRUNCATE TABLE message_reads, chat_unread_counts, messages, chats, users CASCADE');

    // Создание тестовых пользователей
    console.log('👥 Создание тестовых пользователей...');
    const users: User[] = [];
    for (let i = 0; i < 10; i++) {
      const user = userRepository.create({
        telegramId: 1000000000 + i,
        username: `user${i}`,
        firstName: getRandomElement(firstNames),
        lastName: getRandomElement(lastNames),
        isBot: false,
        languageCode: 'ru',
      });
      const savedUser = await userRepository.save(user);
      users.push(savedUser);
    }
    console.log(`✅ Создано ${users.length} пользователей`);

    // Создание тестовых чатов
    console.log('💬 Создание тестовых чатов...');
    const chats: Chat[] = [];
    for (let i = 0; i < 8; i++) {
      const user = getRandomElement(users);
      const chatType = i < 6 ? ChatType.PRIVATE : (i === 6 ? ChatType.GROUP : ChatType.SUPERGROUP);
      
      const chat = chatRepository.create({
        telegramChatId: 2000000000 + i,
        chatType,
        title: chatType === ChatType.PRIVATE 
          ? null 
          : `Группа ${i + 1}`,
        userId: user.id,
        lastMessageAt: null,
      });
      const savedChat = await chatRepository.save(chat);
      chats.push(savedChat);
    }
    console.log(`✅ Создано ${chats.length} чатов`);

    // Создание тестовых сообщений
    console.log('📨 Создание тестовых сообщений...');
    let messageCount = 0;
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    for (const chat of chats) {
      const chatUser = users.find(u => u.id === chat.userId)!;
      const messageCountForChat = Math.floor(Math.random() * 15) + 5; // 5-20 сообщений на чат
      
      let lastMessage: Message | null = null;
      let lastMessageDate: Date | null = null;

      for (let i = 0; i < messageCountForChat; i++) {
        // Чередуем отправителей - иногда пользователь чата, иногда другой случайный пользователь
        const sender = i % 3 === 0 ? chatUser : getRandomElement(users);
        const messageText = getRandomElement(messages);
        const createdAt = getRandomDate(weekAgo, now);

        const message = messageRepository.create({
          chatId: chat.id,
          senderId: sender.id,
          telegramMessageId: 3000000000 + messageCount,
          text: messageText,
          messageType: MessageType.TEXT,
          createdAt,
        });

        const savedMessage = await messageRepository.save(message);
        messageCount++;

        if (!lastMessageDate || createdAt > lastMessageDate) {
          lastMessage = savedMessage;
          lastMessageDate = createdAt;
        }
      }

      // Обновляем последнее сообщение в чате
      if (lastMessage) {
        await chatRepository.update(chat.id, {
          lastMessageId: lastMessage.id,
          lastMessageAt: lastMessageDate,
        });
      }
    }

    console.log(`✅ Создано ${messageCount} сообщений`);
    console.log('🎉 База данных успешно заполнена тестовыми данными!');
  } catch (error) {
    console.error('❌ Ошибка при заполнении базы данных:', error);
    throw error;
  } finally {
    await dataSource.destroy();
    console.log('🔌 Соединение с базой данных закрыто');
  }
}

seed()
  .then(() => {
    console.log('✅ Скрипт завершен успешно');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Ошибка выполнения скрипта:', error);
    process.exit(1);
  });

