import Link from "next/link";
import { ShieldCheck, Search, Users } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { ProductCard } from "@/components/product-card";

export default async function Home() {
  let products = [];
  try { const db = await createClient(); const { data } = await db.from("products").select("id,name,slug,type,price,creator_name,games(name)").eq("status","PUBLISHED").limit(6); products = data || []; } catch { /* konfigurasi database belum tersedia */ }
  return <>
    <section className="hero"><div className="container"><p style={{color:"#5eead4",fontWeight:800}}>MOD & ASSET GAME PC</p><h1>Temukan mod terbaik. Bangun komunitas bersama.</h1><p style={{maxWidth:650,fontSize:18,color:"#cbd5e1"}}>Jelajahi mod premium dari SteamTek dan kontribusi gratis yang telah dimoderasi.</p><div style={{display:"flex",gap:12,marginTop:28}}><Link className="button" href="/mods">Jelajahi katalog</Link><Link className="button secondary" href="/community/submit">Kirim mod gratis</Link></div></div></section>
    <section className="container section"><div className="grid"><div className="card"><Search/><h3>Mudah ditemukan</h3><p className="muted">Cari berdasarkan game, kategori, dan kompatibilitas versi.</p></div><div className="card"><ShieldCheck/><h3>Dimoderasi</h3><p className="muted">Kontribusi komunitas ditinjau sebelum tampil di katalog.</p></div><div className="card"><Users/><h3>Untuk komunitas</h3><p className="muted">Unduhan gratis tanpa login, transparan mengenai sumber dan kreator.</p></div></div></section>
    <section className="container section"><h2>Mod terbaru</h2>{products.length ? <div className="grid">{products.map(p=><ProductCard key={p.id} product={p}/>)}</div> : <div className="card"><p>Katalog belum berisi produk. Terapkan migration dan seed, lalu publikasikan produk dari dasbor admin.</p></div>}</section>
  </>;
}
