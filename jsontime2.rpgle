         //------------------------------------------------------------------
         // Desc: This is an example of running curl and processing results in RPG as JSON
         //
         // Steps in process:
         // Run QSHCURL curl command to get time from: date.jsontest.com as JSON.
         // QSHCURL writes results to IFS file so they can be consumed.
         // YAJL functions read the json results and parses the data.
         //
         // Requirements:
         // YAJL library needed from ScottKlement.com and must be in library list
         // https://www.scottklement.com/yajl
         //
         // QShell on i library QSHONI needs to be installed.
         // https://www.github/com/richardschoen/qshoni
         //
         // Article ref links:
         // https://www.itjungle.com/2018/01/22/guru-using-curl-interact-web-services/
         //------------------------------------------------------------------

     H DFTACTGRP(*NO) ACTGRP('YAJL') OPTION(*SRCSTMT)
     H BNDDIR('YAJL')

      /include yajl_h

         // Data structure for date.jsontest.com JSON results
     D list_t          ds                  qualified
     D                                     template
     D   date                        16A
     D   time                        16A
     D   milliseconds                15p 0

      *// Result list of 1 entry expected
     D result          ds                  qualified
     D   success                      1n
     D   errmsg                     500a   varying
     D   list                              likeds(list_t) dim(1)

     D docNode         s                   like(yajl_val)
     D list            s                   like(yajl_val)
     D node            s                   like(yajl_val)
     D val             s                   like(yajl_val)

      /free

         // https://www.itjungle.com/2018/01/22/guru-using-curl-interact-web-services/
         Dcl-S i int(10);
         Dcl-S lastElem int(10);
         Dcl-S cmderror int(10);
         Dcl-S cmdline char(4096);
         Dcl-S errMsg varchar(500);
         dcl-S ifsoutput varchar(255);
         Dcl-S msg char(52);

         // Command line execution
         dcl-pr qcmdexc ExtPgm;
           cmd          char(4096)     Const Options(*VarSize);
           cmdLength    packed(15: 5) Const;
         end-pr;

         // Set the IFS output file name for JSON
         ifsoutput = '/tmp/jsontime.json';

         // Build curl command to run ro get date from date.jsontest.com
         // STDOUT results from curl go to IFS file /tmp/jsontime.json
         cmdline='QSHONI/QSHCURL CMDLINE(''--url date.jsontest.com'') ' +
              'IFSSTDOUT(*YES) ' +
              'IFSFILE(''' + %trim(ifsoutput) + ''') ' +
              'IFSOPT(*REPLACE)';

         // Run QSHCURL command and handle any errors nicely.
         monitor;
            qcmdexc(%trim(cmdline):%len(%trim(cmdline)));
            cmdError=0;
         on-error;
            cmdError=1;
         endmon;

         // If errors, exit the program
         if cmdError = 1;
            *inlr=*on;
            return;
         endif;

         // Load JSON file into memory node
         node = yajl_stmf_load_tree(%trim(ifsoutput) : errMsg );
         if errMsg <> '';
            // handle error
         endif;

         // Load JSON results to array. We only use element one
         // since date.jsontest.com only returns one date/time element
         i = 1;
         val = YAJL_object_find(node: 'date');
         result.list(i).date = yajl_get_string(val);
         val = YAJL_object_find(node: 'time');
         result.list(i).time = yajl_get_string(val);
         val = YAJL_object_find(node: 'milliseconds_since_epoch');
         result.list(i).milliseconds = yajl_get_number(val);

         // Display parsed JSON result fields
         // after they have been extracted with YAJL
         msg='Date: ' + result.list(i).date;
         dsply msg;
         msg='Time: ' + result.list(i).time;
         dsply msg;
         msg= 'Milliseconds since epoch: ' +
              %char(result.list(i).milliseconds);
         dsply msg;

         // Release YAJL object memory
         yajl_tree_free(node);

         *inlr = *on;
         return; 
