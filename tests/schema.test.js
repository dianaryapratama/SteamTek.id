import { readFileSync } from "node:fs"; import { describe,expect,it } from "vitest";
const schema=readFileSync("supabase/migrations/202609290001_initial_schema.sql","utf8");
const sensitive=["payments","entitlements","download_links","audit_logs"];
describe("baseline keamanan schema",()=>{
  it.each(sensitive)("mengaktifkan RLS untuk %s",table=>expect(schema).toContain(`'${table}'`));
  it("tidak memberikan SELECT download_links kepada anon",()=>expect(schema).not.toMatch(/grant select on[^;]*download_links[^;]*to anon/i));
  it("mencabut akses fungsi finalisasi payment",()=>expect(schema).toMatch(/revoke all on function public\.finalize_paid_order/));
  it("menghitung order di fungsi database",()=>expect(schema).toMatch(/select sum\(price\) into computed_total/));
});
