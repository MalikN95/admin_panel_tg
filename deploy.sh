#!/bin/bash

# Скрипт деплоя приложения на сервер

SERVER_IP="144.124.249.43"
SERVER_USER="root"
SERVER_PASS="X69Sx2y2%M3LGQH3A8vs"
APP_DIR="/root/admin"

echo "🚀 Начинаем деплой приложения..."

# Подключение к серверу и выполнение команд
sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    echo "📁 Создаем папку admin..."
    mkdir -p /root/admin
    cd /root/admin
    
    echo "✅ Папка создана"
ENDSSH

echo "📦 Копируем файлы на сервер..."

# Копируем backend
echo "📤 Копируем backend..."
sshpass -p "$SERVER_PASS" scp -r -o StrictHostKeyChecking=no backend "$SERVER_USER@$SERVER_IP:/root/admin/"

# Копируем frontend (собранный)
echo "📤 Собираем frontend..."
cd /Users/evgenijkukuskin/Documents/Проекты/cursor/admin_telegram
npm run build

echo "📤 Копируем собранный frontend..."
sshpass -p "$SERVER_PASS" scp -r -o StrictHostKeyChecking=no dist "$SERVER_USER@$SERVER_IP:/root/admin/frontend"

# Копируем backup базы данных
echo "📤 Копируем backup базы данных..."
sshpass -p "$SERVER_PASS" scp -o StrictHostKeyChecking=no admin_telegram_backup.sql "$SERVER_USER@$SERVER_IP:/root/admin/"

echo "✅ Файлы скопированы"

echo "🔧 Настраиваем окружение на сервере..."

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" << 'ENDSSH'
    cd /root/admin
    
    echo "📦 Устанавливаем зависимости backend..."
    cd backend
    npm install --production
    
    echo "📦 Устанавливаем зависимости frontend..."
    cd ../frontend
    # Frontend уже собран, зависимости не нужны
    
    echo "✅ Зависимости установлены"
ENDSSH

echo "🎉 Деплой завершен!"
echo "📝 Следующие шаги:"
echo "1. Настройте .env файл в /root/admin/backend/.env"
echo "2. Импортируйте базу данных: psql -U postgres -d admin_telegram < /root/admin/admin_telegram_backup.sql"
echo "3. Запустите backend: cd /root/admin/backend && npm start"
echo "4. Настройте nginx для frontend"

