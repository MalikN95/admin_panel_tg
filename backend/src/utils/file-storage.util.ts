import * as fs from 'fs/promises';
import * as path from 'path';

/**
 * Получает полный путь к файлу с проверкой безопасности
 */
function getSafeFilePath(filePath: string): string | null {
  try {
    // Проверяем, что путь не содержит опасные символы
    const normalizedPath = path.normalize(filePath);
    if (normalizedPath.includes('..')) {
      console.warn(
        `Попытка удалить файл вне разрешенной директории: ${filePath}`,
      );
      return null;
    }

    // Определяем базовую директорию для файлов
    const uploadsDir = path.join(process.cwd(), 'uploads');

    // Если путь абсолютный, проверяем что он в uploads
    if (path.isAbsolute(filePath)) {
      if (!filePath.startsWith(uploadsDir)) {
        console.warn(
          `Попытка удалить файл вне uploads директории: ${filePath}`,
        );
        return null;
      }
      return filePath;
    }

    // Для относительных путей добавляем базовую директорию
    const fullPath = path.join(uploadsDir, filePath);

    // Дополнительная проверка безопасности
    if (!fullPath.startsWith(uploadsDir)) {
      console.warn(
        `Попытка удалить файл вне uploads директории: ${filePath}`,
      );
      return null;
    }

    return fullPath;
  } catch (error) {
    console.error(`Ошибка при обработке пути файла ${filePath}:`, error);
    return null;
  }
}

/**
 * Удаляет файл по пути, если он существует
 */
export async function deleteFileIfExists(filePath: string): Promise<void> {
  if (!filePath || filePath.trim() === '') {
    return;
  }

  const safePath = getSafeFilePath(filePath);
  if (!safePath) {
    return;
  }

  try {
    // Проверяем существование файла
    await fs.access(safePath);
    // Удаляем файл
    await fs.unlink(safePath);
    console.log(`Файл удален: ${safePath}`);
  } catch (error: any) {
    // Если файл не существует (ENOENT), это нормально - возможно уже удален
    if (error.code === 'ENOENT') {
      return;
    }
    // Для других ошибок логируем
    console.error(`Ошибка при удалении файла ${safePath}:`, error);
  }
}

/**
 * Удаляет несколько файлов
 */
export async function deleteFiles(filePaths: string[]): Promise<void> {
  await Promise.all(
    filePaths
      .filter((filePath) => filePath && filePath.trim() !== '')
      .map((filePath) => deleteFileIfExists(filePath))
  );
}

