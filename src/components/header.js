import Link from "next/link";
import { Gamepad2 } from "lucide-react";
import { getAuthContext } from "@/lib/auth";

export async function Header() {
  let profile = null;
  try { ({ profile } = await getAuthContext()); } catch { /* tampilkan navigasi publik saat env belum siap */ }
  return <header className="container nav">
    <Link href="/" style={{display:"flex",alignItems:"center",gap:8,fontWeight:900,fontSize:20}}><Gamepad2 color="#08a88a"/> SteamTek.id</Link>
    <nav className="nav-links" aria-label="Navigasi utama">
      <Link href="/mods">Katalog</Link><Link href="/games">Game</Link><Link href="/community">Komunitas</Link>
      {profile ? <><Link href={profile.role === "ADMIN" ? "/admin" : "/account"}>Dasbor</Link><form action="/auth/signout" method="post"><button className="button secondary">Keluar</button></form></> : <Link className="button" href="/auth/login">Masuk</Link>}
    </nav>
  </header>;
}
