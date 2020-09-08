module Html.Attributes

import Data.List
import Data.Maybe
import Data.Strings
import Language.Reflection

%default total
%language ElabReflection


export
data Attribute : Type where
  Attr : (key : String) -> (value : String) -> Attribute
  BoolAttr : (key : String) -> (value : Bool) -> Attribute
  Style : (key : String) -> (value : String) -> Attribute
  Classes : (classes : List String) -> Attribute

export %inline
attr : (key : String) -> (value : String) -> Attribute
attr = Attr

export %inline
boolAttr : (key : String) -> (value : Bool) -> Attribute
boolAttr = BoolAttr

%inline
integerAttr : (key : String) -> (value : Integer) -> Attribute
integerAttr key value = Attr key (show value)

export %inline
style : (key : String) -> (value : String) -> Attribute
style = Style

export %inline
className : (name : String) -> Attribute
className name = Classes [name]

export %inline
classList : List (String, Bool) -> Attribute
classList classMapping =
  Classes (mapMaybe (\(name, include) => toMaybe include name) classMapping)


data AttributeType = AString | ABool | AInteger

attrType : AttributeType -> TTImp
attrType AString = IPrimVal EmptyFC StringType
attrType ABool = IVar EmptyFC (NS (MkNS ["Prelude"]) (UN "Bool"))
attrType AInteger = IPrimVal EmptyFC IntegerType

attrFnType : TTImp -> TTImp
attrFnType inp = IPi EmptyFC MW ExplicitArg Nothing inp (IVar EmptyFC (UN "Attribute"))

callAttrFn : (ty : AttributeType) -> TTImp
callAttrFn AString = IVar EmptyFC (UN "Attr")
callAttrFn ABool = IVar EmptyFC (UN "boolAttr")
callAttrFn AInteger = IVar EmptyFC (UN "integerAttr")

generateAttrs : List (String, AttributeType) -> Elab ()
generateAttrs attrs =
  declare (attrs >>= attrToDecls)
  where
    attrToDecls : (String, AttributeType) -> List Decl
    attrToDecls (attr, ty) =
      [ IClaim EmptyFC MW Export [Inline] (MkTy EmptyFC (UN attr) (attrFnType (attrType ty)))
      , IDef EmptyFC (UN attr)
          [ PatClause EmptyFC
              (IVar EmptyFC (UN attr))
              `(~(callAttrFn ty) ~(IPrimVal EmptyFC (Str attr)))
          ]
      ]

%runElab generateAttrs
  [ -- Common
    ("id", AString), ("title", AString), ("hidden", ABool)
    -- Inputs
  , ("type", AString), ("value", AString), ("checked", ABool)
  , ("placeholder", AString), ("selected", ABool)
    -- Input helpers
  , ("accept", AString), ("action", AString), ("autofocus", ABool)
  , ("disabled", ABool), ("enctype", AString), ("list", AString)
  , ("maxlength", AInteger), ("minlength", AInteger), ("method", AString)
  , ("multiple", ABool), ("name", AString), ("novalidate", ABool)
  , ("pattern", AString), ("readonly", ABool), ("required", ABool)
  , ("size", AInteger), ("for", AString), ("form", AString)
  , ("max", AString), ("min", AString), ("step", AString)
  -- Input text areas
  , ("cols", AInteger), ("rows", AInteger), ("wrap", AString)
    -- Links and areas
  , ("href", AString), ("target", AString), ("download", AString)
  , ("hreflang", AString), ("media", AString), ("ping", AString)
  , ("rel", AString)
    -- Maps
  , ("ismap", ABool), ("usemap", AString), ("shape", AString)
  , ("coords", AString)
    -- Embedded content
  , ("src", AString), ("width", AInteger), ("height", AInteger)
  , ("alt", AString)
    -- Audio and video
  , ("autoplay", ABool), ("controls", ABool), ("loop", ABool)
  , ("preload", AString), ("poster", AString), ("default", ABool)
  , ("kind", AString), ("srclang", AString)
    -- Iframes
  , ("sandbox", AString), ("srcdoc", AString)
    -- Ordered lists
  , ("reversed", ABool), ("start", AInteger)
    -- Tables
  , ("align", AString), ("colspan", AInteger), ("rowspan", AInteger)
  , ("headers", AString), ("scope", AString)
    -- Less common global attributes
  , ("contenteditable", ABool), ("contextmenu", AString), ("dir", AString)
  , ("draggable", AString), ("dropzone", AString), ("itemprop", AString)
  , ("lang", AString), ("spellcheck", ABool), ("tabindex", AInteger)
    -- Miscellaneous
  , ("cite", AString), ("datetime", AString), ("pubdate", AString)
  , ("manifest", AString)
  ]

export %inline
acceptCharset : String -> Attribute
acceptCharset = attr "accept-charset"

onOff : Bool -> String
onOff True = "on"
onOff False = "off"

export %inline
autocomplete : Bool -> Attribute
autocomplete val = attr "autocomplete" (onOff val)

export %inline
char : Char -> Attribute
char val = attr "accesskey" (cast val)


-- RENDER

getStyles : List Attribute -> List (String, String)
getStyles [] = []
getStyles (Style key value :: xs) = (key, value) :: getStyles xs
getStyles (_ :: xs) = getStyles xs

getClasses : List Attribute -> List (List String)
getClasses [] = []
getClasses (Classes classes :: xs) = classes :: getClasses xs
getClasses (_ :: xs) = getClasses xs

-- TODO: Add escaping
renderAttr : Attribute -> List String
renderAttr (Attr key value) = [key ++ "=\"" ++ value ++ "\""]
renderAttr (BoolAttr key True) = [key]
renderAttr (BoolAttr key False) = []
renderAttr (Style key value) = []
renderAttr (Classes classes) = []

showStyle : (String, String) -> String
showStyle (key, value) = key ++ ":" ++ value

export
renderAttributes : List Attribute -> List String
renderAttributes attrs =
  let classes = concat (getClasses attrs)
      styles = getStyles attrs
      classesAttr = case classes of
        [] => []
        _ :: _ => [Attr "class" (unwords classes)]
      styleAttr = case styles of
        [] => []
        _ :: _ => [Attr "style" (showSep ";" (map showStyle styles))]
  in (classesAttr ++ styleAttr ++ attrs) >>= renderAttr
