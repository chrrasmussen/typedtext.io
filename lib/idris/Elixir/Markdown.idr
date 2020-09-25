module Elixir.Markdown

import Data.List
import Data.Maybe
import Utils.String
import Erlang

%default total


-- This module converts Markdown to HTML.
--
-- Additionally, it translates Literate Idris code into normal code blocks.
-- Literate Idris is using `>` markers to indicate code, while Markdown uses
-- these markers to indicate a blockquote.
--
-- ```idris
-- > foo : Int
-- > foo = 42
-- ```
--
-- Earmark turns this text into the following AST:
-- ```
-- [{"blockquote", [], [{"p", [], ["foo : Int\nfoo = 42"], %{}}], %{}}]
-- ```
--
-- After the transformation, the AST should look like this:
-- ```
-- [{"pre", [], [{"code", [{"class", "idris"}], ["foo : Int\nfoo = 42"], %{}}], %{}}]
-- ```


transformAst : (String -> Maybe a) -> (String -> List (ErlTuple2 String String) -> List ErlTerm -> ErlAnyMap -> Maybe a) -> ErlTerm -> Maybe a
transformAst fromText fromNode ast =
  join $ erlDecodeMay
    (fromText <$> string
      <|> (\(MkTuple4 text attrs nodes ctxt) =>
              fromNode text (erlUnsafeCast (List (ErlTuple2 String String)) attrs) (erlUnsafeCast (List ErlTerm) nodes) ctxt)
            <$> tuple4 string any any anyMap)
    ast

mkNode : String -> List (ErlTuple2 String String) -> List ErlTerm -> ErlAnyMap -> ErlTerm
mkNode tag attrs nodes ctxt =
  cast $ MkTuple4 tag attrs nodes ctxt

textFromParagraph : String -> List (ErlTuple2 String String) -> List ErlTerm -> ErlAnyMap -> Maybe String
textFromParagraph "p" attrs nodes ctxt = erlDecodeMay (list string) nodes >>= head'
textFromParagraph _ attrs nodes ctxt = Nothing

blockquoteToCode : String -> List (ErlTuple2 String String) -> List ErlTerm -> ErlAnyMap -> Maybe ErlTerm
blockquoteToCode "blockquote" attrs nodes ctxt = do
  let paragraphs = mapMaybe (transformAst (const Nothing) textFromParagraph) nodes
  let codeStr = showSep "\n\n" paragraphs
  let codeNode = mkNode "code" [MkTuple2 "class" "idris"] [cast codeStr] empty
  let preNode = mkNode "pre" [] [cast codeNode] empty
  Just $ cast preNode
blockquoteToCode _ attrs nodes ctxt = Nothing

transformLiterateIdris : ErlTerm -> ErlTerm
transformLiterateIdris ast =
  let nodes = erlDecodeDef [] (list any) ast
  in cast $ map (\node => fromMaybe node $ transformAst (const Nothing) blockquoteToCode node) nodes

export
markdownToHtml : String -> Maybe String
markdownToHtml contents = do
  let astResult = erlUnsafeCall ErlTerm "Elixir.Earmark" "as_ast" [contents]
  ast <- erlDecodeMay ((\(MkTuple3 _ ast _) => ast) <$> tuple3 (exact (MkAtom "ok")) any any) astResult
  Just $ erlUnsafeCall String "Elixir.Earmark.Transform" "transform" [transformLiterateIdris ast]
