||| A simple parser combinator library for strings. Inspired by attoparsec zepto.
module Erlang.Data.String.Parser

import Control.Monad.Identity
import Control.Monad.Trans

import Data.Strings
import Data.Fin
import Data.List
import Erlang.Data.Array

%default total

||| The input state, pos is position in the string and maxPos is the length of the input string.
public export
record State where
    constructor S
    input : ErlArray Char
    pos : Int
    maxPos : Int

Show State where
    show s = "(" ++ show (mapMaybe id (toList s.input)) ++ ", " ++ show s.pos ++ ", " ++ show s.maxPos ++ ")"

||| Result of applying a parser
public export
data Result a = Fail Int String | OK a State

Functor Result where
  map f (Fail i err) = Fail i err
  map f (OK r s)     = OK (f r) s

public export
record ParseT (m : Type -> Type) (a : Type) where
    constructor P
    runParser : State -> m (Result a)

public export
Parser : Type -> Type
Parser = ParseT Identity

public export
Functor m => Functor (ParseT m) where
    map f p = P $ \s => map (map f) (p.runParser s)

public export
Monad m => Applicative (ParseT m) where
    pure x = P $ \s => pure $ OK x s
    f <*> x = P $ \s => case !(f.runParser s) of
                            OK f' s' => map (map f') (x.runParser s')
                            Fail i err => pure $ Fail i err

public export
Monad m => Alternative (ParseT m) where
    empty = P $ \s => pure $ Fail s.pos "no alternative left"
    a <|> b = P $ \s => case !(a.runParser s) of
                            OK r s' => pure $ OK r s'
                            Fail _ _ => b.runParser s

public export
Monad m => Monad (ParseT m) where
    m >>= k = P $ \s => case !(m.runParser s) of
                             OK a s' => (k a).runParser s'
                             Fail i err => pure $ Fail i err

public export
MonadTrans ParseT where
    lift x = P $ \s => map (flip OK s) x

||| Run a parser in a monad
||| Returns a tuple of the result and final position on success.
||| Returns an error message on failure.
export
parseT : Functor m => ParseT m a -> String -> m (Either String (a, Int))
parseT p str =
  let charArray = fromList (map Just (unpack str))
  in map (\case
                       OK r s => Right (r, s.pos)
                       Fail i err => Left $ fastAppend ["Parse failed at position ", show i, ": ", err])
                   (p.runParser (S charArray 0 (strLength str)))

||| Run a parser in a pure function
||| Returns a tuple of the result and final position on success.
||| Returns an error message on failure.
export
parse : Parser a -> String -> Either String (a, Int)
parse p str = runIdentity $ parseT p str

||| Combinator that replaces the error message on failure.
||| This allows combinators to output relevant errors
export
(<?>) : Functor m => ParseT m a -> String -> ParseT m a
(<?>) p msg = P $ \s => map (\case
                                OK r s' => OK r s'
                                Fail i _ => Fail i msg)
                            (p.runParser s)

infixl 0 <?>

||| Discards the result of a parser
export
skip : Functor m => ParseT m a -> ParseT m ()
skip = ignore

||| Maps the result of the parser `p` or returns `def` if it fails.
export
optionMap : Functor m => b -> (a -> b) -> ParseT m a -> ParseT m b
optionMap def f p = P $ \s => map (\case
                                     OK r s'  => OK (f r) s'
                                     Fail _ _ => OK def s)
                                  (p.runParser s)

||| Runs the result of the parser `p` or returns `def` if it fails.
export
option : Functor m => a -> ParseT m a -> ParseT m a
option def = optionMap def id

||| Returns a Bool indicating whether `p` succeeded
export
succeeds : Functor m => ParseT m a -> ParseT m Bool
succeeds = optionMap False (const True)

||| Returns a Maybe that contains the result of `p` if it succeeds or `Nothing` if it fails.
export
optional : Functor m => ParseT m a -> ParseT m (Maybe a)
optional = optionMap Nothing Just

||| Fail with some error message
export
fail : Applicative m => String -> ParseT m a
fail x = P $ \s => pure $ Fail s.pos x

||| Succeeds if the next char satisfies the predicate `f`
export
satisfy : Applicative m => (Char -> Bool) -> ParseT m Char
satisfy f = P $ \s => pure $ if s.pos < s.maxPos
                                  then let Just ch = assert_total $ get s.pos s.input
                                             | Nothing => Fail s.pos "satisfy"
                                       in if f ch
                                           then OK ch (S s.input (s.pos + 1) s.maxPos)
                                           else Fail s.pos "satisfy"
                                  else Fail s.pos "satisfy"

