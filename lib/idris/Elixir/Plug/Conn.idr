module Elixir.Plug.Conn

import Erlang

%default total


public export
Conn : Type
Conn =
  ErlMapSubset
    [ MkAtom "scheme" := ErlAtom
    , MkAtom "host" := String
    , MkAtom "port" := Int
    , MkAtom "method" := String
    , MkAtom "request_path" := String
    , MkAtom "query_params" := ErlAnyMap
    , MkAtom "req_headers" := List (ErlTuple2 String String)
    ]

public export
data Scheme = Http | Https | OtherScheme String

public export
data Method = Get | Post | OtherMethod String -- TODO: Add more methods


-- IMPLEMENTATIONS

export
Eq Scheme where
  Http == Http = True
  Https == Https = True
  OtherScheme x == OtherScheme y = x == y
  _ == _ = False

export
Eq Method where
  Get == Get = True
  Post == Post = True
  OtherMethod x == OtherMethod y = x == y
  _ == _ = False


-- REQUEST

atomToString : ErlAtom -> String
atomToString (MkAtom x) = x

export
getReqScheme : Conn -> Scheme
getReqScheme conn =
  let scheme = get (MkAtom "scheme") conn
  in erlDecodeDef
    (OtherScheme (atomToString scheme))
    (exact (MkAtom "http") *> pure Http
      <|> exact (MkAtom "https") *> pure Https)
    scheme

export
getReqHost : Conn -> String
getReqHost conn = get (MkAtom "host") conn

export
getReqPort : Conn -> Int
getReqPort conn = get (MkAtom "port") conn

export
getReqMethod : Conn -> Method
getReqMethod conn =
  let method = get (MkAtom "method") conn
  in erlDecodeDef
    (OtherMethod method)
    (exact "GET" *> pure Get
      <|> exact "POST" *> pure Post)
    method

export
getReqPath : Conn -> String
getReqPath conn = get (MkAtom "request_path") conn

export
getReqQueryParam : (key : String) -> Conn -> Maybe String
getReqQueryParam key conn = do
  let queryParams = get (MkAtom "query_params") conn
  lookup key string queryParams

export
getReqHeader : (key : String) -> Conn -> List String
getReqHeader key conn =
  erlUnsafeCall (List String) "Elixir.Plug.Conn" "get_req_header" [conn, key]


-- RESPONSE

export
putRespHeader : (key : String) -> (value : String) -> Conn -> Maybe Conn
putRespHeader key value conn = unsafePerformIO $ do
  -- Fails if response is already sent
  Right conn <- erlCall "Elixir.Plug.Conn" "put_resp_header" [conn, key, value]
    | Left _ => pure Nothing
  pure $ Just (erlUnsafeCast Conn conn)

export
sendResp : Int -> String -> Conn -> IO (Maybe Conn)
sendResp status content conn = do
  -- Fails if response is already sent
  Right conn <- erlCall "Elixir.Plug.Conn" "send_resp" [conn, status, content]
    | Left _ => pure Nothing
  pure $ Just (erlUnsafeCast Conn conn)
