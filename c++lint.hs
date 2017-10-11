{-# LANGUAGE OverloadedStrings #-}

import Turtle
import System.Environment (lookupEnv)
import qualified Data.Text as T (pack, split, append)
import Prelude hiding (FilePath)

type Define = (Text, Text)

data Settings = Settings
  { file     :: FilePath
  , checks   :: Maybe [Text]
  , includes :: Maybe [Text]
  , defines  :: Maybe [Define]
  }

getPaths :: String -> IO [Text]
getPaths s = do
  e <- lookupEnv s
  return (maybe [] (\t -> T.split (':'==) (T.pack t)) e)

parseFile :: Parser FilePath
parseFile = argPath "file" empty

parseChecks :: Parser [Text]
parseChecks = opt (\t -> Just [t]) "checks" 'c'  empty

parseIncludes :: Parser [Text]
parseIncludes = opt (\t -> Just [t]) "includes" 'i'  empty

parseDefines :: Parser [Define]
parseDefines = opt (\t -> Just [(t, t)]) "defines" 'd'  empty

parseSettings :: IO Settings
parseSettings = options "C++ static linter" settingParser
  where
    settingParser :: Parser Settings
    settingParser = Settings <$> parseFile
                             <*> optional parseChecks
                             <*> optional parseIncludes
                             <*> optional parseDefines

toIncludes :: [Text] -> [Text]
toIncludes = fmap includize
  where
    includize p = "-I" `T.append` p

main = do
  (Settings file checks includes defines) <- parseSettings
  dirs <- getPaths "CPPLINT_INCLUDE_DIRS"
  proc "clang-tidy" ([(format fp file), "--", "--std=c++11"] ++ toIncludes dirs) empty
