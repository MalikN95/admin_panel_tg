--
-- PostgreSQL database dump
--

-- Dumped from database version 14.13 (Homebrew)
-- Dumped by pg_dump version 14.13 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: chats_chattype_enum; Type: TYPE; Schema: public; Owner: evgenijkukuskin
--

CREATE TYPE public.chats_chattype_enum AS ENUM (
    'private',
    'group',
    'supergroup',
    'channel'
);


ALTER TYPE public.chats_chattype_enum OWNER TO postgres;

--
-- Name: messages_messagetype_enum; Type: TYPE; Schema: public; Owner: evgenijkukuskin
--

CREATE TYPE public.messages_messagetype_enum AS ENUM (
    'text',
    'photo',
    'video',
    'voice',
    'document',
    'audio',
    'sticker',
    'video_note',
    'animation',
    'location',
    'contact'
);


ALTER TYPE public.messages_messagetype_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.admins (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: bots; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.bots (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    token character varying(500) NOT NULL,
    username character varying(255),
    "firstName" character varying(255),
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bots OWNER TO postgres;

--
-- Name: chat_unread_counts; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.chat_unread_counts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chat_id uuid NOT NULL,
    user_id uuid NOT NULL,
    "unreadCount" integer DEFAULT 0 NOT NULL,
    last_read_message_id uuid,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chat_unread_counts OWNER TO postgres;

--
-- Name: chats; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.chats (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "telegramChatId" bigint NOT NULL,
    "chatType" public.chats_chattype_enum DEFAULT 'private'::public.chats_chattype_enum NOT NULL,
    title character varying(255),
    user_id uuid NOT NULL,
    last_message_id uuid,
    "lastMessageAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    bot_id uuid NOT NULL,
    "isBotBlocked" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- Name: message_reactions; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.message_reactions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    emoji character varying NOT NULL,
    admin_id character varying,
    "isFromTelegram" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.message_reactions OWNER TO postgres;

--
-- Name: message_reads; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.message_reads (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    user_id uuid NOT NULL,
    read_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.message_reads OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chat_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    "telegramMessageId" bigint NOT NULL,
    text text,
    "messageType" public.messages_messagetype_enum DEFAULT 'text'::public.messages_messagetype_enum NOT NULL,
    "fileId" text,
    "fileUniqueId" text,
    "filePath" text,
    "fileUrl" text,
    caption text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    bot_id uuid NOT NULL,
    "isFromAdmin" boolean DEFAULT false NOT NULL,
    "fileName" character varying(255),
    "isDelivered" boolean DEFAULT false NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    reply_to_message_id uuid
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: template_files; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.template_files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    template_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    file_type character varying(100) NOT NULL,
    file_size bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.template_files OWNER TO postgres;

--
-- Name: templates; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    text text,
    admin_id character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.templates OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: evgenijkukuskin
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "telegramId" bigint NOT NULL,
    username character varying(255),
    "firstName" character varying(255) NOT NULL,
    "lastName" character varying(255),
    "avatarUrl" text,
    "isBot" boolean DEFAULT false NOT NULL,
    "languageCode" character varying(10),
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.admins (id, email, password, "createdAt", "updatedAt") FROM stdin;
2b8e52fb-eab6-4df5-a92e-5aaf550d564c	test@test.com	$2b$10$lxa3usItZyTBlQC/Q9uzWu2kkkBTv9wTC7s4LguXuQKR4kSCBX8TC	2025-11-18 10:48:54.622891	2025-11-18 10:48:54.622891
acfad2a8-2efc-4588-b004-a8222463d6aa	jeke8989@gmail.com	$2b$10$MRTelEMiHNubXUBsHv7A7.FiZQs200u2yc7ml5fYKrSR2FVlemlwu	2025-11-18 10:49:06.331453	2025-11-18 10:49:06.331453
e338ed2f-42eb-4247-9bfc-6a311a377472	test123@example.com	$2b$10$9FI18B9Bdk5oV1o080cKdeuAdrGoU42crKnnervi9vf8XIhVlPrlK	2025-11-19 11:46:50.326981	2025-11-19 11:46:50.326981
fc342d56-9bf0-4017-8223-a3d64461ba91	jeke8989+1@gmail.com	$2b$10$pNkbHl2m8AmaqPcZ/f6A2.wfBoJJTvallOjkWjo4AqrC2imlyVhhu	2025-11-19 11:47:33.757949	2025-11-19 11:47:33.757949
047440fe-2455-40b8-8dd9-9b18b0010ef8	admin@test.com	$2b$10$IgScVVIzj1wgGrfb7SoD2.hlbXaWLNl8foVrWknt.V2NjS7Y/7y4K	2025-11-25 17:37:43.489337	2025-11-25 17:37:43.489337
\.


--
-- Data for Name: bots; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.bots (id, token, username, "firstName", "isActive", "createdAt", "updatedAt") FROM stdin;
e19772c2-6872-4519-a33b-61e3c402f447	8256177641:AAGcEIdVAZymqE_jiM9YaAGzVqlRHeiLZPM	Benefitsars_Bot	Benefitsar	t	2025-11-18 11:42:09.71385	2025-11-18 18:17:48.290169
\.


--
-- Data for Name: chat_unread_counts; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.chat_unread_counts (id, chat_id, user_id, "unreadCount", last_read_message_id, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.chats (id, "telegramChatId", "chatType", title, user_id, last_message_id, "lastMessageAt", "createdAt", "updatedAt", bot_id, "isBotBlocked") FROM stdin;
fb6a5bb5-ab06-486a-8121-20c1bec9d798	8297994113	private	\N	7fed2702-185c-43c3-b14d-877ab9377dfb	\N	2025-11-18 11:43:04.225	2025-11-18 11:43:04.225771	2025-11-18 18:18:42.188851	e19772c2-6872-4519-a33b-61e3c402f447	f
2f045396-5e14-4352-8834-74f68291cced	173385085	private	\N	51ca1952-d39d-4ed4-87e4-309d2cd0bd7f	f8dad18d-acc6-40ae-baf8-7bfa1e23d9f7	2025-11-25 18:16:55.061	2025-11-25 18:07:07.557252	2025-11-25 18:16:55.063643	e19772c2-6872-4519-a33b-61e3c402f447	f
443c551a-1fd4-454a-b531-43f47eaa3e86	5871743469	private	\N	c615ae85-3de7-45fe-8481-5a3b1118d5f4	f7f17a13-86fa-495a-8fbb-dc621b3a3f0b	2025-11-25 18:18:15.744	2025-11-18 13:24:34.737848	2025-11-25 18:18:15.747319	e19772c2-6872-4519-a33b-61e3c402f447	f
\.


--
-- Data for Name: message_reactions; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.message_reactions (id, message_id, emoji, admin_id, "isFromTelegram", "createdAt") FROM stdin;
aef4d3b4-7791-49ae-8f54-6762ee04bf59	4fa3d549-c265-44c6-bec4-06f21878b06c	👍	acfad2a8-2efc-4588-b004-a8222463d6aa	f	2025-11-18 18:14:51.403422
42d78117-120f-4f7a-88e6-e5c0755a5213	5e584090-bce6-42cb-8ea2-1a0d7d40f0b5	👏	acfad2a8-2efc-4588-b004-a8222463d6aa	f	2025-11-19 11:19:36.077587
ef5dd53a-36b4-4f7f-ba25-56e1be884492	dc520957-7c41-4b83-a3b8-fc183634c754	😂	acfad2a8-2efc-4588-b004-a8222463d6aa	f	2025-11-19 11:19:37.147765
1836b2b3-2dd4-47d7-ab72-44b2dc9bc2d3	676f67b8-8917-4002-bea6-263aeebf931a	👍	acfad2a8-2efc-4588-b004-a8222463d6aa	f	2025-11-19 11:19:55.502949
6d86d536-50d4-4428-8f7d-b0ead22dc4a8	64d6d602-fb4a-40de-8c5c-e7c93a7f1224	👍	047440fe-2455-40b8-8dd9-9b18b0010ef8	f	2025-11-25 18:10:42.825243
\.


--
-- Data for Name: message_reads; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.message_reads (id, message_id, user_id, read_at) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.messages (id, chat_id, sender_id, "telegramMessageId", text, "messageType", "fileId", "fileUniqueId", "filePath", "fileUrl", caption, "createdAt", "updatedAt", bot_id, "isFromAdmin", "fileName", "isDelivered", "isRead", reply_to_message_id) FROM stdin;
c692e0c0-459f-43d0-a2c8-489e57c424e4	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	75	мне приоритет на эту историю взять на этой неделе? или все таки требования и квитанции ковырять?	text	\N	\N	\N	\N	\N	2025-11-18 17:42:00.064586	2025-11-18 17:42:31.463249	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
4fa3d549-c265-44c6-bec4-06f21878b06c	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	76	\N	voice	AwACAgIAAxkBAANMaRyF1_dkQhAMM8aflS-wTlXBOmMAAoaVAAKZPuhIPolcrudt5nM2BA	AgADhpUAApk-6Eg	\N	https://api.telegram.org/file/bot8256177641:AAGcEIdVAZymqE_jiM9YaAGzVqlRHeiLZPM/voice/file_26.oga	\N	2025-11-18 17:42:31.456934	2025-11-18 17:44:51.795552	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
9de7e4dd-2352-4e2e-8f55-b3768a7c2e44	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	87	Братан это не Слава	text	\N	\N	\N	\N	\N	2025-11-19 11:19:33.204491	2025-11-19 11:19:47.698394	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
9b4c4e60-b16e-4ed4-8262-fae9a0f099f8	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	88	Да	text	\N	\N	\N	\N	\N	2025-11-19 11:19:47.693955	2025-11-19 11:20:03.452713	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
ef14dd8a-7ab5-460d-b129-bb5d7dc946af	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	92	\N	voice	AwACAgIAAxkBAANcaR2CEXn3WCfScX7aDOCW9L-1WB0AAuSMAAKZPvBI5zreuQFFxVQ2BA	AgAD5IwAApk-8Eg	\N	https://api.telegram.org/file/bot8256177641:AAGcEIdVAZymqE_jiM9YaAGzVqlRHeiLZPM/voice/file_30.oga	\N	2025-11-19 11:38:42.140893	2025-11-19 11:41:59.956486	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
35e342a3-eaf9-4c60-b739-428b383a8b20	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	93	\N	voice	AwACAgIAAxkBAANdaR2CHQMIL5lH4a2RaYCIsaSJVPcAAuWMAAKZPvBIIDqNqKDGnpc2BA	AgAD5YwAApk-8Eg	\N	https://api.telegram.org/file/bot8256177641:AAGcEIdVAZymqE_jiM9YaAGzVqlRHeiLZPM/voice/file_31.oga	\N	2025-11-19 11:38:53.395628	2025-11-19 11:41:59.956486	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
8b3897d3-2459-4ef3-bd9a-17791a074160	2f045396-5e14-4352-8834-74f68291cced	51ca1952-d39d-4ed4-87e4-309d2cd0bd7f	97	выаываыв	text	\N	\N	\N	\N	\N	2025-11-25 18:10:40.59409	2025-11-25 18:10:40.59409	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	f	\N
676f67b8-8917-4002-bea6-263aeebf931a	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	89	Не туда	text	\N	\N	\N	\N	\N	2025-11-19 11:19:51.612925	2025-11-19 11:20:03.452713	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
7aa386b1-5c9b-4d4b-8341-6e8d0a0e7242	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	90	это бот с тобой общается	text	\N	\N	\N	\N	\N	2025-11-19 11:19:52.546615	2025-11-19 11:38:42.152968	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
f8dad18d-acc6-40ae-baf8-7bfa1e23d9f7	2f045396-5e14-4352-8834-74f68291cced	51ca1952-d39d-4ed4-87e4-309d2cd0bd7f	98	выаыв	text	\N	\N	\N	\N	\N	2025-11-25 18:16:55.035289	2025-11-25 18:16:55.035289	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	f	64d6d602-fb4a-40de-8c5c-e7c93a7f1224
2e3d1d1d-814d-4db5-9c82-9133296deacc	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	74	Для отправки заявки на чеки заполните текущую таблицу	text	\N	\N	\N	\N	\N	2025-11-18 17:38:32.47433	2025-11-18 17:42:31.463249	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
fcc433fc-bb61-4bdf-8409-8dc13e75dd8b	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	64	снес тебе всю историю	text	\N	\N	\N	\N	\N	2025-11-18 13:40:22.918403	2025-11-18 17:42:31.463249	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
dc520957-7c41-4b83-a3b8-fc183634c754	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	85	Оплати мне светофор плз пока ссылка работает	text	\N	\N	\N	\N	\N	2025-11-19 00:14:12.584959	2025-11-19 11:20:03.452713	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
5e584090-bce6-42cb-8ea2-1a0d7d40f0b5	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	84	Для совершения платежа перейдите по ссылке: https://ecm.sngb.ru:443/rp/api/v1/payment/8174381e-fc94-405c-af09-4a1079f07fe5\n\nЕсли Вам нужен чек, то перед совершением платежа, отправьте, пожалуйста, сообщение с адресом электронной почты. Туда мы отправим чек об оплате.	text	\N	\N	\N	\N	\N	2025-11-19 00:14:12.584807	2025-11-19 11:20:03.452713	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
edde5638-7fd3-4a78-8011-06d8bbcf0ac1	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	86	\N	voice	AwACAgIAAxkBAANWaRzKGD4kO422dsOuRxd7z0L30DUAAm2aAAKZPuhIOlt5enAKSwo2BA	AgADbZoAApk-6Eg	\N	https://api.telegram.org/file/bot8256177641:AAGcEIdVAZymqE_jiM9YaAGzVqlRHeiLZPM/voice/file_29.oga	\N	2025-11-19 00:14:12.734683	2025-11-19 11:20:03.452713	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
6caf4f47-56fa-487b-aab8-320bd619a231	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	91	Братан пришли номер Ольги кто Бизнес-Мост курирует. Этот долбоеб Антон не шевелется!	text	\N	\N	\N	\N	\N	2025-11-19 11:36:41.380858	2025-11-19 11:38:42.152968	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	t	\N
eed34706-ef60-418a-a216-49bfd948c74e	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	94	Я ему писал чтобы он меня с Ольгой состыковал	text	\N	\N	\N	\N	\N	2025-11-19 11:39:05.973006	2025-11-19 11:39:05.973006	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	f	\N
64d6d602-fb4a-40de-8c5c-e7c93a7f1224	2f045396-5e14-4352-8834-74f68291cced	51ca1952-d39d-4ed4-87e4-309d2cd0bd7f	96	/start site	text	\N	\N	\N	\N	\N	2025-11-25 18:07:07.575559	2025-11-25 18:07:47.553252	e19772c2-6872-4519-a33b-61e3c402f447	f	\N	f	t	\N
f7f17a13-86fa-495a-8fbb-dc621b3a3f0b	443c551a-1fd4-454a-b531-43f47eaa3e86	c615ae85-3de7-45fe-8481-5a3b1118d5f4	99	через бот и админку нам доступен полнецееный функционал взаимодействия с клиент. Ответы на сообщения реакции голосовые и все типы файлов мы принимает и можем отправлять	text	\N	\N	\N	\N	\N	2025-11-25 18:18:15.715684	2025-11-25 18:18:15.715684	e19772c2-6872-4519-a33b-61e3c402f447	t	\N	t	f	5e584090-bce6-42cb-8ea2-1a0d7d40f0b5
\.


--
-- Data for Name: template_files; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.template_files (id, template_id, file_name, file_path, file_type, file_size, created_at) FROM stdin;
75ef0c9d-f968-4854-9935-3d3cefae666f	0d19e0d5-ca4d-4dda-b58c-c15806066f34	2-5436144805241456422 ÐÐ´ÐµÑ-Ð¡ÑÐ°ÑÑ Ð´Ð»Ñ ÑÐµÐºÐ¾Ð² (1).xlsx	1763476573871-2-5436144805241456422 ÐÐ´ÐµÑ-Ð¡ÑÐ°ÑÑ Ð´Ð»Ñ ÑÐµÐºÐ¾Ð² (1).xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	10897	2025-11-18 17:36:13.874127
71acf346-2f61-4ab3-9e6b-2e8d7bac60d3	0e8973f3-f4b0-496f-bb76-b57d24e19b3a	2-5436144805241456422 ÐÐ´ÐµÑ-Ð¡ÑÐ°ÑÑ Ð´Ð»Ñ ÑÐµÐºÐ¾Ð² (1).xlsx	1763476633759-2-5436144805241456422 ÐÐ´ÐµÑ-Ð¡ÑÐ°ÑÑ Ð´Ð»Ñ ÑÐµÐºÐ¾Ð² (1).xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	10897	2025-11-18 17:37:13.76045
f373b06b-0171-4e88-9d57-67cd5456e893	0e8973f3-f4b0-496f-bb76-b57d24e19b3a	950b36b0-f8d9-4328-9d15-659c0bcfc1e9_251020_161934.pdf	1763476633759-950b36b0-f8d9-4328-9d15-659c0bcfc1e9_251020_161934.pdf	application/pdf	654524	2025-11-18 17:37:13.76045
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.templates (id, name, text, admin_id, created_at, updated_at) FROM stdin;
0d19e0d5-ca4d-4dda-b58c-c15806066f34	Заявка чека	Для отправки заявки на чеки заполните текущую таблицу 	default-admin	2025-11-18 17:36:13.854232	2025-11-18 17:36:13.854232
0e8973f3-f4b0-496f-bb76-b57d24e19b3a	Заявки счет-фактуры	Для создания заявки на счет-фактуры заполните таблицу и отправьте боту 	default-admin	2025-11-18 17:37:13.757249	2025-11-18 17:37:13.757249
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: evgenijkukuskin
--

COPY public.users (id, "telegramId", username, "firstName", "lastName", "avatarUrl", "isBot", "languageCode", "createdAt", "updatedAt") FROM stdin;
af391472-c11b-4ac9-8bcc-1f7c8f3167f7	1000000000	user0	Светлана	Семенов	\N	f	ru	2025-11-18 10:51:28.782582	2025-11-18 10:51:28.782582
4fb10f5b-5006-4a19-9878-5a5f8937baed	1000000001	user1	Николай	Степанов	\N	f	ru	2025-11-18 10:51:28.791081	2025-11-18 10:51:28.791081
c181f52c-062c-443e-90c0-aee27b11f45a	1000000002	user2	Татьяна	Федоров	\N	f	ru	2025-11-18 10:51:28.792776	2025-11-18 10:51:28.792776
696042da-e8f1-40fd-b604-19d1bf22cb3f	1000000003	user3	Ольга	Федоров	\N	f	ru	2025-11-18 10:51:28.794138	2025-11-18 10:51:28.794138
0fd1fd38-11d6-4a8a-973e-9bbec82ae0a4	1000000004	user4	Юлия	Михайлов	\N	f	ru	2025-11-18 10:51:28.795509	2025-11-18 10:51:28.795509
47669d23-9916-4ac1-a9c5-aab92230ff60	1000000005	user5	Елена	Семенов	\N	f	ru	2025-11-18 10:51:28.796782	2025-11-18 10:51:28.796782
0658b474-06f5-487b-a675-96d24bb5031c	1000000006	user6	Екатерина	Егоров	\N	f	ru	2025-11-18 10:51:28.797701	2025-11-18 10:51:28.797701
6c95c448-b4d6-4488-b80e-66507fdf4f2d	1000000007	user7	Николай	Степанов	\N	f	ru	2025-11-18 10:51:28.798985	2025-11-18 10:51:28.798985
38577dc4-7217-4799-a3cd-023c70d1ff34	1000000008	user8	Владимир	Попов	\N	f	ru	2025-11-18 10:51:28.799993	2025-11-18 10:51:28.799993
dfa1c887-139a-49ec-9040-1f4234b41e53	1000000009	user9	Алексей	Михайлов	\N	f	ru	2025-11-18 10:51:28.801281	2025-11-18 10:51:28.801281
7fed2702-185c-43c3-b14d-877ab9377dfb	8297994113	xo_platform_support	XO	SUPORT	\N	f	ru	2025-11-18 11:43:04.208703	2025-11-18 11:43:04.208703
c615ae85-3de7-45fe-8481-5a3b1118d5f4	5871743469	Strongberi1	Steel	Steel	\N	f	ru	2025-11-18 13:24:34.729885	2025-11-18 13:24:34.729885
51ca1952-d39d-4ed4-87e4-309d2cd0bd7f	173385085	black_tie_777	Black	Tie	\N	f	ru	2025-11-25 18:07:07.541398	2025-11-25 18:07:07.541398
\.


--
-- Name: chats PK_0117647b3c4a4e5ff198aeb6206; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT "PK_0117647b3c4a4e5ff198aeb6206" PRIMARY KEY (id);


--
-- Name: template_files PK_1292ce4293603d6720f53252ddb; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.template_files
    ADD CONSTRAINT "PK_1292ce4293603d6720f53252ddb" PRIMARY KEY (id);


--
-- Name: messages PK_18325f38ae6de43878487eff986; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "PK_18325f38ae6de43878487eff986" PRIMARY KEY (id);


--
-- Name: templates PK_515948649ce0bbbe391de702ae5; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT "PK_515948649ce0bbbe391de702ae5" PRIMARY KEY (id);


--
-- Name: chat_unread_counts PK_6adee048e36f7c239971b33629f; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chat_unread_counts
    ADD CONSTRAINT "PK_6adee048e36f7c239971b33629f" PRIMARY KEY (id);


--
-- Name: message_reads PK_7d3be462a9d7dfbbccc93c097e1; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT "PK_7d3be462a9d7dfbbccc93c097e1" PRIMARY KEY (id);


--
-- Name: bots PK_8b1b0180229dec2cbfdf5e776e4; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT "PK_8b1b0180229dec2cbfdf5e776e4" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: admins PK_e3b38270c97a854c48d2e80874e; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT "PK_e3b38270c97a854c48d2e80874e" PRIMARY KEY (id);


--
-- Name: message_reactions PK_message_reactions; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "PK_message_reactions" PRIMARY KEY (id);


--
-- Name: admins UQ_051db7d37d478a69a7432df1479; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT "UQ_051db7d37d478a69a7432df1479" UNIQUE (email);


--
-- Name: message_reads UQ_504f22ef54941c99b9ec9e31c32; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT "UQ_504f22ef54941c99b9ec9e31c32" UNIQUE (message_id, user_id);


--
-- Name: bots UQ_db8a984f7b412bca2f520cf82f9; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT "UQ_db8a984f7b412bca2f520cf82f9" UNIQUE (token);


--
-- Name: users UQ_df18d17f84763558ac84192c754; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_df18d17f84763558ac84192c754" UNIQUE ("telegramId");


--
-- Name: chat_unread_counts UQ_f80e744d28a16f9d804132161b3; Type: CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chat_unread_counts
    ADD CONSTRAINT "UQ_f80e744d28a16f9d804132161b3" UNIQUE (chat_id, user_id);


--
-- Name: IDX_051db7d37d478a69a7432df147; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_051db7d37d478a69a7432df147" ON public.admins USING btree (email);


--
-- Name: IDX_158bd07d32182afaeeb39f75a6; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_158bd07d32182afaeeb39f75a6" ON public.chats USING btree (bot_id);


--
-- Name: IDX_1a6c491dc8b622c79a170eac70; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_1a6c491dc8b622c79a170eac70" ON public.chat_unread_counts USING btree (user_id);


--
-- Name: IDX_22133395bd13b970ccd0c34ab2; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_22133395bd13b970ccd0c34ab2" ON public.messages USING btree (sender_id);


--
-- Name: IDX_40550eba0c74bfee6a4708210f; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_40550eba0c74bfee6a4708210f" ON public.messages USING btree (bot_id);


--
-- Name: IDX_6ce6acdb0801254590f8a78c08; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_6ce6acdb0801254590f8a78c08" ON public.messages USING btree ("createdAt");


--
-- Name: IDX_7540635fef1922f0b156b9ef74; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_7540635fef1922f0b156b9ef74" ON public.messages USING btree (chat_id);


--
-- Name: IDX_977d4dcdd4dcb8441bac1b2d96; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_977d4dcdd4dcb8441bac1b2d96" ON public.message_reads USING btree (message_id);


--
-- Name: IDX_b6c92d818d42e3e298e84d9441; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_b6c92d818d42e3e298e84d9441" ON public.chats USING btree (user_id);


--
-- Name: IDX_bf865fe3d734f26e5c814bc433; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_bf865fe3d734f26e5c814bc433" ON public.chats USING btree ("telegramChatId");


--
-- Name: IDX_d087d51858906bcaf1e61f7a21; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_d087d51858906bcaf1e61f7a21" ON public.messages USING btree ("telegramMessageId");


--
-- Name: IDX_db8a984f7b412bca2f520cf82f; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_db8a984f7b412bca2f520cf82f" ON public.bots USING btree (token);


--
-- Name: IDX_df18d17f84763558ac84192c75; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_df18d17f84763558ac84192c75" ON public.users USING btree ("telegramId");


--
-- Name: IDX_f2fde665440a5f6a7c2ea22f2b; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_f2fde665440a5f6a7c2ea22f2b" ON public.message_reads USING btree (user_id);


--
-- Name: IDX_f30ebd0d3d07f2e262a6cbb5fa; Type: INDEX; Schema: public; Owner: evgenijkukuskin
--

CREATE INDEX "IDX_f30ebd0d3d07f2e262a6cbb5fa" ON public.chat_unread_counts USING btree (chat_id);


--
-- Name: template_files FK_04540628a6c6589cfc904ee248c; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.template_files
    ADD CONSTRAINT "FK_04540628a6c6589cfc904ee248c" FOREIGN KEY (template_id) REFERENCES public.templates(id) ON DELETE CASCADE;


--
-- Name: chats FK_07b7d9dde84f3d2f0403de3bf09; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT "FK_07b7d9dde84f3d2f0403de3bf09" FOREIGN KEY (last_message_id) REFERENCES public.messages(id);


--
-- Name: chats FK_158bd07d32182afaeeb39f75a60; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT "FK_158bd07d32182afaeeb39f75a60" FOREIGN KEY (bot_id) REFERENCES public.bots(id);


--
-- Name: chat_unread_counts FK_1a6c491dc8b622c79a170eac704; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chat_unread_counts
    ADD CONSTRAINT "FK_1a6c491dc8b622c79a170eac704" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: messages FK_22133395bd13b970ccd0c34ab22; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_22133395bd13b970ccd0c34ab22" FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: messages FK_40550eba0c74bfee6a4708210f3; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_40550eba0c74bfee6a4708210f3" FOREIGN KEY (bot_id) REFERENCES public.bots(id);


--
-- Name: chat_unread_counts FK_5e82dd3bec7b21eeeb551d1b18a; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chat_unread_counts
    ADD CONSTRAINT "FK_5e82dd3bec7b21eeeb551d1b18a" FOREIGN KEY (last_read_message_id) REFERENCES public.messages(id);


--
-- Name: messages FK_7540635fef1922f0b156b9ef74f; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_7540635fef1922f0b156b9ef74f" FOREIGN KEY (chat_id) REFERENCES public.chats(id);


--
-- Name: messages FK_7f87cbb925b1267778a7f4c5d67; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_7f87cbb925b1267778a7f4c5d67" FOREIGN KEY (reply_to_message_id) REFERENCES public.messages(id);


--
-- Name: message_reads FK_977d4dcdd4dcb8441bac1b2d967; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT "FK_977d4dcdd4dcb8441bac1b2d967" FOREIGN KEY (message_id) REFERENCES public.messages(id);


--
-- Name: chats FK_b6c92d818d42e3e298e84d94414; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT "FK_b6c92d818d42e3e298e84d94414" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: message_reactions FK_ce61e365d81a9dfc15cd36513b0; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "FK_ce61e365d81a9dfc15cd36513b0" FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- Name: message_reads FK_f2fde665440a5f6a7c2ea22f2bd; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.message_reads
    ADD CONSTRAINT "FK_f2fde665440a5f6a7c2ea22f2bd" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chat_unread_counts FK_f30ebd0d3d07f2e262a6cbb5fa6; Type: FK CONSTRAINT; Schema: public; Owner: evgenijkukuskin
--

ALTER TABLE ONLY public.chat_unread_counts
    ADD CONSTRAINT "FK_f30ebd0d3d07f2e262a6cbb5fa6" FOREIGN KEY (chat_id) REFERENCES public.chats(id);


--
-- PostgreSQL database dump complete
--

