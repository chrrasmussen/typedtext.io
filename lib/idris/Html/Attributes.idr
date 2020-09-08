module Html.Attributes

import Data.List
import Data.Maybe
import Data.Strings
import Utils.String


export
data Attribute : Type where
  Attr : (key : String) -> (value : String) -> Attribute
  BoolAttr : (key : String) -> (value : Bool) -> Attribute
  Style : (key : String) -> (value : String) -> Attribute
  Classes : (classes : List String) -> Attribute

export
attr : (key : String) -> (value : String) -> Attribute
attr = Attr

export
boolAttr : (key : String) -> (value : Bool) -> Attribute
boolAttr = BoolAttr

export
style : (key : String) -> (value : String) -> Attribute
style = Style

export
className : (name : String) -> Attribute
className name = Classes [name]

export
classList : List (String, Bool) -> Attribute
classList classMapping =
  Classes (mapMaybe (\(name, include) => toMaybe include name) classMapping)


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
