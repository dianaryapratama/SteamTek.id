import { NextResponse } from "next/server";

export function apiError(error) {
  const message = error?.message || "Terjadi kesalahan server.";
  if (message === "AUTH_REQUIRED") return NextResponse.json({ error: "Silakan masuk terlebih dahulu." }, { status: 401 });
  if (message === "FORBIDDEN") return NextResponse.json({ error: "Anda tidak memiliki izin." }, { status: 403 });
  return NextResponse.json({ error: message }, { status: 400 });
}
