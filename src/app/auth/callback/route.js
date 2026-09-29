import { NextResponse } from "next/server"; import { createClient } from "@/lib/supabase/server";
export async function GET(request){const url=new URL(request.url);const code=url.searchParams.get("code");const next=url.searchParams.get("next")||"/account";if(code){const db=await createClient();await db.auth.exchangeCodeForSession(code)}return NextResponse.redirect(new URL(next,url.origin))}
