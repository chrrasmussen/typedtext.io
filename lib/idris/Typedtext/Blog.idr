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
import Utils.Function
import Typedtext.Article
import Typedtext.Article.Id
import Typedtext.Tags
import Typedtext.Views.Layout
import Typedtext.Views.ListArticles
import Typedtext.Views.ShowArticle
import Typedtext.Views.About
import Typedtext.Views.Helpers.Tags

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

getArticleAndId : (file : String) -> IO (Maybe (ArticleId, Article))
getArticleAndId file = do
  let path = postsDir </> file
  Just article <- readArticle path
    | Nothing => pure Nothing
  pure $ Just (filenameToArticleId file, article)

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
  let tag = getReqQueryParam "tag" conn
  Right files <- dirEntries postsDir
    | Left _ => do
      let html = text "Failed to read directory"
      sendHtml 500 html conn
  articles <- traverse getArticleAndId files
  let allArticles = mapMaybe id articles
  let filteredArticles = sortBy (flip compare `on` fst) $ filter (mustIncludeTag tag . snd) allArticles
  let topTags = take 5 $ sortBy (flip compare `on` snd) (tagsFromArticles (map snd allArticles))
  let html = Layout.view "Posts" Posts (ListArticles.view filteredArticles topTags)
  sendHtml 200 html conn
  where
    mustIncludeTag : Maybe String -> Article -> Bool
    mustIncludeTag Nothing _ = True
    mustIncludeTag (Just tag) article = tag `elem` article.tags

export
viewArticle : Conn -> IO Conn
viewArticle conn = do
  let Just id = getReqQueryParam "id" conn
    | Nothing => do
      let html = text "Not found"
      sendHtml 404 html conn
  Right files <- dirEntries postsDir
    | Left _ => do
      let html = text "Failed to read directory"
      sendHtml 500 html conn
  let Just file = articleIdToFilename files (cast id)
    | Nothing => do
      let html = text "Not found"
      sendHtml 404 html conn
  Just article <- readArticle (postsDir </> file)
    | Nothing => do
      let html = text "Failed to read file"
      sendHtml 500 html conn
  let html = Layout.view article.title Posts (ShowArticle.view article)
  sendHtml 200 html conn

export
viewTags : Conn -> IO Conn
viewTags conn = do
  Right files <- dirEntries postsDir
    | Left _ => do
      let html = text "Failed to read directory"
      sendHtml 500 html conn
  articles <- traverse getArticleAndId files
  let articles' = reverse $ mapMaybe id articles
  let tags = sortBy (compare `on` fst) (tagsFromArticles (map snd articles'))
  let html = Layout.view "Tags" Tags (Tags.view tags)
  sendHtml 200 html conn

export
viewAbout : Conn -> IO Conn
viewAbout conn = do
  let html = Layout.view "About" About About.view
  sendHtml 200 html conn
