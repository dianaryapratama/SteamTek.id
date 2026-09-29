import { NextResponse } from "next/server"; import { createClient } from "@/lib/supabase/server";
export async function POST(request){const db=await createClient();await db.auth.signOut();return NextResponse.redirect(new URL("/",request.url),303)}
