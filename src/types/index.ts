export interface Tag {
  id: string;
  name: string;
  tagType: 'hot' | 'warm' | 'cold';
  color: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface Chat {
  id: string;
  name: string;
  avatar: string;
  lastMessage: string;
  unreadCount: number;
  lastMessageTime?: Date | null;
  botId?: string;
  botUsername?: string | null;
  telegramChatId?: number;
  isBotBlocked?: boolean;
  tags?: Tag[];
}

export const MessageType = {
  TEXT: 'text',
  PHOTO: 'photo',
  VIDEO: 'video',
  VOICE: 'voice',
  DOCUMENT: 'document',
  AUDIO: 'audio',
  STICKER: 'sticker',
  VIDEO_NOTE: 'video_note',
  ANIMATION: 'animation',
  LOCATION: 'location',
  CONTACT: 'contact',
} as const;

export type MessageType = typeof MessageType[keyof typeof MessageType];

export interface MessageReaction {
  id: string;
  messageId: string;
  emoji: string;
  adminId: string;
  isFromTelegram: boolean;
  createdAt: Date;
}

export interface Message {
  id: string;
  chatId: string;
  text: string | null;
  senderId: string;
  timestamp: Date;
  isRead: boolean;
  isDelivered?: boolean;
  messageType: MessageType;
  fileId?: string | null;
  fileUrl?: string | null;
  filePath?: string | null;
  fileName?: string | null;
  caption?: string | null;
  isFromAdmin?: boolean;
  reactions?: MessageReaction[];
  replyToMessageId?: string | null;
  replyToMessage?: Message | null;
}

// Доступные реакции (максимум 5 самых популярных)
export const AVAILABLE_REACTIONS = ['👍', '❤️', '😂', '🔥', '👏'] as const;
export type AvailableReaction = typeof AVAILABLE_REACTIONS[number];

export interface Bot {
  id: string;
  token: string;
  username: string | null;
  firstName: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface BotStatistics {
  totalUsers: number;
  totalMessages: number;
  activeUsers: number;
  blockedUsers: number;
}

export interface TemplateFile {
  id: string;
  templateId: string;
  fileName: string;
  filePath: string;
  fileType: string;
  fileSize: number;
  createdAt: Date;
}

export interface Template {
  id: string;
  name: string;
  text: string | null;
  adminId: string | null;
  files: TemplateFile[];
  createdAt: Date;
  updatedAt: Date;
}

export const CURRENT_USER_ID = 'current-user';

