import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
  server: {
    port: 3001, // Run React app on a different port
  },
  build: {
    outDir: "../public/ui", // Output build to UI' public directory
    emptyOutDir: true,
  },
  css: {
    preprocessorOptions: {
      css: {},
    },
  },
});
