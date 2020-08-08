module Html

import Utils.String

%default total


export
data Html : Type where
  El : (tag : String) -> List (String, String) -> List Html -> Html
  Text : String -> Html
  Raw : String -> Html

export
el : (tag : String) -> List (String, String) -> List Html -> Html
el = El

export
text : String -> Html
text = Text

export
raw : String -> Html
raw = Raw


-- CONCRETE ELEMENTS

export
div : List (String, String) -> List Html -> Html
div = el "div"

export
h1 : List (String, String) -> List Html -> Html
h1 = el "h1"


-- RENDER

renderAttr : (String, String) -> String
renderAttr (key, value) = key ++ "=\"" ++ value ++ "\""

export
render : Html -> String
render (El tag attrs children) = "<" ++ showSep " " (tag :: map renderAttr attrs) ++ ">" ++ concat (assert_total (map render children)) ++ "</" ++ tag ++ ">"
render (Text x) = x
render (Raw x) = x
