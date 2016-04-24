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
(* Title: Interpolation.m *)
(* Context: *)
(* 
  Author:oliver ruebenkoenig *)
(* Date: 30.1.2007, Imtek, Freiburg *)
(* 
  Summary: This is the IMTEK template for writing a mathematica packages *)
(* 
  Package Copyright: GNU GPL *)
(* Package Version: 0.2.1 *)
(* 
  Mathematica Version: 5.2 *)
(* History: a
      now using QRDecomposition for unstructured interpolation;
  added unstructured interpolation *)
(* Keywords: *)
(* 
  Sources: "Motivation for using radial basis functions to solve PDEs", 
  Edward J. Kansa *)
(* 
  Warnings: the code of unstuctured interpolation is far from optimal, slow, 
  see fast evaluation of radial basis functions for improvement *)
(* 
  Limitations: *)
(* Discussion: *)
(* Requirements: *)
(* Examples: *)
(* *)



(* Start Package *)
BeginPackage["Imtek`Interpolation`"];





(* *)
(* documentation *)
(* *)
Needs["Imtek`Maintenance`"]
imsCreateObsoleteFunctionInterface[ CardinalFunction, $Context \
];imsCreateObsoleteFunctionInterface[ LagrangePolynominal, $Context ];

(* constructors *)

(* selectors *)

(* predicates *)

(* functions *)
imsCardinalFunction::usage = 
  "imsCardinalFunction[ data, variable, where, length ] computes the cardinal functions for Lagrange polynomials."
\

imsLagrangePolynominal::usage = "imsLagrangePolynominal[ data, variable, length ] computes the Lagrange polynomial for data with respect to variable and length."
\

imsSpline::usage = "imsSpline[ x_, xi_, order_ ] returns a Spline where x is the center and xi is the distance to the center. Order defaults to 1."
\

imsUnstructuredInterpolation::usage = 
  "imsUnstructuredInterpolation[ data, interpolationFunction, rho, opts ] returns a function that approximates data with interpolation function. Data is a list { { x1, y1, .., f1 }, { x2, y2, .., f2 }, .. }. rho is a tuning parameter which defaults to 0. opts are for LinearSolve."









(* *)
(* implementation part *)
(* *)

(* constructor *)



Begin["`Private`"];



(* provate imports *)
Needs["Utilities`FilterOptions`"]



(* *)
(* define your options *)
(* *)



(* selector *)



(* predicates *)



(* functions *)

imsCardinalFunction[ data_List,var_,  where_Integer, length_:Automatic ] := 
  Module[
    { myLength },
    If[ length === Automatic, myLength = Length[ data ], myLength = length ];
    
    Return[
      Times @@ ( var - Take[ Drop[ data, { where } ], myLength - 1 ] ) / 
        Times @@ ( 
            data[[ where ]] - Take[ Drop[ data, { where } ], myLength -1 ] )
      ];
    ]

imsLagrangePolynominal[ data:List[ List[_, _ ].. ],var_, 
    length_:Automatic ] := 
  Module[
    { myLength },
    If[ length === Automatic, myLength = Length[ data ], myLength = length ];
    Return[
      Sum[
        data[[ i, 2 ]] * imsCardinalFunction[
            First[ Transpose[ data ] ], var, i, length  ],
        { i, 1, Length[ data ] } ]
      ];
    ]

imsLagrangePolynominal[ data:List[ __ ],var_, length_:Automatic ] := 
  imsLagrangePolynominal[ Transpose[ { Range[ Length[ data ] ], data } ], 
    var, length ]

imsSpline[ x_, xi_, order_:1  ] := 
  Function[ { x, xi }, Norm[ x -xi, 2 ]^order ]

imsUnstructuredInterpolation[ data_List, interpolationFunction_Function, 
      rho_:0, opts___ ] /; NumericQ[ rho ]:= 
  Module[
    { 
      coords, vals,
      linSolOpts,
      coeff,
      uniqueVars, q,r,x, xi
      },
    linSolOpts = FilterOptions[ LinearSolve, opts ];
    
    { coords, vals } = { Transpose[ Drop[ #, -1 ] ], #[[-1 ]] }&[  
        Transpose[ data ] ] ;
    
    uniqueVars = Table[ Unique["x"],{ Length[ First[ coords ] ] } ];
    
    {q,r} = QRDecomposition[Transpose[
            Append[
              Transpose[
                Append[ 
                  
                  Table[ interpolationFunction[ coords[[ x ]], 
                      coords[[ xi ]] ], { x, Length[coords] }, { xi, 
                      Length[coords] } ],
                  Table[ 1,  { Length[ coords ] } ]
                  ]
                ], Join[ Table[ 1, { Length[ coords ] } ], { 0 } ]
              ]
            ]  + rho * IdentityMatrix[ Length[ coords ] +1 ] ];
    
    coeff =  LinearSolve[ r,q . Append[ vals,rho ], linSolOpts ];
    
    Return[ 
      Function[ Evaluate[ uniqueVars ], 
        Evaluate[ 
          Sum[ coeff[[ i ]] * 
                interpolationFunction[ uniqueVars, coords[[ i ]] ], { i, 1, 
                Length[ coords ] } ]+Last[ coeff ] ] ] ]
    ]



End[] (* of Begin Private *)



(* Protect[] (* anything *) *)
EndPackage[] 