import Link from "next/link";
import { requireAdmin } from "@/lib/auth";

export default async function Admin() {
  const { supabase } = await requireAdmin();
  const [submissionResult, orderResult, productResult] = await Promise.all([
    supabase.from("submissions").select("*", { count: "exact", head: true }).eq("status", "PENDING_REVIEW"),
    supabase.from("orders").select("*", { count: "exact", head: true }),
    supabase.from("products").select("*", { count: "exact", head: true }),
  ]);
  return <section className="container section"><h1>Dasbor Admin</h1><div className="grid"><Link className="card" href="/admin/submissions"><h2>{submissionResult.count || 0}</h2><p>Menunggu moderasi</p></Link><div className="card"><h2>{orderResult.count || 0}</h2><p>Total pesanan</p></div><div className="card"><h2>{productResult.count || 0}</h2><p>Total produk</p></div></div></section>;
}
