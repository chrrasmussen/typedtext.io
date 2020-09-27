module Typedtext.Article.Id

import Data.List

%default total


export
data ArticleId = MkArticleId Integer

export
Show ArticleId where
  show (MkArticleId id) = cast id

export
Eq ArticleId where
  MkArticleId id1 == MkArticleId id2 = id1 == id2

export
Ord ArticleId where
  compare (MkArticleId id1) (MkArticleId id2) = compare id1 id2

export
filenameToArticleId : (filename : String) -> ArticleId
filenameToArticleId filename = MkArticleId $ cast $ pack $ take 3 $ drop 1 $ unpack filename

export
articleIdToFilename : (files : List String) -> Integer -> Maybe String
articleIdToFilename files id =
  find ((\(MkArticleId fileId) => fileId == id) . filenameToArticleId) files
