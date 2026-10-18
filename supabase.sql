-- Aslbek AI uchun Supabase jadvallari (Mukammal versiya)
-- Buni Supabase dashboard -> SQL Editor -> New query ga joylab, Run bosing

-- 1. Foydalanuvchilar profili jadvali
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  lang text default 'uz',
  created_at timestamp with time zone default now()
);

-- Row Level Security (RLS) yoqish
alter table public.profiles enable row level security;

-- RLS Siyosatlari (Policies)
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- 2. Chat xabarlari jadvali
create table if not exists public.messages (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users on delete cascade not null,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  created_at timestamp with time zone default now()
);

-- Row Level Security (RLS) yoqish
alter table public.messages enable row level security;

-- RLS Siyosatlari (Policies)
create policy "messages_select_own" on public.messages for select using (auth.uid() = user_id);
create policy "messages_insert_own" on public.messages for insert with check (auth.uid() = user_id);
create policy "messages_delete_own" on public.messages for delete using (auth.uid() = user_id);

-- Avtomatik profil yaratish funksiyasi (Yangi foydalanuvchi ro'yxatdan o'tganda)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, lang)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', 'Foydalanuvchi'), 'uz');
  return new;
end;
$$ language plpgsql security definer;

-- Triggerni ulash
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
