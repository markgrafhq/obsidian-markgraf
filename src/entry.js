import { Plugin } from "obsidian";
import "../vendor/markgraf-embed.js";
import { onload } from "../output-es/Markgraf.Obsidian.Plugin/index.js";

// The subclass Obsidian instantiates. It owns nothing but delegating onload
// to the PureScript entry point; everything else lives in Markgraf.Obsidian.*.
export default class MarkgrafPlugin extends Plugin {
  onload() {
    onload(this)();
  }
}
