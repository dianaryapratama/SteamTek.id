import { createClient } from "@/lib/supabase/server";

export async function getAuthContext() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { supabase, user: null, profile: null };
  const { data: profile } = await supabase.from("profiles").select("id,email,display_name,avatar_url,role").eq("id", user.id).single();
  return { supabase, user, profile };
}

export async function requireUser() {
  const context = await getAuthContext();
  if (!context.user) throw new Error("AUTH_REQUIRED");
  return context;
}

export async function requireAdmin() {
  const context = await requireUser();
  if (context.profile?.role !== "ADMIN") throw new Error("FORBIDDEN");
  return context;
}
