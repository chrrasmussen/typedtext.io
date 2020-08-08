module Typedtext.Router

import Erlang
import Elixir.Router
import Typedtext.Blog

%default total
%cg erlang export exports


routes : List Route
routes =
  [ get "/" index
  , get "/post" viewPost
  ]


exports : ErlExport
exports =
  exportRouter routes
