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
(* Title: ExamplePackage.m *)
(* Context: *)
(* 
  Author:oliver ruebenkoenig *)
(* Date: 11.7.2005, Freiburg *)
(* 
  Summary: This is the IMTEK FEMFluidics packages *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.2 *)
(* 
  Mathematica Version: 5.1 *)
(* History:
      4.9.2007: fixed for mma6.0;
   *)
(* Keywords: *)
(* Sources: google for: per-olof persson, 
  implementation of finte element-based navier stokes solver;
  C. Vuikt, FEM for navier-stokes;
  hui chunyiu, joseph,
  application of mesh generation on solving navier-stokes equation *)
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

(* This package provides FEM fluidics operatos *)

(* Copyright (C) 2005 oliver ruebenkoenig, zhenyu liu *)

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

BeginPackage["Imtek`FEMFluidics`", "Imtek`FEMOperators`", 
    "Imtek`MeshElementLibrary`", "Imtek`ShapeFunctions`", "Imtek`Assembler`", 
    "Imtek`Nodes`"];





(* *)
(* documentation *)
(* *)

(* constructors *)

(* selectors *)

(* predicates *)

(* functions *)

imsFEMStokes::usage="imsFEMStokes[ { inESM, inERHS }, elem, elementNodes, densityViscosity ] computes the system of Stokes equations. -\[Del]\[Rho]\[Nu]\[Del]u+\[Del]p=0 and \[Del]u=0. Where u is the u-velocity and the v-velocity and p is the pressure. \[Rho] is the mass density and \[Nu] is the kinematic viscosity.";\

imsNFEMStokes::usage="computes a numerical equivalent of imsFEMStokes.";

imsFEMNavier::usage="imsFEMNavier[ { inESM, inERHS }, elem, elementNodes, uOld,  massDensityVal ] computes the linearized Navier part. \[Rho](u\[Del])u where u is the x and y velocity and \[Rho] is the mass density. For the linearization the solution values of the preivious time step are needed.";\

imsNFEMNavier::usage="computes a numerical equivalent of imsFEMNavier.";

imsFEMFluidicsLoad::usage="imsFEMFluidicsLoad[ { inESM, inERHS }, elem, elementNodes, uLoad, vLoad, pLoad ] computes load for u, v and p.";\

imsNFEMFluidicsLoad::usage="computes a numerical equivalent of imsFEMFluidicsLoad.";\


imsFEMFluidicsTransientMatrix::usage="imsFEMFluidicsTransientMatrix[ { inESM, inERHS }, elem, elementNodes, \[Rho]1, \[Rho]2, \[Rho]3 ] computes \[Rho] \[PartialD]u/\[PartialD]t. Where u is the unknown function and \[Rho]1 is the mass density function of u-velocity, \[Rho]2 of the v-velocity and \[Rho]3 of the pressure.";\

imsNFEMFluidicsTransientMatrix::usage="computes a numerical equivalent of imsFEMFluidicsTransientMatrix.";



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

If[ $VersionNumber \[LessEqual] 5.2, <<LinearAlgebra`MatrixManipulation`, 
    Null ];
If[ $VersionNumber \[LessEqual] 5.2, myBlockMatrix[ x_ ] := BlockMatrix[ x ], 
    myBlockMatrix[ x_ ]:= ArrayFlatten[ x ] ];



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



imsFEMStokes[ { inESM_, inERHS_ }, elem_, elementNodes_, densityViscosity_ ]:=

        Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S1SF,
        KuuST, KvvST, KupST, KvpST,KpuST, KpvST ,
        densityViscosityVals,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      
      (* shape functions *)
      
      sf1 =imsIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0, {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0, {primaryDOFs}, {secondaryDOFs} ];
      emptyS1S1SF = Table[ 0, {secondaryDOFs}, {secondaryDOFs} ];
      KuuST = KvvST =emptyS2S2SF;
      KupST = KvpST = emptyS2S1SF;
      KpuST = KpvST = Transpose[ emptyS2S1SF ];
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      densityViscosityVals =( 
              densityViscosity @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      (* integration *)
      Do[ 
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* local K and L *)
        
        weight =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuST += (Transpose[ sf2xyderiv ] . densityViscosityVals[[ step ]] . 
                sf2xyderiv) * weight;
        KvvST = KuuST;
        
        KupST += ( Transpose[ { sf2[[ step ]] } ] . { sf1xyderiv[[ 1 ]] } ) * 
            weight;
        KvpST += ( Transpose[ { sf2[[ step ]] } ] . { sf1xyderiv[[ 2 ]] } ) * 
            weight;
        
        KpuST += ( Transpose[ { sf1[[ step ]] } ] . { sf2xyderiv[[ 1 ]] } ) * 
            weight;
        KpvST += ( Transpose[ { sf1[[ step ]] } ] . { sf2xyderiv[[ 2 ]] } ) * 
            weight;
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      
      outESMvalues += myBlockMatrix[ {
            { KuuST, emptyS2S2SF, KupST },
            { emptyS2S2SF, KvvST, KvpST},
            { KpuST, KpvST, emptyS1S1SF }
            } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          inERHS
          } ];
      ];



