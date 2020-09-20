module Typedtext.Views.Helpers.Article

import Data.List
import Html
import Typedtext.Article
import Typedtext.Views.Helpers.Tags

%default total


subject : String -> String
subject title =
  "[typedtext.io] " ++ title

viewAuthor : (name : String) -> (email : String) -> (articleTitle : String) -> Html
viewAuthor name email articleTitle =
  a
    [ href ("mailto:" ++ email ++ "?subject=" ++ subject articleTitle) ]
    [ text name ]

viewTag : String -> Html
viewTag tag =
  a
    [ href ("/posts?tag=" ++ tag) ]
    [ text tag ]

export
viewFooter : Article ->Html
viewFooter article =
  div
    []
    [ hr [] []
    , div
        [ className "article-footer"
        ]
        [ div
            []
            [ text "Author: "
            , viewAuthor article.authorName article.authorEmail article.title
            ]
        , div
            []
            (text "Tags: " :: intersperse (text ", ") (map viewTag article.tags))
        ]
    ]
