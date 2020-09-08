module Html

import Language.Reflection
import public Html.Attributes

%default total
%language ElabReflection


export
data Html : Type where
  El : (tag : String) -> List Attribute -> List Html -> Html
  Text : String -> Html
  Raw : String -> Html

export %inline
el : (tag : String) -> List Attribute -> List Html -> Html
el = El

export %inline
text : String -> Html
text = Text

export %inline
unsafeRaw : String -> Html
unsafeRaw = Raw


-- CONCRETE TAGS

generateTags : List String -> Elab ()
generateTags tags =
  declare (tags >>= tagToDecls)
  where
    tagToDecls : String -> List Decl
    tagToDecls tag =
      [ IClaim EmptyFC MW Export [Inline] (MkTy EmptyFC (UN tag) `(List Attribute -> List Html -> Html))
      , IDef EmptyFC (UN tag)
          [ PatClause EmptyFC
              (IVar EmptyFC (UN tag))
              `(El ~(IPrimVal EmptyFC (Str tag)))
          ]
      ]


%runElab generateTags
  [ -- Document
    "html", "head", "body", "title", "script", "style", "link", "meta", "base"
    -- Headers
  , "h1", "h2", "h3", "h4", "h5", "h6"
    -- Grouping content
  , "div", "p", "hr", "pre", "blockquote"
    -- Text
  , "span", "a", "code", "em", "strong", "i", "b", "u", "sub", "sup", "br"
    -- Lists
  , "ol", "ul", "li", "dl", "dt", "dd"
    -- Embedded content
  , "img", "iframe", "canvas", "math"
    -- Inputs
  , "form", "input", "textarea", "button", "select", "option"
  , "fieldset", "legend", "label", "datalist", "optgroup", "output", "progress", "meter"
    -- Sections
  , "section", "nav", "article", "aside", "header", "footer", "address", "main"
    -- Figures
  , "figure", "figcaption"
    -- Tables
  , "table", "caption", "colgroup", "col", "tbody", "thead", "tfoot", "tr", "td", "th"
    -- Audio and video
  , "audio", "video", "source", "track"
    -- Embedded objects
  , "embed", "object", "param"
    -- Text edits
  , "ins", "del"
    -- Semantic text
  , "small", "cite", "dfn", "abbr", "time", "var", "samp", "kbd", "s", "q"
    -- Less common text tags
  , "mark", "ruby", "rt", "rp", "bdi", "bdo", "wbr"
    -- Interactive elements
  , "details", "summary", "menuitem", "menu"
  ]


-- RENDER

-- TODO: Add escaping
export
render : Html -> String
render (El tag attrs children) = "<" ++ showSep " " (tag :: renderAttributes attrs) ++ ">" ++ concat (assert_total (map render children)) ++ "</" ++ tag ++ ">"
render (Text x) = x
render (Raw x) = x