imsNFEMStokes[ { inESM_, inERHS_ }, elem_, elementNodes_, densityViscosity_ ]:=

        Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S1SF,
        KuuST, KvvST, KupST, KvpST,KpuST, KpvST ,
        densityViscosityVals,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      
      (* shape functions *)
      
      sf1 =imsNIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsNIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsNIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsNIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsNIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0., {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0., {primaryDOFs}, {secondaryDOFs} ];
      emptyS1S1SF = Table[ 0., {secondaryDOFs}, {secondaryDOFs} ];
      KuuST = KvvST =emptyS2S2SF;
      KupST = KvpST = emptyS2S1SF;
      KpuST = KpvST = Transpose[ emptyS2S1SF ];
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      densityViscosityVals =( 
              densityViscosity @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      (* integration *)
      Do[ 
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* local K and L *)
        
        weight =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuST += (Transpose[ sf2xyderiv ] . densityViscosityVals[[ step ]] . 
                sf2xyderiv) * weight;
        KvvST = KuuST;
        
        KupST += ( Transpose[ { sf2[[ step ]] } ] . { sf1xyderiv[[ 1 ]] } ) * 
            weight;
        KvpST += ( Transpose[ { sf2[[ step ]] } ] . { sf1xyderiv[[ 2 ]] } ) * 
            weight;
        
        KpuST += ( Transpose[ { sf1[[ step ]] } ] . { sf2xyderiv[[ 1 ]] } ) * 
            weight;
        KpvST += ( Transpose[ { sf1[[ step ]] } ] . { sf2xyderiv[[ 2 ]] } ) * 
            weight;
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      outESMvalues += myBlockMatrix[ {
            { KuuST, emptyS2S2SF, KupST },
            { emptyS2S2SF, KvvST, KvpST},
            { KpuST, KpvST, emptyS1S1SF }
            } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          inERHS
          } ];
      ];



