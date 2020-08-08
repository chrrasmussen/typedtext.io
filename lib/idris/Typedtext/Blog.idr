module Typedtext.Blog

import Erlang
import Elixir.Markdown
import Elixir.Plug.Conn
import Html
import Typedtext.Pages.Layout
import Typedtext.Pages.ListPosts
import Typedtext.Pages.ShowPost


%default total


export
index : Conn -> IO Conn
index conn = do
  let html = Layout.view ListPosts.view
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  Just conn <- sendResp 200 (render html) conn
    | Nothing => pure conn
  pure conn

export
viewPost : Conn -> IO Conn
viewPost conn = do
  let html = Layout.view ShowPost.view
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  Just conn <- sendResp 200 (render html) conn
    | Nothing => pure conn
  pure conn
