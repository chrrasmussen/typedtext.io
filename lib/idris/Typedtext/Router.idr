module Typedtext.Router

import Erlang
import Elixir.Router
import Typedtext.Blog

%default total
%cg erlang export exports


routes : List Route
routes =
  [ get "/" index
  , get "/posts" viewPosts
  , get "/posts/view" viewArticle
  , get "/about" viewAbout
  ]


exports : ErlExport
exports =
  exportRouter routes
