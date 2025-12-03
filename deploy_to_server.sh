#!/bin/bash

# Скрипт автоматического деплоя на сервер

SERVER_IP="144.124.249.43"
SERVER_USER="root"
SERVER_PASS="X69Sx2y2%M3LGQH3A8vs"
APP_DIR="/root/admin"
PROJECT_DIR="/Users/evgenijkukuskin/Documents/Проекты/cursor/admin_telegram"

echo "🚀 Начинаем деплой приложения на сервер $SERVER_IP..."

# Функция для выполнения команд на сервере
execute_remote() {
    sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SERVER_USER@$SERVER_IP" "$1"
}

# Функция для копирования файлов
copy_to_server() {
    sshpass -p "$SERVER_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$1" "$SERVER_USER@$SERVER_IP:$2"
}

echo "📁 Создаем папку admin на сервере..."
execute_remote "mkdir -p $APP_DIR && cd $APP_DIR && pwd"

echo "📦 Копируем backend..."
cd "$PROJECT_DIR"
copy_to_server "backend" "$APP_DIR/"

echo "📦 Копируем собранный frontend..."
copy_to_server "dist" "$APP_DIR/frontend"

echo "📦 Копируем backup базы данных..."
copy_to_server "admin_telegram_backup.sql" "$APP_DIR/"

echo "🔧 Настраиваем окружение на сервере..."

execute_remote << 'ENDSSH'
    cd /root/admin
    
    echo "📦 Устанавливаем зависимости backend..."
    cd backend
    npm install --production
    
    echo "🔨 Собираем backend..."
    npm run build
    
    echo "✅ Backend настроен"
ENDSSH

echo "📝 Создаем .env файл на сервере..."

# Создаем .env файл на сервере
execute_remote "cat > $APP_DIR/backend/.env << 'ENVEOF'
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=admin_telegram

# JWT
JWT_SECRET=your-secret-key-change-in-production

# Server
PORT=3000
NODE_ENV=production

# CORS
FRONTEND_URL=http://144.124.249.43
ENVEOF"

echo "🗄️ Импортируем базу данных..."

execute_remote << 'ENDSSH'
    # Создаем базу данных если не существует
    sudo -u postgres psql -c "CREATE DATABASE admin_telegram;" 2>/dev/null || echo "База данных уже существует"
    
    # Импортируем backup
    sudo -u postgres psql -d admin_telegram < /root/admin/admin_telegram_backup.sql
    
    echo "✅ База данных импортирована"
ENDSSH

echo "🎉 Деплой завершен!"
echo ""
echo "📝 Следующие шаги:"
echo "1. Настройте пароль PostgreSQL в $APP_DIR/backend/.env"
echo "2. Настройте JWT_SECRET в $APP_DIR/backend/.env"
echo "3. Запустите backend: cd $APP_DIR/backend && npm start"
echo "4. Настройте nginx для frontend (см. DEPLOY_INSTRUCTIONS.md)"

