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
(* Title: UnstructuredPlot.m *)
(* Context: Imtek`UnstructuredPlot` *)
(* 
  Author: Jan Lienemann *)
(* Date: 2.12.2004, Freiburg i.Br. *)
(* 
  Summary: This package provides a function to make plots for triangles with \
a linear shape function interpolating between the edges *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.7.1 *)
(* 
  Mathematica Version: 5.2 *)
(* History:
    18.6.2003 initial version (FEPlot);
  11.2.2005 changed name to GraphPlot;
  22.2.2005 Names changed to ims...;
  3.6.2005 Fixed some bugs, 3D capabilities for imsGraphContourPlot, 
  Compile for DividePoly;
  8.6.2005 added some Povray Export support;
  13.6.2005 changed name to UnstructuredPlot;
  13.7.2005 fixed bugs in Povray Export;
  6.2.2006 ContourShading supported;
  20.2.2006 imsFindContour and imsFindContourElements added by o.r.;
  22.3.2006 improved imsFindContour by o.r.;
  8.5.2006 improved imsFindContour to handle more special cases by o.r.;
  3.8.2006 changes imsFindContour to return the intersecing element ids and \
removed duplicate points, lines,etc. changed the return format.;
  3.9.2007 update for mma6.0:oli;
   *)
(* Keywords: *)
(* Sources: *)
(* Warnings:
    imsFindCountrour does not work for quad meshes and hex meshes!
   *)
(* Limitations: *)
(* Discussion: *)
(* Requirements: *)
(* 
  Examples: *)
(* *)



(* Start Package *)
BeginPackage["Imtek`UnstructuredPlot`"];
Unprotect[imsUnstructuredContourPlot, imsUnstructuredContourPlot3D,
    imsUnstructuredMeshPlot,imsUnstructuredPlot3D];





(* *)
(* documentation *)
(* *)

(* functions *)

imsUnstructuredContourPlot3D::usage="imsUnstructuredContourPlot3D[co, inc, val] generates a contour plot of the interpolation of val over the surface triangles of tetrahedral elements specified by a list of node coordinates co and an incidence matrix inc.";\

  
  imsUnstructuredContourPlot::usage="imsUnstructuredContourPlot[co, inc, val] generates a contour plot of the interpolation of val over the triangles specified by a list of node coordinates co and an incidence matrix inc. If the coordinates are 3D coordinates, a Graphics3D is returned.";\

  
  imsUnstructuredMeshPlot::usage="imsUnstructuredMeshPlot[co, inc] generates a plot of a 2D triangular mesh specified by a list of node coordinates co and an incidence matrix inc. If the coordinates are 3D coordinates, a Graphics3D is returned.";\

  
  imsUnstructuredPlot3D::usage="imsUnstructuredPlot3D[co, inc, val] generates a 3D surface plot of the interpolation of val over the triangles specified by a list of node coordinates co and an incidence matrix inc.";\

  
  imsUnstructuredContourPlotWritePovray::usage=
      "imsUnstructuredContourPlotWritePovray[co, inc, val] exports a 3D contour plot to a string in the POVray format. Use Export[\"test.pov\", imsUnstructuredContourPlotWritePovray[co, inc, val], \"Text\"] to write to a file.";\

  
  imsFindContourElements::usage="imsFindContourElements[ incidents, values, contourLevel ] returns a list of those incidences through which the contour at contourLevel passes for given values which are connected by incidents."
\
  
  imsFindContour::usage=
    "imsFindContour[ coords, incidents, values, contourLevel ] returns a list of ids and the respective intersecting coords through which the contour at contourLevel passes for given values which are connected by incidents."







(* *)
(* define your options *)
(* *)

Mesh::usage="Whether to draw a mesh";
Contours::usage="Number of contours or list of contours";
ColorFunction::usage="Assigns a color to a value";
ColorFunctionScaling::usage="Scales ColorFunction to fit between min and max";\

imsPovrayPreamble::usage="User defined Povray preamble";
imsCamera::usage="User defined camera";



