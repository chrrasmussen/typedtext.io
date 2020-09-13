module Typedtext.Views.ShowArticle

import Data.List
import Html
import Elixir.Markdown
import Typedtext.Article
import Typedtext.Views.ContentBox

%default total

viewAuthor : String -> Html
viewAuthor author =
  a
    [ href "#" ]
    [ text author ]

viewTag : String -> Html
viewTag tag =
  a
    [ href ("/posts?tag=" ++ tag) ]
    [ text tag ]

export
view : Article -> Html
view article =
  let Just htmlString = markdownToHtml article.body
    | Nothing => text "Unable to parse text as Markdown"
  in
    ContentBox.view
      (div
        []
        [ span
            [ style "float" "right"
            , style "color" "#888888"
            ]
            [ text article.publishDate ]
        , h1 [] [text article.title]
        , unsafeRaw $ htmlString
        , hr [] []
        , div
            [ className "article-footer"
            ]
            [ div
                []
                [ text "Author: "
                , viewAuthor article.author
                ]
            , div
                []
                (text "Tags: " :: intersperse (text ", ") (map viewTag article.tags))
            ]
        ]
      )
