module Typedtext.Views.ShowArticle

import Data.List
import Html
import Elixir.Markdown
import Typedtext.Article
import Typedtext.Views.Helpers.ContentBox
import Typedtext.Views.Helpers.Article

%default total


export
view : Article -> Html
view article =
  let
    Just introHtml = markdownToHtml article.intro
      | Nothing => text "Unable to parse text as Markdown"
    bodyHtml = article.body >>= markdownToHtml
  in
    ContentBox.view
      (div
        []
        (
          [ span
              [ style "float" "right"
              , style "color" "#888888"
              ]
              [ text article.publishDate ]
          , h1 [] [text article.title]
          , unsafeRaw introHtml
          ] ++ toList (unsafeRaw <$> bodyHtml)
            ++ [ viewFooter article ]
        )
      )
