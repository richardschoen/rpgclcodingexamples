// Based: Croy, Steve (2005) Display-attributes-made-simple/setcolor [Source code]. http://search400.techtarget.com/tip/Display-attributes-made-simple
// https://gist.githubusercontent.com/richardschoen/ea3aa9c48d8a058c144204dd9db3776d/raw/9c811bbcc9f0a25140d4e36dbcd006f36be72670/RtnDspAtr.RPGLE
// --------------------------------------------------
// Procedure name: RtnDspAtr
// Purpose:        Return Display Attribute hex code that can be used on a
//                  screen to set color, underline, or other attributes.
// Returns:        DSPATR hex value
// Parameter:      Color Value - Text representing a color 'GRN' (default)
//                   other values: 'BLU' 'PNK' 'RED' 'TRQ' 'WHT' 'YLW'
// Parameter:      Color Attribute
//                    'UL' - Underline
//                    'RI' - Reverse Image
//                    'UR' - Underline & Reverse Image
//                    'BL' - Blink
//                    'ND' - Non Display
// Parameter:      Protect Field Indicator

// Usage:
//                This value can be used inside a string to dynamically
//                set color within the string.
//  A            FIELD1        60A  O  4 21
//                FIELD1 == RtnDspAtr('WHT')+'This is white'
//                  + RtnDspAtr('GRN')+ 'This is now green.'

//                or it can be used with a attribute field setup in the
//                display file like:
//  A            S0HEADER      30A  B  4 21DSPATR(&DSPATR1)
//  A            DSPATR1        1A  P
//                and loaded like
//                  DSPATR1 = RtnDspAtr('WHT':'UL');
// --------------------------------------------------
Dcl-Proc RtnDspAtr Export;
Dcl-Pi *n      Char(1);
  colorValue   Char(3) CONST OPTIONS(*OMIT:*NOPASS);
  colorAttr    Char(2) CONST OPTIONS(*NOPASS);
  ProtectField Ind CONST OPTIONS(*NOPASS);
End-Pi;

//---
// Define constants
//---
Dcl-C Blue Const(X'3A');
Dcl-C Green Const(X'20');
Dcl-C Pink Const(X'38');
Dcl-C Red Const(X'28');
Dcl-C Turquoise Const(X'30');
Dcl-C White Const(X'22');
Dcl-C Yellow Const(X'32');

Dcl-C Blink CONST(X'2A');
Dcl-C NonDisplay CONST(X'27');
Dcl-C Protect Const(X'80');
Dcl-C Reverse Const(X'01');
Dcl-C Underline Const(X'04');

Dcl-S color Char(3);
Dcl-S attr Char(2);
Dcl-S pr Char(2);
Dcl-S attribute Char(1);


IF %parms < %Parmnum(colorValue)  or %addr(colorvalue) = *null;
  color = 'GRN';
ELSE;
  color = %Upper(colorValue);
ENDIF;
IF %parms < %Parmnum(colorAttr);
  attr = '  ';
ELSE;
  attr = %Upper(ColorAttr);
ENDIF;
IF %parms >= %Parmnum(ProtectField) and ProtectField=*ON;
  pr = 'PR';
ELSE;
  pr = *blank;
ENDIF;

SELECT;
WHEN Color = 'BLU';
  attribute = Blue;
WHEN Color = 'PNK';
  attribute = Pink;
WHEN Color = 'RED';
  attribute = Red;
WHEN Color = 'TRQ';
  attribute = Turquoise;
WHEN Color = 'WHT';
  attribute = White;
WHEN Color = 'YLW';
  attribute = Yellow;
OTHER;
  attribute = Green;
ENDSL;

IF attr = 'UL' or attr = 'UR';
  attribute = %bitOr(attribute:Underline);
ENDIF;
IF attr = 'RI' or attr = 'UR';
  attribute = %bitOr(attribute:Reverse);
ENDIF;
IF attr = 'BL';
  attribute = Blink;
ENDIF;
IF attr = 'ND';
  attribute = NonDisplay;
ENDIF;

IF pr = 'PR';
  attribute = %bitOr(attribute:Protect);
ENDIF;

RETURN attribute;
End-Proc;
