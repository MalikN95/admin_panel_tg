DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_chats_updated_at ON chats;
DROP TRIGGER IF EXISTS update_messages_updated_at ON messages;
DROP TRIGGER IF EXISTS update_chat_unread_counts_updated_at ON chat_unread_counts;
DROP FUNCTION IF EXISTS update_updated_at_column();


