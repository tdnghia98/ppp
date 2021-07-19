{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_plutus_pioneer_program_week04 (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/duy/.cabal/bin"
libdir     = "/Users/duy/.cabal/lib/x86_64-osx-ghc-8.10.4.20210212/plutus-pioneer-program-week04-0.1.0.0-inplace"
dynlibdir  = "/Users/duy/.cabal/lib/x86_64-osx-ghc-8.10.4.20210212"
datadir    = "/Users/duy/.cabal/share/x86_64-osx-ghc-8.10.4.20210212/plutus-pioneer-program-week04-0.1.0.0"
libexecdir = "/Users/duy/.cabal/libexec/x86_64-osx-ghc-8.10.4.20210212/plutus-pioneer-program-week04-0.1.0.0"
sysconfdir = "/Users/duy/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "plutus_pioneer_program_week04_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "plutus_pioneer_program_week04_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "plutus_pioneer_program_week04_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "plutus_pioneer_program_week04_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "plutus_pioneer_program_week04_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "plutus_pioneer_program_week04_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
