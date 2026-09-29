import { defineConfig } from "vitest/config";
import path from "node:path";

export default defineConfig({
  test: { environment: "jsdom", setupFiles: ["./tests/setup.js"], include: ["tests/**/*.test.js"], exclude: ["node_modules/**", "node_modules-partial/**"] },
  resolve: { alias: { "@": path.resolve(import.meta.dirname, "./src") } },
});
