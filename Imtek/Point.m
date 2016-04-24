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
(* Title:Point.m *)
(* Context: *)
(* 
  Author: darius koziol & oliver ruebenkoenig *)
(* 
  Date:2.5.2005, Imtek, Freiburg *)
(* 
  Summary:This is the IMTEK point package providing basic point utilities *)
(* 
  Package Copyright:GNU GPL *)
(* Package Version:0.5.1 *)
(* 
  Mathematica Version:5.1 *)
(* History:
    Bisector returned numeric output for integer input - fixed.
          BetweenQ could failed, if first and second point where the same;
  BetweenQ is numerical unstable - find better algorithm ;
  Added BetweenQ;
  Changed Syntax for PointDistance and PointBisector;
   *)
(* Keywords: *)
(* Sources: *)
(* Warnings: *)
(* Limitations: *)
(* 
  Discussion: *)
(* Requirements: *)
(* Examples: *)
(* *)



(* Disclaimer *)

(* Whereever the GNU GPL is not applicable, 
  the software should be used in the same spirit. *)

(* Users of this code must verify correctness for their application. *)

(* Free Software Foundation,Inc.,59 Temple Place,Suite 330,Boston,
  MA 02111-1307 USA *)

(* Disclaimer: *)

(* This is the IMTEK point package providing basic point utilities *)

(* Copyright (C) 2002-2005 oliver ruebenkoenig *)

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



BeginPackage["Imtek`Point`"];





(* *)
(* Documentation *)
(* *)
Needs["Imtek`Maintenance`"]
imsCreateObsoleteFunctionInterface[ GetX, $Context ];
imsCreateObsoleteFunctionInterface[ GetY, $Context ];
imsCreateObsoleteFunctionInterface[ GetZ, $Context ];
imsCreateObsoleteFunctionInterface[ Coord1DQ, $Context ];
imsCreateObsoleteFunctionInterface[ Coord2DQ, $Context ];
imsCreateObsoleteFunctionInterface[ Coord3DQ, $Context ];
imsCreateObsoleteFunctionInterface[ CoordQ, $Context ];
imsCreateObsoleteFunctionInterface[ BetweenQ, $Context ];
imsCreateObsoleteFunctionInterface[ ToCoord2D, $Context ];
imsCreateObsoleteFunctionInterface[ ToCoord3D, $Context ];
imsCreateObsoleteFunctionInterface[ Distance, $Context ];
imsCreateObsoleteFunctionInterface[ Bisector, $Context ];

imsGetX::usage = "imsGetX[ Coord ] returns the x-coordinate.";
imsGetY::usage = "imsGetY[ Coord ] returns the y-coordinate.";
imsGetZ::usage = "imsGetZ[ Coord ] returns the z-coordinate.";

imsCoord1DQ::usage = \
"imsCoord1DQ[ expr ] gives True if the expr is 1D coord.";
imsCoord2DQ::usage = \
"imsCoord2DQ[ expr ] gives True if the expr is 2D coord.";
imsCoord3DQ::usage = \
"imsCoord3DQ[ expr ] gives True if the expr is 3D coord.";

imsCoordQ::usage = \
"imsCoordQ[ expr ] gives True if the expr is any of 1D/2D or 3D Coords.";

imsBetweenQ::usage="imsBetweenQ[ { Coord, Coord, Coord }, n ] returns True if the last coord is between the first two coords. You can set the precision with n. Default is $MachinePrecision.";\


imsToCoord2D::usage = 
    "imsToCoord2D[ Coord ] takes 1D coord and converts them to { x, 0 }.";

imsToCoord3D::usage = 
    "imsToCoord3D[ Coord ] takes 2D coord and converts them to { x, y, 0 }.";

imsDistance::usage="imsDistance[ { Coord, Coord } ] gives distance between two coords.";\


imsBisector::usage="imsBisector[ { Coord, Coord } ] returns the mid point between the two Coords.";



(* *)
(* Option Docu *)
(* *)



(* *)
(* Error Messages *)
(* *)



Begin["`Private`"];





(* *)
(* define your options *)
(* *)

(* end define options *)



(* List[] is the Constructor *)



imsGetX[ { x_ } ] := x;

imsGetX[ { x_, y_ } ] := x;
imsGetY[ { x_, y_ } ] := y;

imsGetX[ { x_, y_, z_ } ] := x;
imsGetY[ { x_, y_, z_ } ] := y;
imsGetZ[ { x_, y_, z_ } ] := z;



imsCoord1DQ[ { x_ } ] /; AtomQ[ x ] := True;
imsCoord2DQ[ { x_, y_ } ] /; AtomQ[ x ] && AtomQ[ y ]:= True;
imsCoord3DQ[ { x_, y_, z_ } ] /; AtomQ[ x ] && AtomQ[ y ] && AtomQ[ z ] := 
    True;