imsFEMNavier[ { inESM_, inERHS_ }, elem_, elementNodes_, uOld_,  
      massDensityVal_ ]:=
    Block[
      {
        coords, marker,
        sf2Element, sf1Element,
        outESMvalues, outERHSvalues,rows, cols,  rowsERHS, colsERHS,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs, secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S2SF,emptyS2SF, emptyS1SF,
        KuuNS1, KvvNS1, KuuNS2, KuvNS2, KvvNS2, KvuNS2,
        FuNS, FvNS, FuNS2, FvNS2, FuNS3, FvNS3 ,FpNS,
        jacobians,jDets, jInverses, weight,
        massDensityVals,
        uk, vk, pk, u, v, ux, vx, uy, vy, px, py,
        mul },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      outERHSvalues = imsGetElementMatrixValues[ inERHS ];
      rowsERHS = imsGetElementMatrixRows[ inERHS ];
      colsERHS = imsGetElementMatrixColumns[ inERHS ];
      
      (* shape functions *)
      
      sf1 =imsIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0, {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0, {primaryDOFs}, {secondaryDOFs} ];
      emptyS1S2SF = Transpose[ emptyS2S1SF ];
      emptyS1S1SF = Table[ 0, {secondaryDOFs}, {secondaryDOFs} ];
      emptyS2SF = Table[ 0, {primaryDOFs},{1} ];
      emptyS1SF = Table[ 0, {secondaryDOFs},{1} ];
      
      KuuNS1 = KvvNS1 = KuuNS2 = KuvNS2 = KvvNS2 = KvuNS2 = emptyS2S2SF;
      FuNS = FvNS = FuNS2 = FvNS2 = FuNS3 = FvNS3 = emptyS2SF;
      FpNS = emptyS1SF;
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      massDensityVals =( massDensityVal @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      Do[ (* integration *)
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* solution and derivs *)
        
        uk = uOld[[ Range[ primaryDOFs ] ]];
        vk = uOld[[ primaryDOFs + Range[ primaryDOFs ] ]];
        uk = uOld[[ { 1,2,3,4,5,6 } ]];
        vk = uOld[[ { 7,8,9,10,11,12 } ]];
        
        u = Plus @@ ( sf2[[ step ]] * uk );
        { ux, uy } = (Plus@@(#*uk))& /@ sf2xyderiv;
        
        v = Plus @@ ( sf2[[ step ]] * vk );
        { vx, vy } = (Plus@@(#*vk))& /@ sf2xyderiv;
        
        pk = uOld[[ 2 * primaryDOFs + Range[ secondaryDOFs ] ]];
        pk = uOld[[ { 13, 14, 15 } ]];
        { px, py } = (Plus@@(#*pk))& /@ sf1xyderiv;
        
        (* local K and L *)
        
        mul =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuNS1 += ( 
              Transpose[ { sf2[[ step ]], sf2[[ step ]] } ] . ( {u,v}*
                    sf2xyderiv ) )* mul;
        KvvNS1 = KuuNS1;
        KuuNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * ux * { sf2[[ step ]] } ) ) * 
            mul;
        KvvNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * vy * { sf2[[ step ]] } ) ) * 
            mul;
        KuvNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * uy * { sf2[[ step ]] } ) ) * 
            mul;
        KvuNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * vx * { sf2[[ step ]] } ) ) * 
            mul;
        
        FuNS += 
          Transpose[ { 
                massDensityVals[[ step ]] * ( u*ux + v*uy ) *
                  sf2[[ step ]] } ] * mul;
        FvNS += 
          Transpose[ { 
                massDensityVals[[ step ]] * ( u*vx + v*vy ) *
                  sf2[[ step ]] } ] * mul; 
        
        (*
          mu = 10^-2;
          
          FuNS2 += Transpose[ { ( px ) *sf2[[ step ]] } ] * mul;
          FvNS2 += Transpose[ { ( py ) *sf2[[ step ]] } ] * mul;
          
          
          FuNS3 += ( (Plus @@ #)& /@ Transpose[ { ux, uy } * sf2xyderiv ] ) * 
              mu * mul;
          
          FvNS3 += ( (Plus @@ #)& /@ Transpose[ { vx, vy } * sf2xyderiv ] ) * 
              mu * mul;
          
          FpNS += Transpose[ { ( ux + vy ) * sf1[[ step ]] } ] * mul;
          *)
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      outESMvalues += myBlockMatrix[ {
            { ( KuuNS1 + KuuNS2 ), KuvNS2, emptyS2S1SF },
            { KvuNS2, ( KvvNS1 + KvvNS2 ), emptyS2S1SF },
            { emptyS1S2SF, emptyS1S2SF, emptyS1S1SF }
            } ];
      
      outERHSvalues += 
        myBlockMatrix[ { { (FuNS+FuNS2+FuNS3) }, { (FvNS+FvNS2+FvNS3) }, { 
              FpNS } } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          imsMakeElementMatrix[ outERHSvalues, rowsERHS, colsERHS ]
          } ];
      ];



imsNFEMNavier[ { inESM_, inERHS_ }, elem_, elementNodes_, uOld_,  
      massDensityVal_ ]:=
    Block[
      {
        coords, marker,
        sf2Element, sf1Element,
        outESMvalues, outERHSvalues,rows, cols,  rowsERHS, colsERHS,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs, secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S2SF,emptyS2SF, emptyS1SF,
        KuuNS1, KvvNS1, KuuNS2, KuvNS2, KvvNS2, KvuNS2,
        FuNS, FvNS, FuNS2, FvNS2, FuNS3, FvNS3 ,FpNS,
        jacobians,jDets, jInverses, weight,
        massDensityVals,
        uk, vk, pk, u, v, ux, vx, uy, vy, px, py,
        mul },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      outERHSvalues = imsGetElementMatrixValues[ inERHS ];
      rowsERHS = imsGetElementMatrixRows[ inERHS ];
      colsERHS = imsGetElementMatrixColumns[ inERHS ];
      
      (* shape functions *)
      
      sf1 =imsNIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsNIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsNIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsNIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsNIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0., {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0., {primaryDOFs}, {secondaryDOFs} ];
      emptyS1S2SF = Transpose[ emptyS2S1SF ];
      emptyS1S1SF = Table[ 0., {secondaryDOFs}, {secondaryDOFs} ];
      emptyS2SF = Table[ 0., {primaryDOFs},{1} ];
      emptyS1SF = Table[ 0., {secondaryDOFs},{1} ];
      
      KuuNS1 = KvvNS1 = KuuNS2 = KuvNS2 = KvvNS2 = KvuNS2 = emptyS2S2SF;
      FuNS = FvNS = FuNS2 = FvNS2 = FuNS3 = FvNS3 = emptyS2SF;
      FpNS = emptyS1SF;
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      massDensityVals =( massDensityVal @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      Do[ (* integration *)
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* solution and derivs *)
        
        uk = uOld[[ Range[ primaryDOFs ] ]];
        vk = uOld[[ primaryDOFs + Range[ primaryDOFs ] ]];
        uk = uOld[[ { 1,2,3,4,5,6 } ]];
        vk = uOld[[ { 7,8,9,10,11,12 } ]];
        
        u = Plus @@ ( sf2[[ step ]] * uk );
        { ux, uy } = (Plus@@(#*uk))& /@ sf2xyderiv;
        
        v = Plus @@ ( sf2[[ step ]] * vk );
        { vx, vy } = (Plus@@(#*vk))& /@ sf2xyderiv;
        
        pk = uOld[[ 2 * primaryDOFs + Range[ secondaryDOFs ] ]];
        pk = uOld[[ { 13, 14, 15 } ]];
        { px, py } = (Plus@@(#*pk))& /@ sf1xyderiv;
        
        (* local K and L *)
        
        mul =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuNS1 += ( 
              Transpose[ { sf2[[ step ]], sf2[[ step ]] } ] . ( {u,v}*
                    sf2xyderiv ) )* mul;
        KvvNS1 = KuuNS1;
        KuuNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * ux * { sf2[[ step ]] } ) ) * 
            mul;
        KvvNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * vy * { sf2[[ step ]] } ) ) * 
            mul;
        KuvNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * uy * { sf2[[ step ]] } ) ) * 
            mul;
        KvuNS2 += ( 
              Transpose[ { sf2[[ step ]] } ] . ( 
                  massDensityVals[[ step ]] * vx * { sf2[[ step ]] } ) ) * 
            mul;
        
        FuNS += 
          Transpose[ { 
                massDensityVals[[ step ]] * ( u*ux + v*uy ) *
                  sf2[[ step ]] } ] * mul;
        FvNS += 
          Transpose[ { 
                massDensityVals[[ step ]] * ( u*vx + v*vy ) *
                  sf2[[ step ]] } ] * mul; 
        
        (*
          mu = 10^-2;
          
          FuNS2 += Transpose[ { ( px ) *sf2[[ step ]] } ] * mul;
          FvNS2 += Transpose[ { ( py ) *sf2[[ step ]] } ] * mul;
          
          
          FuNS3 += ( (Plus @@ #)& /@ Transpose[ { ux, uy } * sf2xyderiv ] ) * 
              mu * mul;
          
          FvNS3 += ( (Plus @@ #)& /@ Transpose[ { vx, vy } * sf2xyderiv ] ) * 
              mu * mul;
          
          FpNS += Transpose[ { ( ux + vy ) * sf1[[ step ]] } ] * mul;
          *)
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      outESMvalues += myBlockMatrix[ {
            { ( KuuNS1 + KuuNS2 ), KuvNS2, emptyS2S1SF },
            { KvuNS2, ( KvvNS1 + KvvNS2 ), emptyS2S1SF },
            { emptyS1S2SF, emptyS1S2SF, emptyS1S1SF }
            } ];
      
      outERHSvalues += 
        myBlockMatrix[ { { (FuNS+FuNS2+FuNS3) }, { (FvNS+FvNS2+FvNS3) }, { 
              FpNS } } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          imsMakeElementMatrix[ outERHSvalues, rowsERHS, colsERHS ]
          } ];
      ];



imsFEMFluidicsLoad[ { inESM_, inERHS_ }, elem_, elementNodes_, uLoad_, 
      vLoad_, pLoad_ ]:=
    Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        uLoadVals,vLoadVals,pLoadVals,
        Fu, Fv, Fp,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element RHS part *)
      
      outERHSvalues=imsGetElementMatrixValues[ inERHS ];
      rows = imsGetElementMatrixRows[ inERHS ];
      cols = imsGetElementMatrixColumns[ inERHS ];
      
      (* shape functions *)
      
      sf1 =imsIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsIntegrationWeights[ sf2Element ];
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      uLoadVals =( uLoad @@ Flatten[  { marker, # } ] )& /@ ( sf2.coords );
      vLoadVals =( vLoad @@ Flatten[  { marker, # } ] )& /@ ( sf2.coords );
      (* pLoadVals =( pLoad @@ Flatten[  { marker, # } ] )& /@ ( 
                sf1.coords ); *)
      
      (* integration *)
      
      Fu = Plus @@ ( uLoadVals * nIntegrationWeight * jDets  * sf2 );
      Fv = Plus @@ ( vLoadVals * nIntegrationWeight * jDets * sf2  );
      (* Fp =  Plus @@ ( pLoadVals * nIntegrationWeight * jDets * sf1 ); *)
  
          Fp = Table[ 0, {3},{1} ];
      
      Plus @@ ( 
          weight * ( loadVal1 * nSerendipityShapeFunctionIntegration ) );
      
      outERHSvalues += Partition[ Flatten[ { Fu, Fv,Fp } ], 1 ];
      
      Return[ { 
          inESM,
          imsMakeElementMatrix[ outERHSvalues, rows, cols ]
          } ]
      ];



imsNFEMFluidicsLoad[ { inESM_, inERHS_ }, elem_, elementNodes_, uLoad_, 
      vLoad_, pLoad_ ]:=
    Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        uLoadVals,vLoadVals,pLoadVals,
        Fu, Fv, Fp,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element RHS part *)
      
      outERHSvalues=imsGetElementMatrixValues[ inERHS ];
      rows = imsGetElementMatrixRows[ inERHS ];
      cols = imsGetElementMatrixColumns[ inERHS ];
      
      (* shape functions *)
      
      sf1 =imsNIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsNIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsNIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsNIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsNIntegrationWeights[ sf2Element ];
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      uLoadVals =( uLoad @@ Flatten[  { marker, # } ] )& /@ ( sf2.coords );
      vLoadVals =( vLoad @@ Flatten[  { marker, # } ] )& /@ ( sf2.coords );
      (* pLoadVals =( pLoad @@ Flatten[  { marker, # } ] )& /@ ( 
                sf1.coords ); *)
      
      (* integration *)
      
      Fu = Plus @@ ( uLoadVals * nIntegrationWeight * jDets  * sf2 );
      Fv = Plus @@ ( vLoadVals * nIntegrationWeight * jDets * sf2  );
      (* Fp =  Plus @@ ( pLoadVals * nIntegrationWeight * jDets * sf1 ); *)
  
          Fp = Table[ 0., {3},{1} ];
      
      Plus @@ ( 
          weight * ( loadVal1 * nSerendipityShapeFunctionIntegration ) );
      
      outERHSvalues += Partition[ Flatten[ { Fu, Fv,Fp } ], 1 ];
      
      Return[ { 
          inESM,
          imsMakeElementMatrix[ outERHSvalues, rows, cols ]
          } ]
      ];



imsFEMFluidicsTransientMatrix[ { inESM_, inERHS_ }, elem_, elementNodes_, 
      factor1_, factor2_, factor3_ ]:=
    Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S1SF,
        KuuST, KvvST, KppST, KupST, KvpST,KpuST, KpvST ,
        factor1Vals,factor2Vals,factor3Vals,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      
      (* shape functions *)
      
      sf1 =imsIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0, {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0, {primaryDOFs}, {secondaryDOFs} ];
      KppST = Table[ 0, {secondaryDOFs}, {secondaryDOFs} ];
      KuuST = KvvST =emptyS2S2SF;
      KupST = KvpST = emptyS2S1SF;
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      factor1Vals =( factor1 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      factor2Vals =( factor2 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      factor3Vals =( factor3 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      
      (* integration *)
      Do[ 
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* local K and L *)
        
        weight =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuST += 
          factor1Vals[[ step ]] * (Transpose[ sf2xyderiv ] . sf2xyderiv) * 
            weight;
        KvvST += 
          factor2Vals[[ step ]] * (Transpose[ sf2xyderiv ] . sf2xyderiv) * 
            weight;
        KppST += 
          factor3Vals[[ step ]] * (Transpose[ sf1xyderiv ] . sf1xyderiv) * 
            weight;
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      
      outESMvalues += myBlockMatrix[ {
            { KuuST, emptyS2S2SF, emptyS2S1SF },
            { emptyS2S2SF, KvvST, emptyS2S1SF},
            { Transpose[ emptyS2S1SF ], Transpose[ emptyS2S1SF ], KppST }
            } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          inERHS
          } ];
      ];



imsNFEMFluidicsTransientMatrix[ { inESM_, inERHS_ }, elem_, elementNodes_, 
      factor1_, factor2_, factor3_ ]:=
    Block[
      { coords,marker,sf2Element, sf1Element,
        outESMvalues, rows, cols,
        sf1, sf2, sf1rsderiv, sf2rsderiv, sf1xyderiv, sf2xyderiv,
        nIntegrationWeight,
        primaryDOFs,  secondaryDOFs,
        emptyS2S2SF, emptyS2S1SF, emptyS1S1SF,
        KuuST, KvvST, KppST, KupST, KvpST,KpuST, KpvST ,
        factor1Vals,factor2Vals,factor3Vals,
        jacobians,jDets, jInverses,
        weight },
      
      (* element data *)
      coords = imsGetCoords[ elementNodes ];
      marker = imsGetMarkers[ elem ];
      sf2Element = imsPrimaryElement[ Head[ elem ] ];
      sf1Element = imsSecondaryElement[ Head[ elem ] ];
      
      (* element stiffness part *)
      
      outESMvalues = imsGetElementMatrixValues[ inESM ];
      rows = imsGetElementMatrixRows[ inESM ];
      cols = imsGetElementMatrixColumns[ inESM ];
      
      (* shape functions *)
      
      sf1 =imsNIntegratedShapeFunction[ sf1Element ];
      sf1rsderiv = imsNIntegratedShapeFunctionDerivative[ sf1Element ];
      sf2 = imsNIntegratedShapeFunction[ sf2Element ];
      sf2rsderiv = imsNIntegratedShapeFunctionDerivative[ sf2Element ];
      nIntegrationWeight = imsNIntegrationWeights[ sf2Element ];
      
      primaryDOFs = imsElementIncidents[ sf2Element ];
      secondaryDOFs = imsElementIncidents[ sf1Element ];
      
      emptyS2S2SF = Table[ 0., {primaryDOFs},{primaryDOFs} ];
      emptyS2S1SF = Table[ 0., {primaryDOFs}, {secondaryDOFs} ];
      KppST = Table[ 0., {secondaryDOFs}, {secondaryDOFs} ];
      KuuST = KvvST =emptyS2S2SF;
      KupST = KvpST = emptyS2S1SF;
      
      (* mapping *)
      jacobians =  Transpose[ (#.coords)]& /@ sf2rsderiv;
      jDets = Det[ # ]& /@ jacobians;
      jInverses = Inverse[ # ]& /@ jacobians;
      
      (* function integration *)
      
      factor1Vals =( factor1 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      factor2Vals =( factor2 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      factor3Vals =( factor3 @@ Flatten[  { marker, # } ] )& /@ ( 
            sf2.coords );
      
      
      (* integration *)
      Do[ 
        
        (* deriv of sf *)
        
        sf1xyderiv = Transpose[ jInverses[[ step ]] ]. sf1rsderiv[[ step ]];
        sf2xyderiv = Transpose[ jInverses[[ step ]] ]. sf2rsderiv[[ step ]];
        
        (* local K and L *)
        
        weight =  nIntegrationWeight[[ step ]] * jDets[[ step ]];
        
        KuuST += 
          factor1Vals[[ step ]] * (Transpose[ sf2xyderiv ] . sf2xyderiv) * 
            weight;
        KvvST += 
          factor2Vals[[ step ]] * (Transpose[ sf2xyderiv ] . sf2xyderiv) * 
            weight;
        KppST += 
          factor3Vals[[ step ]] * (Transpose[ sf1xyderiv ] . sf1xyderiv) * 
            weight;
        
        ,{ step, Length[ nIntegrationWeight ] }
        ];
      
      
      outESMvalues += myBlockMatrix[ {
            { KuuST, emptyS2S2SF, emptyS2S1SF },
            { emptyS2S2SF, KvvST, emptyS2S1SF},
            { Transpose[ emptyS2S1SF ], Transpose[ emptyS2S1SF ], KppST }
            } ];
      
      Return[ { 
          imsMakeElementMatrix[ outESMvalues, rows, cols ],
          inERHS
          } ];
      ];



(* representors *)
(* *)



(* Begin Private *)
End[]



(* Protect[] *)
EndPackage[] 