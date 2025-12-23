## Database Schema (public)

**Source**: Generated from latest Supabase remote schema (`supabase db dump --schema public`)  
**Focus**: Overview of all public tables, with details for the new **conversation/chat** flow.

---

## Key Tables in `public` Schema

- **Users & profiles**

  - `users`
  - `user_approval_requests`
  - `user_kpis`
  - `user_follows`
  - `user_blocks`

- **Content & engagement**

  - `content`
  - `content_likes`
  - `content_comments`
  - `academy_content`
  - `academy_content_views`
  - `events`
  - `event_registrations`

- **Points & store**

  - `points_transactions`
  - `store_products`
  - `store_orders`

- **Riddles / gamification**

  - `weekly_riddles`
  - `riddle_submissions`

- **Notifications**

  - `notifications`

- **New: Conversations / messaging**
  - `conversations`
  - `conversation_participants`
  - `conversation_messages`
  - `conversation_typing_status`

---

## Users (existing)

Main users table extending `auth.users`. Already includes:

- Online state: `is_online` (boolean), `last_seen_at` (timestamptz)
- Identity & profile: `phone_number`, `full_name`, `profile_picture_url`, `language_preference`, `gender`, etc.
- Points & status: `points_balance`, `status` (`user_status` enum), `role` (`user_role` enum)
- Auth linkage: `auth_user_id` → `auth.users(id)`

This is reused by the conversation tables via foreign keys.

---

## New Conversation / Messaging Schema

### 1. `conversations`

Chat conversation container (1-1 or group).

| Column            | Type        | Constraints / Notes                                |
| ----------------- | ----------- | -------------------------------------------------- |
| `id`              | UUID        | PK, `DEFAULT extensions.uuid_generate_v4()`        |
| `is_group`        | BOOLEAN     | NOT NULL, `DEFAULT false` (false = 1-1 chat)       |
| `title`           | TEXT        | Optional, useful for group chats                   |
| `created_by`      | UUID        | FK → `users(id)`, `ON DELETE SET NULL`             |
| `last_message_at` | TIMESTAMPTZ | Updated when new messages arrive                   |
| `created_at`      | TIMESTAMPTZ | NOT NULL, `DEFAULT now()`                          |
| `updated_at`      | TIMESTAMPTZ | NOT NULL, `DEFAULT now()` (kept fresh via trigger) |

**Indexes**

- `idx_conversations_last_message_at` on `(last_message_at DESC NULLS LAST)`

**Triggers**

- `update_conversations_updated_at`
  - `BEFORE UPDATE ON conversations`
  - Calls `public.update_updated_at_column()` to keep `updated_at` fresh.

**RLS Policies**

- **Users can view their conversations**: `SELECT` allowed if the user is a participant in the conversation.
- **Users can update their conversations**: `UPDATE` allowed for participants (e.g. renaming).

---

### 2. `conversation_participants`

Links users to conversations and stores per-user state (read position).

| Column            | Type        | Constraints / Notes                                     |
| ----------------- | ----------- | ------------------------------------------------------- |
| `id`              | UUID        | PK, `DEFAULT extensions.uuid_generate_v4()`             |
| `conversation_id` | UUID        | NOT NULL, FK → `conversations(id)`, `ON DELETE CASCADE` |
| `user_id`         | UUID        | NOT NULL, FK → `users(id)`, `ON DELETE CASCADE`         |
| `joined_at`       | TIMESTAMPTZ | NOT NULL, `DEFAULT now()`                               |
| `last_read_at`    | TIMESTAMPTZ | Nullable, last message seen by this user in this convo  |

**Constraints**

- `UNIQUE (conversation_id, user_id)` to avoid duplicate membership rows.

**Indexes**

- `idx_conversation_participants_user` on `(user_id)`
- `idx_conversation_participants_conversation` on `(conversation_id)`

**How to compute unread messages**

- For a given participant:
  - Unread messages = messages where  
    `conversation_id = ?` AND `created_at > last_read_at` (or `last_read_at IS NULL`).

**RLS Policies**

- **Users can view own conversation participants**: `SELECT` only where `user_id = auth.uid()`.
- **Users can join conversations**: `INSERT` only where `user_id = auth.uid()`.
- **Users can leave conversations**: `DELETE` only where `user_id = auth.uid()`.
- **Users can update own participant state**: `UPDATE` only where `user_id = auth.uid()` (e.g. update `last_read_at`).

---

### 3. `conversation_messages`

Stores the actual chat messages, including media.

| Column            | Type        | Constraints / Notes                                                |
| ----------------- | ----------- | ------------------------------------------------------------------ |
| `id`              | UUID        | PK, `DEFAULT extensions.uuid_generate_v4()`                        |
| `conversation_id` | UUID        | NOT NULL, FK → `conversations(id)`, `ON DELETE CASCADE`            |
| `sender_id`       | UUID        | NOT NULL, FK → `users(id)`, `ON DELETE CASCADE`                    |
| `content`         | TEXT        | Plain-text message body (optional if only media)                   |
| `media`           | JSONB       | `DEFAULT '[]'::jsonb`, array of media objects (e.g. `{url, type}`) |
| `metadata`        | JSONB       | `DEFAULT '{}'::jsonb`, reactions / reply-to / extra info           |
| `created_at`      | TIMESTAMPTZ | NOT NULL, `DEFAULT now()`                                          |
| `updated_at`      | TIMESTAMPTZ | NOT NULL, `DEFAULT now()`                                          |
| `deleted_at`      | TIMESTAMPTZ | For soft delete (sender-side delete)                               |

