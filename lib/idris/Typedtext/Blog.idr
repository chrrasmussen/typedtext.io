module Typedtext.Blog

import Erlang
import Elixir.Markdown
import Elixir.Plug.Conn
import Html
import Typedtext.Pages.Layout
import Typedtext.Pages.ListArticles
import Typedtext.Pages.ShowArticle


%default total


export
index : Conn -> IO Conn
index conn = do
  let html = Layout.view ListArticles.view
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  Just conn <- sendResp 200 (render html) conn
    | Nothing => pure conn
  pure conn

export
viewArticle : Conn -> IO Conn
viewArticle conn = do
  let html = Layout.view ShowArticle.view
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  Just conn <- sendResp 200 (render html) conn
    | Nothing => pure conn
  pure conn
