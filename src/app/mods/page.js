import { createClient } from "@/lib/supabase/server";
import { ProductCard } from "@/components/product-card";
export const metadata = { title:"Katalog Mod" };
export default async function Mods({ searchParams }) {
  const params = await searchParams; let products=[]; let error=null;
  try { const db=await createClient(); let q=db.from("products").select("id,name,slug,type,price,creator_name,games(name),categories(name)").eq("status","PUBLISHED"); if(params?.q) q=q.ilike("name",`%${params.q}%`); if(["FREE","PREMIUM"].includes(params?.type)) q=q.eq("type",params.type); const result=await q.order("published_at",{ascending:false}); products=result.data||[]; error=result.error; } catch(e){error=e}
  return <section className="container section"><h1>Katalog Mod</h1><form className="card" style={{display:"flex",gap:10,marginBottom:24}}><input name="q" defaultValue={params?.q} placeholder="Cari nama mod..." style={{flex:1,padding:10,border:"1px solid var(--line)",borderRadius:8}}/><select name="type" defaultValue={params?.type||""}><option value="">Semua</option><option value="FREE">Gratis</option><option value="PREMIUM">Premium</option></select><button className="button">Cari</button></form>{error?<p>Database belum terhubung.</p>:<div className="grid">{products.map(p=><ProductCard key={p.id} product={p}/>)}</div>}</section>;
}
