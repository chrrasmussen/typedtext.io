module Elixir.Markdown

import Erlang

%default total


export
markdownToHtml : String -> IO (Maybe String)
markdownToHtml contents = do
  result <- pure $ erlUnsafeCall ErlTerm "Elixir.Earmark" "as_html" [contents]
  pure $ erlDecodeMay ((\(MkTuple3 _ body _) => body) <$> tuple3 (exact (MkAtom "ok")) string any) result
