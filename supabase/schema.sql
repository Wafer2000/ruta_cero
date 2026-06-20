-- ============================================
-- RUTA CERO - Schema para Supabase
-- Ejecutar en SQL Editor de Supabase
-- ============================================

-- 1. Habilitar UUID
create extension if not exists "uuid-ossp";

-- 2. Perfiles de usuario
create table public.user_profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null unique,
  name text not null default '',
  currency text not null default 'COP',
  locale text not null default 'es_CO',
  timezone text not null default 'America/Bogota',
  monthly_income integer not null default 0,
  default_reserve integer not null default 500000,
  salary_day integer not null default 30,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. Ingresos
create table public.incomes (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  amount integer not null,
  type text not null default 'extra',
  month text not null,
  recurring boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 4. Gastos
create table public.expenses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  amount integer not null,
  category text not null default 'other',
  frequency text not null default 'monthly',
  due_day integer,
  active boolean not null default true,
  start_month text,
  end_month text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 5. Deudas
create table public.debts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  type text not null default 'other',
  current_balance integer not null,
  minimum_payment integer not null default 0,
  target_payment integer not null default 0,
  priority text not null default 'medium',
  due_day integer,
  interest_rate_bps integer,
  status text not null default 'active',
  credit_limit integer,
  available_credit integer,
  cutoff_day integer,
  payment_due_day integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 6. Eventos especiales
create table public.special_events (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  amount integer not null,
  month text not null,
  category text not null default 'other',
  flexible boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 7. Pagos reales
create table public.payments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  debt_id uuid references public.debts(id) on delete set null,
  amount integer not null,
  planned_amount integer not null default 0,
  planned_date date,
  paid_date date,
  status text not null default 'pending',
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 8. Historial de cambios
create table public.audit_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  entity text not null,
  entity_id text not null,
  action text not null,
  before_json jsonb,
  after_json jsonb,
  impact_json jsonb,
  created_at timestamptz not null default now()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Cada usuario solo ve sus propios datos
-- ============================================

alter table public.user_profiles enable row level security;
alter table public.incomes enable row level security;
alter table public.expenses enable row level security;
alter table public.debts enable row level security;
alter table public.special_events enable row level security;
alter table public.payments enable row level security;
alter table public.audit_logs enable row level security;

-- Políticas: user_profiles
create policy "Users can view own profile"
  on public.user_profiles for select using (auth.uid() = user_id);
create policy "Users can insert own profile"
  on public.user_profiles for insert with check (auth.uid() = user_id);
create policy "Users can update own profile"
  on public.user_profiles for update using (auth.uid() = user_id);

-- Políticas: incomes
create policy "Users can view own incomes"
  on public.incomes for select using (auth.uid() = user_id);
create policy "Users can insert own incomes"
  on public.incomes for insert with check (auth.uid() = user_id);
create policy "Users can update own incomes"
  on public.incomes for update using (auth.uid() = user_id);
create policy "Users can delete own incomes"
  on public.incomes for delete using (auth.uid() = user_id);

-- Políticas: expenses
create policy "Users can view own expenses"
  on public.expenses for select using (auth.uid() = user_id);
create policy "Users can insert own expenses"
  on public.expenses for insert with check (auth.uid() = user_id);
create policy "Users can update own expenses"
  on public.expenses for update using (auth.uid() = user_id);
create policy "Users can delete own expenses"
  on public.expenses for delete using (auth.uid() = user_id);

-- Políticas: debts
create policy "Users can view own debts"
  on public.debts for select using (auth.uid() = user_id);
create policy "Users can insert own debts"
  on public.debts for insert with check (auth.uid() = user_id);
create policy "Users can update own debts"
  on public.debts for update using (auth.uid() = user_id);
create policy "Users can delete own debts"
  on public.debts for delete using (auth.uid() = user_id);

-- Políticas: special_events
create policy "Users can view own events"
  on public.special_events for select using (auth.uid() = user_id);
create policy "Users can insert own events"
  on public.special_events for insert with check (auth.uid() = user_id);
create policy "Users can update own events"
  on public.special_events for update using (auth.uid() = user_id);
create policy "Users can delete own events"
  on public.special_events for delete using (auth.uid() = user_id);

-- Políticas: payments
create policy "Users can view own payments"
  on public.payments for select using (auth.uid() = user_id);
create policy "Users can insert own payments"
  on public.payments for insert with check (auth.uid() = user_id);
create policy "Users can update own payments"
  on public.payments for update using (auth.uid() = user_id);
create policy "Users can delete own payments"
  on public.payments for delete using (auth.uid() = user_id);

-- Políticas: audit_logs
create policy "Users can view own logs"
  on public.audit_logs for select using (auth.uid() = user_id);
create policy "Users can insert own logs"
  on public.audit_logs for insert with check (auth.uid() = user_id);

-- ============================================
-- FUNCIÓN: auto-actualizar updated_at
-- ============================================

create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_updated_at before update on public.user_profiles
  for each row execute function public.handle_updated_at();
create trigger set_updated_at before update on public.incomes
  for each row execute function public.handle_updated_at();
create trigger set_updated_at before update on public.expenses
  for each row execute function public.handle_updated_at();
create trigger set_updated_at before update on public.debts
  for each row execute function public.handle_updated_at();
create trigger set_updated_at before update on public.special_events
  for each row execute function public.handle_updated_at();
create trigger set_updated_at before update on public.payments
  for each row execute function public.handle_updated_at();

-- ============================================
-- FUNCIÓN: crear perfil automático al registrarse
-- ============================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_profiles (user_id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
