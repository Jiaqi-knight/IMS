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
(* Title: Graphics3D.m *)
(* Context: *)
(* 
  Author: concept: jan korvink, 
  enhancement and bug fixes: oliver ruebenkoenig *)
(* 
  Date: 30.03.2006, IMTEK, Freiburg *)
(* 
  Summary: This convertes Graphics into Graphics3D expressions or extrudes \
them to Graphics3D *)
(* Package Copyright: GNU GPL *)
(* 
  Package Version: 0.2.1 *)
(* Mathematica Version: 5.2 *)
(* History:
      added Text expressions. o.r.;
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



(* Disclaimer: *)

(* Thie program converts mathematica Graphics objects into Graphics3D objects \
or extrudes them to Graphics3D  *)

(* Copyright (C) 2005 Jan Korvink and Oliver Ruebnekoenig *)

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
BeginPackage["Imtek`Graphics3D`"];





(* *)
(* documentation *)
(* *)
Needs["Imtek`Maintenance`"]
imsCreateObsoleteFunctionInterface[ ExtrudeGraphics, $Context ];
imsCreateObsoleteFunctionInterface[ RasterToGraphics, $Context ];
imsCreateObsoleteFunctionInterface[ ToGraphics3D, $Context ];


(* constructors *)

(* selectors *)

(* predicates *)

(* functions *)

imsExtrudeGraphics::usage="imsExtrudeGraphics[ objects, { zMin, zMax } ] convert the planar Graphics objects to 3-dimensional Graphics3D objects by extruding each component into the third dimension on the { zMin, zMax } specified";\


imsRasterToGraphics::usage="imsRasterToGraphics[ raster ] returns the graphics primitive representation of raster.";\


imsToGraphics3D::usage="imsToGraphics3D[ g, level ] converts the graphics object g to a Graphics3D object. g can be any one of Graphics[], Graphics3D[], SurfaceGraphics[], CoutourGraphics[], DensityGraphics[] or GraphicsArray[]. The optional level specifies the z-coordinate to which the Graphics object g is converted. The default for level is 0.";





(* *)
(* Error Messages *)
(* *)

imsExtrudeGraphics::scl="Scaled coordinates are not allowed.";



Begin["`Private`"];



<<Utilities`FilterOptions`
<<Graphics`Shapes`




(* *)
(* implementation part *)
(* *)

(* constructor *)




(* *)
(* define your options *)
(* *)



(* selector *)



(* predicates *)



(* functions *)






imsRasterToGraphics[Raster[s:{{(_)..}..},opts___]]:=Module[{r,nx,ny,func},
      r=Transpose[s];
      {nx,ny}=Dimensions[r];
      func=ColorFunction/.{opts}/.{ColorFunction\[Rule]GrayLevel};
      Flatten[
        Table[{func[r[[i,j]]],Rectangle[{i-1,j-1},{i,j}]},{i,1,nx},{j,1,ny}]]
      ];

imsRasterToGraphics[RasterArray[s:{{(_)..}..}]]:=
    imsRasterToGraphics[RasterArray[s,{{0,0},Dimensions[s]}]];

imsRasterToGraphics[RasterArray[s:{{(_)..}..},{{xmin_,ymin_},{xmax_,ymax_}}]]:=
    Module[{r,nx,ny,dx,dy},
      r=Transpose[s];
      dx=(xmax-xmin)/nx;
      dy=(ymax-ymin)/ny;
      {nx,ny}=Dimensions[r];
      Flatten[
        Table[{r[[i,j]],Rectangle[{(i-1)dx,(j-1)dy},{(i)dx,(j)dy}]},{i,1,
            nx},{j,1,ny}]]
      ];





imsExtrudeGraphics[Point[{x_,y_}],{zm_,zM_}]:=Line[{{x,y,zm},{x,y,zM}}];
imsExtrudeGraphics[Point[s:Scaled[_]],{zm_,zM_}]:=
    Module[{},Message[imsExtrudeGraphics::scl,s];Return[{}]];



imsExtrudeGraphics[Line[q:{{_,_}..}],{zm_,zM_}]:=Module[{},
      (Polygon[(Join@@#)])&/@Transpose[
          {Transpose[{Join[#,{zM}]&/@Drop[q,-1],
                Join[#,{zM}]&/@Drop[q,1]
                }],
            Reverse[#]&/@Transpose[{Join[#,{zm}]&/@Drop[q,-1],
                  Join[#,{zm}]&/@Drop[q,1]}]}]
      ];
imsExtrudeGraphics[Line[q:{({_,_}|Scaled[_])..}],{zm_,zM_}]:=
    Module[{},Message[imsExtrudeGraphics::scl,q];Return[{}]];



imsExtrudeGraphics[Rectangle[{xm_,ym_},{xM_,yM_}],{zm_,zM_}]:=
    Polygon[#]&/@{{{xm,ym,zm},{xM,ym,zm},{xM,ym,zM},{xm,ym,zM},{xm,ym,zm}},
        {{xM,yM,zm},{xM,ym,zm},{xM,ym,zM},{xM,yM,zM},{xM,yM,zm}},
        {{xm,yM,zm},{xM,yM,zm},{xM,yM,zM},{xm,yM,zM},{xm,yM,zm}},
        {{xm,yM,zm},{xm,ym,zm},{xm,ym,zM},{xm,yM,zM},{xm,yM,zm}},
        {{xm,ym,zm},{xM,ym,zm},{xM,yM,zm},{xm,yM,zm},{xm,ym,zm}},
        {{xm,ym,zM},{xM,ym,zM},{xM,yM,zM},{xm,yM,zM},{xm,ym,zM}}
        };



imsExtrudeGraphics[Polygon[q:{{_,_}..}],{zm_,zM_}]:=Module[{p},
      p=Join[q,{q[[1]]}];
      {imsExtrudeGraphics[Line[q],{zm,zM}],
        Polygon[Join[#,{zm}]&/@p],Polygon[Join[#,{zM}]&/@p]
        }
      ];
imsExtrudeGraphics[Polygon[q:{({_,_}|Scaled[_])..}],{zm_,zM_}]:=
    Module[{},Message[imsExtrudeGraphics::scl,q];Return[{}]];



imsExtrudeGraphics[Circle[{x_,y_},r_],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Line[Table[{x,y}+r{Sin[i],Cos[i]},{i,0,2\[Pi],\[Pi]/10.}]],{zm,zM}];
imsExtrudeGraphics[Circle[{x_,y_},{rx_,ry_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Line[Table[{x,y}+{rx Sin[i],ry Cos[i]},{i,0,2\[Pi],\[Pi]/10.}]],{zm,
        zM}];
imsExtrudeGraphics[Circle[{x_,y_},r_,{tx_,ty_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Line[Table[{x,y}+r{Sin[i],Cos[i]},{i,tx,ty,\[Pi]/10.}]],{zm,zM}];
imsExtrudeGraphics[Circle[{x_,y_},{rx_,ry_},{tx_,ty_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Line[Table[{x,y}+{rx Sin[i],ry Cos[i]},{i,tx,ty,\[Pi]/10.}]],{zm,zM}];



imsExtrudeGraphics[Disk[{x_,y_},r_],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Polygon[Table[{x,y}+r{Sin[i],Cos[i]},{i,0,2\[Pi],\[Pi]/10.}]],{zm,zM}];
imsExtrudeGraphics[Disk[{x_,y_},{rx_,ry_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Polygon[Table[{x,y}+{rx Sin[i],ry Cos[i]},{i,0,2\[Pi],\[Pi]/10.}]],{zm,
        zM}];
imsExtrudeGraphics[Disk[{x_,y_},r_,{tx_,ty_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Polygon[Table[{x,y}+r{Sin[i],Cos[i]},{i,tx,ty,\[Pi]/10.}]],{zm,zM}];
imsExtrudeGraphics[Disk[{x_,y_},{rx_,ry_},{tx_,ty_}],{zm_,zM_}]:=
    imsExtrudeGraphics[
      Polygon[Table[{x,y}+{rx Sin[i],ry Cos[i]},{i,tx,ty,\[Pi]/10.}]],{zm,
        zM}];



imsExtrudeGraphics[r_Raster,{zm_,zM_}]:=
    imsExtrudeGraphics[#,{zm,zM}]&/@
      Flatten[{EdgeForm[],imsRasterToGraphics[r]}];



imsExtrudeGraphics[Text[e_,c_],{zm_,zM_}]:=Text[e,Join[c,{zm}]];
imsExtrudeGraphics[Text[e_,c_,o_],{zm_,zM_}]:=Text[e,Join[c,{zm}],o];
imsExtrudeGraphics[Text[e_,c_,o_,d_],{zm_,zM_}]:=Text[e,Join[c,{zm}],o,d];



imsExtrudeGraphics[g_Graphics,{zm_,zM_}]:=Module[{fg,primitives, opts={}},
      fg=FullGraphics[g];
      primitives=fg[[1]];
      If[Length[fg]\[Equal]2,opts=fg[[2]]];
      Graphics3D[{EdgeForm[],
          imsExtrudeGraphics[#,{zm,zM}]&/@Flatten[{primitives}]}]
      ];



imsExtrudeGraphics[unknown_,{zm_,zM_}]:=unknown;



SetAttributes[ to3D, Listable ]



to3D[ Scaled[ { x_, y_ } ], level_:0. ] := Scaled[ { x, y, level } ]



to3D[ Text[ expr_, { x_, y_ }, offset___, dir___ ],level_:0. ] := 
    Text[ expr, {x,y,level}, offset, dir ] ;



to3D[ Circle[ { x_, y_ }, { rx_, ry_ } ],level_:0., t1_:0., t2_:2.*Pi, 
      tStep_:Pi/10. ] := 
    Line[ Table[ { x +rx Sin[ t ], y + ry Cos[ t ], level }, { t, t1, t2, 
          tStep }  ] ];

to3D[ Circle[ { x_, y_ }, r_ ], level_:0. ] := 
    to3D[ Circle[ { x, y }, { r, r } ], level ];
to3D[ Circle[ { x_, y_ }, r_, { t1_, t2_ } ], level_:0. ] := 
    to3D[ Circle[ { x, y }, { r, r } ],level,  t1, t2, (t2 - t1)/10. ];



to3D[ Disk[ { x_, y_ }, { rx_, ry_ } ],level_:0., t1_:0., t2_:2.*Pi, 
      tStep_:Pi/10. ] := 
    Polygon[ Table[ { x +rx Sin[ t ], y + ry Cos[ t ], level }, { t, t1, t2, 
          tStep }  ] ];

to3D[ Disk[ { x_, y_ }, r_ ], level_:0. ] := 
    to3D[ Disk[ { x, y }, { r, r } ], level ];
to3D[ Disk[ { x_, y_ }, r_, { t1_, t2_ } ], level_:0. ] := 
    to3D[ Disk[ { x, y }, { r, r } ],level,  t1, t2, (t2 - t1)/10. ];



to3D[ Point[ { x_, y_ } ], level_:0. ] := Point[ { x, y, level } ];
to3D[ Point[ a:Scaled[ { x_, y_ } ] ], level_:0. ] := 
    Point[ to3D[ a, level ] ];

to3D[ a:Point[ { _, _, _ } ], level_:0. ] := a;
to3D[ a:Point[ Scaled[ { _, _, _ } ] ], level_:0. ] := a;



to3D[ Line[ a: { { _, _ }.. } ], level_:0. ] := 
    Line[ Join[ #, { level } ]& /@ a ];
to3D[ Line[ a: { Scaled[ { _, _ } ].. } ], level_:0. ] := 
    Line[ to3D[ #, level ]& /@ a  ];

to3D[ a:Line[ { { _, _, _ }.. } ], level_:0. ] := a;
to3D[ a:Line[ { Scaled[ { _, _, _ } ].. } ], level_:0. ] := a;



to3D[ Polygon[ a: { { _, _ }.. } ], level_:0. ] := 
    Polygon[ Join[ #, { level } ]& /@ a ];
to3D[ Polygon[ a: { Scaled[ { _, _ } ].. } ], level_:0. ] := 
    Polygon[ to3D[ #, level ]& /@ a  ];

to3D[ a: Polygon[ { { _, _, _ }.. } ], level_:0. ] := a;
to3D[ a:Polygon[ { Scaled[ { _, _, _ } ].. } ], level_:0. ] := a;



to3D[ Rectangle[ { x1_, y1_ }, { x2_, y2_ } ], level_:0. ] := 
  Polygon[ { { x1, y1, level }, { x2, y1, level }, { x2, y2, level }, { x1, 
        y2, level } } ]

to3D[ Rectangle[ Scaled[ { x1_, y1_ } ], Scaled[ { x2_, y2_ } ] ], 
      level_:0. ] := 
    Polygon[ Scaled[ # ] ]& /@ { { x1, y1, level }, { x2, y1, level }, { x2, 
          y2, level }, { x1, y2, level } };

to3D[ Rectangle[ { x1_, y1_ }, { x2_, y2_ }, gr_ ], 
    level_:0. ] := {Line[ { { x1, y1, level }, { x2, y1, level }, { x2, y2, 
          level }, { x1, y2, level }, { x1, y1, level }  } ], 
    TranslateShape[ to3D[ gr, level ], { x1, y1, level } ]  }

to3D[ Rectangle[ Scaled[ { x1_, y1_ } ], Scaled[ { x2_, y2_ } ], gr_ ], 
    level_:0. ] := {Line[ { Scaled[ { x1, y1, level } ], 
        Scaled[ { x2, y1, level } ], Scaled[ { x2, y2, level } ], 
        Scaled[ { x1, y2, level } ], Scaled[ { x1, y1, level } ] } ], 
    TranslateShape[to3D[ gr, level ], { x1, y1, level } ]  }



to3D[ PostScript[ ___ ] ] := {};



to3D[ Raster[ array_, rect_, opts___ ], level_:0 ]:=
    Block[{r,c,scaledData,minX,maxx,minY,maxy,dx,dy,x,y},
      {r,c}=Dimensions[ array ];
      {{minX,minY},{maxx,maxy}}=rect;
      dx=(maxx-minX)/r;dy=(maxy-minY)/c;
      x[i_]:=minX+i*dx;y[j_]:=minY+j*dy;
      scaledData=Flatten[array];
      scaledData=(scaledData-Min[scaledData])/(Max[scaledData]-
              Min[scaledData]);
      Transpose[{GrayLevel[#]&/@scaledData,Flatten[Table[
              
              Polygon[{{x[i],y[j],level },{x[i+1],y[j],level },{x[i+1],y[j+1],
                    level },{x[i],y[j+1],level }}],{i,0,r-1},{j,0,c-1}]]}]
      ];

to3D[ Raster[ array_, opts___ ], level_:0.]:= 
  to3D[ Raster[ array, { { 0, 0 },Dimensions[ array ] }, opts ], level ];







to3D[ RasterArray[ array_, rect_ ], level_:0 ]:=
    Block[{r,c,scaledData,minx,maxx,miny,maxy,dx,dy,x,y},
      {r,c}=Dimensions[ array ];
      {{minx,miny},{maxx,maxy}}=rect;
      dx=(maxx-minx)/r;dy=(maxy-miny)/c;
      x[i_]:=minx+i*dx;y[j_]:=miny+j*dy;
      cellDirectives=Flatten[ array ];
      Join[{EdgeForm[]},Transpose[{cellDirectives,Flatten[Table[
                
                Polygon[{{x[i],y[j],level },{x[i+1],y[j],level },{x[i+1],
                      y[j+1],level },{x[i],y[j+1],level }}],{j,0,c-1},{i,0,
                  r-1}]]}]]
      ];

to3D[ RasterArray[ array_ ], level_:0.]:= 
  to3D[ RasterArray[ array, { { 0, 0 },Dimensions[ array ] } ], level ];







to3D[any_AbsoluteDashing, ___ ]:=any;
to3D[any_AbsolutePointSize, ___ ]:=any;
to3D[any_AbsoluteThickness, ___ ]:=any;
to3D[any_CMYKColor, ___ ]:=any;
to3D[any_Dashing, ___ ]:=any;
to3D[any_GrayLevel, ___ ]:=any;
to3D[any_Hue, ___ ]:=any;
to3D[any_PointSize, ___ ]:=any;
to3D[any_RGBColor, ___ ]:=any;
to3D[any_Thickness, ___ ]:=any;



to3D[any_SurfaceColor,_]:=any;
to3D[any_FaceForm,_]:=any;
to3D[any_EdgeForm,_]:=any;



imsToGraphics3D[
      g:(_Graphics|_Graphics3D|_SurfaceGraphics|_ContourGraphics|_\
DensityGraphics), level_:0. ] := Graphics3D @@ to3D[ g, level ];

imsToGraphics3D[ GraphicsArray[ array_ ,opts___], level_:0. ] := 
  GraphicsArray[ (imsToGraphics3D[ #, level ]& /@ array ),opts]

to3D[ Graphics[ x_, opts___ ], level_:0. ] := { 
      to3D[ x, level ],{ FilterOptions[Graphics3D, opts ] } };
to3D[ a_ContourGraphics, level_:0. ] := to3D[ Graphics[ a ], level ];
to3D[ a_Graphics3D, level_:0. ] := List @@ a;
to3D[ a_SurfaceGraphics, level_:0. ] := List @@ Graphics3D[ a ];
to3D[ dg:DensityGraphics[ x_, opts___ ], level_:0. ]:=Block[
      { ef },
      
      dgmOptsQ = Mesh/.opts /.Options[ DensityGraphics ];
      If[ dgmOptsQ, ef=EdgeForm[GrayLevel[0]],ef=EdgeForm[] ];
      
      ct3D = to3D[ Graphics[ DensityGraphics[ x, opts ] ], level ];
      (* This is a realy dirty hack *)
      { Join[ { ef }, ct3D[[ 1]] ],
        ct3D[[ 2 ]]  }
       ];



(* representors *)



End[] (* of Begin Private *)



(* Protect[] (* anything *) *)
EndPackage[] 