||| Succeeds if the string `str` follows.
export
string : Applicative m => String -> ParseT m ()
string str = P $ \s => pure $ let len = strLength str in
                              if s.pos+len <= s.maxPos
                                  then let head = pack $ mapMaybe id (getRange s.pos len s.input) in
                                       if head == str
                                         then OK () (S s.input (s.pos + len) s.maxPos)
                                         else Fail s.pos ("string " ++ show str)
                                  else Fail s.pos ("string " ++ show str)

||| Succeeds if the end of the string is reached.
export
eos : Applicative m => ParseT m ()
eos = P $ \s => pure $ if s.pos == s.maxPos
                           then OK () s
                           else Fail s.pos "expected the end of the string"

||| Succeeds if the next char is `c`
export
char : Applicative m => Char -> ParseT m ()
char c = skip $ satisfy (== c)

||| Parses a space character
export
space : Applicative m => ParseT m Char
space = satisfy isSpace

mutual
    ||| Succeeds if `p` succeeds, will continue to match `p` until it fails
    ||| and accumulate the results in a list
    export
    covering
    some : Monad m => ParseT m a -> ParseT m (List a)
    some p = [| p :: many p |]

    ||| Always succeeds, will accumulate the results of `p` in a list until it fails.
    export
    covering
    many : Monad m => ParseT m a -> ParseT m (List a)
    many p = some p <|> pure []

||| Parse left-nested lists of the form `((init op arg) op arg) op arg`
export
covering
hchainl : Monad m => ParseT m init -> ParseT m (init -> arg -> init) -> ParseT m arg -> ParseT m init
hchainl pini pop parg = pini >>= go
  where
  covering
  go : init -> ParseT m init
  go x = (do op <- pop
             arg <- parg
             go $ op x arg) <|> pure x

||| Parse right-nested lists of the form `arg op (arg op (arg op end))`
export
covering
hchainr : Monad m => ParseT m arg -> ParseT m (arg -> end -> end) -> ParseT m end -> ParseT m end
hchainr parg pop pend = go id <*> pend
  where
  covering
  go : (end -> end) -> ParseT m (end -> end)
  go f = (do arg <- parg
             op <- pop
             go $ f . op arg) <|> pure f

||| Always succeeds, applies the predicate `f` on chars until it fails and creates a string
||| from the results.
export
covering
takeWhile : Monad m => (Char -> Bool) -> ParseT m String
takeWhile f = pack <$> many (satisfy f)

||| Parses one or more space characters
export
covering
spaces : Monad m => ParseT m ()
spaces = skip (many space) <?> "white space"

||| Discards brackets around a matching parser
export
parens : Monad m => ParseT m a -> ParseT m a
parens p = char '(' *> p <* char ')'

||| Discards whitespace after a matching parser
export
covering
lexeme : Monad m => ParseT m a -> ParseT m a
lexeme p = p <* spaces

||| Matches a specific string, then skips following whitespace
export
covering
token : Monad m => String -> ParseT m ()
token s = lexeme (skip $ string s) <?> "token " ++ show s

||| Matches a single digit
export
digit : Monad m => ParseT m (Fin 10)
digit = do x <- satisfy isDigit
           case lookup x digits of
                Nothing => fail "not a digit"
                Just y => pure y
  where
    digits : List (Char, Fin 10)
    digits = [ ('0', 0)
             , ('1', 1)
             , ('2', 2)
             , ('3', 3)
             , ('4', 4)
             , ('5', 5)
             , ('6', 6)
             , ('7', 7)
             , ('8', 8)
             , ('9', 9)
             ]

fromDigits : Num a => ((Fin 10) -> a) -> List (Fin 10) -> a
fromDigits f xs = foldl addDigit 0 xs
where
  addDigit : a -> (Fin 10) -> a
  addDigit num d = 10*num + (f d)

intFromDigits : List (Fin 10) -> Integer
intFromDigits = fromDigits finToInteger

natFromDigits : List (Fin 10) -> Nat
natFromDigits = fromDigits finToNat

||| Matches a natural number
export
covering
natural : Monad m => ParseT m Nat
natural = natFromDigits <$> some digit

||| Matches an integer, eg. "12", "-4"
export
covering
integer : Monad m => ParseT m Integer
integer = do minus <- succeeds (char '-')
             x <- some digit
             pure $ if minus then (intFromDigits x)*(-1) else intFromDigits x
