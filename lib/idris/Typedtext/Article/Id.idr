module Typedtext.Article.Id

import Data.List

%default total


export
data ArticleId = MkArticleId Integer

export
Show ArticleId where
  show (MkArticleId id) = cast id

export
filenameToArticleId : (filename : String) -> ArticleId
filenameToArticleId filename = MkArticleId $ cast $ pack $ take 3 $ drop 1 $ unpack filename

export
articleIdToFilename : (files : List String) -> Integer -> Maybe String
articleIdToFilename files id =
  find ((\(MkArticleId fileId) => fileId == id) . filenameToArticleId) files
