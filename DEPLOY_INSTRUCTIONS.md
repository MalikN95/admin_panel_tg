# Инструкции по деплою на сервер

## Сервер
- IP: 144.124.249.43
- Пароль: X69Sx2y2%M3LGQH3A8vs
- Папка: /root/admin

## Шаги деплоя

### 1. Подключение к серверу
```bash
ssh root@144.124.249.43
# Введите пароль: X69Sx2y2%M3LGQH3A8vs
```

### 2. Создание папки и подготовка
```bash
mkdir -p /root/admin
cd /root/admin
```

### 3. Копирование файлов с локальной машины

На локальной машине выполните:
```bash
cd /Users/evgenijkukuskin/Documents/Проекты/cursor/admin_telegram

# Копируем архив
scp admin_telegram_deploy.tar.gz root@144.124.249.43:/root/admin/

# Копируем собранный frontend
scp -r dist root@144.124.249.43:/root/admin/frontend

# Копируем backup базы данных
scp admin_telegram_backup.sql root@144.124.249.43:/root/admin/
```

### 4. На сервере - распаковка и установка

```bash
cd /root/admin
tar -xzf admin_telegram_deploy.tar.gz

# Установка зависимостей backend
cd backend
npm install --production

# Сборка backend
npm run build
```

### 5. Настройка базы данных

```bash
# Создайте базу данных (если еще не создана)
sudo -u postgres psql -c "CREATE DATABASE admin_telegram;"

# Импортируйте backup
sudo -u postgres psql -d admin_telegram < /root/admin/admin_telegram_backup.sql
```

### 6. Настройка .env файла

Создайте файл `/root/admin/backend/.env`:
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=ваш_пароль_postgres
DB_NAME=admin_telegram

# JWT
JWT_SECRET=ваш_секретный_ключ_jwt

# Server
PORT=3000
NODE_ENV=production

# CORS
FRONTEND_URL=http://144.124.249.43:5173
```

### 7. Запуск приложения

#### Backend (через PM2 или systemd)
```bash
cd /root/admin/backend

# Установка PM2 (если еще не установлен)
npm install -g pm2

# Запуск backend
pm2 start dist/main.js --name admin-backend
pm2 save
pm2 startup
```

#### Frontend (через nginx)

Создайте конфигурацию nginx `/etc/nginx/sites-available/admin`:
```nginx
server {
    listen 80;
    server_name 144.124.249.43;

    root /root/admin/frontend;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Активируйте конфигурацию:
```bash
sudo ln -s /etc/nginx/sites-available/admin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 8. Проверка

- Backend: http://144.124.249.43:3000
- Frontend: http://144.124.249.43

### 9. Данные для входа

- Email: admin@test.com
- Пароль: admin123

## Полезные команды

```bash
# Просмотр логов backend
pm2 logs admin-backend

# Перезапуск backend
pm2 restart admin-backend

# Статус backend
pm2 status
```

