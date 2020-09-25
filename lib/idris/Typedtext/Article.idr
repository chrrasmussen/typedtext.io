module Typedtext.Article

import Control.Monad.Identity
import Data.List
import Data.List1
import Data.Strings
import Erlang.Data.String.Parser


public export
record Article where
  constructor MkArticle
  authorName : String
  authorEmail : String
  publishDate : String
  tags : List String
  title : String
  intro : String
  body : Maybe String

export
Show Article where
  show p =
    unwords ["MkArticle", show p.authorName, show p.authorEmail, show p.publishDate, show p.tags, show p.title, show p.body]


-- HELPER FUNCTIONS

anyChar : Parser Char
anyChar = satisfy (const True)

manyTill : Parser a -> Parser end -> Parser (List a)
manyTill p end =
  do end; pure []
    <|> do x <- p; xs <- manyTill p end; pure (x :: xs)


-- PARSING

comment : Parser a -> Parser a
comment body = do
  string "<!--"
  spaces
  result <- body
  spaces
  string "-->"
  pure result

foldMarker : Parser ()
foldMarker = comment (string "FOLD")

field : Parser (String, String)
field = do
  key <- takeWhile (\t => (not (t `elem` [':', '\n'])))
  spaces
  string ":"
  spaces
  value <- takeWhile (/= '\n')
  pure (key, value)

title : Parser String
title = do
  string "#"
  spaces
  takeWhile (/= '\n')

splitTags : String -> List String
splitTags str =
  filter (/= "") $ forget $ map (trim . pack) $ splitOn ',' (unpack str)

article : Parser Article
article = do
  spaces
  fs <- comment (many (do fs <- field; string "\n"; pure fs))
  spaces
  title' <- title
  spaces
  intro' <- map pack $ manyTill anyChar (foldMarker <|> eos)
  body' <- remaining
  let Just [authorName', authorEmail', publishDate', tags'] = traverse (\f => lookup f fs) ["AUTHOR_NAME", "AUTHOR_EMAIL", "PUBLISH_DATE", "TAGS"]
    | _ => fail (UserError "Could not find all fields")
  pure $ MkArticle authorName' authorEmail' publishDate' (splitTags tags') title' intro' (if body' /= "" then Just body' else Nothing)

export
parseArticle : String -> Either String Article
parseArticle body =
  case parse article body of
    OK article _ => Right article
    Fail err => Left (show err)
