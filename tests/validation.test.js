import { describe, expect, it } from "vitest";
import { checkoutSchema, submissionSchema } from "@/lib/validation";

const validSubmission = { name:"Mod Peta Nusantara", gameId:"11111111-1111-4111-8111-111111111111", categoryId:null, modVersion:"1.0", compatibilityNotes:"Game versi 1.57", description:"Deskripsi lengkap untuk mod komunitas ini.", tutorial:"Ekstrak dan aktifkan.", creatorName:"Kreator", downloadUrl:"https://example.com/mod.zip", sourceUrl:"https://example.com/source", screenshotUrls:[], distributionPermission:true, submit:true };
describe("validasi kontribusi",()=>{
  it("menerima URL HTTPS dan izin distribusi",()=>expect(submissionSchema.parse(validSubmission).name).toBe(validSubmission.name));
  it("menolak skema file",()=>expect(()=>submissionSchema.parse({...validSubmission,downloadUrl:"file:///etc/passwd"})).toThrow());
  it("mewajibkan izin distribusi",()=>expect(()=>submissionSchema.parse({...validSubmission,distributionPermission:false})).toThrow());
});
describe("validasi checkout",()=>{
  it("menerima UUID produk",()=>expect(checkoutSchema.parse({productIds:[validSubmission.gameId]}).productIds).toHaveLength(1));
  it("menolak keranjang kosong",()=>expect(()=>checkoutSchema.parse({productIds:[]})).toThrow());
});
