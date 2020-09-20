module Elixir.Markdown

import Erlang

%default total


export
markdownToHtml : String -> Maybe String
markdownToHtml contents = do
  let astResult = erlUnsafeCall ErlTerm "Elixir.Earmark" "as_ast" [contents]
  ast <- erlDecodeMay ((\(MkTuple3 _ ast _) => ast) <$> tuple3 (exact (MkAtom "ok")) any any) astResult
  Just $ erlUnsafeCall String "Elixir.Earmark.Transform" "transform" [ast]
