      //
      // Author: Michael Sansoterra,  ITJungle.com
      //
      // WrapText Service Program
      //
      //
      // Program Compilation Notes:
      //
      // 1. Create Module (CRTRPGMOD)
      // 2. CRTSRVPGM SRVPGM(xxxx/WRAPTEXT)
      //              EXPORT(*ALL)
      //              TEXT('Wrap Text Utility')
      //              USRPRF(*OWNER)
      //
      //
      //
      // SQL Registration - Table Function Definition:
      // ===============================================
      // Create Function xxxx/WrapText
      // (UnformattedText VarChar(8192),
      //  LineLen         Dec(5,0),
      //  LineBreak       VarChar(10))
      // Returns Table
      // (LineNo   Dec(5,0),
      //  LineText VarChar(128))
      // Language RPGLE
      // Not Fenced
      // Deterministic
      // No SQL
      // External Name 'xxxx/WRAPTEXT(WRAPTEXT_TF)'
      // Disallow Parallel
      // Parameter Style DB2SQL
      // Cardinality 10
      //
      //
      //
      //
     HNoMain Option(*SrcStmt)

      //  UDTF call parameter constants

     D UDTF_FirstCall  S             10I 0 Inz(-2)
     D UDTF_Open       S             10I 0 Inz(-1)
     D UDTF_Fetch      S             10I 0 Inz(0)
     D UDTF_Close      S             10I 0 Inz(1)
     D UDTF_LastCall   S             10I 0 Inz(2)

      //  SQL States

     D SQLSTATEOK      C                   '00000'
     D ENDOFTABLE      C                   '02000'
     D UDTF_ERROR      C                   'US001'

      //====================================================================
      // Prototype for replace utility
      //====================================================================
     DReplace          PR          8192    Varying
     D parmSearchStr               8192    Varying Const Options(*VarSize)
     D FindStr                     8192    Varying Const Options(*VarSize)
     D ReplaceStr                  8192    Varying Const Options(*VarSize)
      //====================================================================
      // Prototype for wrapping unformatted data to a specified length
      //====================================================================
     D WrapText        PR         12288
     D  UnfText                    8192    Varying Const Options(*VarSize)
     D  LineLen                       5  0 Const
     D  LineBreak                    10    Varying Const Options(*NoPass)
      //====================================================================
      // Prototype for wrapping unformatted data to a specified length
      //====================================================================
     D WrapText_TF     PR
      // Function Input(s)
     D  UnfText                    8192    Varying Const Options(*VarSize)
     D  LineLen                       5  0 Const
     D  LineBreak                    10    Varying Const
      // Function Output(s)
     D  LineNo                        5  0
     D  LineText                    128    Varying
      // Function Input Null Indicators
     D  UnfText_NI                    5I 0
     D  LineLen_NI                    5I 0
     D  LineBreak_NI                  5I 0
      // Function Output Null Indicators
     D  LineNo_NI                     5I 0
     D  LineText_NI                   5I 0
      // DB2SQL Style Parameters
     D SQLState                       5
     D FunctionName                 517
     D SpecificName                 128
     D SQLMsgText                    70    Varying
      // UDTF Call Type
     D TFCallType                    10I 0

      //===============================================================
      // Subprocedure: Wrap Text to Specified Length
      //===============================================================
     P WrapText        B                   Export

     D WrapText        PI         12288
     D  UnfText                    8192    Varying Const Options(*VarSize)
     D  LineLen                       5  0 Const
     D  LineBreak                    10    Varying Const Options(*NoPass)
      // Work Fields
     D WrkText         s            + 1    Like(UnfText)
     D LineText        s          12288
     D WordText        s                   Like(UnfText)
     D FmtText         s          12288
     D WordLen         s              5  0
      // Word/Line counters
     D Line            s              5  0
     D Word            s              5  0

      /Free
         WrkText=%TrimL(UnfText)+' ';
         If %Parms>=3;
             If %Len(LineBreak)>0;
                 WrkText=Replace(WrkText:LineBreak:' '+LineBreak+' ');
             EndIf;
         EndIf;

         If LineLen<=*Zero
         Or LineLen>%Size(UnfText);
             Return 'INVALID LEN*';
         EndIf;

         If UnfText=*Blank;
             Return '';
         EndIf;

         Dow %Len(WrkText)>*Zero;

             // Find Boundary of word
             WordLen=%Scan(' ':WrkText)-1;

             If WordLen>*Zero;

                 // Test if Word length is greater than the wrap length
                 If WordLen>LineLen ;
                     WordText=%Subst(WrkText:1:LineLen);
                     WrkText=%Subst(WrkText:LineLen+1);
                 Else;
                     WordText=%Subst(WrkText:1:WordLen);
                     WrkText=%TrimL(%Subst(WrkText:WordLen+1));
                 EndIf;

                 // Test if break was requested
                 If %Parms=3;
                     If WordText=LineBreak;
                         WordText=' ';
                         ExSr BuildLine;
                     EndIf;
                 EndIf;

                 // If Length of Current Line + Length of the current word
                 // > than formatted line length, make a new line
                 If %Len(%TrimR(LineText)) +
                    %Len(WordText)+1>LineLen
                 And %Len(%TrimR(LineText))>0;
                    ExSr BuildLine;
                 EndIf;

                 //  Append Word to current Line
                 //  NOTE: Word will be blank if a line break specified
                 If WordText<>*Blanks;
                     Word=Word+1;
                     If Word=1;
                         LineText=WordText;
                     Else;
                         LineText=%TrimR(LineText)+' '+WordText;
                     EndIf;
                 EndIf;

             EndIf;
         EndDo;

         // Build Remaining Line
         If LineText<>*blanks;
             ExSr BuildLine;
         EndIf;

         Return FmtText;

         // Build Single Line according to the requested format width
         BegSr BuildLine;
             Word=*Zero;
             If Line=*Zero;
                 FmtText=%Subst(LineText:1:LineLen);
             Else;
                 If LineLen*Line>%Size(FmtText);
                     LeaveSr;
                 Else;
                     FmtText=%Subst(FmtText:1:LineLen*Line) +
                             %Subst(LineText:1:LineLen);
                 EndIf;
             EndIf;
             Line=Line+1;

             LineText=*Blank;
         EndSr;
      /End-Free
     P WrapText        E


      //===============================================================
      // Subprocedure: Wrap Text & return as individual lines to DB2 TF
      //===============================================================
     P WrapText_TF     B                   Export
     D WrapText_TF     PI
      // Function Input(s)
     D  UnfText                    8192    Varying Const Options(*VarSize)
     D  LineLen                       5  0 Const
     D  LineBreak                    10    Varying Const
      // Function Output(s)
     D  LineNo                        5  0
     D  LineText                    128    Varying
      // Function Input Null Indicators
     D  UnfText_NI                    5I 0
     D  LineLen_NI                    5I 0
     D  LineBreak_NI                  5I 0
      // Function Output Null Indicators
     D  LineNo_NI                     5I 0
     D  LineText_NI                   5I 0
      // DB2SQL Style Parameters
     D SQLState                       5
     D FunctionName                 517
     D SpecificName                 128
     D SQLMsgText                    70    Varying
      // UDTF Call Type
     D TFCallType                    10I 0

     DLineLenTmp       S              5  0
     DText             S          12288    Varying Static
     DNoLines          S             10I 0 Static
     DCurLine          S             10I 0 Static
      /Free
         SQLState=SQLStateOK;

         Select;
         // Function Open -> Prepare data for retrieval
         When TFCallType=UDTF_Open;
             If LineLen<=0
             Or LineLen>=%Size(UnfText)-2;
                 SQLState=ENDOFTABLE;
                 Return;
             EndIf;
             NoLines=*Zero;
             CurLine=*Zero;
             Text=WrapText(UnfText:LineLen:LineBreak);

             NoLines=%Len(%TrimR(Text))/LineLen;
             If %Rem(%Len(%TrimR(Text)):LineLen)>0;
                 NoLines+=1;
             EndIf;

         // Function Fetch -> Return data from multi-occur data
         // structure
         When TFCallType=UDTF_Fetch;
             If CurLine=NoLines;
                 SQLState=ENDOFTABLE;
             Else;
                 LineNo=CurLine+1;
                 If CurLine*LineLen+LineLen>%Size(Text)-2;
                     LineLenTmp=%Size(Text)-2-(CurLine*LineLen);
                 Else;
                     LineLenTmp=LineLen;
                 EndIf;
                 LineText=%TrimR(
                 %Subst(Text:CurLine*LineLen+1:LineLenTmp));

                 CurLine+=1;
             EndIf;
         When TFCallType=UDTF_Close;
         EndSl;
      /End-Free
     P WrapText_TF     E

      //================================================================
      // Find and Replace a string
      //
      // Parameters:
      //    Search   IN - String to search
      //    Find     IN - String to find
      //    Replace  IN - String to replace
      //
      // Returns:
      //    Result        String with replaced data
      //
      //
      // Notes:
      //
      //
      //================================================================
     PReplace          B                   Export
     DReplace          PI          8192    Varying
     D parmSearchStr               8192    Varying Const Options(*VarSize)
     D FindStr                     8192    Varying Const Options(*VarSize)
     D ReplaceStr                  8192    Varying Const Options(*VarSize)

     D SearchStr       S           8192    Varying Static

     D Pos             S              5i 0
     D SL              S              5i 0
     D FL              S              5i 0

      /Free
         SearchStr=parmSearchStr;

         FL=%Len(FindStr);
         Pos=*zero;

         Dow pos + fl<=%Len(SearchStr);
             SL=pos+1;
             Pos=%Scan(FindStr:SearchStr:sl);

             // Leave if search string isn't found
             If Pos=*Zero;
                 Leave;
             EndIf;

             // Build new string with replaced text in the middle
             If Pos + fl > %Len(SearchStr);
                 SearchStr=%Subst(SearchStr:1:Pos-1) +
                           ReplaceStr;
             Else;
                  SearchStr=%Subst(SearchStr:1:Pos-1) +
                            ReplaceStr +
                            %Subst(SearchStr:Pos + fl);
             EndIf;

             // Set starting position for search of next occurance

             Pos=Pos+%Len(ReplaceStr)-1;
         EndDo;

         Return SearchStr;
      /End-Free
     P Replace         E

