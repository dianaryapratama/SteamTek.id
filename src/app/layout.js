import "./globals.css";
import { Header } from "@/components/header";

export const metadata = { title: { default:"SteamTek.id — Mod Game PC", template:"%s | SteamTek.id" }, description:"Marketplace mod premium dan repositori mod gratis komunitas Indonesia." };
export default function RootLayout({ children }) { return <html lang="id"><body><Header/><main>{children}</main><footer className="section" style={{borderTop:"1px solid var(--line)"}}><div className="container"><strong>SteamTek.id</strong><p className="muted">Marketplace single-vendor dan repositori komunitas. File didistribusikan melalui hosting eksternal.</p></div></footer></body></html>; }
