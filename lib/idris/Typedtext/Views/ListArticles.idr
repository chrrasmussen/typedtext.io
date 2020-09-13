module Typedtext.Views.ListArticles

import Html
import Typedtext.Article
import Typedtext.Article.Id
import Typedtext.Views.ContentBox
import Typedtext.Views.Tags

%default total


viewTags : List (String, Integer) -> Html
viewTags tags =
  div
    [ className "tags"
    ]
    [ ContentBox.view
        (div
          []
          [ h2
              []
              [ text "Top tags" ]
          , ul
              [ style "line-height" "24px"
              ]
              (map viewTag tags)
          ]
        )
    ]

viewArticle : ArticleId -> Article -> Html
viewArticle id article =
  ContentBox.view
    (div
      []
      [ span
          [ style "float" "right"
          , style "color" "#888888"
          ]
          [ text article.publishDate ]
      , h2
          []
          [ text article.title ]
      , p
          []
          [ text "..." ]
      , p
          []
          [ a
              [ href ("/posts/view?id=" ++ show id) ]
              [ text "Read more" ]
          ]
      ]
    )

wrapInMarginTopContainer : Html -> Html
wrapInMarginTopContainer content =
  div
    [ className "margintop15-skipfirst" ]
    [ content ]

export
view : List (ArticleId, Article) -> List (String, Integer) -> Html
view articles topTags =
  div
    [ style "display" "flex"
    ]
    [ div
        [ style "flex" "1"
        ]
        (map (wrapInMarginTopContainer . uncurry viewArticle) articles)
    , div
        [ style "width" "250px"
        , style "margin-left" "15px"
        ]
        [ viewTags topTags
        ]
    ]
