-- Создание таблицы templates
CREATE TABLE IF NOT EXISTS templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    text TEXT,
    admin_id VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Создание индекса для admin_id
CREATE INDEX IF NOT EXISTS idx_templates_admin_id ON templates(admin_id);

-- Создание таблицы template_files
CREATE TABLE IF NOT EXISTS template_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_template_files_template FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);

-- Создание индекса для template_id
CREATE INDEX IF NOT EXISTS idx_template_files_template_id ON template_files(template_id);

