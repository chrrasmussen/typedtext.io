module Typedtext.Views.ListArticles

import Data.List
import Data.SortedMap
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

viewArticle : (id : String) -> Article -> Html
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
              [ href ("/posts/view?id=" ++ id) ]
              [ text "Read more" ]
          ]
      ]
    )

wrapInMarginTopContainer : Html -> Html
wrapInMarginTopContainer content =
  div
    [ className "margintop15-skipfirst" ]
    [ content ]

countElements : Ord a => List a -> List (a, Integer)
countElements xs = toList $ foldl (mergeWith (+)) empty (map (\key => singleton key 1) xs)

tagsFromArticles : List Article -> List (String, Integer)
tagsFromArticles articles = countElements (concatMap (.tags) articles)

-- TODO: Unexported version exists in `Data.Either`. Move and export?
on : (b -> b -> c) -> (a -> b) -> a -> a -> c
on f g x y = g x `f` g y

export
view : List (String, Article) -> Html
view articles =
  let topTags = take 5 $ sortBy (flip compare `on` snd) (tagsFromArticles (map snd articles))
  in div
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
