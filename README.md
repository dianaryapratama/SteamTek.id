# SteamTek.id

Marketplace digital single-vendor dan repositori mod game PC berbasis komunitas. Produk premium hanya dikelola admin; member dapat mengirim mod gratis untuk dimoderasi; pengunjung dapat mengunduh produk gratis tanpa login.

## Stack

- Next.js App Router + React (JavaScript)
- Tailwind CSS + komponen UI lokal + Lucide Icons
- Supabase PostgreSQL, Auth, SSR, dan Row Level Security
- Vercel
- File mod melalui URL hosting eksternal (tanpa Supabase Storage)

## Menjalankan lokal

1. Gunakan Node.js 20.9 atau lebih baru.
2. Jalankan `npm install`.
3. Salin `.env.example` menjadi `.env.local` dan isi variabelnya. Jangan commit file env.
4. Hubungkan Supabase CLI lalu jalankan `supabase db push` dan `supabase db seed`.
5. Jalankan `npm run dev`.

Supabase SDK baru dapat memakai `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. `NEXT_PUBLIC_SUPABASE_ANON_KEY` hanya fallback kompatibilitas. `SUPABASE_SERVICE_ROLE_KEY` wajib server-only dan digunakan terbatas pada endpoint download/payment yang sudah melakukan pemeriksaan akses.

## Konfigurasi Supabase Auth

Tambahkan Site URL dan redirect URL `http://localhost:3000/auth/callback` (lokal) serta `https://DOMAIN-ANDA/auth/callback` (produksi) di dashboard Supabase.

Registrasi publik selalu membuat role `MEMBER` melalui trigger. Admin pertama dibuat secara administratif menggunakan SQL Editor/dashboard dengan akun operator tepercaya, bukan endpoint publik:

```sql
update public.profiles set role = 'ADMIN' where email = 'admin@example.com';
```

## Pembayaran

Default `PAYMENT_PROVIDER=mock` hanya mencatat pembayaran dan tidak memberikan entitlement. Pilih gateway Indonesia dan simpan secret hanya di environment server. Webhook mengirim header `x-steamtek-signature` berupa HMAC-SHA256 dari raw body menggunakan `PAYMENT_WEBHOOK_SECRET`. Untuk provider nyata, adaptasikan verifikasi sesuai dokumentasi resmi provider; jangan mengandalkan redirect sukses browser.

Endpoint produksi: `https://DOMAIN-ANDA/api/payment/webhook`.

## Deployment Vercel

Atur variabel `.env.example` di Vercel, ganti `NEXT_PUBLIC_SITE_URL`, daftarkan redirect Auth, terapkan migration sebelum deploy, lalu jalankan `npm run build`. Aktifkan backup harian/PITR sesuai paket Supabase dan SMTP produksi untuk email Auth.

## Pengujian

```bash
npm run lint
npm test
npm run build
```

Laporan audit dan gap ada di [IMPLEMENTATION_AUDIT.md](IMPLEMENTATION_AUDIT.md). Migration berada di `supabase/migrations/`; seed ada di `supabase/seed.sql`.

## Catatan keamanan

URL premium tidak memiliki kebijakan SELECT publik dan hanya diambil server setelah entitlement aktif diperiksa. URL eksternal yang sudah diterima pembeli tetap dapat dibagikan; sistem ini bukan DRM. Pemeriksaan URL otomatis kelak harus memblokir jaringan privat, loopback, metadata cloud, dan redirect tidak aman.
