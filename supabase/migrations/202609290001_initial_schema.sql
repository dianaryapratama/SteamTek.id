-- SteamTek.id baseline schema. Jalankan melalui Supabase CLI (`supabase db push`).
create extension if not exists pgcrypto;

create type public.user_role as enum ('ADMIN', 'MEMBER');
create type public.product_type as enum ('FREE', 'PREMIUM');
create type public.publish_status as enum ('DRAFT', 'PUBLISHED', 'ARCHIVED');
create type public.submission_status as enum ('DRAFT', 'PENDING_REVIEW', 'REVISION_REQUIRED', 'APPROVED', 'REJECTED');
create type public.review_decision as enum ('APPROVED', 'REVISION_REQUIRED', 'REJECTED');
create type public.order_status as enum ('PENDING', 'PAID', 'FAILED', 'EXPIRED', 'CANCELLED', 'REFUNDED');
create type public.payment_status as enum ('PENDING', 'PAID', 'FAILED', 'EXPIRED', 'REFUNDED');
create type public.entitlement_status as enum ('ACTIVE', 'REVOKED', 'REFUNDED');
create type public.link_status as enum ('ACTIVE', 'BROKEN', 'UNDER_REVIEW', 'DISABLED');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  avatar_url text,
  role public.user_role not null default 'MEMBER',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index profiles_email_lower_idx on public.profiles(lower(email));

create table public.games (
  id uuid primary key default gen_random_uuid(), name text not null,
  slug text not null unique, description text, image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.game_versions (
  id uuid primary key default gen_random_uuid(), game_id uuid not null references public.games(id) on delete cascade,
  version text not null, is_active boolean not null default true, created_at timestamptz not null default now(),
  unique(game_id, version)
);
create table public.categories (
  id uuid primary key default gen_random_uuid(), game_id uuid references public.games(id) on delete cascade,
  name text not null, slug text not null, description text, is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(game_id, slug)
);
create table public.products (
  id uuid primary key default gen_random_uuid(), game_id uuid not null references public.games(id),
  category_id uuid references public.categories(id), created_by uuid not null references public.profiles(id),
  source_submission_id uuid, name text not null, slug text not null unique,
  description text not null, tutorial text, creator_name text not null, source_url text,
  screenshot_urls text[] not null default '{}', type public.product_type not null,
  price numeric(14,2) not null default 0, currency char(3) not null default 'IDR',
  status public.publish_status not null default 'DRAFT', published_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint products_price_by_type check ((type = 'FREE' and price = 0) or (type = 'PREMIUM' and price > 0)),
  constraint products_currency_upper check (currency = upper(currency))
);
create index products_catalog_idx on public.products(status, type, game_id, category_id);
create table public.product_versions (
  id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
  version text not null, changelog text, released_at timestamptz not null default now(), is_current boolean not null default false,
  unique(product_id, version)
);
create unique index product_versions_current_idx on public.product_versions(product_id) where is_current;
create table public.compatibilities (
  id uuid primary key default gen_random_uuid(), product_version_id uuid not null references public.product_versions(id) on delete cascade,
  game_version_id uuid not null references public.game_versions(id) on delete cascade,
  status text not null default 'COMPATIBLE' check (status in ('COMPATIBLE','PARTIAL','INCOMPATIBLE')),
  notes text, unique(product_version_id, game_version_id)
);
create table public.download_links (
  id uuid primary key default gen_random_uuid(), product_version_id uuid not null references public.product_versions(id) on delete cascade,
  provider text not null, external_url text not null check (external_url ~* '^https?://'),
  is_mirror boolean not null default false, status public.link_status not null default 'UNDER_REVIEW',
  last_checked_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.submissions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id),
  product_id uuid references public.products(id), game_id uuid not null references public.games(id),
  category_id uuid references public.categories(id), name text not null, mod_version text not null,
  compatibility_notes text not null, description text not null, tutorial text, creator_name text not null,
  download_url text not null check (download_url ~* '^https?://'), screenshot_urls text[] not null default '{}',
  source_url text not null check (source_url ~* '^https?://'), distribution_permission boolean not null,
  status public.submission_status not null default 'DRAFT', revision_number integer not null default 1,
  submitted_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint submission_requires_permission check (status = 'DRAFT' or distribution_permission)
);
create index submissions_owner_status_idx on public.submissions(user_id, status);
create table public.submission_reviews (
  id uuid primary key default gen_random_uuid(), submission_id uuid not null references public.submissions(id) on delete cascade,
  reviewer_id uuid not null references public.profiles(id), decision public.review_decision not null,
  notes text not null, snapshot jsonb not null, created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id),
  order_number text not null unique, subtotal numeric(14,2) not null check (subtotal >= 0),
  total numeric(14,2) not null check (total >= 0), currency char(3) not null default 'IDR',
  status public.order_status not null default 'PENDING', paid_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index orders_user_created_idx on public.orders(user_id, created_at desc);
