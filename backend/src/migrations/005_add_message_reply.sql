-- Добавление поддержки ответов на сообщения (reply)

ALTER TABLE messages 
ADD COLUMN reply_to_message_id UUID NULL;

ALTER TABLE messages
ADD CONSTRAINT fk_reply_to_message 
  FOREIGN KEY (reply_to_message_id) 
  REFERENCES messages(id) 
  ON DELETE SET NULL;

CREATE INDEX idx_messages_reply_to ON messages(reply_to_message_id);

