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
(* Title: StructuredMesher.m *)
(* Context: *)
(* 
  Author:christian moosmann *)
(* Date: 14.3.2006, Freiburg *)
(* 
  Summary: tools for generating structured meshes *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.25 *)
(* 
  Mathematica Version: 5.2 *)
(* History: 
  ;
  14.3.:Bug in quadratic 3D mesh (incedents);
  13.3.: added Wrapper, added Option imsCoordinateMapping;
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

(* <one line to give the program's name and a brief idea of what it does.> *)
\

(* Copyright (C) <year> <name of author> *)

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
BeginPackage["Imtek`StructuredMesher`"];





(* *)
(* documentation *)
(* *)

(* constructors *)

imsGenerateLinearStructuredMesh::usage="imsGenerateLinearStructuredMesh[ xdiv (, ydiv, zdiv) ] generates a linear structured mesh in domain (-1 (, -1,-1) ) to ( 1 (, 1, 1))"

imsGenerateQuadraticStructuredMesh::usage="imsGenerateQuadraticStructuredMesh[ xdiv (, ydiv, zdiv) ] generates a quadratic structured mesh in domain (-1 (, -1,-1) ) to ( 1 (, 1, 1))"

imsGenerateUnitLinearMesh1D::usage="imsGenerateUnitLinearMesh1D[ xdiv ] generates a linear stuctured mesh in Domain (-1) to (1)"

imsGenerateUnitQuadraticMesh1D::usage="imsGenerateUnitQuadraticMesh1D[ xdiv ] generates a quadratic stuctured mesh in Domain (-1) to (1)"

imsGenerateUnitLinearMesh2D::usage="imsGenerateUnitLinearMesh2D[ xdiv, ydiv ] generates a linear stuctured mesh in Domain (-1,-1) to (1,1)"

imsGenerateUnitQuadraticMesh2D::usage="imsGenerateUnitQuadraticMesh2D[ xdiv, ydiv ] generates a quadratic stuctured mesh in Domain (-1,-1) to (1,1)"

imsGenerateUnitLinearMesh3D::usage="imsGenerateUnitLinearMesh3D[ xdiv, ydiv, zdiv ] generates a linear stuctured mesh in Domain (-1,-1,-1) to (1,1,1)"

imsGenerateUnitQuadraticMesh3D::usage="imsGenerateUnitQuadraticMesh3D[ xdiv, ydiv, zdiv ] generates a quadratic stuctured mesh in Domain (-1,-1,-1) to (1,1,1)"
\


(* selectors *)

(* mutators *)

imsGlueNexi::usage="imsGlueNexi[firstNexus,secondNexus,accuracy] glues two nexi together by merging nodes that are the same by accuracy"
\

(* predicates *)

(* functions *)




(* *)
(* options docu *)
(* *)

imsCoordinateMapping::usage="mapping the coordinates to another domain"



(* *)
(* error messages *)
(* *)



Begin["`Private`"];



(* *)
Needs["Imtek`Graph`"]
Needs["Imtek`MeshElementLibrary`"]
Needs["Imtek`ShapeFunctions`"]
Needs[ "Imtek`Point`" ]
Needs["Utilities`FilterOptions`"];
(* private imports *)
(* *)



(* *)
(* implementation part *)
(* *)

(* wrapper *)

imsGenerateLinearStructuredMesh[xdiv_Integer,ydiv_Integer,zdiv_Integer,
      opts:(_Rule...)]:=imsGenerateUnitLinearMesh3D[xdiv,ydiv,zdiv,opts];
imsGenerateLinearStructuredMesh[xdiv_Integer,ydiv_Integer,opts:(_Rule...)]:=
    imsGenerateUnitLinearMesh2D[xdiv,ydiv,opts];
imsGenerateLinearStructuredMesh[xdiv_Integer,opts:(_Rule...)]:=
    imsGenerateUnitLinearMesh1D[xdiv,opts];

imsGenerateQuadraticStructuredMesh[xdiv_Integer,ydiv_Integer,zdiv_Integer,
      opts:(_Rule...)]:=imsGenerateUnitQuadraticMesh3D[xdiv,ydiv,zdiv,opts];
imsGenerateQuadraticStructuredMesh[xdiv_Integer,ydiv_Integer,opts:(_Rule...)]:=
    imsGenerateUnitQuadraticMesh2D[xdiv,ydiv,opts];
imsGenerateQuadraticStructuredMesh[xdiv_Integer,opts:(_Rule...)]:=
    imsGenerateUnitQuadraticMesh1D[xdiv,opts];


(* constructor *)

(*    *)
(* 1D *)
(*    *)

imsGenerateUnitLinearMesh1D[xdiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,coordsMapping},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitLinearMesh1D];
    coords=coordsMapping[#]&/@Table[{i-1},{i,0,2,2/xdiv}];
    incidents=Table[{i,i+1},{i,1,xdiv}];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=MapIndexed[imsMakeLineLinear1DOF[ #2[[1]], #1]&,incidents];
    boundaryIncs={{1},{xdiv+1}};
    Return[
      imsMakeNexus[ imsSetMarkers[allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]


imsGenerateUnitQuadraticMesh1D[xdiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,coordsMapping},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitQuadraticMesh1D];
    coords=coordsMapping[#]&/@Table[{i-1},{i,0,2,1/xdiv}];
    incidents=Table[{i,2+i,1+i},{i,1,2xdiv,2}];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=
      MapIndexed[imsMakeLineQuadratic1DOF[ #2[[1]], #1]&,incidents];
    boundaryIncs={{1},{2xdiv+1}};
    (*boundaryIncs=
          Partition[
            Sort[Join[Range[1,2 xdiv+1,1],
                Range[(3 xdiv+2)*ydiv+1,(3 xdiv+2)*ydiv+2xdiv+1],
                Table[i(3xdiv+2),{i,ydiv}],
                Table[2 xdiv+1 +i(3xdiv+2),{i,ydiv-1}] ,
                Table[1 +i(3xdiv+2),{i,ydiv-1}] ,
                Table[2 xdiv+2 +i(3xdiv+2),{i,0,ydiv-1}]  ]],1];*)
    
    Return[imsMakeNexus[  imsSetMarkers[allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]


(*    *)
(* 2D *)
(*    *)

imsGenerateUnitLinearMesh2D[xdiv_,ydiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,coordsMapping,id,co,
      rest},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitLinearMesh2D];
    coords=#-{1,1}&/@Flatten[Table[{i,j},{j,0,2,2/ydiv},{i,0,2,2/xdiv}],1];
    incidents=
      Flatten[Table[{i+j*(xdiv+1)+1,i+j*(xdiv+1)+2,i+(j+1)*(xdiv+1)+2,
            i+(j+1)*(xdiv+1)+1},{j,0,ydiv-1},{i,0,xdiv-1}],1];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=MapIndexed[imsMakeQuadLinear1DOF[ #2[[1]], #1]&,incidents];
    boundaryIncs=
      Select[allNodes,(imsGetCoords[#][[1]]\[Equal]-1||
                imsGetCoords[#][[1]]\[Equal]1||imsGetCoords[#][[2]]\[Equal]-1||
                imsGetCoords[#][[2]]\[Equal]1)&]/.imsNode[id_,
            rest___]\[Rule]{id};
    allNodes=
      allNodes/.imsNode[id_,co_,rest___]\[RuleDelayed]imsNode[id,
            coordsMapping[co],rest];
    Return[
      imsMakeNexus[ imsSetMarkers[allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]


imsGenerateUnitQuadraticMesh2D[xdiv_,ydiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,coordsMapping,id,co,
      rest},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitQuadraticMesh2D];
    coords=
      Sort[Join[#-{1,1}&/@
            Flatten[Table[{i,j},{j,0,2,2/ydiv},{i,0,2,2/xdiv}],1],#-{1,1}&/@
            Flatten[Table[{i,j},{j,0,2,2/ydiv},{i,1/xdiv,(2xdiv-1)/xdiv,
                  2/xdiv}],1],#-{1,1}&/@
            Flatten[Table[{i,j},{j,1/ydiv,(2 ydiv-1)/ydiv,2/ydiv},{i,0,2,
                  2/xdiv}],1]],OrderedQ[{#1[[{2,1}]],#2[[{2,1}]]}]&];
    incidents=Flatten[Table[{
             2 i+j* (3 xdiv+2)+1 ,2 i+j* (3 xdiv+2)+3,2i+3+(j+1)*(2+3 xdiv),
            2i+1+(j+1)*(2+3 xdiv),
            2 i+j* (3 xdiv+2)+2,i+j* (3 xdiv+2)+3 +2 xdiv,
            2i+2+(j+1)*(2+3 xdiv),i+j* (3 xdiv+2)+2 +2 xdiv
              },{j,0,ydiv-1},{i,0,xdiv-1}],1];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=
      MapIndexed[imsMakeQuadQuadratic1DOFSerendipity[ #2[[1]], #1]&,
        incidents];
    boundaryIncs=
      Select[allNodes,(imsGetCoords[#][[1]]\[Equal]-1||
                imsGetCoords[#][[1]]\[Equal]1||imsGetCoords[#][[2]]\[Equal]-1||
                imsGetCoords[#][[2]]\[Equal]1)&]/.imsNode[id_,
            rest___]\[Rule]{id};
    (*boundaryIncs=
          Partition[
            Sort[Join[Range[1,2 xdiv+1,1],
                Range[(3 xdiv+2)*ydiv+1,(3 xdiv+2)*ydiv+2xdiv+1],
                Table[i(3xdiv+2),{i,ydiv}],
                Table[2 xdiv+1 +i(3xdiv+2),{i,ydiv-1}] ,
                Table[1 +i(3xdiv+2),{i,ydiv-1}] ,
                Table[2 xdiv+2 +i(3xdiv+2),{i,0,ydiv-1}]  ]],1];*)
    
    allNodes=allNodes/.imsNode[id_,co_,rest___]\[RuleDelayed]imsNode[id,
            coordsMapping[co],rest];
    Return[
      imsMakeNexus[  imsSetMarkers[allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]


(*    *)
(* 3D *)
(*    *)

imsGenerateUnitLinearMesh3D[xdiv_,ydiv_,zdiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,coordsMapping,id,co,
      rest},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitLinearMesh3D];
    coords=#-{1,1,1}&/@
        Flatten[Table[{i,j,k},{k,0,2,2/zdiv},{j,0,2,2/ydiv},{i,0,2,2/xdiv}],
          2];
    incidents=
      Flatten[Table[{i+j*(xdiv+1)+(k+1)*((xdiv+1)*(ydiv+1))+1,
            i+j*(xdiv+1)+(k+1)*((xdiv+1)*(ydiv+1))+2,
            i+(j+1)*(xdiv+1)+(k+1)*((xdiv+1)*(ydiv+1))+2,
            i+(j+1)*(xdiv+1)+(k+1)*((xdiv+1)*(ydiv+1))+1,
            i+j*(xdiv+1)+k*((xdiv+1)*(ydiv+1))+1,
            i+j*(xdiv+1)+k*((xdiv+1)*(ydiv+1))+2,
            i+(j+1)*(xdiv+1)+k*((xdiv+1)*(ydiv+1))+2,
            i+(j+1)*(xdiv+1)+k*((xdiv+1)*(ydiv+1))+1},{k,0,zdiv-1},{j,0,
            ydiv-1},{i,0,xdiv-1}],2];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=
      MapIndexed[imsMakeHexahedronLinear1DOF[ #2[[1]], #1]&,incidents];
    boundaryIncs=
      Select[allNodes,(imsGetCoords[#][[1]]\[Equal]-1||
                imsGetCoords[#][[1]]\[Equal]1||imsGetCoords[#][[2]]\[Equal]-1||
                imsGetCoords[#][[2]]\[Equal]1||imsGetCoords[#][[3]]\[Equal]-1||
                imsGetCoords[#][[3]]\[Equal]1)&]/.imsNode[id_,
            rest___]\[Rule]{id};
    allNodes=
      allNodes/.imsNode[id_,co_,rest___]\[RuleDelayed]imsNode[id,
            coordsMapping[co],rest];
    Return[
      imsMakeNexus[ imsSetMarkers[ allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]


imsGenerateUnitQuadraticMesh3D[xdiv_,ydiv_,zdiv_,opts___]:=Module[
    {coords,incidents,allNodes,allElements,boundaryIncs,faceBase,faceHalf,
      lineBase,lineHalf,completeFace,completeLine,coordsMapping,id,co,rest},
    coordsMapping=
      imsCoordinateMapping/.{opts}/.Options[imsGenerateUnitQuadraticMesh3D];
    coords=
      Sort[Join[#-{1,1,1}&/@
            Flatten[Table[{i,j,k},{k,0,2,2/zdiv},{j,0,2,2/ydiv},{i,0,2,
                  2/xdiv}],2],#-{1,1,1}&/@
            Flatten[Table[{i,j,k},{k,0,2,2/zdiv},{j,0,2,2/ydiv},{i,
                  1/xdiv,(2xdiv-1)/xdiv,2/xdiv}],2],#-{1,1,1}&/@
            Flatten[Table[{i,j,k},{k,0,2,2/zdiv},{j,1/ydiv,(2 ydiv-1)/ydiv,
                  2/ydiv},{i,0,2,2/xdiv}],2],
          #-{1,1,1}&/@
            Flatten[Table[{i,j,k},{k,1/zdiv,(2 zdiv-1)/zdiv,2/zdiv},{j,0,2,
                  2/ydiv},{i,0,2,2/xdiv}],2]],
        OrderedQ[{#1[[{3,2,1}]],#2[[{3,2,1}]]}]&];
    faceBase=(2 xdiv+1)*(2ydiv+1)-xdiv*ydiv;
    faceHalf=(xdiv+1)*(ydiv+1);
    completeFace=faceBase+faceHalf;
    lineBase= 2xdiv +1;
    lineHalf=xdiv +1;
    completeLine=lineBase+lineHalf;
    incidents=Flatten[Table[{
            (k+1)*completeFace+
              j*completeLine+2i+3,(k+1)*completeFace+(j+1)*
                completeLine+2i+3,(k+1)*completeFace+(j+1)*
                completeLine+2i+1,(k+1)*completeFace+j*completeLine+2i+1,
            k*completeFace+j*completeLine+2i+3,
            k*completeFace+(j+1)*completeLine+2i+3,
            k*completeFace+(j+1)*completeLine+2i+1,
            k*completeFace+j*completeLine+2i+1,
            (k+1)*completeFace+j*completeLine+lineBase+
              i+2,(k+1)*completeFace+(j+1)*completeLine+2i+2,(k+1)*
                completeFace+j*completeLine+lineBase+i+1,(k+1)*completeFace+
              j*completeLine+2i+2,
            (k)*completeFace+j*completeLine+lineBase+
              i+2,(k)*completeFace+(j+1)*completeLine+2i+2,(k)*completeFace+
              j*completeLine+lineBase+i+1,(k)*completeFace+
              j*completeLine+2i+2,
            k*completeFace+faceBase+j*(xdiv+1)+i+2,
            k*completeFace+faceBase+(j+1)*(xdiv+1)+i+2,
            k*completeFace+faceBase+(j+1)*(xdiv+1)+i+1,
            k*completeFace+faceBase+j*(xdiv+1)+i+1
            },
          {k,0,zdiv-1},{j,0,ydiv-1},{i,0,xdiv-1}],2];
    allNodes=MapIndexed[imsMakeNode[ #2[[1]], #1]&,coords];
    allElements=
      MapIndexed[imsMakeHexahedronQuadratic1DOFSerendipity[ #2[[1]], #1]&,
        incidents];
    boundaryIncs=
      Select[allNodes,(imsGetCoords[#][[1]]\[Equal]-1||
                imsGetCoords[#][[1]]\[Equal]1||imsGetCoords[#][[2]]\[Equal]-1||
                imsGetCoords[#][[2]]\[Equal]1||imsGetCoords[#][[3]]\[Equal]-1||
                imsGetCoords[#][[3]]\[Equal]1)&]/.imsNode[id_,
            rest___]\[Rule]{id};
    allNodes=
      allNodes/.imsNode[id_,co_,rest___]\[RuleDelayed]imsNode[id,
            coordsMapping[co],rest];
    Return[
      imsMakeNexus[ imsSetMarkers[ allNodes[[Flatten[boundaryIncs]]],1],
        Delete[allNodes,boundaryIncs], allElements ]]
    ]



(* *)



(* *)
(* define your options *)
(* *)

Options[imsGenerateUnitLinearMesh1D]=
    Options[imsGenerateUnitQuadraticMesh1D]=
      Options[imsGenerateUnitLinearMesh2D]=
        Options[imsGenerateUnitQuadraticMesh2D]=
          Options[imsGenerateUnitLinearMesh3D]=
            Options[imsGenerateUnitQuadraticMesh3D]=
              Options[imsGenerateLinearStructuredMesh]=
                Options[
                    imsGenerateQuadraticStructuredMesh]={imsCoordinateMapping \
\[Rule] Identity};





(* selector *)
(* *)



(* mutator *)

imsGlueNexi[firstNexus_imsNexus,secondNexus_imsNexus,accuracy_]:=Module[
    {id,coords,marker,rest,nodesOne,maxNodeOne,maxElementOne,nodesTwo,
      actualNode,coordFunc,nodeCoords,nodeData,mergedNodes,rulesList , 
      elementsTwo,nodeIDs, elementType},
    
    nodesOne=
      imsGetNodes[
          firstNexus]/.imsNode[id_,coords_,marker_,rest___]\[RuleDelayed]
          imsNode[id,imsRound[coords,accuracy],marker,rest];
    maxNodeOne=imsGetIds[Last[nodesOne]];
    nodesTwo=
      imsGetNodes[
          secondNexus]/.imsNode[id_,coords_,marker_,rest___]\[RuleDelayed]
          imsNode[id+maxNodeOne,imsRound[coords,accuracy],marker,rest];
    Do[
      actualNode=nodesTwo[[i]];
      coordFunc[imsGetCoords[actualNode]]=
        If[imsDataNodeQ[actualNode],{imsGetIds[actualNode],
            imsGetMarkers[actualNode],imsGetValues[actualNode],
            imsGetDatas[actualNode]},{imsGetIds[actualNode],
            imsGetMarkers[actualNode],imsGetValues[actualNode]}];
      ,{i,1,Length[nodesTwo]}];
    Do[
      actualNode=nodesOne[[i]];
      coordFunc[imsGetCoords[actualNode]]=
        If[imsDataNodeQ[actualNode],{imsGetIds[actualNode],
            imsGetMarkers[actualNode],imsGetValues[actualNode],
            imsGetDatas[actualNode]},{imsGetIds[actualNode],
            imsGetMarkers[actualNode],imsGetValues[actualNode]}];
      ,{i,1,Length[nodesOne]}];
    nodeCoords=(DownValues[coordFunc]/.coordFunc\[Rule]List)[[All,1,1,1]];
    nodeData=(DownValues[coordFunc]/.coordFunc\[Rule]List)[[All,2]];
    mergedNodes=
      Sort[Transpose[{Transpose[{nodeCoords}],
              Transpose[{nodeData}]}]/.{{coords_},{{id_Integer,marker_,
                  rest_}}}\[RuleDelayed]imsMakeNode[id,coords,marker,rest]];
    rulesList=
      Table[imsGetIds[mergedNodes[[i]]]->i,{i,1,Length[mergedNodes]}];
    mergedNodes=
      mergedNodes/.imsNode[id_,rest___]\[RuleDelayed]
          imsNode[id/.rulesList,rest];
    maxElementOne=imsGetIds[Last[imsGetElements[ firstNexus ]]];
    elementsTwo=
      imsGetElements[
          secondNexus]/.elementType_[id_Integer,nodeIDs_List,
            rest___]\[RuleDelayed]
          elementType[
            id+maxElementOne,(coordFunc[#][[1]]&/@
                  imsGetCoords[nodesTwo[[nodeIDs]]])/.rulesList,rest];
    Return[
      imsMakeNexus[ Select[mergedNodes,imsGetMarkers[#]\[NotEqual]0&],
        Select[mergedNodes,imsGetMarkers[#]==0&],
        Join[imsGetElements[ firstNexus ],elementsTwo] ]]
    ]

(* *)



(* predicates *)
(* *)



(* private functions *)

imsRound[number_,precision_]:=N[precision*Round[number/precision]]
SetAttributes[imsRound, Listable]

(* *)

(* public functions *)
(* *)



(* representors *)
(* *)



(* Begin Private *)
End[]



(* Protect[] *)
EndPackage[] 