imsCoord1DQ[ ___ ]:= False;
imsCoord2DQ[ ___ ]:= False;
imsCoord3DQ[ ___ ]:= False;

imsCoordQ[ expr_ ] := 
    imsCoord1DQ[ expr ] || imsCoord2DQ[ expr ] || imsCoord3DQ[ expr ];
imsCoordQ[ ___ ]:= False;

imsBetweenQ[ { { xi_,yi_ },  { xj_, yj_}, { xk_,yk_ } },
    accugoal_:$MachinePrecision ]:=
  Which[
    (* first and second point are the same *)
    
    Abs[ xi -xj ] < 10.0^-accugoal && Abs[ yi -yj ] < 10.0^-accugoal,
    Abs[ xi -xk ] < 10.0^-accugoal && Abs[ yi -yk ] < 10.0^-accugoal,
    
    (* not collinear *)
    !(0.5 * Abs[xi*(yj-yk)+xj*(yk-yi)+xk*(yi-yj)] < 
          10.0^-accugoal),False,
    (* x-vertical *)
    xi\[NotEqual]xj,
    xi\[LessEqual]xk&&xk\[LessEqual]xj||
      xi\[GreaterEqual]xk&&xk\[GreaterEqual]xj,
    (* else *)
    True,
    yi\[LessEqual]yk&&yk\[LessEqual]yj||
      yi\[GreaterEqual]yk&&yk\[GreaterEqual]yj
    ]

imsBetweenQ[ { { xi_, yi_, zi_ }, { xj_, yj_, zj_ }, { xk_, yk_, zk_ } },
    accugoal_:$MachinePrecision ] := Which[ 
    (* first and second point are the same *)
    
    xi == xj  && yi \[Equal] yj && zi \[Equal] zj, 
    xi == xk && yi \[Equal] yk && zi \[Equal] zk,  
    Abs[ xi -xj ] < 10.0^-accugoal && Abs[ yi -yj ] < 10.0^-accugoal && 
      Abs[ zi -zj ] < 10.0^-accugoal,
    Abs[ xi -xk ] < 10.0^-accugoal && Abs[ yi -yk ] < 10.0^-accugoal && 
      Abs[ zi -zk ] < 10.0^-accugoal,
    
    (* not collinear *)
     !(0.5 * Abs[
              
              xi yj-xi yk-yj zi+yk zi-xi zj+yi zj-yk zj+xk (yi-yj-zi+zj)+
                xj (-yi+yk+zi-zk)+xi zk-yi zk+yj zk ] <10.0^-accugoal ),
    False,
    
    (* x-vertical *)
    xi \[NotEqual] xj, 
    xi \[LessEqual] xk && xk \[LessEqual] xj || 
      xi \[GreaterEqual] xk && xk \[GreaterEqual] xj,
    
    (* y-vertical *)
    yi \[NotEqual] yj,  
    yi \[LessEqual] yk && yk \[LessEqual] yj || 
      yi \[GreaterEqual] yk && yk \[GreaterEqual] yj,
    
    (* else *)
    True,  
    zi \[LessEqual] zk && zk \[LessEqual] zj || 
      zi \[GreaterEqual] zk && zk \[GreaterEqual] zj
    ]



imsToCoord2D[ { x_ } ] := { x, 0  };

imsToCoord3D[ { x_, y_ } ] := { x, y, 0 };


imsDistance[ { { xa_ }, { xb_ } } ]:=Sqrt[  Power[ ( xb - xa ), 2] ];

imsDistance[ { { xa_, ya_ }, { xb_, yb_ } } ]:=
    Sqrt[  Power[ ( xb - xa ), 2] + Power[ ( yb - ya ), 2 ] 
      ];

imsDistance[ { { xa_, ya_, za_ }, { xb_, yb_, zb_ } } ]:=
    Sqrt[  Power[ ( xb - xa ), 2] + Power[ ( yb - ya ), 2 ] + 
        Power[ ( zb - za ), 2 ]  
      ];

imsBisector[ { { xa_ }, { xb_ } } ] := { xa + 0.5 * ( xb - xa ) };

imsBisector[ { { xa_, ya_ }, { xb_, yb_ } } ] := 
    { xa + 1/2 * ( xb - xa ) , ya + 1/2 * ( yb - ya ) };

imsBisector[ { { xa_, ya_, za_ }, { xb_, yb_, zb_ } } ] := 
    {
      xa + 1/2 * ( xb - xa ) ,
      ya + 1/2 * ( yb - ya ) ,
      za + 1/2 * ( zb - za ) 
      };



End[] (*of Begin Private*)



(*Protect[] (*anything*)*)
EndPackage[]