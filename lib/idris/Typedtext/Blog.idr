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

getArticle : (path : String) -> IO (Maybe Article)
getArticle path = do
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
      sendResp' 500 (render html) conn
  articles <- traverse (getArticle . (postsDir </>)) files
  let articles' = mapMaybe id (reverse articles)
  let html = Layout.view (ListArticles.view articles')
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  sendResp' 200 (render html) conn

export
viewArticle : Conn -> IO Conn
viewArticle conn = do
  Just post <- getArticle (postsDir </> "A001_HelloWorld.lidr")
    | Nothing => do
      let html = text "Failed to read file"
      sendResp' 500 (render html) conn
  let html = Layout.view (ShowArticle.view post)
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  sendResp' 200 (render html) conn

export
viewAbout : Conn -> IO Conn
viewAbout conn = do
  let html = Layout.view About.view
  let Just conn = putRespHeader "Content-Type" "text/html; charset=UTF-8" conn
    | Nothing => pure conn
  sendResp' 200 (render html) conn
