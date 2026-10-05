// Starter config + spindlePack. Extends the starter's own vite.config.ts so
// the template's real pipeline is what gets tested.
// Build with: npx vite build -c vite.demo.config.ts
// Pick targets with SPINDLE_PACK_TARGETS (e.g. joiplay); none are built by default.
import { defineConfig, mergeConfig } from "vite";
import base from "./vite.config.js";
import { spindlePack } from "./pack/plugin.js";

export default mergeConfig(
  base,
  defineConfig({
    plugins: [
      spindlePack({
        name: "Spindle Demo",
        identifier: "com.rohal12.spindledemo",
        icon: "src/assets/media/icon.png",
        version: process.env.DEMO_VERSION || "0.0.0",
        targets: [],
      }),
    ],
  }),
);
