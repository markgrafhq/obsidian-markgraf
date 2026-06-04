module SyncVersion (main) where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Markgraf.Obsidian.Scripts.Json (getStringField, parse, setStringField, stringify)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)

-- | Propagate `package.json`'s version into the two files Obsidian reads:
-- | `manifest.json` (the live version) and `versions.json` (the
-- | version → minAppVersion map the community registry consults).
main :: Effect Unit
main = do
  pkg <- readJson "package.json"
  manifest <- readJson "manifest.json"
  versions <- readJson "versions.json"
  let version = getStringField "version" pkg
  setStringField "version" version manifest
  writeJson "manifest.json" manifest
  setStringField version (getStringField "minAppVersion" manifest) versions
  writeJson "versions.json" versions
  log ("synced version → " <> version)
  where
  readJson path = readTextFile UTF8 path >>= parse
  writeJson path value = do
    serialised <- stringify 2 value
    writeTextFile UTF8 path (serialised <> "\n")
