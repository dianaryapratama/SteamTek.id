import js from "@eslint/js";

export default [
  { ignores: [".next/**", ".next-stale-*/**", "coverage/**", "docs-local/**", "node_modules-partial/**"] },
  js.configs.recommended,
  {
    files: ["**/*.{js,mjs}"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parserOptions: { ecmaFeatures: { jsx: true } },
      globals: { console:"readonly", process:"readonly", Buffer:"readonly", location:"readonly", window:"readonly", fetch:"readonly", URL:"readonly", URLSearchParams:"readonly", FormData:"readonly" },
    },
    rules: { "no-unused-vars": "off" },
  },
];
