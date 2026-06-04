module SyncEmbed (main) where

import Prelude

import Data.Char (toCharCode)
import Data.Foldable (foldMap)
import Data.Int (hexadecimal, toStringAs)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Data.String.CodeUnits (singleton, toCharArray)
import Effect (Effect)
import Effect.Class.Console (log)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.FS.Perms (all, mkPerms)
import Node.FS.Sync (mkdir', readFile, readTextFile, writeTextFile)

src :: String
src = "node_modules/@markgrafhq/markgraf-embed/dist"

-- | Pull the embed bundle into the plugin tree:
-- |   * `vendor/markgraf-embed.js` — the player IIFE, with Unicode
-- |     noncharacters escaped so the bundled main.js is plain UTF-8.
-- |   * `styles.css` — the embed stylesheet, with the CommitMono @font-face
-- |     inlined as a data URL so Obsidian's updater (which ships only
-- |     main.js / manifest.json / styles.css) still has the font, plus the
-- |     inline parse-error styling the plugin renders.
main :: Effect Unit
main = do
  mkdir' "vendor" { recursive: true, mode: mkPerms all all all }
  embedJs <- readTextFile UTF8 (src <> "/markgraf-embed.js")
  writeTextFile UTF8 "vendor/markgraf-embed.js" (escapeNoncharacters embedJs)
  css <- readTextFile UTF8 (src <> "/markgraf-embed.css")
  fontUrl <- inlineFont
  writeTextFile UTF8 "styles.css" (replaceAll fontRef (Replacement fontUrl) css <> errorCss)
  log "synced markgraf-embed → vendor/markgraf-embed.js + styles.css"
  where
  fontRef = Pattern "./CommitMono-Regular.woff2"

inlineFont :: Effect String
inlineFont = do
  buf <- readFile (src <> "/CommitMono-Regular.woff2")
  b64 <- Buffer.toString Base64 buf
  pure ("data:font/woff2;base64," <> b64)

errorCss :: String
errorCss =
  "\n.markgraf-error{color:var(--text-error);white-space:pre-wrap;font-family:var(--font-monospace);}\n"

-- Rewrites Unicode noncharacters (U+FFFE, U+FFFF, U+FDD0–U+FDEF) to `\uXXXX`
-- escapes. purs-backend-es serialises the `￿` from `Bounded Char` as a raw
-- codepoint, which trips strict UTF-8 validators downstream (see MAR-50).
escapeNoncharacters :: String -> String
escapeNoncharacters = toCharArray >>> foldMap escapeChar

escapeChar :: Char -> String
escapeChar c =
  if isNoncharacter code then "\\u" <> toStringAs hexadecimal code
  else singleton c
  where
  code = toCharCode c

isNoncharacter :: Int -> Boolean
isNoncharacter code =
  code == 0xFFFE || code == 0xFFFF || (code >= 0xFDD0 && code <= 0xFDEF)
