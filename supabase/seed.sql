-- SteamTek.id development seed. Aman dijalankan ulang.
-- Password login tidak disimpan di repository.

do $seed$
begin

-- Placeholder Auth menjaga foreign key seed tetap reproducible.
-- Password akun remote dibuat melalui proses administratif terpisah.
insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, is_sso_user, is_anonymous
) values
('00000000-0000-0000-0000-000000000000','10000000-0000-4000-8000-000000000001',
 'authenticated','authenticated','admin@steamtek.id',
 '{"provider":"email","providers":["email"]}',
 '{"display_name":"Admin SteamTek","avatar_url":"https://randomuser.me/api/portraits/men/32.jpg"}',
 now(),now(),false,false),
('00000000-0000-0000-0000-000000000000','10000000-0000-4000-8000-000000000002',
 'authenticated','authenticated','member@steamtek.id',
 '{"provider":"email","providers":["email"]}',
 '{"display_name":"Member SteamTek","avatar_url":"https://randomuser.me/api/portraits/women/44.jpg"}',
 now(),now(),false,false)
on conflict(id) do update set raw_user_meta_data=excluded.raw_user_meta_data,updated_at=now();

execute 'alter table public.profiles disable trigger profiles_protect_role';
insert into public.profiles(id,email,display_name,avatar_url,role) values
('10000000-0000-4000-8000-000000000001','admin@steamtek.id','Admin SteamTek','https://randomuser.me/api/portraits/men/32.jpg','ADMIN'),
('10000000-0000-4000-8000-000000000002','member@steamtek.id','Member SteamTek','https://randomuser.me/api/portraits/women/44.jpg','MEMBER')
on conflict(id) do update set email=excluded.email,display_name=excluded.display_name,
avatar_url=excluded.avatar_url,role=excluded.role,updated_at=now();
execute 'alter table public.profiles enable trigger profiles_protect_role';

insert into public.games(id,name,slug,description,image_url) values
('20000000-0000-4000-8000-000000000001','Euro Truck Simulator 2','euro-truck-simulator-2','Simulator truk lintas Eropa dengan komunitas mod aktif.','https://images.unsplash.com/photo-1519003722824-194d4455a60c?auto=format&fit=crop&w=1200&q=80'),
('20000000-0000-4000-8000-000000000002','American Truck Simulator','american-truck-simulator','Simulator perjalanan truk melintasi Amerika.','https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1200&q=80')
on conflict(slug) do update set description=excluded.description,image_url=excluded.image_url,is_active=true,updated_at=now();

insert into public.game_versions(id,game_id,version) values
('21000000-0000-4000-8000-000000000001',(select id from public.games where slug='euro-truck-simulator-2'),'1.56'),
('21000000-0000-4000-8000-000000000002',(select id from public.games where slug='euro-truck-simulator-2'),'1.57'),
('21000000-0000-4000-8000-000000000003',(select id from public.games where slug='euro-truck-simulator-2'),'1.58'),
('21000000-0000-4000-8000-000000000004',(select id from public.games where slug='american-truck-simulator'),'1.56'),
('21000000-0000-4000-8000-000000000005',(select id from public.games where slug='american-truck-simulator'),'1.57')
on conflict(game_id,version) do update set is_active=true;

insert into public.categories(id,game_id,name,slug,description) values
('22000000-0000-4000-8000-000000000001',(select id from public.games where slug='euro-truck-simulator-2'),'Kendaraan','kendaraan','Truk, bus, mobil, dan kendaraan lain.'),
('22000000-0000-4000-8000-000000000002',(select id from public.games where slug='euro-truck-simulator-2'),'Peta','peta','Ekspansi dan modifikasi peta.'),
('22000000-0000-4000-8000-000000000003',(select id from public.games where slug='euro-truck-simulator-2'),'Grafis','grafis','Cuaca, pencahayaan, tekstur, dan visual.'),
('22000000-0000-4000-8000-000000000004',(select id from public.games where slug='american-truck-simulator'),'Kendaraan','kendaraan','Truk dan kendaraan Amerika.'),
('22000000-0000-4000-8000-000000000005',(select id from public.games where slug='american-truck-simulator'),'Peta','peta','Ekspansi dan modifikasi peta.'),
('22000000-0000-4000-8000-000000000006',(select id from public.games where slug='american-truck-simulator'),'Audio','audio','Suara mesin, lingkungan, dan kabin.')
on conflict(game_id,slug) do update set name=excluded.name,description=excluded.description,is_active=true,updated_at=now();

insert into public.products(
 id,game_id,category_id,created_by,name,slug,description,tutorial,creator_name,
 source_url,screenshot_urls,type,price,status,published_at
) values
('30000000-0000-4000-8000-000000000001',(select id from public.games where slug='euro-truck-simulator-2'),
 (select id from public.categories where game_id=(select id from public.games where slug='euro-truck-simulator-2') and slug='kendaraan'),
 '10000000-0000-4000-8000-000000000001','Bus Nusantara Legacy','bus-nusantara-legacy',
 'Mod bus gratis dengan interior dan animasi kabin.','Pindahkan ke folder mod lalu aktifkan melalui Mod Manager.',
 'Komunitas SteamTek','https://steamtek.id',array['https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=1200&q=80'],'FREE',0,'PUBLISHED',now()),
