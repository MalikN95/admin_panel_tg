-- Создание ENUM типов
CREATE TYPE chat_type_enum AS ENUM ('private', 'group', 'supergroup', 'channel');
CREATE TYPE message_type_enum AS ENUM ('text', 'photo', 'video', 'voice', 'document', 'audio', 'sticker', 'video_note', 'animation', 'location', 'contact');

-- Создание таблицы users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_id BIGINT UNIQUE NOT NULL,
    username VARCHAR(255),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    avatar_url TEXT,
    is_bot BOOLEAN DEFAULT FALSE,
    language_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индекса для users.telegram_id
CREATE UNIQUE INDEX idx_users_telegram_id ON users(telegram_id);

-- Создание таблицы chats
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_chat_id BIGINT UNIQUE NOT NULL,
    chat_type chat_type_enum DEFAULT 'private',
    title VARCHAR(255),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    last_message_id UUID,
    last_message_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов для chats
CREATE UNIQUE INDEX idx_chats_telegram_chat_id ON chats(telegram_chat_id);
CREATE INDEX idx_chats_user_id ON chats(user_id);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at);

-- Создание таблицы messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    telegram_message_id BIGINT NOT NULL,
    text TEXT,
    message_type message_type_enum DEFAULT 'text',
    file_id TEXT,
    file_unique_id TEXT,
    file_path TEXT,
    file_url TEXT,
    caption TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов для messages
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_telegram_message_id ON messages(telegram_message_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Добавление внешнего ключа для chats.last_message_id
ALTER TABLE chats ADD CONSTRAINT fk_chats_last_message 
    FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL;

-- Создание таблицы message_reads
CREATE TABLE message_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

-- Создание индексов для message_reads
CREATE INDEX idx_message_reads_message_id ON message_reads(message_id);
CREATE INDEX idx_message_reads_user_id ON message_reads(user_id);
CREATE INDEX idx_message_reads_read_at ON message_reads(read_at);

-- Создание таблицы chat_unread_counts
CREATE TABLE chat_unread_counts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    unread_count INTEGER DEFAULT 0,
    last_read_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(chat_id, user_id)
);

-- Создание индексов для chat_unread_counts
CREATE INDEX idx_chat_unread_counts_chat_id ON chat_unread_counts(chat_id);
CREATE INDEX idx_chat_unread_counts_user_id ON chat_unread_counts(user_id);
CREATE INDEX idx_chat_unread_counts_chat_user ON chat_unread_counts(chat_id, user_id);

-- Создание функции для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Создание триггеров для автоматического обновления updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at BEFORE UPDATE ON chats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_unread_counts_updated_at BEFORE UPDATE ON chat_unread_counts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

