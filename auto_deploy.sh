#!/bin/bash

# Автоматический деплой с использованием expect для ввода пароля

SERVER_IP="144.124.249.43"
SERVER_USER="root"
SERVER_PASS="X69Sx2y2%M3LGQH3A8vs"
APP_DIR="/root/admin"
PROJECT_DIR="/Users/evgenijkukuskin/Documents/Проекты/cursor/admin_telegram"

echo "🚀 Начинаем автоматический деплой..."

cd "$PROJECT_DIR"

# Создаем expect скрипт для автоматического ввода пароля
expect << EOF
set timeout 300
spawn ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "mkdir -p $APP_DIR && cd $APP_DIR && pwd"
expect {
    "password:" { send "$SERVER_PASS\r"; exp_continue }
    "yes/no" { send "yes\r"; exp_continue }
    eof
}
EOF

echo "📦 Копируем файлы..."

# Копируем backend
expect << EOF
set timeout 600
spawn scp -r -o StrictHostKeyChecking=no backend $SERVER_USER@$SERVER_IP:$APP_DIR/
expect {
    "password:" { send "$SERVER_PASS\r"; exp_continue }
    eof
}
EOF

# Копируем frontend
expect << EOF
set timeout 600
spawn scp -r -o StrictHostKeyChecking=no dist $SERVER_USER@$SERVER_IP:$APP_DIR/frontend
expect {
    "password:" { send "$SERVER_PASS\r"; exp_continue }
    eof
}
EOF

# Копируем backup БД
expect << EOF
set timeout 300
spawn scp -o StrictHostKeyChecking=no admin_telegram_backup.sql $SERVER_USER@$SERVER_IP:$APP_DIR/
expect {
    "password:" { send "$SERVER_PASS\r"; exp_continue }
    eof
}
EOF

echo "🔧 Настраиваем окружение на сервере..."

expect << 'ENDOF'
set timeout 600
spawn ssh -o StrictHostKeyChecking=no root@144.124.249.43
expect {
    "password:" { send "X69Sx2y2%M3LGQH3A8vs\r"; exp_continue }
    "# " { 
        send "cd /root/admin/backend\r"
        expect "# "
        send "npm install --production\r"
        expect "# "
        send "npm run build\r"
        expect "# "
        send "exit\r"
    }
}
expect eof
ENDOF

echo "✅ Деплой завершен!"
echo "📝 Следующие шаги см. в QUICK_DEPLOY.md"

