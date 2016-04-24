(*******************************************************************
This file was generated automatically by the Mathematica front end.
It contains Initialization cells from a Notebook file, which
typically will have the same name as this file except ending in
".nb" instead of ".m".

This file is intended to be loaded into the Mathematica kernel using
the package loading commands Get or Needs.  Doing so is equivalent
to using the Evaluate Initialization Cells menu command in the front
end.

DO NOT EDIT THIS FILE.  This entire file is regenerated
automatically each time the parent Notebook file is saved in the
Mathematica front end.  Any changes you make to this file will be
overwritten.
***********************************************************************)





(* *)
(* Title: LanguageExtension.m *)
(* Context: *)
(* 
  Author:oliver ruebenkoenig *)
(* Date: 18.1.2007, Freiburg *)
(* 
  Summary: This extends the mathematica language *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.2 *)
(* 
  Mathematica Version: 5.2 *)
(* History:
      fixed bug in interface;
   *)
(* Keywords: *)
(* 
  Sources: imsUnsortedUnion is from the mathematica help documentation *)
(* 
  Warnings: *)
(* Limitations: *)
(* Discussion: *)
(* Requirements: *)
(* 
  Examples: *)
(* *)



(* Disclaimer *)

(* Whereever the GNU GPL is not applicable, 
  the software should be used in the same spirit. *)

(* Users of this code must verify correctness for their application. *)

(* Free Software Foundation,Inc.,59 Temple Place,Suite 330,Boston,
  MA 02111-1307 USA *)

(* Disclaimer: *)

(* This extend the mathematica language *)

(* Copyright (C) 2007 oliver ruebenkoenig *)

(* This program is free software; *)

(* you can redistribute it and/
      or modify it under the terms of the GNU General Public License *)

(* as published by the Free Software Foundation;
  either version 2 of the License, *)

(* or (at your option) any later version.This program is distributed in the \
hope that *)

(* it will be useful,but WITHOUT ANY WARRANTY; *)

(* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A \
PARTICULAR PURPOSE. *)

(* See the GNU General Public License for more details. 
      You should have received a copy of *)

(* the GNU General Public License along with this program;if not, 
  write to the *)

(* Free Software Foundation,Inc.,59 Temple Place,Suite 330,Boston,
  MA 02111-1307 USA *)



(* Start Package *)
BeginPackage["Imtek`LanguageExtension`"];





(* *)
(* documentation *)
(* *)

(* constructors *)

(* selectors *)

(* predicates *)

(* functions *)

imsUnsortedUnion::usage="imsUnsortedUnion[list] returns an unsorted union of list.";\


imsIndexedUnion::usage=
  "imsIndexedUnion[list] returns a sorted union of the list and a list of indices giving the position of the elements in list."



(* *)
(* options docu *)
(* *)



(* *)
(* error messages *)
(* *)



Begin["`Private`"];



(* *)
(* private imports *)
(* *)



(* *)
(* implementation part *)
(* *)

(* constructor *)
(* *)



(* *)
(* define your options *)
(* *)



(* selector *)
(* *)



(* predicates *)
(* *)



(* private functions *)
(* *)

(* public functions *)
(* *)

imsIndexedUnion[ coords_ ] := 
  Transpose[ 
    Union[ MapIndexed[ List, coords ], 
      SameTest \[Rule] (#1[[1]]===#2[[1]]&) ] ]

imsUnsortedUnion[ x_ ] := Module[ {f}, f[y_]:=(f[y]=Sequence[];y); f/@x ]



(* representors *)
(* *)



(* Begin Private *)
End[]



(* Protect[] *)
EndPackage[] 