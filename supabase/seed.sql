-- Seed aman dan idempoten. created_by produk memerlukan user admin nyata sehingga produk dibuat lewat dashboard.
insert into public.games(name, slug, description) values
('Euro Truck Simulator 2', 'euro-truck-simulator-2', 'Simulator truk lintas Eropa'),
('American Truck Simulator', 'american-truck-simulator', 'Simulator truk lintas Amerika')
on conflict(slug) do nothing;

insert into public.game_versions(game_id, version)
select id, '1.57' from public.games where slug in ('euro-truck-simulator-2','american-truck-simulator')
on conflict(game_id, version) do nothing;

insert into public.categories(game_id, name, slug, description)
select id, 'Kendaraan', 'kendaraan', 'Truk, mobil, dan kendaraan lainnya' from public.games
on conflict(game_id, slug) do nothing;
insert into public.categories(game_id, name, slug, description)
select id, 'Peta', 'peta', 'Ekspansi dan modifikasi peta' from public.games
on conflict(game_id, slug) do nothing;
