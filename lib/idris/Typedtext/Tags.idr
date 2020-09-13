module Typedtext.Tags

import Data.SortedMap
import Typedtext.Article

%default total


countElements : Ord a => List a -> List (a, Integer)
countElements xs = toList $ foldl (mergeWith (+)) empty (map (\key => singleton key 1) xs)

export
tagsFromArticles : List Article -> List (String, Integer)
tagsFromArticles articles = countElements (concatMap (.tags) articles)
