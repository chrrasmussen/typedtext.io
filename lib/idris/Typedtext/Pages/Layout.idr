module Typedtext.Pages.Layout

import Html

%default total


export
view : Html -> Html
view content =
  div
    [ ("style", "background-color: gray")
    ]
    [ h1 [] [text "typedtext.io"]
    , content
    ]
