module Utils.Function

%default total


-- TODO: Unexported version exists in `Data.Either`. Move and export?
export
on : (b -> b -> c) -> (a -> b) -> a -> a -> c
on f g x y = g x `f` g y
