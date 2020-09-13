module Typedtext.Views.ListArticles

import Html
import Typedtext.Article
import Typedtext.Views.ContentBox

%default total


viewBadge : Integer -> Html
viewBadge count =
  let size : Integer = 24
  in span
    [ style "display" "inline-block"
    , style "width" (cast size ++ "px")
    , style "height" (cast size ++ "px")
    , style "line-height" (cast size ++ "px")
    , style "border-radius" (cast (size `div` 2) ++ "px")
    , style "background-color" "#4A4A4A"
    , style "color" "white"
    , style "font-size" "12px"
    , style "text-align" "center"
    ]
    [ text (cast count)
    ]

viewTag : (String, Integer) -> Html
viewTag (tag, count) =
  li
    []
    [ a
        [ href "#" ]
        [ text tag ]
    , span
        [ style "margin-left" "8px" ]
        [ viewBadge count ]
    ]

viewTags : List (String, Integer) -> Html
viewTags tags =
  div
    []
    [ ContentBox.view
        (div
          []
          [ h2
              []
              [ text "Tags" ]
          , ul
              []
              (map viewTag tags)
          ]
        )
    ]

viewArticle : Article -> Html
viewArticle article =
  ContentBox.view
    (div
      []
      [ a
          [ attr "href" "#" ]
          [ text article.title ]
      , span
          [ style "float" "right" ]
          [ text article.publishDate ]
      ]
    )

export
view : List Article -> Html
view articles =
  div
    [ style "display" "flex"
    ]
    [ div
        [ style "flex" "1"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "15px"
        ]
        (map viewArticle articles)
    , div
        [ style "width" "250px"
        , style "margin-left" "15px"
        ]
        [ viewTags
            [ ("non-technical", 5)
            , ("first", 1)
            ]
        ]
    ]
