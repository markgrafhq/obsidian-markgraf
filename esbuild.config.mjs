import esbuild from "esbuild";

// Bundle the purs-backend-es output plus the embed IIFE into the single
// CommonJS main.js Obsidian loads. `obsidian` and `electron` are provided by
// the host at runtime, so they stay external.
esbuild
  .build({
    entryPoints: ["src/entry.js"],
    outfile: "main.js",
    bundle: true,
    format: "cjs",
    platform: "browser",
    target: "es2022",
    external: ["obsidian", "electron"],
    legalComments: "none",
    logLevel: "info",
  })
  .catch(() => process.exit(1));
