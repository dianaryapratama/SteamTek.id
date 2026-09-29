import { z } from "zod";

const safeUrl = z.string().url().refine((value) => ["https:", "http:"].includes(new URL(value).protocol), "URL harus menggunakan HTTP atau HTTPS");
export const submissionSchema = z.object({
  name: z.string().trim().min(3).max(120), gameId: z.string().uuid(), categoryId: z.string().uuid().nullable().optional(),
  modVersion: z.string().trim().min(1).max(40), compatibilityNotes: z.string().trim().min(2).max(500),
  description: z.string().trim().min(20).max(10000), tutorial: z.string().trim().max(10000).optional().default(""),
  creatorName: z.string().trim().min(2).max(120), downloadUrl: safeUrl, sourceUrl: safeUrl,
  screenshotUrls: z.array(safeUrl).max(8).default([]), distributionPermission: z.literal(true), submit: z.boolean().default(true),
});
export const checkoutSchema = z.object({ productIds: z.array(z.string().uuid()).min(1).max(20) });
export const moderationSchema = z.object({ decision: z.enum(["APPROVED", "REVISION_REQUIRED", "REJECTED"]), notes: z.string().trim().min(3).max(2000) });
