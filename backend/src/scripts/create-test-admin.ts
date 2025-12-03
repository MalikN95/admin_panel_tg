import { DataSource } from 'typeorm';
import { config } from 'dotenv';
import * as bcrypt from 'bcrypt';
import { Admin } from '../entities/Admin.entity';

config();

async function createTestAdmin() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'admin_telegram',
    entities: [Admin],
    synchronize: false,
    logging: false,
  });

  try {
    await dataSource.initialize();
    console.log('✅ Подключение к базе данных установлено');

    const adminRepository = dataSource.getRepository(Admin);

    // Проверяем, существует ли уже тестовый админ
    const existingAdmin = await adminRepository.findOne({
      where: { email: 'admin@test.com' },
    });

    if (existingAdmin) {
      console.log('⚠️  Тестовый админ уже существует');
      console.log('📧 Email: admin@test.com');
      console.log('🔑 Пароль: admin123');
      await dataSource.destroy();
      return;
    }

    // Хешируем пароль
    const hashedPassword = await bcrypt.hash('admin123', 10);

    // Создаем тестового админа
    const admin = adminRepository.create({
      email: 'admin@test.com',
      password: hashedPassword,
    });

    await adminRepository.save(admin);

    console.log('✅ Тестовый админ успешно создан!');
    console.log('📧 Email: admin@test.com');
    console.log('🔑 Пароль: admin123');
    console.log('🆔 ID:', admin.id);

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Ошибка при создании тестового админа:', error);
    process.exit(1);
  }
}

createTestAdmin();

