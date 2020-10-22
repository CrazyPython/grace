module Grace where

import Grace.Syntax (Syntax)

import qualified Data.ByteString.Lazy                  as ByteString.Lazy
import qualified Data.Text.Prettyprint.Doc             as Pretty
import qualified Data.Text.Prettyprint.Doc.Render.Text as Pretty.Text
import qualified Grace.Lexer
import qualified Grace.Normalize
import qualified Grace.Parser
import qualified Grace.Pretty
import qualified Grace.Type
import qualified System.Exit                           as Exit

pretty :: Syntax -> IO ()
pretty syntax = Pretty.Text.putDoc doc
  where
    doc =   Pretty.group (Grace.Pretty.expression syntax)
        <>  Pretty.hardline

main :: IO ()
main = do
    bytes <- ByteString.Lazy.getContents

    expression <- case Grace.Lexer.runAlex bytes Grace.Parser.parseExpression of
        Left  string     -> fail string
        Right expression -> return expression

    case Grace.Type.typeOf expression of
        Left string -> do
            putStrLn string

            Exit.exitFailure
        Right inferredType -> do
            pretty inferredType

    pretty (Grace.Normalize.normalize expression)
