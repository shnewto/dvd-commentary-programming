{-# LANGUAGE ScopedTypeVariables #-}

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

-- During experiments, hacking on the code below, pulled from 
-- https://github.com/vincenthz/hs-git/blob/master/tests/Repo.hs

onLocalRepo f = do
    fpath <- findRepoMaybe
    case fpath of
        Nothing ->
            putStrLn
                "cannot run this test without repository. clone the original repository for test"
        Just _ -> Data.Git.Storage.withCurrentRepo f


doLocalMarshallEq
    :: Git SHA1
    -> IO
           [ [ Maybe
                   ( Ref SHA1
                   , Ref SHA1
                   , (ObjectHeader SHA1, L.ByteString)
                   , (ObjectHeader SHA1, L.ByteString)
                   )
             ]
           ]

doLocalMarshallEq git = do
    prefixes <- looseEnumeratePrefixes (gitRepoPath git)
    forM prefixes $ \prefix -> do
        refs <- looseEnumerateWithPrefix (gitRepoPath git) prefix
        forM refs $ \ref -> do
            raw <- looseReadRaw (gitRepoPath git) ref
            obj <- looseRead (gitRepoPath git) ref
            let content = looseMarshall obj
            let raw2    = looseUnmarshallRaw content
            let hashed  = hashLBS content
            if ref /= hashed
                then return $ Just (ref, hashed, raw, raw2)
                else return Nothing

printDiff (actualRef, gotRef, (actualHeader, actualRaw), (gotHeader, gotRaw)) =
    do
        putStrLn "=========== difference found"
        putStrLn ("ref expected: " ++ show actualRef)
        putStrLn ("ref got     : " ++ show gotRef)
        putStrLn ("header expected: " ++ show actualHeader)
        putStrLn ("header got     : " ++ show gotHeader)
        putStrLn "raw diff:"
        putStrLn $ dumpDiffLBS actualRaw gotRaw

printLocalMarshallError l
    | null l
    = putStrLn "local marshall:   [OK]"
    | otherwise
    = putStrLn ("local marshall: [" ++ show (length l) ++ " errors]")
        >> mapM_ printDiff l
        >> exitFailure

someFunc :: IO ()
-- someFunc = putStrLn "someFunc"
someFunc = do
    onLocalRepo $ \(git :: Git SHA1) -> do
        doLocalMarshallEq git >>= printLocalMarshallError . catMaybes . concat
        return ()
