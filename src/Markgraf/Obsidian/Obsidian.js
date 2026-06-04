import { MarkdownRenderChild } from "obsidian";

export const registerCodeBlockProcessorImpl =
  (plugin) => (lang) => (handler) => () => {
    plugin.registerMarkdownCodeBlockProcessor(lang, (source, el, ctx) => {
      handler(source)(el)(ctx)();
    });
  };

export const windowMarkgrafTryParseFnImpl = () =>
  (window.markgraf && window.markgraf.tryParse) || null;

export const callTryParseImpl = (fn) => (src) => () => fn(src);

export const parseOkImpl = (result) => result.ok;

export const parseErrorImpl = (result) => result.error;

export const mountEmbedImpl = (el) => (src) => () => {
  el.classList.add("markgraf-embed");
  el.setAttribute("data-markgraf", "");
  const fn = window.markgraf && window.markgraf.mount;
  if (!fn) return;
  fn(el, src);
  const playBtn = el.querySelector('[data-mg="play"]');
  const stage = el.querySelector('[data-mg="stage"]');
  if (playBtn && stage) {
    stage.addEventListener("click", (ev) => {
      ev.preventDefault();
      playBtn.click();
    });
  }
};

export const renderErrorImpl = (el) => (message) => () => {
  el.empty();
  el.createEl("pre", { cls: "markgraf-error" }).setText("markgraf: " + message);
};

export const addRenderChildImpl = (ctx) => (el) => (onunload) => () => {
  const child = new MarkdownRenderChild(el);
  child.onunload = onunload;
  ctx.addChild(child);
};

export const clearElementImpl = (el) => () => {
  el.empty();
};
