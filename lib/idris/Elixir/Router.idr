module Elixir.Router

import Data.List
import Erlang
import Elixir.Plug

%default total


public export
Handler : Type
Handler = Conn -> IO Conn

export
data Route : Type where
  MkRoute : Method -> (path : String) -> Handler -> Route


export
get : String -> Handler -> Route
get = MkRoute Get

export
post : String -> Handler -> Route
post = MkRoute Post


-- PLUG BEHAVIOUR

Opts : Type
Opts = ()

init : ErlTerm -> IO Opts
init plugOpts = pure ()

call : List Route -> Opts -> Conn -> IO Conn
call routes initOpts conn = do
  let method = getReqMethod conn
  let path = getReqPath conn
  let Just (MkRoute _ _ handler) = find (\(MkRoute m p _) => m == method && p == path) routes
    | Nothing => do
      Just conn <- sendResp 404 "Not found" conn
        | Nothing => pure conn
      pure conn
  handler conn


export %inline
exportRouter : List Route -> ErlExport
exportRouter routes =
  exportPlug (MkPlug init (call routes))
