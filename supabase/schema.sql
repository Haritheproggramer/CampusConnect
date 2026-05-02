-- Campus Connect Supabase schema
-- Run this in Supabase SQL editor: Dashboard > SQL Editor > New Query
create extension if not exists pgcrypto;

-- ── users ────────────────────────────────────────────────────────────────────
create table if not exists public.users (
  id uuid primary key,
  name text not null,
  role text not null check (role in ('student','teacher','admin')),
  email text not null unique,
  department text default '',
  class_name text default '',
  roll_no text default '',
  section text default '',
  group_name text default '',
  subject text default '',
  is_cr boolean default false,
  created_at timestamptz default now()
);

-- Add is_cr if upgrading from older schema
alter table public.users add column if not exists is_cr boolean default false;
alter table public.users add column if not exists group_name text default '';

-- ── students ──────────────────────────────────────────────────────────────────
create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  class_name text default '',
  roll_no text default '',
  section text default '',
  group_name text default '',
  department text default '',
  email text default '',
  created_at timestamptz default now()
);

alter table public.students add column if not exists group_name text default '';

-- ── messages (broadcasts + DMs) ───────────────────────────────────────────────
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  body text not null,
  -- category: 'all' | 'department' | 'class' | 'direct'
  category text not null default 'all',
  sender_id text not null,
  sender_name text not null,
  sender_role text not null default 'student',
  target_class text default 'all',
  target_department text default 'all',
  priority text not null default 'Normal',
  -- DM fields (null = broadcast)
  receiver_id text,
  receiver_name text,
  timestamp timestamptz default now()
);

-- Add DM columns if upgrading from older schema
alter table public.messages add column if not exists receiver_id text;
alter table public.messages add column if not exists receiver_name text;

-- ── announcements ─────────────────────────────────────────────────────────────
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  sender_id text not null,
  sender_name text not null,
  priority text not null default 'Normal',
  date timestamptz default now(),
  -- Strict single category: 'all' | 'department' | 'class'
  category text default 'all',
  target_class text default 'all',
  target_department text default 'all'
);

-- Add category if upgrading from older schema
alter table public.announcements add column if not exists category text default 'all';

-- ── tasks ─────────────────────────────────────────────────────────────────────
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  due_date timestamptz default (now() + interval '7 days'),
  assigned_by text not null default '',
  priority text not null default 'Normal',
  completed boolean default false,
  created_at timestamptz default now()
);

-- ── files ─────────────────────────────────────────────────────────────────────
create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  uploaded_by text not null,
  uploaded_at timestamptz default now(),
  file_type text default 'link'
);

-- ── announcement_reads ────────────────────────────────────────────────────────
create table if not exists public.announcement_reads (
  announcement_id uuid not null,
  student_id uuid not null,
  read_at timestamptz default now(),
  primary key (announcement_id, student_id)
);

-- ── Row Level Security ───────────────────────────────────────────────────────
alter table public.users enable row level security;
alter table public.students enable row level security;
alter table public.messages enable row level security;
alter table public.announcements enable row level security;
alter table public.tasks enable row level security;
alter table public.files enable row level security;
alter table public.announcement_reads enable row level security;

-- Allow anon to read students (needed for contact list before full auth)
-- Authenticated users can full read/write (tighten for production)
do $$
begin
  if not exists (select 1 from pg_policies where policyname = 'users_rw' and tablename = 'users') then
    create policy users_rw on public.users for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'students_rw' and tablename = 'students') then
    create policy students_rw on public.students for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'messages_rw' and tablename = 'messages') then
    create policy messages_rw on public.messages for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'announcements_rw' and tablename = 'announcements') then
    create policy announcements_rw on public.announcements for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'tasks_rw' and tablename = 'tasks') then
    create policy tasks_rw on public.tasks for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'files_rw' and tablename = 'files') then
    create policy files_rw on public.files for all to authenticated using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where policyname = 'reads_rw' and tablename = 'announcement_reads') then
    create policy reads_rw on public.announcement_reads for all to authenticated using (true) with check (true);
  end if;
end;
$$;

-- ── Realtime ─────────────────────────────────────────────────────────────────
-- Enable realtime for live message streaming
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.announcements;
alter publication supabase_realtime add table public.tasks;
