import { IsString, IsIn } from 'class-validator';

// 5 самых популярных реакций
const AVAILABLE_REACTIONS = ['👍', '❤️', '😂', '🔥', '👏'] as const;

export class AddReactionDto {
  @IsString()
  @IsIn(AVAILABLE_REACTIONS, {
    message: `Реакция должна быть одной из: ${AVAILABLE_REACTIONS.join(', ')}`,
  })
  emoji: string;
}

export { AVAILABLE_REACTIONS };

