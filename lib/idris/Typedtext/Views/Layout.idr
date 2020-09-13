module Typedtext.Views.Layout

import Html

%default total


-- STYLES

menuBarHeight : Integer
menuBarHeight = 60

contentWidth : Integer
contentWidth = 800

headerBackgroundColor : String
headerBackgroundColor = "#4A4A4A"

menuBarActiveColor : String
menuBarActiveColor = "white"

footerTextColor : String
footerTextColor = "#888888"


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
        , style "padding" "0 15px"
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
    , style "box-shadow" "rgba(0, 0, 0, 0.1) 0px 8px 16px 0px"
    ]
    [ div
        [ style "width" (cast contentWidth ++ "px")
        , style "margin" "0 auto"
        , style "display" "flex"
        , style "justify-content" "space-between"
        ]
        [ div
            []
            [ h1
              [ style "display" "none" ]
              [ text "typedtext.io" ]
            , a
                [ href "/"
                ]
                [ img
                    [ src "images/logo.png"
                    , alt "Logo for typedtext.io"
                    , style "width" "190px"
                    , style "height" "60px"
                    ]
                    []
                ]
            ]
        , div
            [ style "background-color" "green" ]
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
      , style "margin-top" "30px"
      , style "margin-bottom" "15px"
      , style "text-align" "center"
      , style "color" footerTextColor
      , style "font-size" "12px"
      ]
      [ line1
      , line2
      , line3
      ]


export
view : SelectedPage -> Html -> Html
view selectedPage content =
  let pagePadding = 15
  in html
    [ style "background-color" "#EEEEEE"
    ]
    [ head
        []
        [ title [] [ text "typedtext.io" ]
        ]
        , link
            [ href "css/app.css"
            , rel "stylesheet"
            ]
            []
    , body
        [ style "margin" "0"
        , style "font-family" "-apple-system, system-ui, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif"
        , style "font-size" "16px"
        , style "line-height" "1.2em"
        ]
        [ header selectedPage
        , div
            [ style "width" (cast (contentWidth + pagePadding * 2) ++ "px")
            , style "margin" "30px auto 0 auto"
            ]
            [ div
                [ style "padding" ("0 " ++ cast pagePadding ++ "px")
                ]
                [ content ]
            ]
        , footer
        ]
    ]
