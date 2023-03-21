**free
         //------------------------------------------------------------------
         // Desc: This is an example of running curl and processing results in RPG as JSON
         //
         // Steps in process:
         // Run QSHCURL curl command to get time from: date.jsontest.com as JSON.
         // QSHCURL writes results to IFS file so they can be consumed.
         // DATA-INTO reads the json results and parses with YAJLINFO parser.
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

         // Data structure for date.jsontest.com JSON results
         dcl-ds results Qualified;
            date varchar(15);
            milliseconds_since_epoch packed(15);
            time varchar(15);
         end-ds;

         // Display message
         dcl-s msg char(52);

         dcl-S cmderror int(10);
         dcl-S cmdline char(4096);
         dcl-S errMsg varchar(500);
         dcl-S ifsoutput varchar(255);

         // Command line execution
         dcl-pr qcmdexc ExtPgm;
           cmd          char(4096)     Const Options(*VarSize);
           cmdLength    packed(15: 5) Const;
         end-pr;

         // Set the IFS output file name for JSON
         ifsoutput = '/tmp/jsontime.json';

         // Build QSHCURL curl command to run to get date from date.jsontest.com
         // STDOUT JSON results from curl go to IFS file /tmp/jsontime.json
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

         // Read JSON results with DATA-INTO and YAJLINTO
         // as the parser.
         data-into results
                  %data(%trim(ifsoutput)
                  : 'doc=file case=any')
              %parser('YAJLINTO');

         // Display parsed JSON result fields
         msg='Date: ' + results.date;
         dsply msg;
         msg='Time: ' + results.time;
         dsply msg;
         msg= 'Milliseconds since epoch: ' +
              %char(results.milliseconds_since_epoch);
         dsply msg;

         *inlr=*on;
         return;
 
