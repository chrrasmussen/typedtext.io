module Typedtext.Views.ShowArticle

import Html
import Elixir.Markdown
import Typedtext.Article
import Typedtext.Views.ContentBox

%default total


export
view : Article -> Html
view article =
  let Just htmlString = markdownToHtml article.body
    | Nothing => text "Unable to parse text as Markdown"
  in
    ContentBox.view
      (div
        []
        [ h1 [] [text article.title]
        , unsafeRaw $ htmlString
        ]
      )
