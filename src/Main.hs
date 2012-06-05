--------------------------------------------------------------------------------
{-# LANGUAGE DeriveDataTypeable #-}
module Main
    ( main
    ) where


--------------------------------------------------------------------------------
import           Control.Monad          (forM_)
import           Data.List              (intercalate)
import           Data.Maybe             (listToMaybe)
import           Data.Version           (Version(..))
import           System.Console.CmdArgs


--------------------------------------------------------------------------------
import           Paths_stylish_haskell  (version)
import           StylishHaskell
import           StylishHaskell.Config
import           StylishHaskell.Step
import           StylishHaskell.Verbose


--------------------------------------------------------------------------------
data StylishArgs = StylishArgs
    { config  :: Maybe FilePath
    , verbose :: Bool
    , files   :: [FilePath]
    } deriving (Data, Show, Typeable)


--------------------------------------------------------------------------------
stylishArgs :: StylishArgs
stylishArgs = StylishArgs
    { config  = Nothing &= typFile &= help "Configuration file"
    , verbose = False              &= help "Run in verbose mode"
    , files   = []      &= typFile &= args
    } &= summary ("stylish-haskell-" ++ versionString version)
  where
    versionString = intercalate "." . map show . versionBranch


--------------------------------------------------------------------------------
main :: IO ()
main = do
    sa   <- cmdArgs stylishArgs
    let verbose'  = makeVerbose (verbose sa)
    conf <- loadConfig verbose' (config sa)
    let filePath  = listToMaybe $ files sa
        steps     = configSteps conf

    forM_ steps $ \step -> verbose' $ "Enabled " ++ stepName step ++ " step"
    contents <- maybe getContents readFile filePath
    putStr $ unlines $ runSteps filePath steps $ lines contents
