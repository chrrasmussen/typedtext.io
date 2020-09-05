module Typedtext.Router

import Erlang
import Elixir.Router
import Typedtext.Blog

%default total
%cg erlang export exports


routes : List Route
routes =
  [ get "/" index
  , get "/article" viewArticle
  ]


exports : ErlExport
exports =
  exportRouter routes
