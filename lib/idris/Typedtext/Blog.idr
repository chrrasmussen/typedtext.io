module Typedtext.Blog

import Data.Either
import Data.List
import Data.Maybe
import System.Path
import Erlang
import Erlang.System.Directory
import Elixir.Markdown
import Elixir.Plug.Conn
import Html
import Typedtext.Article
import Typedtext.Views.Layout
import Typedtext.Views.ListArticles
import Typedtext.Views.ShowArticle
import Typedtext.Views.About


%default total

postsDir : String
postsDir = "lib/idris/Typedtext/Articles"

readArticle : (path : String) -> IO (Maybe Article)
readArticle path = do
  Right contents <- readFile path
    | Left _ => pure Nothing
  let Right post = parseArticle contents
    | Left _ => pure Nothing
  pure $ Just post

sendResp' : Int -> String -> Conn -> IO Conn
sendResp' status content conn = do
  Just conn <- sendResp status content conn
    | Nothing => pure conn
  pure conn

sendHtml : Int -> Html -> Conn -> IO Conn
sendHtml status html conn = do
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  sendResp' status (render html) conn


-- HANDLERS

export
index : Conn -> IO Conn
index conn = do
  let Just conn = putRespHeader "Location" "/posts" conn
    | Nothing => pure conn
  sendResp' 302 "" conn

export
viewPosts : Conn -> IO Conn
viewPosts conn = do
  Right files <- dirEntries postsDir
    | Left _ => do
      let html = text "Failed to read directory"
      sendHtml 500 html conn
  articles <- traverse getArticle files
  let articles' = reverse (mapMaybe id articles)
  let html = Layout.view Posts (ListArticles.view articles')
  sendHtml 200 html conn
  where
    getArticle : (file : String) -> IO (Maybe (String, Article))
    getArticle file = do
      let path = postsDir </> file
      Just article <- readArticle path
        | Nothing => pure Nothing
      pure $ Just (file, article)

export
viewArticle : Conn -> IO Conn
viewArticle conn = do
  Just post <- readArticle (postsDir </> "A001_HelloWorld.lidr")
    | Nothing => do
      let html = text "Failed to read file"
      sendHtml 500 html conn
  let html = Layout.view Posts (ShowArticle.view post)
  sendHtml 200 html conn

export
viewAbout : Conn -> IO Conn
viewAbout conn = do
  let html = Layout.view About About.view
  sendHtml 200 html conn
