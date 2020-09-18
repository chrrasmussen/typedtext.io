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


data AttributeType = AStr | ABool | AInt

attrType : AttributeType -> TTImp
attrType AStr = IPrimVal EmptyFC StringType
attrType ABool = IVar EmptyFC (NS (MkNS ["Prelude"]) (UN "Bool"))
attrType AInt = IPrimVal EmptyFC IntegerType

callAttrFn : (ty : AttributeType) -> TTImp
callAttrFn AStr = IVar EmptyFC (UN "Attr")
callAttrFn ABool = IVar EmptyFC (UN "boolAttr")
callAttrFn AInt = IVar EmptyFC (UN "integerAttr")

generateAttrs : List (String, AttributeType) -> Elab ()
generateAttrs attrs =
  declare (attrs >>= attrToDecls)
  where
    attrToDecls : (String, AttributeType) -> List Decl
    attrToDecls (attr, ty) =
      [ IClaim EmptyFC MW Export [Inline] (MkTy EmptyFC (UN attr) `(~(attrType ty) -> Attribute))
      , IDef EmptyFC (UN attr)
          [ PatClause EmptyFC
              (IVar EmptyFC (UN attr))
              `(~(callAttrFn ty) ~(IPrimVal EmptyFC (Str attr)))
          ]
      ]

%runElab generateAttrs
  [ -- Document
    ("charset", AStr)
    -- Common
  , ("id", AStr), ("title", AStr), ("hidden", ABool)
    -- Inputs
  , ("type", AStr), ("value", AStr), ("checked", ABool)
  , ("placeholder", AStr), ("selected", ABool)
    -- Input helpers
  , ("accept", AStr), ("action", AStr), ("autofocus", ABool)
  , ("disabled", ABool), ("enctype", AStr), ("list", AStr)
  , ("maxlength", AInt), ("minlength", AInt), ("method", AStr)
  , ("multiple", ABool), ("name", AStr), ("novalidate", ABool)
  , ("pattern", AStr), ("readonly", ABool), ("required", ABool)
  , ("size", AInt), ("for", AStr), ("form", AStr)
  , ("max", AStr), ("min", AStr), ("step", AStr)
  -- Input text areas
  , ("cols", AInt), ("rows", AInt), ("wrap", AStr)
    -- Links and areas
  , ("href", AStr), ("target", AStr), ("download", AStr)
  , ("hreflang", AStr), ("media", AStr), ("ping", AStr)
  , ("rel", AStr)
    -- Maps
  , ("ismap", ABool), ("usemap", AStr), ("shape", AStr)
  , ("coords", AStr)
    -- Embedded content
  , ("src", AStr), ("width", AInt), ("height", AInt)
  , ("alt", AStr)
    -- Audio and video
  , ("autoplay", ABool), ("controls", ABool), ("loop", ABool)
  , ("preload", AStr), ("poster", AStr), ("default", ABool)
  , ("kind", AStr), ("srclang", AStr)
    -- Iframes
  , ("sandbox", AStr), ("srcdoc", AStr)
    -- Ordered lists
  , ("reversed", ABool), ("start", AInt)
    -- Tables
  , ("align", AStr), ("colspan", AInt), ("rowspan", AInt)
  , ("headers", AStr), ("scope", AStr)
    -- Less common global attributes
  , ("contenteditable", ABool), ("contextmenu", AStr), ("dir", AStr)
  , ("draggable", AStr), ("dropzone", AStr), ("itemprop", AStr)
  , ("lang", AStr), ("spellcheck", ABool), ("tabindex", AInt)
    -- Miscellaneous
  , ("cite", AStr), ("datetime", AStr), ("pubdate", AStr)
  , ("manifest", AStr)
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
