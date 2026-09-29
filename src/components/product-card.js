import Link from "next/link";
export function ProductCard({ product }) {
  return <article className="card">
    <span className={`badge ${product.type === "PREMIUM" ? "premium" : ""}`}>{product.type === "PREMIUM" ? "Premium" : "Gratis"}</span>
    <h3><Link href={`/mods/${product.slug}`}>{product.name}</Link></h3>
    <p className="muted">{product.games?.name || "Game"} · {product.creator_name}</p>
    <strong>{product.type === "FREE" ? "Gratis" : new Intl.NumberFormat("id-ID", {style:"currency",currency:"IDR",maximumFractionDigits:0}).format(product.price)}</strong>
  </article>;
}
