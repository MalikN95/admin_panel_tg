-- Migration: Add bot support for multiple Telegram bots

-- Create bots table
CREATE TABLE IF NOT EXISTS bots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(500) UNIQUE NOT NULL,
    username VARCHAR(255),
    first_name VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bots_token ON bots(token);
CREATE INDEX idx_bots_is_active ON bots(is_active);

-- Add bot_id to chats table
ALTER TABLE chats ADD COLUMN bot_id UUID;
ALTER TABLE chats ADD CONSTRAINT fk_chats_bot FOREIGN KEY (bot_id) REFERENCES bots(id) ON DELETE CASCADE;
CREATE INDEX idx_chats_bot_id ON chats(bot_id);

-- Remove unique constraint from telegram_chat_id and add composite unique constraint
ALTER TABLE chats DROP CONSTRAINT IF EXISTS UQ_chats_telegram_chat_id;
ALTER TABLE chats DROP CONSTRAINT IF EXISTS chats_telegram_chat_id_key;

-- Create composite unique index for telegramChatId + botId
CREATE UNIQUE INDEX idx_chats_telegram_chat_id_bot_id ON chats(telegram_chat_id, bot_id);

-- Add bot_id and is_from_admin to messages table
ALTER TABLE messages ADD COLUMN bot_id UUID;
ALTER TABLE messages ADD COLUMN is_from_admin BOOLEAN DEFAULT false;
ALTER TABLE messages ADD CONSTRAINT fk_messages_bot FOREIGN KEY (bot_id) REFERENCES bots(id) ON DELETE CASCADE;
CREATE INDEX idx_messages_bot_id ON messages(bot_id);
CREATE INDEX idx_messages_is_from_admin ON messages(is_from_admin);

-- Insert default bot from environment variable (will be done via seed script)
-- This is just a placeholder comment for the token: TELEGRAM_BOT_TOKEN

-- Update existing chats and messages to use the first bot (will be done via application code)