('30000000-0000-4000-8000-000000000002',(select id from public.games where slug='euro-truck-simulator-2'),
 (select id from public.categories where game_id=(select id from public.games where slug='euro-truck-simulator-2') and slug='peta'),
 '10000000-0000-4000-8000-000000000001','Jalur Pegunungan Jawa','jalur-pegunungan-jawa',
 'Peta gratis dengan jalan pegunungan, desa, dan terminal.','Letakkan paket peta di atas map utama.',
 'Komunitas SteamTek','https://steamtek.id',array['https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=80'],'FREE',0,'PUBLISHED',now()),
('30000000-0000-4000-8000-000000000003',(select id from public.games where slug='american-truck-simulator'),
 (select id from public.categories where game_id=(select id from public.games where slug='american-truck-simulator') and slug='audio'),
 '10000000-0000-4000-8000-000000000001','Realistic Cabin Sound','realistic-cabin-sound',
 'Paket suara kabin, sein, rem angin, dan lingkungan.','Aktifkan di atas mod suara lain.',
 'SteamTek Audio Lab','https://steamtek.id',array['https://images.unsplash.com/photo-1597404294360-feeeda04612e?auto=format&fit=crop&w=1200&q=80'],'FREE',0,'PUBLISHED',now()),
('30000000-0000-4000-8000-000000000004',(select id from public.games where slug='euro-truck-simulator-2'),
 (select id from public.categories where game_id=(select id from public.games where slug='euro-truck-simulator-2') and slug='grafis'),
 '10000000-0000-4000-8000-000000000001','Cinematic Weather Pro','cinematic-weather-pro',
 'Cuaca sinematik, langit resolusi tinggi, kabut, dan pencahayaan malam.','Pasang sebagai prioritas tinggi.',
 'SteamTek Studio','https://steamtek.id',array['https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80'],'PREMIUM',79000,'PUBLISHED',now()),
('30000000-0000-4000-8000-000000000005',(select id from public.games where slug='euro-truck-simulator-2'),
 (select id from public.categories where game_id=(select id from public.games where slug='euro-truck-simulator-2') and slug='kendaraan'),
 '10000000-0000-4000-8000-000000000001','Luxury Coach XHD','luxury-coach-xhd',
 'Bus premium dengan dashboard interaktif, animasi, dan pilihan livery.','Aktifkan kendaraan dan livery melalui Mod Manager.',
 'SteamTek Vehicle Works','https://steamtek.id',array['https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=1200&q=80'],'PREMIUM',129000,'PUBLISHED',now()),
('30000000-0000-4000-8000-000000000006',(select id from public.games where slug='american-truck-simulator'),
 (select id from public.categories where game_id=(select id from public.games where slug='american-truck-simulator') and slug='peta'),
 '10000000-0000-4000-8000-000000000001','Desert Route Expansion','desert-route-expansion',
 'Ekspansi premium rute gurun dengan kota kecil dan rest area.','Urutkan file sesuai panduan dalam paket.',
 'SteamTek Map Division','https://steamtek.id',array['https://images.unsplash.com/photo-1509316785289-025f5b846b35?auto=format&fit=crop&w=1200&q=80'],'PREMIUM',99000,'PUBLISHED',now())
on conflict(slug) do update set description=excluded.description,tutorial=excluded.tutorial,
screenshot_urls=excluded.screenshot_urls,price=excluded.price,status='PUBLISHED',updated_at=now();

insert into public.product_versions(id,product_id,version,changelog,is_current) values
('31000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000001','1.2.0','Peningkatan animasi interior.',true),
('31000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000002','1.1.0','Penambahan terminal dan jalur.',true),
('31000000-0000-4000-8000-000000000003','30000000-0000-4000-8000-000000000003','2.0.0','Audio kabin diperbarui.',true),
('31000000-0000-4000-8000-000000000004','30000000-0000-4000-8000-000000000004','3.1.0','Preset cuaca baru.',true),
('31000000-0000-4000-8000-000000000005','30000000-0000-4000-8000-000000000005','1.5.0','Dashboard dan livery baru.',true),
('31000000-0000-4000-8000-000000000006','30000000-0000-4000-8000-000000000006','1.3.0','Kota dan rest area baru.',true)
on conflict(product_id,version) do update set changelog=excluded.changelog,is_current=true,released_at=now();

