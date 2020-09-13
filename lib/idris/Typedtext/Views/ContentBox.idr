module Typedtext.Views.ContentBox

import Html

%default total


export
view : Html -> Html
view content =
  div
    [ style "background-color" "white"
    , style "padding" "1px" -- Prevent margins from collapsing
    , style "border-radius" "16px"
    , style "box-shadow" "rgba(0, 0, 0, 0.1) 0px 8px 16px 0px"
    ]
    [ div
        [ style "margin" "15px" ]
        [ content ]
    ]
