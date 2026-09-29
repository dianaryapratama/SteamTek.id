# Audit implementasi SteamTek.id

Tanggal audit: 29 September 2026.

## Kondisi repository awal

Remote `origin` hanya berisi commit `c654fbc Create docs`, PDF rancangan teknis, dan file placeholder `docs`. Tidak ada aplikasi, README, package manager, konfigurasi, schema, ataupun test. Karena belum ada source code, tidak ada fitur existing yang dapat dipertahankan atau dimigrasikan dari Prisma/Auth.js.

PDF workspace dan PDF remote identik (SHA-256 `0430A01B7809AF0E38E90A3969B3DB60EECC75324CFF82C39CCFEFFCC9FBE108`). Seluruh FR-01–FR-45, NFR-01–NFR-15, ERD, API, dan business rules ditinjau sebagai baseline.

## Implementasi pada branch development/supabase-integration

- Next.js App Router, React, JavaScript, Tailwind CSS, dan Lucide.
- Supabase SSR Auth: register, login, logout, verifikasi callback, forgot/reset password, session proxy, protected route, dan RBAC.
- Schema PostgreSQL untuk 18 tabel domain, constraint, indeks, fungsi transaksi, seed, dan RLS.
- Katalog, pencarian sederhana, halaman produk, game, unduh FREE, dan gate entitlement PREMIUM.
- Kontribusi komunitas dan moderasi atomik yang menerbitkan produk gratis.
- Checkout dengan kalkulasi database, order, payment record, webhook HMAC, entitlement idempoten, library, dan riwayat order.
- Metadata SEO, sitemap, robots, dan security headers.

## Gap dan dependensi eksternal

- Gateway pembayaran Indonesia belum dipilih dan belum ada credential sandbox. Adapter `mock` tidak mengaktifkan entitlement; webhook generik tersedia sebagai batas keamanan awal.
- Pengiriman invoice/notifikasi transaksional memerlukan SMTP/layanan email dan template.
- CRUD admin lengkap seluruh master data, wishlist/review/report UI, mirror-link management, analitik lanjutan, rate limiting terdistribusi, health checker URL aman terhadap SSRF, E2E browser, dan uji beban belum lengkap.
- RLS perlu diuji terhadap instance Supabase nyata setelah migration diterapkan. Migration tidak dijalankan otomatis agar tidak menyentuh schema remote yang belum diaudit dan karena service-role/database credential tidak tersedia.
- Target performa, availability, backup, RPO/RTO, serta WCAG memerlukan validasi pada lingkungan deployment.
