module Typedtext.Views.Helpers.Tags

import Html
import Typedtext.Tags
import Typedtext.Views.Helpers.ContentBox

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
    , style "font-size" "13px"
    , style "text-align" "center"
    ]
    [ text (cast count)
    ]

export
viewTag : (String, Integer) -> Html
viewTag (tag, count) =
  li
    []
    [ a
        [ href ("/posts?tag=" ++ tag) ]
        [ text tag ]
    , span
        [ style "margin-left" "8px" ]
        [ viewBadge count ]
    ]

export
view : List (String, Integer) -> Html
view tags =
  ContentBox.view
    (div
      [ className "tags"
      ]
      [ h1 [] [ text "All tags" ]
      , ul
          [ style "line-height" "24px"
          ]
          (map viewTag tags)
      ]
    )