**Indexes**

- `idx_conversation_messages_conversation_created_at` on `(conversation_id, created_at DESC)`
- `idx_conversation_messages_sender_created_at` on `(sender_id, created_at DESC)`

**Triggers**

- `conversation_messages_after_insert`
  - `AFTER INSERT ON conversation_messages`
  - Calls `public.update_conversation_last_message()` which:
    - Sets `conversations.last_message_at = NEW.created_at`
    - Updates `conversations.updated_at = now()`

**RLS Policies**

- **Users can view conversation messages**: `SELECT` allowed only if user is a participant of that conversation.
- **Users can send messages**: `INSERT` allowed only if:
  - `sender_id = auth.uid()`, and
  - The user is a participant in the target conversation.
- **Senders can soft-delete own messages**: `UPDATE` allowed only where `sender_id = auth.uid()` (e.g. to set `deleted_at` or edit `content`).

**Media model**

- `media` is a JSON array, so you can support:
  - Images, video, audio, documents, etc.
  - Example item: `{ "url": "https://...", "type": "image", "thumbUrl": "https://..." }`

---

### 4. `conversation_typing_status`

Persisted typing indicator per user per conversation.

| Column            | Type        | Constraints / Notes                                     |
| ----------------- | ----------- | ------------------------------------------------------- |
| `id`              | UUID        | PK, `DEFAULT extensions.uuid_generate_v4()`             |
| `conversation_id` | UUID        | NOT NULL, FK → `conversations(id)`, `ON DELETE CASCADE` |
| `user_id`         | UUID        | NOT NULL, FK → `users(id)`, `ON DELETE CASCADE`         |
| `is_typing`       | BOOLEAN     | NOT NULL, `DEFAULT false`                               |
| `updated_at`      | TIMESTAMPTZ | NOT NULL, `DEFAULT now()`                               |

**Constraints**

- `UNIQUE (conversation_id, user_id)` to have at most one row per user per conversation.

**Indexes**

- `idx_conversation_typing_conversation` on `(conversation_id)`
- `idx_conversation_typing_user` on `(user_id)`

**RLS Policies**

- **Users can view typing status in their conversations**: `SELECT` allowed if user is a participant in that conversation.
- **Users can update own typing status**: `INSERT` allowed only where `user_id = auth.uid()`.
- **Users can change own typing status**: `UPDATE` allowed only where `user_id = auth.uid()`.

**Usage pattern**

- On keydown / typing start:
  - Upsert row with `is_typing = true`, `updated_at = now()`.
- On typing stop / blur:
  - Update row with `is_typing = false`, `updated_at = now()`.

---

## High-level Conversation Flow

- **Start / open conversation**

  - Create a row in `conversations` (optionally with `is_group = false` for 1-1).
  - Insert rows in `conversation_participants` for all users.

- **Send message**

  - Insert into `conversation_messages` with `conversation_id`, `sender_id`, `content` and/or `media`.
  - Trigger updates `conversations.last_message_at` automatically.

- **Read / unread**

  - When a user views a conversation, update `conversation_participants.last_read_at` to `now()`.
  - Unread count per conversation = messages where `created_at > last_read_at` for that participant.

- **Typing indicator**
  - Frontend updates `conversation_typing_status` for current user in a conversation.
  - Other participants subscribe and show "is typing" if `is_typing = true` and `updated_at` is recent.

---

## Grants (for Supabase roles)

For the new tables the migration grants:

- `GRANT ALL ON TABLE public.conversations TO anon, authenticated, service_role;`
- `GRANT ALL ON TABLE public.conversation_participants TO anon, authenticated, service_role;`
- `GRANT ALL ON TABLE public.conversation_messages TO anon, authenticated, service_role;`
- `GRANT ALL ON TABLE public.conversation_typing_status TO anon, authenticated, service_role;`

Combined with the RLS policies above, this enables:

- **Logged-in users** (`authenticated`) to:
  - Participate in conversations,
  - Send and read messages where they are participants,
  - See who is typing in their conversations.
- **Service role** to bypass RLS if needed for backend tasks.

# Database Schema Documentation

**Last Updated:** Generated from latest database schema  
**Schema:** `public`

This document provides a comprehensive overview of all tables, types, functions, and relationships in the public schema.

---

## Table of Contents

