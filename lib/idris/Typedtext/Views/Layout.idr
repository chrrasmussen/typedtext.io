module Typedtext.Views.Layout

import Html

%default total


-- STYLES

menuBarHeight : Integer
menuBarHeight = 70

contentWidth : Integer
contentWidth = 800

headerBackgroundColor : String
headerBackgroundColor = "#4A4A4A"

menuBarActiveColor : String
menuBarActiveColor = "white"

footerTextColor : String
footerTextColor = "#666677"


-- VIEW

public export
data SelectedPage
  = Posts
  | Tags
  | About

export
Eq SelectedPage where
  Posts == Posts = True
  Tags == Tags = True
  About == About = True
  _ == _ = False

menuButton : (isActive : Bool) -> (url : String) -> (title : String) -> Html
menuButton isActive url title =
  let
    backgroundColor = if isActive then menuBarActiveColor else headerBackgroundColor
    textColor = if isActive then headerBackgroundColor else menuBarActiveColor
  in div
    [ style "display" "inline-block"
    ]
    [ a
        [ href url
        , style "display" "inline-block"
        , style "line-height" (cast menuBarHeight ++ "px")
        , style "background-color" backgroundColor
        , style "color" textColor
        , style "padding" "0 16px"
        , style "font-size" "18px"
        ]
        [ text title ]
    ]

header : SelectedPage -> Html
header selectedPage =
  div
    [ className "header"
    , style "background-color" headerBackgroundColor
    , style "height" (cast menuBarHeight ++ "px")
    , style "box-shadow" "rgba(0, 0, 0, 0.05) 0px 8px 16px 0px"
    ]
    [ div
        [ style "max-width" (cast contentWidth ++ "px")
        , style "margin" "0 auto"
        , style "padding" "0 10px"
        , style "display" "flex"
        , style "justify-content" "space-between"
        , style "align-items" "center"
        ]
        [ div
            []
            [ h1
              [ style "display" "none" ]
              [ text "typedtext.io" ]
            , a
                [ href "/"
                , style "display" "block"
                ]
                [ img
                    [ src "/images/typedtext-logo.svg"
                    , alt "Logo for typedtext.io"
                    , className "logo-image"
                    ]
                    []
                    , img
                         [ src "/images/typedtext-title.svg"
                         , alt "Title for typedtext.io"
                         , className "logo-text"
                         ]
                         []
                ]
            ]
        , div
            [ style "background-color" "transparent" ]
            [ menuButton (selectedPage == Posts) "/posts" "Posts"
            , menuButton (selectedPage == Tags) "/tags" "Tags"
            , menuButton (selectedPage == About) "/about" "About"
            ]
        ]
    ]

footer : Html
footer =
  let
    line1 =
      div
        []
        [ a
            [ href "https://github.com/chrrasmussen/typedtext.io" ]
            [ text "Website" ]
        , text " written in "
        , a
            [ href "https://www.idris-lang.org" ]
            [ text "Idris 2" ]
        , text "."
        ]
    line2 =
      div
        []
        [ text "Generated to "
        , a
            [ href "https://www.erlang.org" ]
            [ text "Erlang" ]
        , text " using "
        , a
            [ href "https://github.com/chrrasmussen/Idris2-Erlang" ]
            [ text "Idris2-Erlang" ]
        , text "."
        ]
    line3 =
      div
        []
        [ text "Built on top of "
        , a
            [ href "https://www.phoenixframework.org" ]
            [ text "Phoenix Framework" ]
        , text "."
        ]
  in div
      [ className "footer"
      , style "margin-top" "32px"
      , style "margin-bottom" "16px"
      , style "text-align" "center"
      , style "color" footerTextColor
      , style "font-size" "13px"
      ]
      [ line1
      , line2
      , line3
      ]


export
view : (title : String) -> SelectedPage -> Html -> Html
view titleStr selectedPage content =
  let pagePadding = 8
  in html
    [ style "background-color" "#F2F2F2"
    ]
    [ head
        []
        [ title [] [ text (titleStr ++ " — typedtext.io") ]
        , meta
            [ attr "lang" "en"
            ]
            []
        , meta
            [ name "author"
            , attr "content" "Christian Rasmussen"
            ]
            []
        , meta
            [ name "description"
            , attr "content" "Technology blog by Christian Rasmussen"
            ]
            []
        , meta
            [ name "viewport"
            , attr "content" "width=device-width, initial-scale=1.0"
            ]
            []
        , link
            [ rel "shortcut icon"
            , href "/favicon.png"
            , type "image/x-icon"
            ]
            []
        ]
        , link
            [ href "/css/app.css"
            , rel "stylesheet"
            ]
            []
        , link
            [ href "/css/highlight-github.css"
            , rel "stylesheet"
            ]
            []
        , script
            [ boolAttr "async" True
            , boolAttr "defer" True
            , attr "data-domain" "typedtext.io"
            , src "https://plausible.io/js/plausible.js"
            ]
            []
        , script
            [ boolAttr "defer" True
            , src "/js/highlight.pack.js"
            ]
            []
        , script
            [ boolAttr "defer" True
            , src "/js/highlight-idris.js"
            ]
            []
        , script
            [ boolAttr "defer" True
            , src "/js/app.js"
            ]
            []
    , body
        [ style "margin" "0"
        , style "font-family" "-apple-system, system-ui, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif"
        , style "font-size" "16px"
        ]
        [ header selectedPage
        , div
            [ style "max-width" (cast (contentWidth + pagePadding * 2) ++ "px")
            , style "margin" "32px auto 0 auto"
            ]
            [ div
                [ style "padding" ("0 " ++ cast pagePadding ++ "px")
                ]
                [ content ]
            ]
        , footer
        ]
    ]
