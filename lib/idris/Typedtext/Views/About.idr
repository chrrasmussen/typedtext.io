module Typedtext.Views.About

import Html
import Elixir.Markdown
import Typedtext.Views.Helpers.ContentBox

%default total

content : String
content = "
## Blog content

On this blog I will mainly write about:

- Progress on [Idris2-Erlang](https://github.com/chrrasmussen/Idris2-Erlang) and [related projects](https://github.com/chrrasmussen?tab=repositories)
- Things I learn/experiments in Idris 2


## About me

I am a developer that like to build web {sites,apps,services} and iOS apps. In 2014 I started to get into functional programming, learning languages like Erlang/Elixir, Elm, Haskell and Idris. These days I focus my learning on Idris 2, and trying to make Idris 2 into a viable option for web development.

More information:

- [GitHub profile](https://github.com/chrrasmussen)
- [Personal website](http://christian.rasmussen.io)
"

viewContent : Html
viewContent =
  let Just html = markdownToHtml content
    | Nothing => text "Unable to parse text as Markdown"
  in unsafeRaw html

export
view : Html
view =
  ContentBox.view viewContent
