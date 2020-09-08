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

export
className : (name : String) -> Attribute
className name = Classes [name]

export
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
      [ IClaim EmptyFC MW Export [] (MkTy EmptyFC (UN attr) (attrFnType (attrType ty)))
      , IDef EmptyFC (UN attr)
          [ PatClause EmptyFC
              (IVar EmptyFC (UN attr))
              `(~(callAttrFn ty) ~(IPrimVal EmptyFC (Str attr)))
          ]
      ]

%runElab generateAttrs $
  map (\n => (n, AString))
      [ "id", "title", "type", "value", "placeholder", "accept", "action"
      , "enctype", "list", "method", "name", "pattern", "for", "form", "max"
      , "min", "step", "wrap", "href", "target", "download", "hreflang"
      , "media", "ping", "rel", "usemap", "shape", "coords", "src", "alt"
      , "preload", "poster", "kind", "srclang", "sandbox", "srcdoc", "align"
      , "headers", "scope", "contextmenu", "dir", "draggable", "dropzone"
      , "itemprop", "lang", "cite", "datetime", "pubdate", "manifest"
      ] ++
    map (\n => (n, ABool))
      [ "hidden", "checked", "selected", "autofocus", "disabled", "multiple"
      , "novalidate", "readonly", "required", "ismap", "autoplay", "controls"
      , "loop", "default", "reversed", "contenteditable", "spellcheck"
      ] ++
    map (\n => (n, AInteger))
      [ "maxlength", "minlength", "size", "cols", "rows", "width", "height"
      , "start", "colspan", "rowspan", "tabindex"
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
