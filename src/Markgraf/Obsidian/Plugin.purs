module Markgraf.Obsidian.Plugin (onload) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Markgraf.Obsidian.Obsidian (MarkdownContext, Plugin, addRenderChild, callTryParse, clearElement, isDarkMode, lookupTryParse, mountEmbed, parseError, parseOk, registerCodeBlockProcessor, renderError)
import Web.DOM.Element (Element, setAttribute)

-- | Plugin entry point: register the processor that turns every ```markgraf
-- | fence into a live player. Obsidian invokes this from the subclass in
-- | `entry.js` on load.
onload :: Plugin -> Effect Unit
onload plugin = registerCodeBlockProcessor plugin language renderBlock
  where
  language = "markgraf"

-- | Render one fenced block: show the parse error inline when the source is
-- | invalid, otherwise mount the player and tear it down with the note view.
renderBlock :: String -> Element -> MarkdownContext -> Effect Unit
renderBlock source el ctx = do
  problem <- parseProblem source
  case problem of
    Just err -> renderError el err
    Nothing -> mountLive
  where
  mountLive = do
    matchTheme
    mountEmbed el source
    addRenderChild ctx el (clearElement el)
  matchTheme = do
    dark <- isDarkMode
    setAttribute "data-markgraf-theme" (if dark then "dark" else "light") el

-- | The embed's parser verdict for `source`: `Just message` when it fails to
-- | parse, `Nothing` when it parses or the embed bundle has not loaded yet.
parseProblem :: String -> Effect (Maybe String)
parseProblem source = do
  fn <- lookupTryParse
  case fn of
    Nothing -> pure Nothing
    Just tryParse -> do
      result <- callTryParse tryParse source
      pure (if parseOk result then Nothing else Just (parseError result))
