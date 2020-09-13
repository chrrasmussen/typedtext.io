module Typedtext.Views.About

import Html
import Typedtext.Views.ContentBox

%default total


export
view : Html
view =
  ContentBox.view
    (div
      []
      [ text "This blog is authored by "
      , a
          [ href "https://github.com/chrrasmussen" ]
          [ text "Christian Rasmussen" ]
      , text "."
      ]
    )
