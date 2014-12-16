{- |
Module      :  $Header$
Description :  hsay.
Copyright   :  (c) Alexander Berntsen 2014
License     :  GPL-3

Maintainer  :  alexander@plaimi.net
-} module Main where

import Control.Arrow
  (
  second,
  )
import Data.List
  (
  intersperse,
  )
import Data.Monoid
  (
  Sum (Sum),
  mappend,
  mempty,
  )
import GHC.IO.Exception
  (
  ExitCode,
  )
import Network.HTTP.Base
  (
  urlEncode,
  )
import System.Environment
  (
  getArgs,
  )
import System.Exit
  (
  exitWith,
  )
import System.Hclip
  (
  getClipboard,
  )
import System.IO
  (
  hFlush,
  stdout,
  )
import System.Posix.IO
  (
  stdInput,
  )
import System.Posix.Terminal
  (
  queryTerminal,
  )
import System.Process
  (
  spawnProcess,
  waitForProcess,
  )

import Paths_hsay

data Language = MkLang  {lang :: String}
              | DefLang {lang :: String}

defprogopts :: (String, [String])
defprogopts = ("mpg123", ["-q"])

infixr 9 ~+~
(~+~) :: IO a -> IO a -> IO a
f ~+~ g = queryTerminal stdInput >>= \t -> if t then f else g

main :: IO ()
main = do
  as <- getArgs
  f  <- getDataFileName "data/flip.mp3"
  uncurry tts (getLang as) f

getLang :: [String] -> (Language, [String])
getLang (('-':l):xs) = (MkLang l,     xs)
getLang xs           = (DefLang "en", xs)

tts :: Language -> [String] -> FilePath -> IO ()
tts l [] f = resl l f ~+~ (getContents >>= \cs -> run l (words cs) f)
tts l as f = run l as f

run :: Language -> [String] -> FilePath -> IO ()
run l as f = fork (build l as f) >>= exitWith

resl :: Language -> FilePath -> IO ()
resl l f = do
  putStr ">"
  hFlush stdout
  n <- getLine
  case take 5 n of
    "#LANG" -> resl (MkLang $ drop 6 n) f
    "#CLIP" -> do
      c <- getClipboard
      fork (build l (words c) f) >> resl l f
    _       -> fork (build l (words n) f) >>  resl l f
 
fork :: (FilePath, [String]) -> IO ExitCode
fork f = uncurry spawnProcess f >>= waitForProcess

build :: Language -> [String] -> FilePath -> (FilePath, [String])
build l xs f  = (++ intersperse f [ mkUrl l $ unwords t
                                  | t <- chunk [] xs ]) `second` defprogopts

mkUrl :: Language -> String -> String
mkUrl l us = "http://translate.google.com/translate_tts?ie=UTF-8&tl="
             ++ lang l ++ "&q=" ++ urlEncode us

concatInits :: [Sum Int] -> [Sum Int]
-- Thanks to ollef for this.
concatInits = go mempty
  where
    go _   []     = []
    go acc (x:xs) = x' : go x' xs where x' = mappend acc x

fit :: [[a]] -> [[a]]
-- Thanks to ollef for this.
fit xs = map snd $ takeWhile ((< Sum 101) . fst) $ zip lxs xs
  where lxs = concatInits $ map (Sum . (+1) . length) xs

chunk :: Eq a => [[[a]]] -> [[a]] -> [[[a]]]
-- The left list is the parsed-to-appropriate-size 'a's.
-- The right list is the yet-to-be-parsed-to-appropriate-size 'a's.
chunk xs []         = xs
chunk xs yss@(y:ys) = case fit [y] of
                    [] -> chunk (xs ++ [[take 99 y]]) (drop 99 y : ys)
                    _  -> chunk (xs ++ [fit yss])     (diff (fit yss) yss)

diff :: Eq a => [a] -> [a] -> [a]
diff [] ys                     = ys
diff _  []                     = []
diff (x:xs) (y:ys) | x == y    = diff xs ys
                   | otherwise = ys