create table public.order_items (
  id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id), title_snapshot text not null,
  unit_price numeric(14,2) not null check (unit_price > 0), quantity integer not null default 1 check (quantity = 1),
  unique(order_id, product_id)
);
create table public.payments (
  id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id),
  provider text not null, provider_reference text, amount numeric(14,2) not null check (amount > 0),
  currency char(3) not null default 'IDR', status public.payment_status not null default 'PENDING',
  idempotency_key text not null unique, provider_payload jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(provider, provider_reference)
);
create table public.entitlements (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id),
  product_id uuid not null references public.products(id), order_item_id uuid not null references public.order_items(id),
  status public.entitlement_status not null default 'ACTIVE', granted_at timestamptz not null default now(), revoked_at timestamptz,
  unique(user_id, order_item_id)
);
create index entitlements_access_idx on public.entitlements(user_id, product_id, status);
create table public.download_events (
  id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id),
  product_id uuid not null references public.products(id), download_link_id uuid references public.download_links(id),
  ip_hash text, user_agent text, downloaded_at timestamptz not null default now()
);
create table public.reviews (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id),
  product_id uuid not null references public.products(id), rating smallint not null check (rating between 1 and 5),
  content text not null, is_visible boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(user_id, product_id)
);
create table public.wishlists (
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(user_id, product_id)
);
create table public.reports (
  id uuid primary key default gen_random_uuid(), reporter_id uuid references public.profiles(id),
  product_id uuid not null references public.products(id), type text not null check (type in ('BROKEN_LINK','MALWARE','COPYRIGHT','INAPPROPRIATE','OTHER')),
  details text not null, status text not null default 'OPEN' check (status in ('OPEN','INVESTIGATING','RESOLVED','REJECTED')),
  resolved_by uuid references public.profiles(id), created_at timestamptz not null default now(), resolved_at timestamptz
);
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id),
  action text not null, entity_type text not null, entity_id uuid, metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index audit_logs_entity_idx on public.audit_logs(entity_type, entity_id, created_at desc);

alter table public.products add constraint products_source_submission_fk foreign key(source_submission_id) references public.submissions(id);

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'ADMIN');
$$;
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id, email, display_name, role)
  values(new.id, new.email, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)), 'MEMBER');
  return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create or replace function public.protect_profile_role() returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.role is distinct from old.role and not public.is_admin() then raise exception 'Role hanya dapat diubah admin'; end if;
  new.updated_at = now(); return new;
end; $$;
create trigger profiles_protect_role before update on public.profiles for each row execute function public.protect_profile_role();

-- Checkout menghitung ulang seluruh harga dari database.
create or replace function public.create_order(product_ids uuid[]) returns uuid language plpgsql security definer set search_path = '' as $$
declare new_order_id uuid; computed_total numeric(14,2); order_no text;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if cardinality(product_ids) is null or cardinality(product_ids) = 0 then raise exception 'EMPTY_CART'; end if;
  if exists(select 1 from unnest(product_ids) x group by x having count(*) > 1) then raise exception 'DUPLICATE_PRODUCT'; end if;
  select sum(price) into computed_total from public.products where id = any(product_ids) and type = 'PREMIUM' and status = 'PUBLISHED';
  if (select count(*) from public.products where id = any(product_ids) and type = 'PREMIUM' and status = 'PUBLISHED') <> cardinality(product_ids) then raise exception 'INVALID_PRODUCT'; end if;
  order_no := 'ST-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
  insert into public.orders(user_id, order_number, subtotal, total) values(auth.uid(), order_no, computed_total, computed_total) returning id into new_order_id;
  insert into public.order_items(order_id, product_id, title_snapshot, unit_price)
    select new_order_id, id, name, price from public.products where id = any(product_ids);
  return new_order_id;
end; $$;
revoke all on function public.create_order(uuid[]) from public;
grant execute on function public.create_order(uuid[]) to authenticated;

-- Webhook memanggil fungsi ini melalui service-role setelah signature/nominal diverifikasi.
create or replace function public.finalize_paid_order(target_order uuid, target_payment uuid, provider_data jsonb default '{}') returns void
language plpgsql security definer set search_path = '' as $$
declare order_row public.orders%rowtype; payment_row public.payments%rowtype;
begin
  select * into order_row from public.orders where id = target_order for update;
  select * into payment_row from public.payments where id = target_payment and order_id = target_order for update;
  if order_row.id is null or payment_row.id is null then raise exception 'NOT_FOUND'; end if;
  if payment_row.amount <> order_row.total or payment_row.currency <> order_row.currency then raise exception 'AMOUNT_MISMATCH'; end if;
  if order_row.status = 'PAID' then return; end if;
  update public.payments set status = 'PAID', provider_payload = provider_data, updated_at = now() where id = target_payment;
  update public.orders set status = 'PAID', paid_at = now(), updated_at = now() where id = target_order;
  insert into public.entitlements(user_id, product_id, order_item_id)
    select order_row.user_id, oi.product_id, oi.id from public.order_items oi where oi.order_id = target_order
    on conflict(user_id, order_item_id) do nothing;
  insert into public.audit_logs(actor_id, action, entity_type, entity_id, metadata)
    values(null, 'PAYMENT_CONFIRMED', 'order', target_order, jsonb_build_object('payment_id', target_payment));
