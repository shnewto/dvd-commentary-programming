module Lib
    ( someFunc
    )
where

import           Git
import           Git.Libgit2
import           Control.Monad.IO.Class
import           Data.Tagged
import           Data.Time
import qualified Data.Text                     as T

someFunc :: IO ()
someFunc = putStrLn "someFunc"
