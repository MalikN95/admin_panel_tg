CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO admins (id, email, password)
VALUES (
    gen_random_uuid(),
    'admin@test.com',
    '$2b$10$lkeUjg5bJSAqthyzCHxSuOB5lTPf7Y1JmjIzf5UX3cWhVKO26NFAG'
)
ON CONFLICT (email) DO NOTHING;