end; $$;
revoke all on function public.finalize_paid_order(uuid, uuid, jsonb) from public, anon, authenticated;
grant execute on function public.finalize_paid_order(uuid, uuid, jsonb) to service_role;

-- Privileges and RLS. Tidak ada SELECT publik langsung pada download_links/payments/audit_logs.
grant usage on schema public to anon, authenticated;
grant select on public.games, public.game_versions, public.categories, public.products, public.product_versions, public.compatibilities, public.reviews to anon, authenticated;
grant select, update on public.profiles to authenticated;
grant select, insert, update on public.submissions to authenticated;
grant select on public.submission_reviews, public.orders, public.order_items, public.payments, public.entitlements, public.download_events to authenticated;
grant insert, update, delete on public.wishlists to authenticated;
grant select on public.wishlists to authenticated;
grant insert on public.reviews, public.reports to anon, authenticated;
grant select on public.reports to authenticated;

do $$ declare t text; begin
  foreach t in array array['profiles','games','game_versions','categories','products','product_versions','compatibilities','download_links','submissions','submission_reviews','orders','order_items','payments','entitlements','download_events','reviews','wishlists','reports','audit_logs'] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

create policy profiles_self_read on public.profiles for select to authenticated using(id = auth.uid() or public.is_admin());
create policy profiles_self_update on public.profiles for update to authenticated using(id = auth.uid() or public.is_admin()) with check(id = auth.uid() or public.is_admin());
create policy public_active_games on public.games for select using(is_active or public.is_admin());
create policy public_active_versions on public.game_versions for select using(is_active or public.is_admin());
create policy public_active_categories on public.categories for select using(is_active or public.is_admin());
create policy public_published_products on public.products for select using(status = 'PUBLISHED' or public.is_admin());
create policy public_product_versions on public.product_versions for select using(exists(select 1 from public.products p where p.id = product_id and (p.status = 'PUBLISHED' or public.is_admin())));
create policy public_compatibilities on public.compatibilities for select using(exists(select 1 from public.product_versions pv join public.products p on p.id = pv.product_id where pv.id = product_version_id and (p.status = 'PUBLISHED' or public.is_admin())));
create policy admin_download_links on public.download_links for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy submission_owner_read on public.submissions for select to authenticated using(user_id = auth.uid() or public.is_admin());
create policy submission_owner_insert on public.submissions for insert to authenticated with check(user_id = auth.uid() and status in ('DRAFT','PENDING_REVIEW'));
create policy submission_owner_update on public.submissions for update to authenticated using((user_id = auth.uid() and status in ('DRAFT','REVISION_REQUIRED')) or public.is_admin()) with check((user_id = auth.uid() and status in ('DRAFT','PENDING_REVIEW')) or public.is_admin());
create policy submission_reviews_visible on public.submission_reviews for select to authenticated using(public.is_admin() or exists(select 1 from public.submissions s where s.id = submission_id and s.user_id = auth.uid()));
create policy order_owner_read on public.orders for select to authenticated using(user_id = auth.uid() or public.is_admin());
create policy order_items_owner_read on public.order_items for select to authenticated using(public.is_admin() or exists(select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
create policy payments_owner_read on public.payments for select to authenticated using(public.is_admin() or exists(select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
create policy entitlement_owner_read on public.entitlements for select to authenticated using(user_id = auth.uid() or public.is_admin());
create policy download_events_owner_read on public.download_events for select to authenticated using(user_id = auth.uid() or public.is_admin());
create policy public_visible_reviews on public.reviews for select using(is_visible or user_id = auth.uid() or public.is_admin());
create policy review_owner_insert on public.reviews for insert to authenticated with check(user_id = auth.uid());
create policy wishlist_owner_all on public.wishlists for all to authenticated using(user_id = auth.uid()) with check(user_id = auth.uid());
create policy reports_create on public.reports for insert with check(reporter_id is null or reporter_id = auth.uid());
create policy reports_owner_read on public.reports for select to authenticated using(reporter_id = auth.uid() or public.is_admin());
create policy admin_audit_read on public.audit_logs for select to authenticated using(public.is_admin());

-- Admin CRUD melalui authenticated client tetap dipagari role.
create policy admin_games_all on public.games for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_game_versions_all on public.game_versions for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_categories_all on public.categories for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_products_all on public.products for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_product_versions_all on public.product_versions for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_compatibilities_all on public.compatibilities for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy admin_submission_reviews_insert on public.submission_reviews for insert to authenticated with check(public.is_admin() and reviewer_id = auth.uid());
create policy admin_reports_update on public.reports for update to authenticated using(public.is_admin()) with check(public.is_admin());
