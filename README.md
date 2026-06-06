# Markgraf for Obsidian

Render <code>```markgraf</code> fenced code blocks as **live, scrubbable
animated diagrams** directly inside your Obsidian notes.

````markdown
```markgraf
seed 1

keyframe "a request arrives" {
  +node browser "Browser"
  +node server "Server"
  +edge browser server

  browser -> server "GET /"
}
```
````

The block above renders as a canvas player with a play/pause button, a scrub
bar, and a speed selector — the same embed used on the markgraf website and the
[browser extension](https://github.com/markgrafhq/markgraf-browser-extension).

## How it works

Obsidian hands each fenced block to a markdown code-block processor, so there
is no DOM scraping: the plugin registers a processor for the `markgraf`
language, parse-checks the source, and mounts the embed player into the block's
element. A broken snippet shows its parse error inline instead of rendering
nothing. Each player is attached to a `MarkdownRenderChild`, so it tears down
when you navigate away — no leaked canvases.

The plugin is **desktop-only** for now: the embed renders with Canvas2D, which
is reliable in Obsidian's Electron runtime but fights mobile WebView quirks.

## Architecture

Like the other markgraf integrations, the logic is PureScript with a thin FFI
shim consuming [`@markgrafhq/markgraf-embed`](https://www.npmjs.com/package/@markgrafhq/markgraf-embed):

| File | Role |
| --- | --- |
| `src/Markgraf/Obsidian/Plugin.purs` | `onload` registers the code-block processor |
| `src/Markgraf/Obsidian/Obsidian.purs` / `.js` | FFI over the Obsidian Plugin API + embed |
| `src/entry.js` | the `Plugin` subclass Obsidian instantiates; delegates `onload` |
| `scripts/SyncEmbed.purs` | pulls `markgraf-embed.{js,css}` into the build |
| `scripts/SyncVersion.purs` | mirrors `package.json` version into `manifest.json` + `versions.json` |

`bun run build` syncs the embed (escaping Unicode noncharacters and inlining the
CommitMono font as a data URL so the stylesheet is self-contained), compiles the
PureScript through `purs-backend-es`, and `esbuild`s it together with the embed
into the single CommonJS `main.js` Obsidian loads.

## Build

```sh
bun install
bun run build
```

This produces `main.js` and `styles.css` (alongside the committed
`manifest.json`). To try it in a vault, copy `main.js`, `manifest.json`, and
`styles.css` into `<vault>/.obsidian/plugins/markgraf/` and enable the plugin in
Settings → Community plugins.

## License

MIT
