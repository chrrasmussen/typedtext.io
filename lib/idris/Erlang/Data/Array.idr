module Erlang.Data.Array

import Erlang


export
data ErlArray : Type -> Type where
  MkArray : (size : Int) -> ErlTerm -> ErlArray a


export
new : Int -> ErlArray a
new size =
  let arrData = erlUnsafeCall ErlTerm "array" "new" [size, MkTuple2 (MkAtom "default") (MkRaw Nothing)]
  in MkArray size arrData

export
size : ErlArray a -> Int
size (MkArray s _) = s

export
get : Int -> ErlArray a -> Maybe a
get idx (MkArray s arrData) =
  let MkRaw val = erlUnsafeCall (Raw (Maybe a)) "array" "get" [idx, arrData]
  in val

export
getRange : (start : Int) -> (length : Int) -> ErlArray a -> List (Maybe a)
getRange start length array = go (integerToNat (cast length)) start
  where
    go : Nat -> (idx : Int) -> List (Maybe a)
    go Z     idx = []
    go (S k) idx = get idx array :: go k (idx + 1)
    
export
set : Int -> a -> ErlArray a -> ErlArray a
set idx value (MkArray s arrData) =
  let newArrData = erlUnsafeCall ErlTerm "array" "set" [idx, MkRaw (Just value), arrData]
  in MkArray s newArrData

export
reset : Int -> ErlArray a -> ErlArray a
reset idx (MkArray s arrData) =
  let newArrData = erlUnsafeCall ErlTerm "array" "reset" [idx, arrData]
  in MkArray s newArrData

export
fromList : List (Maybe a) -> ErlArray a
fromList xs =
  fst $ foldl step (new (cast (length xs)), 0) xs
  where
    step : (ErlArray a, Int) -> Maybe a -> (ErlArray a, Int)
    step (array, idx) Nothing    = (            array, idx + 1)
    step (array, idx) (Just val) = (set idx val array, idx + 1)
    
export
toList : ErlArray a -> List (Maybe a)
toList (MkArray s arrData) =
  let MkRaw xs = erlUnsafeCall (Raw (List (Maybe a))) "array" "to_list" [arrData]
  in xs

export
Show a => Show (ErlArray a) where
  show array = "fromList " ++ show (toList array)
