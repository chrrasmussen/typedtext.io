module Elixir.Markdown

import Erlang

%default total


export
markdownToHtml : String -> Maybe String
markdownToHtml contents =
  let result = erlUnsafeCall ErlTerm "Elixir.Earmark" "as_html" [contents]
  in erlDecodeMay ((\(MkTuple3 _ body _) => body) <$> tuple3 (exact (MkAtom "ok")) string any) result
