-- Campus Connect Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key,
  name text not null,
  role text not null check (role in ('student','teacher','admin')),
  email text not null unique,
  department text default '',
  class_name text default '',
  roll_no text default '',
  section text default '',
  subject text default '',
  created_at timestamptz default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  class_name text default '',
  roll_no text default '',
  section text default '',
  department text default '',
  email text default '',
  created_at timestamptz default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  category text not null default 'general',
  sender_id text not null,
  sender_name text not null,
  sender_role text not null,
  target_class text default 'all',
  target_department text default 'all',
  priority text not null default 'Normal',
  timestamp timestamptz default now()
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  sender_id text not null,
  sender_name text not null,
  priority text not null default 'Normal',
  date timestamptz default now(),
  target_class text default 'all',
  target_department text default 'all'
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  due_date timestamptz,
  assigned_by text not null,
  priority text not null default 'Normal',
  completed boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  uploaded_by text not null,
  uploaded_at timestamptz default now(),
  file_type text default 'link'
);

create table if not exists public.announcement_reads (
  announcement_id uuid not null,
  student_id uuid not null,
  read_at timestamptz default now(),
  primary key (announcement_id, student_id)
);

alter table public.users enable row level security;
alter table public.students enable row level security;
alter table public.messages enable row level security;
alter table public.announcements enable row level security;
alter table public.tasks enable row level security;
alter table public.files enable row level security;
alter table public.announcement_reads enable row level security;

-- MVP policies: authenticated users can read/write; tighten for production.
create policy if not exists users_rw on public.users for all to authenticated using (true) with check (true);
create policy if not exists students_rw on public.students for all to authenticated using (true) with check (true);
create policy if not exists messages_rw on public.messages for all to authenticated using (true) with check (true);
create policy if not exists announcements_rw on public.announcements for all to authenticated using (true) with check (true);
create policy if not exists tasks_rw on public.tasks for all to authenticated using (true) with check (true);
create policy if not exists files_rw on public.files for all to authenticated using (true) with check (true);
create policy if not exists announcement_reads_rw on public.announcement_reads for all to authenticated using (true) with check (true);
