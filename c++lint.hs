{-# LANGUAGE OverloadedStrings #-}

import Turtle
import System.Environment (lookupEnv)
import Data.Text (pack, split)

getPaths :: String -> IO [Text]
getPaths s = do
  e <- lookupEnv s
  return (maybe [] (\t -> split (':'==) (pack t)) e)

main = do
  dirs <- getPaths "CPPLINT_INCLUDE_DIRS"
  print dirs