(* Needs[ "Imtek`Geometry`Point`" ];*)



Begin["`Private`"];



Needs[ "Utilities`FilterOptions`" ];



Options[imsUnstructuredContourPlot]={Contours\[Rule]10,Mesh\[Rule]False,
      ColorFunction\[Rule](Hue[#*2/3]&),ColorFunctionScaling\[Rule]True,
      ContourShading\[Rule]True};
Options[imsUnstructuredContourPlot3D]={Contours\[Rule]10,Mesh\[Rule]False,
      ColorFunction\[Rule](Hue[#*2/3]&),ColorFunctionScaling\[Rule]True,
      ContourShading\[Rule]True};
Options[imsUnstructuredPlot3D]={Mesh\[Rule]True};
Options[imsUnstructuredContourPlotWritePovray]={Contours\[Rule]10,
      ColorFunction\[Rule](Hue[#*2/3]&),ColorFunctionScaling\[Rule]True,
      imsCamera\[Rule]Automatic,imsPovrayPreamble\[Rule]Automatic};





MyToString[s_]:=ToString[s,CForm];

POVraypreamble="// Standard includes\n
#include \"colors.inc\"\n
#include \"textures.inc\"\n
#declare DefaultFinish=finish { phong 0.8 \nambient 0.2}\n
\n
#default {texture {pigment { color <1, 1, 1>}\nfinish { DefaultFinish }}}\n
\n
light_source {\n
	<2.44458, -1.38661, 2.01853>\n
	color rgb <1, 0, 0>\n
}\n
\n
light_source {\n
	<2.31998, -0.934944, 2.9582>\n
	color rgb <0, 1, 0>\n
}\n
\n
light_source {\n
	<1.30779, -1.21417, 2.9582>\n
	color rgb <0, 0, 1>\n
}\n";

PolyToTri[p_List]:=Module[{p1=First[p],ps=Drop[p,1]},
    Prepend[#,p1]&/@Partition[ps,2,1]
    ]

ToRGBColor[Hue[h_,s_,v_]]:=Module[{Hi=Floor[h*6],f,q,p=v*(1-s),t},f=h*6-Hi;
    q=v*(1-f*s);
    t=v*(1-(1-f)*s);
    Switch[Hi,0,RGBColor[v,t,p],1,RGBColor[q,v,p],2,RGBColor[p,v,t],3,
      RGBColor[p,q,v],4,RGBColor[t,p,v],5,RGBColor[v,p,q],6,RGBColor[v,t,p]]]

ToRGBColor[Hue[h_]]:=ToRGBColor[Hue[h,1,1]];

ListToPovvec[
    l_]:=("<"<>StringDrop[StringJoin@@((MyToString[#]<>", ")&/@l),-2]<>">")

povCamDist[lookat_List,corner_List,viewdir_List,angle_]:=
  Norm[corner-lookat]/Sin[angle/2]/Norm[viewdir]

LineC[l_,r___]:=Line[Append[l,l[[1]]],r];

(* functions *)

(* Arguments: 
    List of Tupels {Coordinate 1, Coordinate 2, ..., Value }, {Lower cont. 
        trigger, Upper cont. trigger} *)
DividePoly=
  Compile[{{xyv,_Real,2},{cont,_Real,1},{c1inf,True|False},{c2inf,
        True|False}},Module[{f,xyvin,polygoni,v1=0.,v2=0.,p1,p2,l},
      polygoni={Drop[xyv[[1]],-1]};
      l={Drop[xyv[[1]],-1]};
      (* List of boundary lines of the polygons *)
      
      xyvin=Append[Partition[xyv,2,1],{xyv[[-1]],xyv[[1]]}];
      
      
      (* for each line find intersection with contour planes. 
            If first point of line is in the contour, take it, 
        if it is out of the contour, 
        seek new point going along the line to the next point *)
      (* 
        9 cases for two points (below, in, above) *)
      
      (
            v1=#[[1,-1]];v2=#[[2,-1]]; (* Values *)
            
            p1=Drop[#[[1]],-1];p2=Drop[#[[2]],-1];
            If[v1==v2,
              
              If[v1>=cont[[1]]||c1inf, (* 
                  v1==v2 \[GreaterEqual] lower (in or above) *)
              
                  If[v1<cont[[2]]||c2inf, (* v1==v2 < upper (in) *)
          
                          AppendTo[polygoni,p1] 
                  (* Both are inside, append starting point of line; 
                    else: do not append *)
                  ]
                ]
              ,
              
              If[v1<cont[[1]]&&Not[c1inf],(* v1 < lower (below) *)
           
                     If[
                  v2>=cont[[1]],(* v2 \[GreaterEqual] lower (in or above) *)
 
                                   
                  f=(cont[[1]]-v1)/(v2-v1); (* \[Rule] need a new point *)
   
                                 AppendTo[polygoni,(1-f)*p1+f*p2]
                  ];
                
                If[v2>=cont[[2]]&&Not[c2inf],(* 
                    v2 \[GreaterEqual] upper (above) *)
                  
                  f=(cont[[2]]-v1)/(v2-v1);(* \[Rule] need another new point, 
                    since we have two intersections! *)
                  
                  AppendTo[polygoni,(1-f)*p1+f*p2]
                  ]
                ,
                
                If[v1<cont[[2]]||c2inf,(* 
                    v1 < upper (in, since v1 not < lower) *)
                 
                   AppendTo[polygoni,p1]; (* \[Rule] use point *)
            
                        
                  If[v2<cont[[1]]&&Not[c1inf],(* v2 < lower (below) *)
       
                                 
                    f=(v1-cont[[1]])/(v1-v2); (* \[Rule] need a new point *)
 
                                       AppendTo[polygoni,(1-f)*p1+f*p2];,
                    
                    If[v2>=cont[[2]]&&Not[c2inf],(* 
                        v2 \[GreaterEqual] upper (above) *)
                  
                          f=(cont[[2]]-v1)/(v2-v1); (* \[Rule] 
                          need a new point *)
                      
                      AppendTo[polygoni,(1-f)*p1+f*p2];
                      ]
                    ], (* v1 above *)
                  
                  If[v2<cont[[2]]||c2inf, (* v2 < upper (in or below) *)
     
                                   
                    f=(v1-cont[[2]])/(v1-v2);(* \[Rule] need a new point *)
  
                                      AppendTo[polygoni,(1-f)*p1+f*p2];
                    ];
                  
                  If[v2<cont[[1]]&&Not[c1inf], (* v2 < lower (below) *)
      
                                  
                    f=(v1-cont[[1]])/(v1-v2);(* \[Rule] 
                        need another new point, 
                      since we have two intersections! *)
                    
                    AppendTo[polygoni,(1-f)*p1+f*p2];
                    ]
                  ]
                ]
              ];
            0)&/@xyvin;
      (* Remove duplicates *)
      
      If[Length[polygoni]>1,
        Fold[If[#1\[Equal]{}||#1[[1]]\[NotEqual]#2,Append[#1,#2],#1]&,
          polygoni[[{2}]],Drop[polygoni,2]],{{}}]
      ],{{polygoni,_Real,2},{p1,_Real,1},{p2,_Real,
        1},{v1,_Real},{v2,_Real},{xyvin,_Real,3},{f,_Real,0}}
    ];

PlotTri[xyv_List,cont_List,opt___]:=Module[{minv,maxv,cc,r},
    (* max. and min. of values *)
    
    minv=Min[Last/@xyv];
    maxv=Max[Last/@xyv];
    cc=(Join[#,{(Plus@@#)/2.,False,False}])&/@ (* make pairs of lower tigger, 
          upper trigger and append the average value of the contour for \
determination of plotting color *)
        Select[Partition[cont,2,1],
          (#[[1]]<=maxv&&#[[2]]>=minv)&];
    (* use only contours which actually occur in the triangle, to save time *)

        cc=Join[{{0,First[cont],First[cont],True,False}},
        cc,{{Last[cont],0,Last[cont],False,True}}];
    Select[
      {#[[3]], (* average value; for color *)
            
            DividePoly[xyv,#[[{1,2}]],#[[4]],#[[5]]]
            }&/@cc,
      (* for each contour, partition triangle; if there is a result, 
        select only *)
      Length[#[[2]]]>2&] (* 
      only select non-degenerate polygons *)
    ]

contourTest[ values_, contourLevel_ ] := 
  Which[ # < contourLevel, -1, # > contourLevel, 1, True, 0 ]& /@ values

findContourIntersectionCoord[ { c1_, c2_ }, { v1_, v2_ }, cVal_ ] := 
  c1 + ( c2-c1 )*( v1-cVal )/( v1-v2 )

orderPoints[ { id_, p:{ _ } } ] := {id,p}
orderPoints[ { id_, p:{ _, __ } } ] := {id,Sort[ p ]}

selectNonDuplicate[ { ids_, coords_ } ] := {ids, coords[[1]]}



(* Arguments: list of coordinates, list of incidences, 
  list of FEM result values, options *)

imsUnstructuredContourPlot[co_List,inc_List,val_List,opt___]:=Module[{
      maxv=Max@@val,minv=Min@@val,(* get minimum and maximum values *)
      
      cont, (* store trigger values for individual contours *)
      
      xyv=Transpose[Append[Transpose[co],val]], (* use coordinates, 
        value tupel *) 
      cn,(* number of contours *) 
      pmesh, (* plot mesh yes/no *) 
      cf, (* ColorFunction *)
      cfs , (* ColorFunctionScaling *)
      
      consh, (* ContourShading *)
      is3D
      },
    is3D=(Length[co[[1]]]>2);
    {cn,pmesh,cf,cfs,
        consh}={Contours,Mesh,ColorFunction,ColorFunctionScaling,
            ContourShading}/.{opt}/.Options[imsUnstructuredContourPlot]; (* 
      process options *)
    
    cont=If[Head[cn]===List,minv=cn[[1]];maxv=Last[cn];cn, 
        If[minv\[Equal]maxv,{minv},Range[minv,maxv,(maxv-minv)/cn]]];(* 
      find trigger values for contours *)
    Show[
      If[is3D,Graphics3D[{FaceForm[
                  
                  cf[If[cfs,(1-(#[[1]]-minv)/
                            If[maxv\[Equal]minv,1,(maxv-minv)]),#[[1]]]]], (* 
                  get color from contour central value *)
                
                If[pmesh, (* 
                    if contour lines should be plotted *)
                  \
{If[consh,Polygon,LineC][#[[2]]]}, (* else: *)
                  {EdgeForm[],
                    cf[If[cfs,(1-(#[[1]]-minv)/
                              If[maxv\[Equal]minv,1,(maxv-minv)]),#[[1]]]],
                    If[consh,Polygon,LineC][#[[2]]]}]}&/@
            Flatten[((PlotTri[xyv[[#]]&/@#,cont])&/@inc),1], (* 
            For every triangle, 
            partition for each contour value and plot resulting polygons *)
  
                  FilterOptions[Graphics3D,opt]
          ],
        Graphics[{
                
                cf[If[cfs,(1-(#[[1]]-minv)/
                          If[maxv\[Equal]minv,1,(maxv-minv)]),#[[1]]]], (* 
                  get color from contour central value *)
                
                If[pmesh, (* 
                    if contour lines should be plotted *)
                  \
{If[consh,Polygon[#[[2]]],{}],GrayLevel[0],LineC[#[[2]]]}, (* 
                    else: *)
                  {If[consh,Polygon,
                        LineC][#[[2]]]}]}&/@
            Flatten[((PlotTri[xyv[[#]]&/@#,cont])&/@inc),1], (* 
            For every triangle, 
            partition for each contour value and plot resulting polygons *)
  
                  FilterOptions[Graphics,opt]]],
      FilterOptions[Show,opt]]
    ]



imsUnstructuredContourPlot3D[co_List,inc_List,val_List,opt___]:=Module[{
      maxv=Max@@val,minv=Min@@val,(* get minimum and maximum values *)
      
      cont, (* store trigger values for individual contours *)
      
      xyv=Transpose[Append[Transpose[co],val]], (* use coordinates, 
        value tupel *) 
      cn,(* number of contours *) 
      pmesh ,(* plot mesh yes/no *) 
      cf, (* ColorFunction *)
      cfs,  (* ColorFunctionScaling *)
      
      consh (* ContourShading *)
      },
    {cn,pmesh,cf,cfs,
        consh}={Contours,Mesh,ColorFunction,ColorFunctionScaling,
            ContourShading}/.{opt}/.Options[imsUnstructuredContourPlot3D]; (* 
      process options *)
    
    cont=If[Head[cn]===List,minv=cn[[1]];maxv=Last[cn];cn,
        If[minv\[Equal]maxv,{minv},Range[minv,maxv,(maxv-minv)/cn]]];(* 
      find trigger values for contours *)
    Show[
      Graphics3D[{
              
              FaceForm[
                cf[If[cfs,(1-(#[[1]]-minv)/
                          If[maxv\[Equal]minv,1,(maxv-minv)]),#[[1]]]]],
               (* get color from contour central value *)
              
              If[pmesh,
                If[consh,Polygon,LineC][#[[2]]], (* 
                  if contour lines should be plotted *)
                \
{EdgeForm[],cf[If[cfs,(1-(#[[1]]-minv)/
                            If[maxv\[Equal]minv,1,(maxv-minv)]),#[[1]]]],
                  If[consh,Polygon,LineC][#[[2]]]}
                ] (* else: *)
              }&/@
          Flatten[((PlotTri[xyv[[#]]&/@#,cont])&/@
                Union[Sort/@Flatten[Table[Drop[#,{i}],{i,1,4}]&/@inc,1]]),
            1], (* For every triangle, 
          partition and plot resulting polygons *)
        (* 
          oli: Lighting -> False only works for mma5.2 and below *)
        
        FilterOptions[Graphics3D,opt,Lighting\[Rule]False] ],
      FilterOptions[Show,opt]]
    ]



imsUnstructuredMeshPlot[co_List,inc_List,opt___]:=
  Show[If[Length[co[[1]]]>2,Graphics3D,Graphics][
      Line[Join[co[[#]]&/@#,{co[[#[[1]]]]}]]&/@inc,
      FilterOptions[If[Length[co[[1]]]>2,Graphics3D,Graphics],opt]],
    FilterOptions[Show,opt]]



imsUnstructuredPlot3D[co_List,inc_List,val_List,opt___]:=
  Module[{pmesh,xyv=Transpose[Append[Transpose[co],val]]},
    pmesh=Mesh/.{opt}/.Options[imsUnstructuredPlot3D];
    Show[Graphics3D[
        If[pmesh,
              Polygon[Join[xyv[[#]]&/@#,{xyv[[#[[1]]]]}]],{EdgeForm[],
                Polygon[Join[xyv[[#]]&/@#,{xyv[[#[[1]]]]}]]}]&/@inc,
        FilterOptions[Graphics3D,opt]],FilterOptions[Show,opt]]]



imsUnstructuredContourPlotWritePovray[co_List,inc_List,val_List,opt___]:=
  Module[{
      maxv=Max@@val,minv=Min@@val,(* get minimum and maximum values *)
      
      cont, (* store trigger values for individual contours *)
      
      xyv=Transpose[Append[Transpose[co],val]], (* use coordinates, 
        value tupel *) 
      cn,(* number of contours *) 
      pmesh, (* plot mesh yes/no *) 
      cf, (* ColorFunction *)
      cfs ,(* ColorFunctionScaling *)
      ps,
      data,ptr,colstr,cfev,bbox,bboxcorners,
      center,preamb,camera
      },
    bbox={{Min@@co[[All,1]],Min@@co[[All,2]],
          Min@@co[[All,3]]},{Max@@co[[All,1]],Max@@co[[All,2]],
          Max@@co[[All,3]]}};
    bboxcorners=Tuples[Transpose[bbox]];
    center=Plus@@bbox/2;
    {cn,cf,cfs,camera,
        preamb}={Contours,ColorFunction,ColorFunctionScaling,imsCamera,
            imsPovrayPreamble}/.{opt}/.Options[
          imsUnstructuredContourPlotWritePovray]; (* process options *)
    
    If[preamb===Automatic,preamb=POVraypreamble];
    If[camera===Automatic,camera="camera {\n
              right <-4/3,0,0>\n
              direction <0, 1, 0>\n
              sky <0,0,1>\n
          	location  "<>ListToPovvec[
            center-{1.,
                  2.,-0.5}*(Max@@(povCamDist[center,#,{1.,2.,-0.5},
                            30 \[Degree]]&/@bboxcorners))]<>"\n
          	angle 40\n
          	look_at   "<>ListToPovvec[N[center]]<>"\n
           }\n"];
    If[cn=!=\[Infinity],
      
      (* finite number of contours, so do subdivision ourselves *)
      
      cont=If[Head[cn]===List,minv=cn[[1]];maxv=Last[cn];cn,
          If[minv\[Equal]maxv,{minv},Range[minv,maxv,(maxv-minv)/cn]]];(* 
        find trigger values for contours *)
      
      ptr=N[Flatten[((PlotTri[xyv[[#]]&/@#,cont])&/@inc),1]];
      colstr=(("#declare ContourColor"<>
                  StringReplace[MyToString[#],{"."\[Rule]"p","-"\[Rule]"m"}]<>
                  " = texture { pigment { color rgb"<>ListToPovvec[
                    ToRGBColor[
                      cf[If[cfs,(1-(#-minv)/
                                If[maxv\[Equal]minv,1,(maxv-minv)]),#]]]]<>
                  " } }\n")&/@Union[ptr[[All,1]]]);
      
      ps={#[[1]],PolyToTri[#[[2]]]}&/@ptr;
      data=Flatten[(cfev=#[[1]];{cfev,#}&/@#[[2]])&/@ps,1];
      
      preamb<>"\n"<>camera<>"\n"<>colstr<>
        "object{mesh {\n"<>((" triangle {"<>StringJoin@@(
                      (ListToPovvec[#]<>" ")&/@#[[2]])<>
                  "\n   texture { ContourColor"<>
                  StringReplace[
                    MyToString[#[[1]]],{"."\[Rule]"p","-"\[Rule]"m"}]<>
                  "} }\n")&/@N[data])<>"}}\n",
      
      (* infinite number of contours, so let povray do the job *)
      
      ps=Flatten[If[Length[#]>3,PolyToTri[#],{#}]&/@inc,1];
      preamb<>"\n"<>camera<>"\n"<>"object{ mesh2 {\n"<>
        "  vertex_vectors { "<>
        ToString[Length[co]]<>","<>
        
        StringDrop[StringJoin@@(("\n    "<>ListToPovvec[#]<>",")&/@co),-1]<>"\n  }\n  texture_list { "<>
        ToString[Length[val]]<>","<>
        StringDrop[
          StringJoin@@(("\n    "<>"texture { pigment { color rgb "<>
         
                                   
                      ListToPovvec[
                        ToRGBColor[
                          cf[If[cfs,(1-(#-minv)/
                                    If[maxv\[Equal]minv,1,(maxv-minv)]),#]]]]<>
                      " }},")&/@val),-1]<>
        "\n  }\n  face_indices { "<>
        ToString[Length[ps]]<>","<>
        StringDrop[
          StringJoin@@(("\n    "<>ListToPovvec[#-1]<>","<>
                   
                         StringDrop[StringDrop[ListToPovvec[#-1],-1],1]<>
                      ",")&/@ps),-1]
      <>"\n  }\n"<>"}}\n"
      ]
    ]



imsFindContourElements[ incidents_, values_, contourLevel_ ] := Module[
      { contourTestedValues,sortedContourTestedValues },
      
      contourTestedValues = contourTest[ values, contourLevel ];
      sortedContourTestedValues = contourTestedValues[[ # ]]& /@ incidents;
      
      Return[ 
        Flatten[ 
          Position[ 
            Union[ # ]& /@ 
              sortedContourTestedValues, _?(Length[ # ]\[GreaterEqual] 
                    2&) ] ] ];
      ];



imsFindContour[coords_,incidents_,values_,contourLevel_]:=Module[
    {contourElements,contourIncidents,contourCoords,contourVals,coordList,
      theseValues,belowLevelPosition,abouveLevelPosition,onLevelPosition,
      intersectionPos,x,y,rest,newCoords,lst,newCoordList},
    
    contourElements=imsFindContourElements[incidents,values,contourLevel];
    
    contourIncidents=incidents[[contourElements]];
    contourCoords=coords[[#]]&/@contourIncidents;
    contourVals=values[[#]]&/@contourIncidents;
    
    coordList={};
    Do[
      belowLevelPosition=
        Flatten[Position[theseValues=contourVals[[i]],_?(#<contourLevel&)]];
      abouveLevelPosition=Flatten[Position[theseValues,_?(#>contourLevel&)]];
      onLevelPosition=Flatten[Position[theseValues,_?(#==contourLevel&)]];
      
      Which[
        (* we have no interface passing through a contour level *)
        
        Length[ onLevelPosition ]\[Equal]0,
        
        intersectionPos=
          Flatten[Outer[List,belowLevelPosition,abouveLevelPosition],
              1]/.{x_List,y_List,rest__}\[Rule]Reverse[{x,y,rest}];
        newCoords=
          findContourIntersectionCoord[contourCoords[[i]][[#]],
                theseValues[[#]],contourLevel]&/@intersectionPos;,
        
        (* we have a segment passing through a contour *)
        
        Length[ onLevelPosition ]\[GreaterEqual] 1 &&  
          Length[ belowLevelPosition ]\[GreaterEqual] 1 && 
          Length[ abouveLevelPosition ]\[GreaterEqual] 1,
        intersectionPos=
          Flatten[Outer[List,belowLevelPosition,abouveLevelPosition],
              1]/.{x_List,y_List,rest__}\[Rule]Reverse[{x,y,rest}];
        newCoords=
          Join[ findContourIntersectionCoord[contourCoords[[i]][[#]],
                  theseValues[[#]],contourLevel]&/@intersectionPos, 
            contourCoords[[i]][[onLevelPosition]] ];
        ,
        
        (* we have only a contour point *)
        True, 
        newCoords=contourCoords[[i]][[onLevelPosition]];
        ];
      
      (* Print[ contourElements[[i]], " ", newCoords ]; *)
      
      (* AppendTo[coordList,newCoords]; *)
      
      AppendTo[ coordList, { contourElements[[i]], newCoords } ]
      ,{i,Length[contourElements]}
      ];
    
    (* in 3D we convert the polygons to triangles *)
    
    newCoordList =
      coordList /. { id_, { p1_List, p2_List, p3_List, p4_List } } \[Rule] 
          Sequence[ { id, {p1,p2,p3}  },{id, {p3,p4,p1}}];
    
    (* sort the duplicate entries *)
    
    lst = selectNonDuplicate/@(Transpose /@ 
            Split[ Sort[ orderPoints /@ newCoordList, 
                OrderedQ[{ #1[[2]], #2[[2]] } ]& ], #1[[2]] \[Equal] #2[[2]]& \
]);
    
    Return[lst];
    ]



End[]; (* of Begin Private *)



Protect[imsUnstructuredContourPlot,imsUnstructuredMeshPlot,
    imsUnstructuredPlot3D,imsUnstructuredContourPlot3D] ;(* anything *) 
EndPackage[] ;



