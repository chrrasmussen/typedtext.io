module Typedtext.Views.ListArticles

import Html
import Elixir.Markdown
import Typedtext.Article
import Typedtext.Article.Id
import Typedtext.Views.Helpers.ContentBox
import Typedtext.Views.Helpers.Article
import Typedtext.Views.Helpers.Tags

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
  let
    Just introHtml = markdownToHtml article.intro
      | Nothing => text "Unable to parse text as Markdown"
    footer =
      if article.body /= Nothing
        then
          [ p
              []
              [ a
                  [ href ("/posts/view?id=" ++ show id) ]
                  [ text "Read more →" ]
              ]
          ]
        else
          [ viewFooter article ]
  in
    ContentBox.view
      (div
        [ className "article"
        ]
        (
          [ span
              [ style "float" "right"
              , style "color" "#666677"
              ]
              [ text article.publishDate ]
          , h1
              []
              [ text article.title ]
          , unsafeRaw introHtml
          ] ++ footer
        )
      )

wrapInMarginTopContainer : Html -> Html
wrapInMarginTopContainer content =
  div
    [ className "margintop24-skipfirst" ]
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
        [ style "width" "200px"
        , style "margin-left" "24px"
        , className "top-tags"
        ]
        [ viewTags topTags
        ]
    ]
