module Typedtext.Views.ShowArticle

import Data.List
import Html
import Elixir.Markdown
import Typedtext.Article
import Typedtext.Views.ContentBox

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
view : Article -> Html
view article =
  let Just htmlString = markdownToHtml article.body
    | Nothing => text "Unable to parse text as Markdown"
  in
    ContentBox.view
      (div
        []
        [ span
            [ style "float" "right"
            , style "color" "#888888"
            ]
            [ text article.publishDate ]
        , h1 [] [text article.title]
        , unsafeRaw $ htmlString
        , hr [] []
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
      )
