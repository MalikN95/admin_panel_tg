-- Создание ENUM для типов тегов
CREATE TYPE tag_type_enum AS ENUM ('hot', 'warm', 'cold');

-- Создание таблицы тегов
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    tag_type tag_type_enum NOT NULL,
    color VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание таблицы связи многие-ко-многим между чатами и тегами
CREATE TABLE chat_tags (
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (chat_id, tag_id)
);

-- Создание индексов
CREATE INDEX idx_chat_tags_chat_id ON chat_tags(chat_id);
CREATE INDEX idx_chat_tags_tag_id ON chat_tags(tag_id);

-- Вставка предустановленных тегов
INSERT INTO tags (id, name, tag_type, color) VALUES
    (gen_random_uuid(), 'Горячий', 'hot', '#EF4444'),
    (gen_random_uuid(), 'Теплый', 'warm', '#F59E0B'),
    (gen_random_uuid(), 'Холодный', 'cold', '#3B82F6')
ON CONFLICT (name) DO NOTHING;