insert into public.compatibilities(id,product_version_id,game_version_id,status,notes) values
('32000000-0000-4000-8000-000000000001','31000000-0000-4000-8000-000000000001',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='euro-truck-simulator-2' and gv.version='1.57'),'COMPATIBLE','ETS2 1.57'),
('32000000-0000-4000-8000-000000000002','31000000-0000-4000-8000-000000000002',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='euro-truck-simulator-2' and gv.version='1.57'),'COMPATIBLE','ETS2 1.57'),
('32000000-0000-4000-8000-000000000003','31000000-0000-4000-8000-000000000003',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='american-truck-simulator' and gv.version='1.57'),'COMPATIBLE','ATS 1.57'),
('32000000-0000-4000-8000-000000000004','31000000-0000-4000-8000-000000000004',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='euro-truck-simulator-2' and gv.version='1.58'),'COMPATIBLE','ETS2 1.58'),
('32000000-0000-4000-8000-000000000005','31000000-0000-4000-8000-000000000005',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='euro-truck-simulator-2' and gv.version='1.58'),'COMPATIBLE','ETS2 1.58'),
('32000000-0000-4000-8000-000000000006','31000000-0000-4000-8000-000000000006',(select gv.id from public.game_versions gv join public.games g on g.id=gv.game_id where g.slug='american-truck-simulator' and gv.version='1.57'),'COMPATIBLE','ATS 1.57')
on conflict(product_version_id,game_version_id) do update set status=excluded.status,notes=excluded.notes;

insert into public.download_links(id,product_version_id,provider,external_url,status) values
('33000000-0000-4000-8000-000000000001','31000000-0000-4000-8000-000000000001','Demo External','https://example.com/steamtek/bus-nusantara','ACTIVE'),
('33000000-0000-4000-8000-000000000002','31000000-0000-4000-8000-000000000002','Demo External','https://example.com/steamtek/pegunungan-jawa','ACTIVE'),
('33000000-0000-4000-8000-000000000003','31000000-0000-4000-8000-000000000003','Demo External','https://example.com/steamtek/cabin-sound','ACTIVE'),
('33000000-0000-4000-8000-000000000004','31000000-0000-4000-8000-000000000004','Demo Premium','https://example.com/steamtek/weather-pro','ACTIVE'),
('33000000-0000-4000-8000-000000000005','31000000-0000-4000-8000-000000000005','Demo Premium','https://example.com/steamtek/coach-xhd','ACTIVE'),
('33000000-0000-4000-8000-000000000006','31000000-0000-4000-8000-000000000006','Demo Premium','https://example.com/steamtek/desert-route','ACTIVE')
on conflict(id) do update set external_url=excluded.external_url,status=excluded.status,updated_at=now();

insert into public.submissions(id,user_id,game_id,category_id,name,mod_version,compatibility_notes,
description,tutorial,creator_name,download_url,screenshot_urls,source_url,distribution_permission,status,submitted_at)
values('40000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000002',
(select id from public.games where slug='euro-truck-simulator-2'),
(select id from public.categories where game_id=(select id from public.games where slug='euro-truck-simulator-2') and slug='kendaraan'),
'Truck Livery Merah Putih','1.0.0','ETS2 1.57 dan 1.58','Livery komunitas bertema merah putih.',
'Salin ke folder mod.','Member SteamTek','https://example.com/steamtek/livery-merah-putih',
array['https://images.unsplash.com/photo-1559297434-fae8a1916a79?auto=format&fit=crop&w=1200&q=80'],
'https://steamtek.id',true,'PENDING_REVIEW',now())
on conflict(id) do update set status='PENDING_REVIEW',updated_at=now();

insert into public.orders(id,user_id,order_number,subtotal,total,status,paid_at)
values('50000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000002','ST-DEMO-2026-001',79000,79000,'PAID',now())
on conflict(order_number) do update set status='PAID',updated_at=now();
insert into public.order_items(id,order_id,product_id,title_snapshot,unit_price)
values('51000000-0000-4000-8000-000000000001','50000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000004','Cinematic Weather Pro',79000)
on conflict(order_id,product_id) do update set unit_price=excluded.unit_price;
insert into public.payments(id,order_id,provider,provider_reference,amount,status,idempotency_key)
values('52000000-0000-4000-8000-000000000001','50000000-0000-4000-8000-000000000001','seed','SEED-PAYMENT-001',79000,'PAID','seed-payment-001')
on conflict(idempotency_key) do update set status='PAID',updated_at=now();
insert into public.entitlements(id,user_id,product_id,order_item_id,status)
values('53000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000004','51000000-0000-4000-8000-000000000001','ACTIVE')
on conflict(user_id,order_item_id) do update set status='ACTIVE',revoked_at=null;

insert into public.reviews(id,user_id,product_id,rating,content) values
('60000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000004',5,'Pencahayaan malam bagus dan performa stabil.'),
('60000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000001',4,'Interior rapi dan mudah dipasang.')
on conflict(user_id,product_id) do update set rating=excluded.rating,content=excluded.content,updated_at=now();
insert into public.wishlists(user_id,product_id) values
('10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000005'),
('10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000006')
on conflict do nothing;

end
$seed$;
