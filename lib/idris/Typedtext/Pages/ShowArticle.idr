module Typedtext.Pages.ShowArticle

import Html
import Elixir.Markdown
import Typedtext.Article

%default total


export
view : Article -> Html
view article =
  let Just htmlString = markdownToHtml article.body
    | Nothing => text "Unable to parse text as Markdown"
  in
    div
      []
      [ h1 [] [text article.title]
      , raw $ htmlString
      ]
