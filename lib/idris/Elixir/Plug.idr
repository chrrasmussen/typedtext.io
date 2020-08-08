module Elixir.Plug

import Erlang
import public Elixir.Plug.Conn

%default total


public export
record Plug where
  constructor MkPlug
  init : ErlTerm -> IO a
  call : a -> Conn -> IO Conn

export %inline
exportPlug : Plug -> ErlExport
exportPlug (MkPlug {a} init call) =
  Fun "init" (MkIOFun1 initFun)
    <+> Fun "call" (MkIOFun2 callFun)
  where
    initFun : ErlTerm -> IO ErlTerm
    initFun plugOpts = do
      opts <- init plugOpts
      pure (cast (MkRaw opts))
    callFun : Conn -> ErlTerm -> IO Conn
    callFun conn initOpts = do
      let MkRaw opts = erlUnsafeCast (Raw a) initOpts
      call opts conn
