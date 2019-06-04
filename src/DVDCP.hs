module DVDCP
    ( someFunc
    )
where

import qualified Data.ByteString.Lazy          as L
import qualified Data.ByteString               as B

import           Control.Applicative
import           Control.Monad

import           Data.Git.Storage.Object
import           Data.Git.Storage.Loose
import           Data.Git.Storage
import           Data.Git.Ref
import           Data.Git.Types
import           Data.Git.Repository
import           Data.Git.Monad

import           Data.Maybe

import           Text.Bytedump
import           System.Exit


someFunc :: IO ()
someFunc = putStrLn "someFunc"
