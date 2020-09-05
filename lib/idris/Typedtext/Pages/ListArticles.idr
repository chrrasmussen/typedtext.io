module Typedtext.Pages.ListArticles

import Html
import Typedtext.Article

%default total


export
view : List Article -> Html
view articles =
  div
    []
    ([ h1 [] [text "Posts"] ] ++ map (\p => div [] [text p.title]) articles)
