module Markgraf.Obsidian.Obsidian
  ( Plugin
  , MarkdownContext
  , registerCodeBlockProcessor
  , TryParseFn
  , ParseResult
  , lookupTryParse
  , callTryParse
  , parseOk
  , parseError
  , isDarkMode
  , mountEmbed
  , renderError
  , addRenderChild
  , clearElement
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Web.DOM.Element (Element)

-- | An Obsidian `Plugin` instance — the `this` Obsidian hands our subclass.
foreign import data Plugin :: Type

-- | The per-block render context Obsidian passes to a code-block processor.
-- | We use it only to attach a `MarkdownRenderChild` for teardown.
foreign import data MarkdownContext :: Type

foreign import registerCodeBlockProcessorImpl
  :: Plugin
  -> String
  -> (String -> Element -> MarkdownContext -> Effect Unit)
  -> Effect Unit

-- | Register a handler for fenced blocks tagged with `language`. Obsidian
-- | calls it once per matching block with the source, the host element, and
-- | the render context; it auto-unregisters when the plugin unloads.
registerCodeBlockProcessor
  :: Plugin
  -> String
  -> (String -> Element -> MarkdownContext -> Effect Unit)
  -> Effect Unit
registerCodeBlockProcessor = registerCodeBlockProcessorImpl

-- | The embed's `window.markgraf.tryParse`, present once the embed bundle has
-- | run. Opaque to PureScript; only `callTryParse` consumes it.
foreign import data TryParseFn :: Type

-- | The `{ ok, error }` record `tryParse` returns.
foreign import data ParseResult :: Type

foreign import windowMarkgrafTryParseFnImpl :: Effect (Nullable TryParseFn)

-- | Look up the embed's parse-check function. `Nothing` when the embed bundle
-- | has not attached `window.markgraf` yet, in which case the caller mounts
-- | optimistically rather than blocking.
lookupTryParse :: Effect (Maybe TryParseFn)
lookupTryParse = toMaybe <$> windowMarkgrafTryParseFnImpl

foreign import callTryParseImpl :: TryParseFn -> String -> Effect ParseResult

callTryParse :: TryParseFn -> String -> Effect ParseResult
callTryParse = callTryParseImpl

foreign import parseOkImpl :: ParseResult -> Boolean

parseOk :: ParseResult -> Boolean
parseOk = parseOkImpl

foreign import parseErrorImpl :: ParseResult -> String

parseError :: ParseResult -> String
parseError = parseErrorImpl

foreign import isDarkModeImpl :: Effect Boolean

-- | Whether Obsidian is in a dark theme, so the player can pick a matching
-- | palette. Read from the `theme-dark` class Obsidian toggles on `<body>`.
isDarkMode :: Effect Boolean
isDarkMode = isDarkModeImpl

foreign import mountEmbedImpl :: Element -> String -> Effect Unit

-- | Mount the live player into `el` via the embed's `window.markgraf.mount`,
-- | wiring the canvas-click play toggle the way the browser extension does.
mountEmbed :: Element -> String -> Effect Unit
mountEmbed = mountEmbedImpl

foreign import renderErrorImpl :: Element -> String -> Effect Unit

-- | Replace `el`'s contents with the parse error, so a broken snippet shows
-- | why inline instead of silently rendering nothing.
renderError :: Element -> String -> Effect Unit
renderError = renderErrorImpl

foreign import addRenderChildImpl :: MarkdownContext -> Element -> Effect Unit -> Effect Unit

-- | Attach a `MarkdownRenderChild` whose `onunload` runs the given effect, so
-- | the player is torn down when its note view closes.
addRenderChild :: MarkdownContext -> Element -> Effect Unit -> Effect Unit
addRenderChild = addRenderChildImpl

foreign import clearElementImpl :: Element -> Effect Unit

clearElement :: Element -> Effect Unit
clearElement = clearElementImpl