1. [Enums & Custom Types](#enums--custom-types)
2. [Tables](#tables)
3. [Functions](#functions)
4. [Triggers](#triggers)
5. [Relationships](#relationships)
6. [Indexes](#indexes)

---

## Enums & Custom Types

### `academy_file_type`

- `video`
- `zoom_workshop`
- `assignment`
- `reel`

### `content_type`

- `vod` - Video on Demand
- `podcast`
- `feed`

### `event_type`

- `zoom_workshop`
- `live_event`
- `reel`

### `gender_type`

- `male`
- `female`
- `other`
- `prefer_not_to_say`

### `language_preference`

- `en` - English
- `he` - Hebrew

### `notification_type`

- `riddle_new`
- `zoom_starting`
- `event_reminder`
- `order_update`
- `follow`
- `comment`
- `like`

### `order_status`

- `pending`
- `confirmed`
- `shipped`
- `delivered`
- `cancelled`

### `payment_method`

- `points`
- `credit_card`

### `points_transaction_type`

- `earned`
- `spent`
- `refunded`

### `riddle_solution_type`

- `text`
- `voice`
- `video`

### `user_role`

- `user`
- `creator`
- `admin`

### `user_status`

- `pending`
- `approved`
- `rejected`
- `suspended`

---

## Tables

### `users`

Main users table extending Supabase auth.users

| Column                | Type                | Constraints                      | Description                                  |
| --------------------- | ------------------- | -------------------------------- | -------------------------------------------- |
| `id`                  | UUID                | PRIMARY KEY, FK → auth.users(id) | User ID (matches auth.users)                 |
| `phone_number`        | VARCHAR(20)         | UNIQUE, NOT NULL                 | Normalized phone number                      |
| `full_name`           | VARCHAR(255)        |                                  | User's full name                             |
| `profile_picture_url` | TEXT                |                                  | Profile picture URL                          |
| `language_preference` | language_preference | DEFAULT 'en', NOT NULL           | Preferred language                           |
| `birthday`            | DATE                |                                  | User's birthday                              |
| `city`                | VARCHAR(100)        |                                  | User's city                                  |
| `gender`              | gender_type         |                                  | User's gender                                |
| `device_model`        | VARCHAR(100)        |                                  | Device model                                 |
| `social_media_links`  | JSONB               | DEFAULT '{}'                     | JSON object with social media platform links |
| `profession`          | VARCHAR(255)        |                                  | User's profession                            |
| `bio`                 | TEXT                |                                  | User biography                               |
| `description`         | TEXT                |                                  | User description                             |
| `points_balance`      | INTEGER             | DEFAULT 0, NOT NULL, CHECK >= 0  | Current points balance                       |
| `status`              | user_status         | DEFAULT 'pending', NOT NULL      | Account status                               |
| `role`                | user_role           | DEFAULT 'user', NOT NULL         | User role                                    |
| `is_online`           | BOOLEAN             | DEFAULT false, NOT NULL          | Online status                                |
| `last_seen_at`        | TIMESTAMPTZ         |                                  | Last seen timestamp                          |
| `created_at`          | TIMESTAMPTZ         | DEFAULT now(), NOT NULL          | Creation timestamp                           |
| `updated_at`          | TIMESTAMPTZ         | DEFAULT now(), NOT NULL          | Last update timestamp                        |
| `approved_at`         | TIMESTAMPTZ         |                                  | Approval timestamp                           |
| `approved_by`         | UUID                | FK → users(id)                   | Admin who approved                           |
| `auth_user_id`        | UUID                | UNIQUE, FK → auth.users(id)      | Auth table user ID                           |
| `otp_code`            | VARCHAR(6)          |                                  | OTP code for authentication                  |
| `otp_created_at`      | TIMESTAMPTZ         |                                  | OTP creation timestamp                       |
| `email`               | VARCHAR             |                                  | User email                                   |

**Indexes:**

- `idx_users_created_at` (created_at DESC)
- `idx_users_is_online` (is_online) WHERE is_online = true
- `idx_users_phone_number` (phone_number)
- `idx_users_role` (role)
- `idx_users_status` (status)

---

### `user_approval_requests`

Tracks user approval requests

| Column             | Type        | Constraints                 | Description              |
| ------------------ | ----------- | --------------------------- | ------------------------ |
| `id`               | UUID        | PRIMARY KEY                 | Request ID               |
| `user_id`          | UUID        | NOT NULL, FK → users(id)    | User requesting approval |
| `requested_at`     | TIMESTAMPTZ | DEFAULT now(), NOT NULL     | Request timestamp        |
| `reviewed_at`      | TIMESTAMPTZ |                             | Review timestamp         |
| `reviewed_by`      | UUID        | FK → users(id)              | Admin who reviewed       |
| `status`           | user_status | DEFAULT 'pending', NOT NULL | Request status           |
| `rejection_reason` | TEXT        |                             | Reason for rejection     |

**Indexes:**

- `idx_user_approval_requests_requested_at` (requested_at DESC)
- `idx_user_approval_requests_status` (status)
- `idx_user_approval_requests_user` (user_id)

---

### `user_kpis`

Denormalized user KPIs for performance

| Column                  | Type        | Constraints                 | Description               |
| ----------------------- | ----------- | --------------------------- | ------------------------- |
| `user_id`               | UUID        | PRIMARY KEY, FK → users(id) | User ID                   |
| `posts_published_count` | INTEGER     | DEFAULT 0, NOT NULL         | Number of published posts |
| `followers_count`       | INTEGER     | DEFAULT 0, NOT NULL         | Number of followers       |
| `following_count`       | INTEGER     | DEFAULT 0, NOT NULL         | Number of users following |
| `updated_at`            | TIMESTAMPTZ | DEFAULT now(), NOT NULL     | Last update timestamp     |

---

### `user_follows`

User follow relationships

| Column         | Type        | Constraints              | Description         |
| -------------- | ----------- | ------------------------ | ------------------- |
| `id`           | UUID        | PRIMARY KEY              | Follow ID           |
| `follower_id`  | UUID        | NOT NULL, FK → users(id) | User who follows    |
| `following_id` | UUID        | NOT NULL, FK → users(id) | User being followed |
| `created_at`   | TIMESTAMPTZ | DEFAULT now(), NOT NULL  | Follow timestamp    |

**Constraints:**

- UNIQUE (follower_id, following_id)
- CHECK (follower_id <> following_id)

**Indexes:**

- `idx_user_follows_follower` (follower_id)
- `idx_user_follows_following` (following_id)

---

### `user_blocks`

User block relationships

| Column       | Type        | Constraints              | Description        |
| ------------ | ----------- | ------------------------ | ------------------ |
| `id`         | UUID        | PRIMARY KEY              | Block ID           |
| `blocker_id` | UUID        | NOT NULL, FK → users(id) | User who blocks    |
| `blocked_id` | UUID        | NOT NULL, FK → users(id) | User being blocked |
| `created_at` | TIMESTAMPTZ | DEFAULT now(), NOT NULL  | Block timestamp    |

**Constraints:**

- UNIQUE (blocker_id, blocked_id)
- CHECK (blocker_id <> blocked_id)

**Indexes:**

- `idx_user_blocks_blocker` (blocker_id)
- `idx_user_blocks_blocked` (blocked_id)

---

### `content`

Content table for VOD, Podcast, and Feed posts

| Column                     | Type         | Constraints              | Description                                      |
| -------------------------- | ------------ | ------------------------ | ------------------------------------------------ |
| `id`                       | UUID         | PRIMARY KEY              | Content ID                                       |
| `title`                    | VARCHAR(255) |                          | Content title                                    |
| `description`              | TEXT         |                          | Content description                              |
| `content_type`             | content_type | NOT NULL                 | Type of content                                  |
| `user_id`                  | UUID         | NOT NULL, FK → users(id) | Creator user ID                                  |
| `media_file_url`           | TEXT         |                          | Single media file URL                            |
| `media_files`              | JSONB        | DEFAULT '[]'             | JSON array of media file URLs (for feed posts)   |
| `thumbnail_url`            | TEXT         |                          | Thumbnail URL                                    |
| `category`                 | VARCHAR(100) |                          | Content category                                 |
| `points_to_earn`           | INTEGER      | DEFAULT 0, CHECK >= 0    | Points awarded for viewing                       |
| `is_featured`              | BOOLEAN      | DEFAULT false, NOT NULL  | Featured flag                                    |
| `is_published`             | BOOLEAN      | DEFAULT true, NOT NULL   | Published flag                                   |
| `is_shared_to_community`   | BOOLEAN      | DEFAULT true, NOT NULL   | Shared to community flag                         |
| `external_share_platforms` | JSONB        | DEFAULT '[]'             | JSON array of platforms where content was shared |
| `view_count`               | INTEGER      | DEFAULT 0, NOT NULL      | View count                                       |
| `likes_count`              | INTEGER      | DEFAULT 0, NOT NULL      | Likes count                                      |
| `comments_count`           | INTEGER      | DEFAULT 0, NOT NULL      | Comments count                                   |
| `created_at`               | TIMESTAMPTZ  | DEFAULT now(), NOT NULL  | Creation timestamp                               |
| `updated_at`               | TIMESTAMPTZ  | DEFAULT now(), NOT NULL  | Last update timestamp                            |
| `deleted_at`               | TIMESTAMPTZ  |                          | Soft delete timestamp                            |

**Indexes:**

- `idx_content_created_at` (created_at DESC)
- `idx_content_deleted_at` (deleted_at) WHERE deleted_at IS NULL
- `idx_content_is_published` (is_published) WHERE is_published = true
- `idx_content_shared` (is_shared_to_community) WHERE is_shared_to_community = true
- `idx_content_title_search` (title) USING gin (gin_trgm_ops)
- `idx_content_type` (content_type)
- `idx_content_user_id` (user_id)

---

### `content_likes`

Content likes

| Column       | Type        | Constraints                | Description    |
| ------------ | ----------- | -------------------------- | -------------- |
| `id`         | UUID        | PRIMARY KEY                | Like ID        |
| `content_id` | UUID        | NOT NULL, FK → content(id) | Content ID     |
| `user_id`    | UUID        | NOT NULL, FK → users(id)   | User who liked |
| `created_at` | TIMESTAMPTZ | DEFAULT now(), NOT NULL    | Like timestamp |

**Constraints:**

- UNIQUE (content_id, user_id)

**Indexes:**

- `idx_content_likes_content` (content_id)
- `idx_content_likes_user` (user_id)

---

### `content_comments`

Content comments

| Column       | Type        | Constraints                | Description           |
| ------------ | ----------- | -------------------------- | --------------------- |
| `id`         | UUID        | PRIMARY KEY                | Comment ID            |
| `content_id` | UUID        | NOT NULL, FK → content(id) | Content ID            |
| `user_id`    | UUID        | NOT NULL, FK → users(id)   | Commenter user ID     |
| `content`    | TEXT        | NOT NULL                   | Comment text          |
| `created_at` | TIMESTAMPTZ | DEFAULT now(), NOT NULL    | Creation timestamp    |
| `updated_at` | TIMESTAMPTZ | DEFAULT now(), NOT NULL    | Last update timestamp |
| `deleted_at` | TIMESTAMPTZ |                            | Soft delete timestamp |

**Indexes:**

- `idx_content_comments_content` (content_id)
- `idx_content_comments_created_at` (created_at DESC)
- `idx_content_comments_deleted_at` (deleted_at) WHERE deleted_at IS NULL
- `idx_content_comments_user` (user_id)

---

### `points_transactions`

Audit trail for all points transactions

| Column                | Type                    | Constraints              | Description                                                        |
| --------------------- | ----------------------- | ------------------------ | ------------------------------------------------------------------ |
| `id`                  | UUID                    | PRIMARY KEY              | Transaction ID                                                     |
| `user_id`             | UUID                    | NOT NULL, FK → users(id) | User ID                                                            |
| `transaction_type`    | points_transaction_type | NOT NULL                 | Transaction type                                                   |
| `amount`              | INTEGER                 | NOT NULL                 | Transaction amount                                                 |
| `balance_after`       | INTEGER                 | NOT NULL                 | Balance after transaction                                          |
| `description`         | TEXT                    |                          | Transaction description                                            |
| `related_entity_type` | VARCHAR(50)             |                          | Type of related entity (content, event, riddle, store_order, etc.) |
| `related_entity_id`   | UUID                    |                          | ID of related entity                                               |
| `created_at`          | TIMESTAMPTZ             | DEFAULT now(), NOT NULL  | Transaction timestamp                                              |

**Indexes:**

- `idx_points_transactions_created_at` (created_at DESC)
- `idx_points_transactions_related` (related_entity_type, related_entity_id)
- `idx_points_transactions_type` (transaction_type)
- `idx_points_transactions_user` (user_id)

---

### `events`

Events including Zoom workshops

| Column              | Type         | Constraints             | Description               |
| ------------------- | ------------ | ----------------------- | ------------------------- |
| `id`                | UUID         | PRIMARY KEY             | Event ID                  |
| `title`             | VARCHAR(255) | NOT NULL                | Event title               |
| `description`       | TEXT         |                         | Event description         |
| `event_type`        | event_type   | NOT NULL                | Event type                |
| `event_date`        | TIMESTAMPTZ  | NOT NULL                | Event date/time           |
| `duration_minutes`  | INTEGER      |                         | Event duration in minutes |
| `cost_points`       | INTEGER      | DEFAULT 0, CHECK >= 0   | Cost in points            |
| `cost_credit_cents` | INTEGER      |                         | Cost in cents             |
| `max_tickets`       | INTEGER      |                         | Maximum tickets available |
| `tickets_sold`      | INTEGER      | DEFAULT 0, NOT NULL     | Tickets sold count        |
| `zoom_link`         | TEXT         |                         | Zoom meeting link         |
| `zoom_meeting_id`   | VARCHAR(255) |                         | Zoom meeting ID           |
| `image_url`         | TEXT         |                         | Event image URL           |
| `is_published`      | BOOLEAN      | DEFAULT true, NOT NULL  | Published flag            |
| `created_by`        | UUID         | FK → users(id)          | Creator user ID           |
| `created_at`        | TIMESTAMPTZ  | DEFAULT now(), NOT NULL | Creation timestamp        |
| `updated_at`        | TIMESTAMPTZ  | DEFAULT now(), NOT NULL | Last update timestamp     |

**Indexes:**

- `idx_events_created_by` (created_by)
- `idx_events_date` (event_date)
- `idx_events_is_published` (is_published) WHERE is_published = true
- `idx_events_type` (event_type)

---

### `event_registrations`

Event registrations

| Column              | Type           | Constraints                    | Description            |
| ------------------- | -------------- | ------------------------------ | ---------------------- |
| `id`                | UUID           | PRIMARY KEY                    | Registration ID        |
| `event_id`          | UUID           | NOT NULL, FK → events(id)      | Event ID               |
| `user_id`           | UUID           | NOT NULL, FK → users(id)       | User ID                |
| `payment_method`    | payment_method | NOT NULL                       | Payment method used    |
| `points_paid`       | INTEGER        | DEFAULT 0, CHECK >= 0          | Points paid            |
| `credit_paid_cents` | INTEGER        |                                | Credit paid in cents   |
| `status`            | VARCHAR(50)    | DEFAULT 'registered', NOT NULL | Registration status    |
| `registered_at`     | TIMESTAMPTZ    | DEFAULT now(), NOT NULL        | Registration timestamp |
| `attended_at`       | TIMESTAMPTZ    |                                | Attendance timestamp   |

**Constraints:**

- UNIQUE (event_id, user_id)

**Indexes:**

- `idx_event_registrations_event` (event_id)
- `idx_event_registrations_status` (status)
- `idx_event_registrations_user` (user_id)

---

### `academy_content`

Academy lessons, videos, and assignments

| Column               | Type              | Constraints             | Description           |
| -------------------- | ----------------- | ----------------------- | --------------------- |
| `id`                 | UUID              | PRIMARY KEY             | Content ID            |
| `title`              | VARCHAR(255)      | NOT NULL                | Content title         |
| `description`        | TEXT              |                         | Content description   |
| `file_type`          | academy_file_type | NOT NULL                | File type             |
| `media_file_url`     | TEXT              |                         | Media file URL        |
| `points_to_earn`     | INTEGER           | DEFAULT 0, CHECK >= 0   | Points to earn        |
| `event_id`           | UUID              | FK → events(id)         | Related event ID      |
| `assignment_details` | JSONB             |                         | Assignment details    |
| `is_published`       | BOOLEAN           | DEFAULT true, NOT NULL  | Published flag        |
| `created_by`         | UUID              | FK → users(id)          | Creator user ID       |
| `created_at`         | TIMESTAMPTZ       | DEFAULT now(), NOT NULL | Creation timestamp    |
| `updated_at`         | TIMESTAMPTZ       | DEFAULT now(), NOT NULL | Last update timestamp |

**Indexes:**

- `idx_academy_content_created_at` (created_at DESC)
- `idx_academy_content_created_by` (created_by)
- `idx_academy_content_is_published` (is_published) WHERE is_published = true
- `idx_academy_content_type` (file_type)

---

### `academy_content_views`

Academy content views tracking

| Column          | Type        | Constraints                        | Description    |
| --------------- | ----------- | ---------------------------------- | -------------- |
| `id`            | UUID        | PRIMARY KEY                        | View ID        |
| `content_id`    | UUID        | NOT NULL, FK → academy_content(id) | Content ID     |
| `user_id`       | UUID        | NOT NULL, FK → users(id)           | User ID        |
| `viewed_at`     | TIMESTAMPTZ | DEFAULT now(), NOT NULL            | View timestamp |
| `points_earned` | INTEGER     | DEFAULT 0, CHECK >= 0              | Points earned  |

**Constraints:**

- UNIQUE (content_id, user_id)

**Indexes:**

- `idx_academy_content_views_content` (content_id)
- `idx_academy_content_views_user` (user_id)
- `idx_academy_content_views_viewed_at` (viewed_at DESC)

---

### `weekly_riddles`

Weekly riddle challenges with Gemini AI integration

| Column           | Type                 | Constraints             | Description           |
| ---------------- | -------------------- | ----------------------- | --------------------- |
| `id`             | UUID                 | PRIMARY KEY             | Riddle ID             |
| `title`          | VARCHAR(255)         | NOT NULL                | Riddle title          |
| `description`    | TEXT                 |                         | Riddle description    |
| `rules`          | TEXT                 |                         | Riddle rules          |
| `solution_type`  | riddle_solution_type | NOT NULL                | Solution type         |
| `text_solutions` | JSONB                | DEFAULT '[]'            | Text solutions array  |
| `points_to_earn` | INTEGER              | NOT NULL, CHECK > 0     | Points to earn        |
| `admin_vod_url`  | TEXT                 |                         | Admin VOD URL         |
| `start_date`     | TIMESTAMPTZ          | DEFAULT now(), NOT NULL | Start date            |
| `end_date`       | TIMESTAMPTZ          | NOT NULL                | End date              |
| `is_active`      | BOOLEAN              | DEFAULT true, NOT NULL  | Active flag           |
| `created_by`     | UUID                 | FK → users(id)          | Creator user ID       |
| `created_at`     | TIMESTAMPTZ          | DEFAULT now(), NOT NULL | Creation timestamp    |
| `updated_at`     | TIMESTAMPTZ          | DEFAULT now(), NOT NULL | Last update timestamp |

**Constraints:**

- CHECK (end_date > start_date)

**Indexes:**

- `idx_weekly_riddles_active` (is_active) WHERE is_active = true
- `idx_weekly_riddles_created_at` (created_at DESC)
- `idx_weekly_riddles_end_date` (end_date)

---

### `riddle_submissions`

Riddle submissions

| Column               | Type        | Constraints                       | Description                                      |
| -------------------- | ----------- | --------------------------------- | ------------------------------------------------ |
| `id`                 | UUID        | PRIMARY KEY                       | Submission ID                                    |
| `riddle_id`          | UUID        | NOT NULL, FK → weekly_riddles(id) | Riddle ID                                        |
| `user_id`            | UUID        | NOT NULL, FK → users(id)          | User ID                                          |
| `solution_text`      | TEXT        |                                   | Text solution                                    |
| `solution_voice_url` | TEXT        |                                   | Voice solution URL                               |
| `solution_video_url` | TEXT        |                                   | Video solution URL                               |
| `gemini_response`    | JSONB       |                                   | Stores Gemini AI response/analysis of submission |
| `is_correct`         | BOOLEAN     |                                   | Correctness flag                                 |
| `points_earned`      | INTEGER     | DEFAULT 0, CHECK >= 0             | Points earned                                    |
| `submitted_at`       | TIMESTAMPTZ | DEFAULT now(), NOT NULL           | Submission timestamp                             |

**Constraints:**

- UNIQUE (riddle_id, user_id)

**Indexes:**

- `idx_riddle_submissions_riddle` (riddle_id)
- `idx_riddle_submissions_submitted_at` (submitted_at DESC)
- `idx_riddle_submissions_user` (user_id)

---

### `store_products`

Products available in the points-based store

| Column                  | Type         | Constraints                     | Description           |
| ----------------------- | ------------ | ------------------------------- | --------------------- |
| `id`                    | UUID         | PRIMARY KEY                     | Product ID            |
| `name`                  | VARCHAR(255) | NOT NULL                        | Product name          |
| `description`           | TEXT         |                                 | Product description   |
| `description_video_url` | TEXT         |                                 | Description video URL |
| `cost_points`           | INTEGER      | NOT NULL, CHECK > 0             | Cost in points        |
| `quantity_in_stock`     | INTEGER      | DEFAULT 0, NOT NULL, CHECK >= 0 | Stock quantity        |
| `image_url`             | TEXT         |                                 | Product image URL     |
| `is_available`          | BOOLEAN      | DEFAULT true, NOT NULL          | Availability flag     |
| `created_by`            | UUID         | FK → users(id)                  | Creator user ID       |
| `created_at`            | TIMESTAMPTZ  | DEFAULT now(), NOT NULL         | Creation timestamp    |
| `updated_at`            | TIMESTAMPTZ  | DEFAULT now(), NOT NULL         | Last update timestamp |

**Indexes:**

- `idx_store_products_available` (is_available) WHERE is_available = true
- `idx_store_products_created_at` (created_at DESC)

---

### `store_orders`

Store orders

| Column             | Type         | Constraints                       | Description        |
| ------------------ | ------------ | --------------------------------- | ------------------ |
| `id`               | UUID         | PRIMARY KEY                       | Order ID           |
| `user_id`          | UUID         | NOT NULL, FK → users(id)          | User ID            |
| `product_id`       | UUID         | NOT NULL, FK → store_products(id) | Product ID         |
| `quantity`         | INTEGER      | NOT NULL, CHECK > 0               | Order quantity     |
| `points_paid`      | INTEGER      | NOT NULL, CHECK > 0               | Points paid        |
| `shipping_address` | TEXT         | NOT NULL                          | Shipping address   |
| `shipping_zip`     | VARCHAR(20)  | NOT NULL                          | Shipping ZIP code  |
| `shipping_phone`   | VARCHAR(20)  | NOT NULL                          | Shipping phone     |
| `status`           | order_status | DEFAULT 'pending', NOT NULL       | Order status       |
| `ordered_at`       | TIMESTAMPTZ  | DEFAULT now(), NOT NULL           | Order timestamp    |
| `shipped_at`       | TIMESTAMPTZ  |                                   | Shipment timestamp |
| `delivered_at`     | TIMESTAMPTZ  |                                   | Delivery timestamp |

**Indexes:**

- `idx_store_orders_ordered_at` (ordered_at DESC)
- `idx_store_orders_product` (product_id)
- `idx_store_orders_status` (status)
- `idx_store_orders_user` (user_id)

---

### `notifications`

User notifications system

| Column                | Type              | Constraints              | Description          |
| --------------------- | ----------------- | ------------------------ | -------------------- |
| `id`                  | UUID              | PRIMARY KEY              | Notification ID      |
| `user_id`             | UUID              | NOT NULL, FK → users(id) | User ID              |
| `notification_type`   | notification_type | NOT NULL                 | Notification type    |
| `title`               | VARCHAR(255)      | NOT NULL                 | Notification title   |
| `message`             | TEXT              | NOT NULL                 | Notification message |
| `is_read`             | BOOLEAN           | DEFAULT false, NOT NULL  | Read flag            |
| `related_entity_type` | VARCHAR(50)       |                          | Related entity type  |
| `related_entity_id`   | UUID              |                          | Related entity ID    |
| `created_at`          | TIMESTAMPTZ       | DEFAULT now(), NOT NULL  | Creation timestamp   |

**Indexes:**

- `idx_notifications_created_at` (created_at DESC)
- `idx_notifications_read` (is_read) WHERE is_read = false
- `idx_notifications_type` (notification_type)
- `idx_notifications_user` (user_id)

---

## Functions

### Authentication & User Management

#### `check_user_exists(p_phone_number VARCHAR)`

Checks if a user exists by phone number.

**Returns:** TABLE(user_id UUID, phone_number VARCHAR, status user_status, user_exists BOOLEAN)

#### `generate_and_save_otp(p_phone_number VARCHAR)`

Generates and saves an OTP code for a user. Creates a new user if they don't exist.

**Returns:** VARCHAR(6) - The generated OTP code

#### `verify_otp(p_phone_number VARCHAR, p_otp_code VARCHAR)`

Verifies an OTP code for a user.

**Returns:** TABLE(user_id UUID, phone_number VARCHAR, full_name VARCHAR, status user_status, role user_role, points_balance INTEGER, language_preference language_preference, created_at TIMESTAMPTZ)

**Errors:**

- P0001: User not found
- P0002: Account has been rejected
- P0003: Account has been suspended
- P0004: No OTP found
- P0005: OTP has expired
- P0006: Invalid OTP code

#### `complete_user_registration_step2(...)`

Completes user registration step 2 with profile information.

**Parameters:**

- `p_user_id` UUID
- `p_full_name` VARCHAR (optional)
- `p_profile_picture_url` TEXT (optional)
- `p_language_preference` language_preference (optional, default: 'en')
- `p_birthday` DATE (optional)
- `p_city` VARCHAR (optional)
- `p_gender` gender_type (optional)
- `p_device_model` VARCHAR (optional)
- `p_social_media_links` JSONB (optional, default: '{}')
- `p_profession` VARCHAR (optional)
- `p_bio` TEXT (optional)
- `p_description` TEXT (optional)

**Returns:** TABLE(user_id UUID, full_name VARCHAR, status user_status, updated_at TIMESTAMPTZ)

#### `register_user_step1(p_phone_number VARCHAR, p_password TEXT, p_auth_user_id UUID)`

Legacy function for password-based registration (may be deprecated).

**Returns:** TABLE(user_id UUID, phone_number VARCHAR, status user_status, created_at TIMESTAMPTZ)

### Points Management

#### `get_user_total_points_earned(user_uuid UUID)`

Gets the total points earned by a user.

**Returns:** INTEGER

#### `handle_points_transaction()`

Trigger function that updates user's points balance when a transaction is created.

### User Relationships

#### `is_following(follower_uuid UUID, following_uuid UUID)`

Checks if one user is following another.

**Returns:** BOOLEAN

#### `is_blocked(checker_uuid UUID, checked_uuid UUID)`

Checks if two users have blocked each other (bidirectional check).

**Returns:** BOOLEAN

### Content Management

#### `update_content_likes_count()`

Trigger function that updates the likes_count on content when likes are added/removed.

#### `update_content_comments_count()`

Trigger function that updates the comments_count on content when comments are added/removed.

### User Management

#### `create_user_approval_request()`

Trigger function that creates an approval request when a new user is created.

#### `initialize_user_kpis()`

Trigger function that initializes user KPIs when a new user is created.

#### `update_user_followers_count()`

Trigger function that updates follower/following counts when follows are added/removed.

#### `update_user_posts_count()`

Trigger function that updates posts count when feed posts are created/deleted.

#### `update_updated_at_column()`

Generic trigger function that updates the updated_at column.

---

## Triggers

| Trigger Name                            | Table               | Event                  | Function                          |
| --------------------------------------- | ------------------- | ---------------------- | --------------------------------- |
| `create_user_approval_request_trigger`  | users               | AFTER INSERT           | `create_user_approval_request()`  |
| `initialize_user_kpis_trigger`          | users               | AFTER INSERT           | `initialize_user_kpis()`          |
| `handle_points_transaction_trigger`     | points_transactions | BEFORE INSERT          | `handle_points_transaction()`     |
| `update_content_likes_count_trigger`    | content_likes       | AFTER INSERT OR DELETE | `update_content_likes_count()`    |
| `update_content_comments_count_trigger` | content_comments    | AFTER INSERT OR DELETE | `update_content_comments_count()` |
| `update_followers_count`                | user_follows        | AFTER INSERT OR DELETE | `update_user_followers_count()`   |
| `update_posts_count`                    | content             | AFTER INSERT OR DELETE | `update_user_posts_count()`       |
| `update_academy_content_updated_at`     | academy_content     | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_content_comments_updated_at`    | content_comments    | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_content_updated_at`             | content             | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_events_updated_at`              | events              | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_store_products_updated_at`      | store_products      | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_users_updated_at`               | users               | BEFORE UPDATE          | `update_updated_at_column()`      |
| `update_weekly_riddles_updated_at`      | weekly_riddles      | BEFORE UPDATE          | `update_updated_at_column()`      |

---

## Relationships

### Foreign Key Relationships

```
users
├── id → auth.users(id) [CASCADE]
├── approved_by → users(id)
└── auth_user_id → auth.users(id)

user_approval_requests
├── user_id → users(id) [CASCADE]
└── reviewed_by → users(id) [SET NULL]

user_follows
├── follower_id → users(id) [CASCADE]
└── following_id → users(id) [CASCADE]

user_blocks
├── blocker_id → users(id) [CASCADE]
└── blocked_id → users(id) [CASCADE]

user_kpis
└── user_id → users(id) [CASCADE]

content
└── user_id → users(id) [CASCADE]

content_likes
├── content_id → content(id) [CASCADE]
└── user_id → users(id) [CASCADE]

content_comments
├── content_id → content(id) [CASCADE]
└── user_id → users(id) [CASCADE]

points_transactions
└── user_id → users(id) [CASCADE]

events
└── created_by → users(id) [SET NULL]

event_registrations
├── event_id → events(id) [CASCADE]
└── user_id → users(id) [CASCADE]

academy_content
├── created_by → users(id) [SET NULL]
└── event_id → events(id) [SET NULL]

academy_content_views
├── content_id → academy_content(id) [CASCADE]
└── user_id → users(id) [CASCADE]

weekly_riddles
└── created_by → users(id) [SET NULL]

riddle_submissions
├── riddle_id → weekly_riddles(id) [CASCADE]
└── user_id → users(id) [CASCADE]

store_products
└── created_by → users(id) [SET NULL]

store_orders
├── user_id → users(id) [CASCADE]
└── product_id → store_products(id) [RESTRICT]

notifications
└── user_id → users(id) [CASCADE]
```

---

## Row Level Security (RLS) Policies

### `users` table

- **Admins can view all users**: Admins can SELECT all users
- **Users can view own profile**: Users can SELECT their own profile
- **Users can view approved profiles**: Users can SELECT approved profiles
- **Users can update own profile**: Users can UPDATE their own profile

### `content` table

- **Admins can manage all content**: Admins can manage all content
- **Users can create own content**: Users can INSERT their own content
- **Users can update own content**: Users can UPDATE their own content
- **Users can view published content**: Users can SELECT published content

### `content_likes` table

- **Users can create own content likes**: Users can INSERT their own likes
- **Users can delete own content likes**: Users can DELETE their own likes
- **Users can view content likes**: Users can SELECT likes on published content

### `content_comments` table

- **Users can create own content comments**: Users can INSERT their own comments
- **Users can update own content comments**: Users can UPDATE their own comments
- **Users can view content comments**: Users can SELECT comments on published content

### `events` table

- **Admins can manage all events**: Admins can manage all events
- **Users can view published events**: Users can SELECT published events

### `notifications` table

- **Users can view own notifications**: Users can SELECT their own notifications

### `points_transactions` table

- **Users can view own points transactions**: Users can SELECT their own transactions

### `store_orders` table

- **Users can view own store orders**: Users can SELECT their own orders

---

## Notes

1. **OTP Authentication**: The system uses OTP-based authentication. Users receive OTP codes via phone number, which expire after 10 minutes.

2. **User Approval Flow**: New users are created with `pending` status. An approval request is automatically created via trigger.

3. **Points System**: Points are tracked through `points_transactions` table. The `users.points_balance` is updated automatically via trigger.

4. **Soft Deletes**: Content and comments use soft deletes via `deleted_at` timestamp.

5. **Denormalized Counts**: Counts like `likes_count`, `comments_count`, `followers_count` are denormalized for performance and updated via triggers.

6. **Content Types**: The system supports three content types: VOD (Video on Demand), Podcast, and Feed posts.

7. **Event Types**: Events can be Zoom workshops, live events, or reels.

8. **Riddle System**: Weekly riddles support text, voice, and video solutions with Gemini AI integration.

---

## Schema Generation

This schema documentation was generated from the latest database schema using:

```bash
supabase db dump --schema public --data-only=false
```

To regenerate this documentation, run:

```bash
supabase db dump --schema public --data-only=false > /tmp/schema_dump.sql
```

Then parse the dump and update this file accordingly.
