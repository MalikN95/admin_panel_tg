# Backend для Telegram Admin Panel

## Установка и настройка

1. Установите зависимости:
```bash
npm install
```

2. Создайте файл `.env` на основе `.env.example`:
```bash
cp .env.example .env
```

3. Настройте переменные окружения в `.env`:
   - `DB_HOST` - хост PostgreSQL (по умолчанию localhost)
   - `DB_PORT` - порт PostgreSQL (по умолчанию 5432)
   - `DB_USERNAME` - имя пользователя БД
   - `DB_PASSWORD` - пароль БД
   - `DB_NAME` - название базы данных

4. Создайте базу данных PostgreSQL:
```bash
createdb admin_telegram
```

5. Выполните SQL миграцию для создания таблиц:
```bash
psql -U postgres -d admin_telegram -f src/migrations/001_initial_schema.sql
```

Или через psql:
```bash
psql -U postgres -d admin_telegram
\i src/migrations/001_initial_schema.sql
```

## Запуск

### Режим разработки:
```bash
npm run start:dev
```

### Продакшн:
```bash
npm run build
npm start
```

## Структура базы данных

- **users** - пользователи Telegram
- **chats** - чаты
- **messages** - сообщения
- **message_reads** - отметки о прочтении сообщений
- **chat_unread_counts** - счетчики непрочитанных сообщений

## API

API будет добавлено позже для интеграции с Telegram ботом.

