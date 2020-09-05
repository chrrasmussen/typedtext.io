module Html

import Language.Reflection
import Utils.String

%default total
%language ElabReflection


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


-- CONCRETE TAGS

generateTags : List String -> Elab ()
generateTags tags =
  declare (tags >>= tagToDecls)
  where
    tagToDecls : String -> List Decl
    tagToDecls tag =
      [ IClaim EmptyFC MW Export [] (MkTy EmptyFC (UN tag) `(List (String, String) -> List Html -> Html))
      , IDef EmptyFC (UN tag)
          [ PatClause EmptyFC
              (IVar EmptyFC (UN tag))
              `(El ~(IPrimVal EmptyFC (Str tag)))
          ]
      ]


%runElab generateTags ["div", "h1"]


-- RENDER

renderAttr : (String, String) -> String
renderAttr (key, value) = key ++ "=\"" ++ value ++ "\""

export
render : Html -> String
render (El tag attrs children) = "<" ++ showSep " " (tag :: map renderAttr attrs) ++ ">" ++ concat (assert_total (map render children)) ++ "</" ++ tag ++ ">"
render (Text x) = x
render (Raw x) = x
