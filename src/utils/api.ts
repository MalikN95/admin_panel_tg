import axios from 'axios';
import type { Bot, Message, MessageType, BotStatistics, Template, Tag, Chat } from '../types';

const MODE = import.meta.env.VITE_APP_MODE || 'dev';
const API_BASE_URL = MODE === 'live' 
  ? (import.meta.env.VITE_API_URL_LIVE || 'http://144.124.249.43:8081/api') 
  : '/api';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor для добавления токена к запросам
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor для обработки ошибок
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Токен истек или невалидный - автоматический редирект на страницу входа
      localStorage.removeItem('accessToken');
      localStorage.removeItem('admin');
      // Используем replace вместо href для более чистого редиректа (без добавления в историю)
      window.location.replace('/login');
    }
    return Promise.reject(error);
  }
);

// API методы для отправки медиа-сообщений
export const sendMessageWithMedia = async (
  chatId: string,
  text?: string,
  file?: File,
  messageType?: MessageType,
  caption?: string,
  replyToMessageId?: string
) => {
  const formData = new FormData();
  
  if (text) {
    formData.append('text', text);
  }
  
  if (file) {
    formData.append('file', file);
  }
  
  if (messageType) {
    formData.append('messageType', messageType);
  }
  
  if (caption) {
    formData.append('caption', caption);
  }

  if (replyToMessageId) {
    formData.append('replyToMessageId', replyToMessageId);
  }

  const response = await api.post(`/chats/${chatId}/messages`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });

  return response.data;
};

// API методы для работы с ботами
export const getBots = async (): Promise<Bot[]> => {
  const response = await api.get('/bots');
  return response.data;
};

export const createBot = async (token: string): Promise<Bot> => {
  const response = await api.post('/bots', { token });
  return response.data;
};

export const deleteBot = async (botId: string): Promise<void> => {
  await api.delete(`/bots/${botId}`);
};

export const toggleBotStatus = async (botId: string): Promise<Bot> => {
  const response = await api.post(`/bots/${botId}/toggle-status`);
  return response.data;
};

export const getBotStatistics = async (botId: string): Promise<BotStatistics> => {
  const response = await api.get(`/bots/${botId}/statistics`);
  return response.data;
};

// Отметить чат как прочитанный
export const markChatAsRead = async (chatId: string): Promise<void> => {
  await api.post(`/chats/${chatId}/mark-as-read`);
};

// Удалить сообщение
export const deleteMessage = async (messageId: string): Promise<void> => {
  await api.post(`/chats/messages/${messageId}/delete`);
};

// Очистить историю чата
export const clearChatHistory = async (chatId: string): Promise<void> => {
  await api.post(`/chats/${chatId}/clear-history`);
};

// API методы для работы с шаблонами
export const getTemplates = async (): Promise<Template[]> => {
  const response = await api.get('/templates');
  return response.data;
};

export const createTemplate = async (
  name: string,
  text: string | null,
  files?: File[]
): Promise<Template> => {
  const formData = new FormData();
  formData.append('name', name);
  
  // Always append text, even if empty
  formData.append('text', text || '');
  
  if (files && files.length > 0) {
    files.forEach((file) => {
      formData.append('files', file);
    });
  }
  
  const response = await api.post('/templates', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  
  return response.data;
};

export const updateTemplate = async (
  id: string,
  name?: string,
  text?: string | null,
  files?: File[]
): Promise<Template> => {
  const formData = new FormData();
  
  if (name !== undefined) {
    formData.append('name', name);
  }
  
  if (text !== undefined) {
    formData.append('text', text || '');
  }
  
  if (files && files.length > 0) {
    files.forEach((file) => {
      formData.append('files', file);
    });
  }
  
  const response = await api.patch(`/templates/${id}`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  
  return response.data;
};

export const deleteTemplate = async (id: string): Promise<void> => {
  await api.delete(`/templates/${id}`);
};

export const deleteTemplateFile = async (templateId: string, fileId: string): Promise<void> => {
  await api.delete(`/templates/${templateId}/files/${fileId}`);
};

export const getTemplateFileUrl = (templateId: string, fileId: string): string => {
  return `${API_BASE_URL}/templates/${templateId}/files/${fileId}`;
};

// Reactions API
export const addReaction = async (messageId: string, emoji: string): Promise<Message> => {
  const response = await api.post(`/chats/messages/${messageId}/reactions`, { emoji });
  return response.data;
};

export const removeReaction = async (messageId: string, reactionId: string): Promise<Message> => {
  const response = await api.delete(`/chats/messages/${messageId}/reactions/${reactionId}`);
  return response.data;
};

// Tags API
export const getAllTags = async (): Promise<Tag[]> => {
  const response = await api.get('/chats/tags-list');
  return response.data;
};

export const addTagToChat = async (chatId: string, tagId: string): Promise<Chat> => {
  const response = await api.post(`/chats/${chatId}/tags/${tagId}`);
  return response.data;
};

export const removeTagFromChat = async (chatId: string, tagId: string): Promise<Chat> => {
  const response = await api.delete(`/chats/${chatId}/tags/${tagId}`);
  return response.data;
};

