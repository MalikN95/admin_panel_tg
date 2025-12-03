# Быстрый деплой на сервер

## Сервер: 144.124.249.43
## Пароль: X69Sx2y2%M3LGQH3A8vs

## Выполните эти команды по порядку:

### 1. Подключитесь к серверу
```bash
ssh root@144.124.249.43
# Пароль: X69Sx2y2%M3LGQH3A8vs
```

### 2. На сервере - создайте папку и подготовьте окружение
```bash
mkdir -p /root/admin
cd /root/admin

# Проверьте наличие Node.js
node --version || (echo "Установите Node.js" && exit 1)

# Проверьте наличие PostgreSQL
psql --version || (echo "Установите PostgreSQL" && exit 1)
```

### 3. На локальной машине - скопируйте файлы

Откройте **новый терминал** (не закрывая SSH сессию) и выполните:

```bash
cd /Users/evgenijkukuskin/Documents/Проекты/cursor/admin_telegram

# Копируем backend
scp -r backend root@144.124.249.43:/root/admin/

# Копируем собранный frontend
scp -r dist root@144.124.249.43:/root/admin/frontend

# Копируем backup базы данных
scp admin_telegram_backup.sql root@144.124.249.43:/root/admin/
```

### 4. Вернитесь в SSH сессию на сервере - установите зависимости

```bash
cd /root/admin/backend
npm install --production
npm run build
```

### 5. Создайте .env файл

```bash
cat > /root/admin/backend/.env << 'EOF'
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=admin_telegram

# JWT
JWT_SECRET=change-this-secret-key-in-production-$(date +%s)

# Server
PORT=3000
NODE_ENV=production

# CORS
FRONTEND_URL=http://144.124.249.43
EOF
```

### 6. Импортируйте базу данных

```bash
# Создайте базу данных (если еще не создана)
sudo -u postgres psql -c "CREATE DATABASE admin_telegram;"

# Импортируйте backup
sudo -u postgres psql -d admin_telegram < /root/admin/admin_telegram_backup.sql
```

### 7. Запустите backend

```bash
cd /root/admin/backend

# Установите PM2 (если еще не установлен)
npm install -g pm2

# Запустите backend
pm2 start dist/main.js --name admin-backend
pm2 save
pm2 startup
```

### 8. Настройте nginx для frontend

```bash
# Создайте конфигурацию nginx
sudo tee /etc/nginx/sites-available/admin << 'EOF'
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
EOF

# Активируйте конфигурацию
sudo ln -sf /etc/nginx/sites-available/admin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 9. Проверьте работу

- Backend: http://144.124.249.43:3000
- Frontend: http://144.124.249.43

### 10. Данные для входа

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

# Просмотр логов nginx
sudo tail -f /var/log/nginx/error.log
```

