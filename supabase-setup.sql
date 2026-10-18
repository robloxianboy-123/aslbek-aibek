-- Aslbek AI uchun Supabase jadvallari
-- Buni Supabase dashboard -> SQL Editor -> New query ga joylab, Run bosing

create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  lang text default 'uz',
  created_at timestamp with time zone default now()
);
alter table profiles enable row level security;

create policy "profiles_select_own" on profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on profiles for update using (auth.uid() = id);

create table if not exists messages (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null,
  role text not null,
  content text not null,
  created_at timestamp with time zone default now()
);
alter table messages enable row level security;

create policy "messages_select_own" on messages for select using (auth.uid() = user_id);
create policy "messages_insert_own" on messages for insert with check (auth.uid() = user_id);
create policy "messages_delete_own" on messages for delete using (auth.uid() = user_id);
