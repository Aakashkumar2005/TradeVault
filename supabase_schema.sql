-- TRADEVAULT PRODUCTION SUPABASE SCHEMA
-- Run this entire file in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  firm text default 'FundingPips',
  model text default '2-Step Flex',
  account_size numeric default 5000,
  daily_limit numeric default 4,
  max_loss_limit numeric default 12,
  target_limit numeric default 8,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.setups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  tag text default 'Custom',
  description text default '',
  created_at timestamptz default now()
);

create table if not exists public.trades (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  trade_date timestamptz not null,
  pair text not null,
  direction text,
  session text,
  setup text,
  grade text,
  result text,
  pnl numeric default 0,
  r_multiple numeric default 0,
  entry text,
  sl text,
  tp text,
  lots text,
  risk text,
  reason text,
  notes text,
  lesson text,
  screenshot_url text,
  fomo boolean default false,
  revenge boolean default false,
  rule_violation boolean default false,
  discipline integer,
  created_at timestamptz default now()
);

create table if not exists public.psychology (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  checkin_date timestamptz not null,
  state text,
  score integer,
  notes text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.setups enable row level security;
alter table public.trades enable row level security;
alter table public.psychology enable row level security;

drop policy if exists "profiles own rows" on public.profiles;
create policy "profiles own rows" on public.profiles
for all using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "setups own rows" on public.setups;
create policy "setups own rows" on public.setups
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "trades own rows" on public.trades;
create policy "trades own rows" on public.trades
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "psychology own rows" on public.psychology;
create policy "psychology own rows" on public.psychology
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Storage bucket for Bookmap/trade screenshots.
insert into storage.buckets (id, name, public)
values ('trade-screenshots', 'trade-screenshots', true)
on conflict (id) do update set public = true;

drop policy if exists "trade screenshots read" on storage.objects;
create policy "trade screenshots read"
on storage.objects for select
using (bucket_id = 'trade-screenshots');

drop policy if exists "trade screenshots insert" on storage.objects;
create policy "trade screenshots insert"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'trade-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "trade screenshots update" on storage.objects;
create policy "trade screenshots update"
on storage.objects for update to authenticated
using (
  bucket_id = 'trade-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'trade-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "trade screenshots delete" on storage.objects;
create policy "trade screenshots delete"
on storage.objects for delete to authenticated
using (
  bucket_id = 'trade-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Optional trigger to keep profiles.updated_at current.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();
