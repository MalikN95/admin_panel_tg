-- 004_add_message_reactions.sql
CREATE TABLE IF NOT EXISTS "message_reactions" (
  "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "message_id" uuid NOT NULL,
  "emoji" character varying NOT NULL,
  "admin_id" character varying,
  "isFromTelegram" boolean NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT "PK_message_reactions" PRIMARY KEY ("id")
);

-- Create index on message_id for faster lookups
CREATE INDEX IF NOT EXISTS "IDX_message_reactions_message_id" ON "message_reactions" ("message_id");

-- Add foreign key constraint
ALTER TABLE "message_reactions" ADD CONSTRAINT "FK_message_reactions_message_id" 
  FOREIGN KEY ("message_id") REFERENCES "messages"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

