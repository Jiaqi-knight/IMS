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
(* Title: OperatorUtilities.m *)
(* Context: *)
(* 
  Author:oliver ruebenkoenig *)
(* Date: 21.9.2005, Freiburg *)
(* 
  Summary: This package provides utilities for operators *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.1 *)
(* 
  Mathematica Version: 5.2 *)
(* History: *)
(* Keywords: *)
(* Sources: *)
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

(* This package provides utilities for operators *)

(* Copyright (C) 2005 oliver ruebenkoenig *)

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

BeginPackage["Imtek`OperatorUtilities`" , {"Imtek`Assembler`"}];





(* *)
(* documentation *)
(* *)

(* constructors *)

(* selectors *)

(* predicates *)

(* functions *)

imsOperatorSkeleton::usage ="imsOperatorSkeleton[ { esm_imsElementMatrix, rhs_imsElementMatrix }, element , nodes, esmKernel, rhsKernel ] computes the kernel functions,  which will be given all the coordinates of nodes and as a last value the marker of element. Then the result of esmKernel is applied to the element matrix ems and rhsKernel to rhs. ";



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
Needs["Imtek`Nodes`"]



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
(* 
  very evil code! i broke the rule of constructor/
      selctor for performance reasons *)

imsOperatorSkeleton[ { imsElementMatrix[ esmValues_, esmRows_, esmCols_ ], 
      imsElementMatrix[ rhsValues_, rhsRows_, rhsCols_ ] },
    elem_[ id_, nodeIds_, marker_, data___ ] , elementNodes_, esmKernel_,  
    rhsKernel_  ]:=
  {
    imsElementMatrix[ 
      esmValues  + 
        esmKernel[ 
          Sequence @@ Flatten[ { imsGetCoords[ elementNodes ], marker } ] ], 
      esmRows, esmCols ],
    imsElementMatrix[ 
      rhsValues + 
        rhsKernel[ 
          Sequence @@ Flatten[ { imsGetCoords[ elementNodes ], marker } ] ], 
      rhsRows, rhsCols ]
    }



(* representors *)
(* *)



(* Begin Private *)
End[]



(* Protect[] *)
EndPackage[] 
