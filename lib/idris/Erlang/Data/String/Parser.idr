||| A simple parser combinator library for strings. Inspired by attoparsec zepto.
module Erlang.Data.String.Parser

import Control.Monad.Identity
import Control.Monad.Trans

import Data.Fin
import Data.List
import Erlang

%default total


public export
data ParseError
  = NoAlternativeLeft
  | NoCharactersLeft
  | SatisfyFailed
  | ExpectedString String
  | ExpectedToken String
  | ExpectedWhitespace
  | ExpectedDigit
  | ExpectedEndOfString
  | UserError String

export
Show ParseError where
  show NoAlternativeLeft = "No alternative left"
  show NoCharactersLeft = "No characters left"
  show SatisfyFailed = "Satisfy failed"
  show (ExpectedString x) = "Expected string: " ++ x
  show (ExpectedToken x) = "Expected token: " ++ x
  show ExpectedWhitespace = "Expected whitespace"
  show ExpectedDigit = "Expected digit"
  show ExpectedEndOfString = "Expected end of string"
  show (UserError x) = "User error: " ++ x

public export
data Result a = Fail ParseError | OK a String

export
Functor Result where
  map f (Fail err) = Fail err
  map f (OK val s) = OK (f val) s

export
record ParseT m a where
  constructor P
  runParser : String -> m (Result a)

||| Run a parser in a monad
||| Returns an error message on failure.
export
parseT : ParseT m a -> String -> m (Result a)
parseT (P runParser) inp = runParser inp

public export
Parser : Type -> Type
Parser = ParseT Identity

||| Run a parser in a pure function
||| Returns an error message on failure.
export
parse : Parser a -> String -> Result a
parse (P runParser) inp = runIdentity (runParser inp)

public export
Functor m => Functor (ParseT m) where
    map f p = P $ \s => map (map f) (p.runParser s)

public export
Monad m => Applicative (ParseT m) where
    pure x = P $ \s => pure $ OK x s
    f <*> x = P $ \s => case !(f.runParser s) of
                            OK f' s' => map (map f') (x.runParser s')
                            Fail err => pure $ Fail err

public export
Monad m => Alternative (ParseT m) where
    empty = P $ \s => pure $ Fail NoAlternativeLeft
    a <|> b = P $ \s => case !(a.runParser s) of
                            OK r s' => pure $ OK r s'
                            Fail _ => b.runParser s

public export
Monad m => Monad (ParseT m) where
    m >>= k = P $ \s => case !(m.runParser s) of
                             OK a s' => (k a).runParser s'
                             Fail err => pure $ Fail err

public export
MonadTrans ParseT where
    lift x = P $ \s => map (flip OK s) x

infixl 0 <?>

||| Combinator that replaces the error message on failure.
||| This allows combinators to output relevant errors
export
(<?>) : Functor m => ParseT m a -> ParseError -> ParseT m a
(<?>) p err = P $ \s => map (\case
                                OK r s' => OK r s'
                                Fail _ => Fail err)
                            (p.runParser s)



||| Discards the result of a parser
export
skip : Functor m => ParseT m a -> ParseT m ()
skip = ignore

||| Maps the result of the parser `p` or returns `def` if it fails.
export
optionMap : Functor m => b -> (a -> b) -> ParseT m a -> ParseT m b
optionMap def f p = P $ \s => map (\case
                                     OK r s'  => OK (f r) s'
                                     Fail _ => OK def s)
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
fail : Applicative m => ParseError -> ParseT m a
fail err = P $ \s => pure $ Fail err

satisfyResult : String -> (Char -> Bool) -> Result Char
satisfyResult s f =
  let Just (char, rest) = strUncons s
        | Nothing => Fail NoCharactersLeft
  in if f char
    then OK char rest
    else Fail SatisfyFailed

||| Succeeds if the next char satisfies the predicate `f`
export
satisfy : Applicative m => (Char -> Bool) -> ParseT m Char
satisfy f = P $ \s => pure $ do
  let Just (char, rest) = strUncons s
        | Nothing => Fail NoCharactersLeft
  if f char
    then OK char rest
    else Fail SatisfyFailed

-- TODO: This is the only function that is specific to Erlang. It could
-- be defined as a primitive.
splitAt : Integer -> String -> (String, String)
splitAt pos str =
  let h = erlUnsafeCall String "string" "slice" [str, the Integer 0, pos]
      t = erlUnsafeCall String "string" "slice" [str, pos]
  in (h, t)

||| Succeeds if the string `str` follows.
export
string : Applicative m => String -> ParseT m ()
string str = P $ \s => pure
  let (h, t) = splitAt (natToInteger (length str)) s
  in if h == str
    then OK () t
    else Fail (ExpectedString str)

||| Succeeds with the remaining string
export
remaining : Applicative m => ParseT m String
remaining = P $ \s => pure $ OK s ""

||| Succeeds if the end of the string is reached.
export
eos : Applicative m => ParseT m ()
eos = P $ \s => pure $ if s == ""
                           then OK () s
                           else Fail ExpectedEndOfString

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
spaces = skip (many space) <?> ExpectedWhitespace

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
token s = lexeme (skip $ string s) <?> ExpectedToken s

||| Matches a single digit
export
digit : Monad m => ParseT m (Fin 10)
digit = do x <- satisfy isDigit
           case lookup x digits of
                Nothing => fail ExpectedDigit
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
