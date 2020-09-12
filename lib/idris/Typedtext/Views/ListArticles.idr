module Typedtext.Views.ListArticles

import Html
import Typedtext.Article

%default total


viewArticle : Article -> Html
viewArticle article =
  li
    []
    [ a
        [ attr "href" "#" ]
        [ text article.title ]
    , span
        [ style "float" "right" ]
        [ text article.publishDate ]
    ]

export
view : List Article -> Html
view articles =
  div
    []
    [ h2 [] [text "Posts"]
    , ol
        []
        (map viewArticle articles)
    ]
