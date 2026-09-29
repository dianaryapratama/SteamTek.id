"use client";
import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export default function Login() { const [error,setError]=useState(""); const [busy,setBusy]=useState(false); const router=useRouter(); async function submit(e){e.preventDefault();setBusy(true);setError("");const form=new FormData(e.currentTarget);const {error}=await createClient().auth.signInWithPassword({email:form.get("email"),password:form.get("password")});if(error){setError("Email atau kata sandi tidak valid.");setBusy(false);return}const next=new URLSearchParams(window.location.search).get("next");router.push(next||"/account");router.refresh()} return <section className="container section" style={{maxWidth:520}}><form className="card" onSubmit={submit}><h1>Masuk</h1>{error&&<p role="alert">{error}</p>}<label className="field">Email<input name="email" type="email" required autoComplete="email"/></label><label className="field">Kata sandi<input name="password" type="password" required autoComplete="current-password"/></label><button className="button" disabled={busy}>{busy?"Memproses...":"Masuk"}</button><p><Link href="/auth/forgot-password">Lupa kata sandi?</Link></p><p>Belum punya akun? <Link href="/auth/register">Daftar</Link></p></form></section>; }
