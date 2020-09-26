module Typedtext.Views.Helpers.ContentBox

import Html

%default total


export
view : Html -> Html
view content =
  div
    [ style "background-color" "white"
    , style "border-radius" "16px"
    , style "padding" "24px"
    ]
    [ content ]
