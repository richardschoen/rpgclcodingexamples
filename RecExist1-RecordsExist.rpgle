**free                                                                                                                  
        ctl-opt dftactgrp(*no);                                                                                         
        //--------------------------------------------------------------------                                          
        // Desc: RecordsExist sample subprocedure to query for records found.                                           
        // Text: RecordsExist Subprocedure Example
        // Type: SQLRPGLE
        // https://www.mcpressonline.com/programming/rpg/qualified-data-structures                                      
        // https://www.rpgpgm.com/2017/03/using-get-diagnostic-for-sql-errors.html                                      
        //--------------------------------------------------------------------                                          
                                                                                                                        
        // SQL diagnostics info                                                                                         
        dcl-s MessageId char(10) ;                                                                                      
        dcl-s MessageId1 varchar(7) ;                                                                                   
        dcl-s MessageId2 like(MessageId1) ;                                                                             
        dcl-s MessageLength int(5) ;                                                                                    
        dcl-s MessageText varchar(32740) ;                                                                              
        dcl-s ReturnedSQLCode char(5) ;                                                                                 
        dcl-s ReturnedSQLState char(5) ;                                                                                
        dcl-s RowsCount int(10) ;                                                                                       
        dcl-s LastSqlState char(5) ;                                                                                    
        dcl-s LastSqlCode int(10) ;                                                                                     
        dcl-s RtnExist int(10) ;                                                                                        
                                                                                                                        
       // Records exist for table/criteria                                                                              
       dcl-pr RecordsExist int(10);                                                                                     
          ptablename varchar(100) const;                                                                                
          pcriteria varchar(100) const;                                                                                 
       end-pr;                                                                                                          
        dcl-s count packed(5);                                                                                          
        dcl-s sqlquery1 varchar(2048);                                                                                  
        dcl-s sqlquery2 varchar(2048);                                                                                  
        dcl-s sqlquery3 varchar(2048);                                                                                  
        dcl-s cmd varchar(32702);                                                                                       
        dcl-s rc int(10);                                                                                               
        dcl-s msg varchar(50);                                                                                          
                                                                                                                        
      // System Header Includes                                                                                         
      /copy qsysinc/qrpglesrc,qcdrcmdd                                                                                  
      /copy qsysinc/qrpglesrc,qcdrcmdi                                                                                  
      /copy qsysinc/qrpglesrc,qusec                                                                                     
                                                                                                                        
       // This record should exist;                                                                                     
       rtnexist=RecordsExist('QIWS/QCUSTCDT':'cusnum=938472');                                                          
       msg='Cust:938472 exists? '  + %char(rtnexist);                                                                   
       dsply msg;                                                                                                       
                                                                                                                        
       // This record should not exist;                                                                                 
       rtnexist=RecordsExist('QIWS/QCUSTCDT':'cusnum=555555');                                                          
       msg='Cust:555555 exists? '  + %char(rtnexist);                                                                   
       dsply msg;                                                                                                       
                                                                                                                        
       // This should come back as 1 unless no records in table                                                         
       rtnexist=RecordsExist('QIWS/QCUSTCDT':' ');                                                                      
       msg='All records exist? '  + %char(rtnexist);                                                                    
       dsply msg;                                                                                                       
                                                                                                                        
       // Exit program                                                                                                  
       *inlr=*on;                                                                                                       
       return;                                                                                                          
                                                                                                                        
        //----------------------------------------------------------                                                    
        // Proc: Records Exist                                                                                          
        // Desc: Run SQL to see if records exist for selected criteria.                                                 
        // Parms:                                                                                                       
        // ptablename - Library qualified table or view name. Ex: QIWS/QCUSCTDT                                         
        // pcriteria - Where criteria. The WHERE is already implied. Ex: cusnum=938472                                  
        //             Pass pcriteria as blank if you want to count all table records.                                  
        // Info links:                                                                                                  
        // Link: https://www.rpgpgm.com/2017/03/using-get-diagnostic-for-sql-errors.html                                
        //       https://stackoverflow.com/questions/15389830/                                                          
        //       whats-the-correct-way-to-check-sql-found-condition-in-ile-rpg                                          
        //       https://wiki.midrange.com/index.php/SQLSTATE_Codes                                                     
        //----------------------------------------------------------                                                    
        dcl-proc RecordsExist;                                                                                          
        dcl-pi *N INT(10);                                                                                              
          ptablename varchar(100) const;                                                                                
          pcriteria varchar(100) const;                                                                                 
        end-pi;                                                                                                         
                                                                                                                        
             dcl-s lcRecordsExist INT(10);                                                                              
             dcl-s lcSql varchar(1000);                                                                                 
             dcl-s lcExists INT(10);                                                                                    
                                                                                                                        
             // Monitor for errors so we can handle nicely                                                              
             monitor;                                                                                                   
                                                                                                                        
             // Set up SQL statement for existence check using sysdummy1                                                
             // sysdummy1 only ever returns a single record.                                                            
             if %trim(pcriteria) <> '';                                                                                 
               // Get record count based on passed in criteria                                                          
               lcSql='Select 1 from sysibm/sysdummy1 where exists(' +                                                   
               'Select ''1'' from ' + ptablename + ' where ' + pcriteria + ')';                                         
             else;                                                                                                      
               // Get record count based on all table records                                                           
               lcSql='Select 1 from sysibm/sysdummy1 where exists(' +                                                   
               'Select ''1'' from ' + ptablename + ')';                                                                 
             endif;                                                                                                     
                                                                                                                        
             // Prepare SQL statement                                                                                   
             Exec SQL                                                                                                   
               Prepare stmtex From :lcSql;                                                                              
             Diagnostics();                                                                                             
                                                                                                                        
             // Declare a cursor for the statment                                                                       
             Exec SQL                                                                                                   
               Declare cursorex Cursor For stmtex;                                                                      
                                                                                                                        
             // Run the query and open cursor                                                                           
             Exec SQL                                                                                                   
               Open cursorex;                                                                                           
                                                                                                                        
             // Fetch next record in data set                                                                           
             Exec SQL FETCH cursorex into :lcExists;                                                                    
                                                                                                                        
             // Return appropriate exit code                                                                            
             if sqlcode=0 and sqlstate='00000';                                                                         
                // Return 1 which means a record was read.                                                              
                // Sysdummy1 should only ever return one record.                                                        
                lcRecordsExist=1;                                                                                       
             else;                                                                                                      
                // Return 0 which means no records available to read                                                    
                lcRecordsExist=0;                                                                                       
             endif;                                                                                                     
                                                                                                                        
             // Close cursor                                                                                            
             Exec SQL                                                                                                   
                close cursorex;                                                                                         
                                                                                                                        
             // Some unhandled error occurred                                                                           
             on-error;                                                                                                  
                // Make sure cursor is closed                                                                           
                Exec SQL                                                                                                
                   close cursorex;                                                                                      
                // Return -2 which means errors occurred                                                                
                lcRecordsExist=-2;                                                                                      
             endmon;                                                                                                    
                                                                                                                        
             // Return our value                                                                                        
             return lcRecordsExist;                                                                                     
                                                                                                                        
         end-proc;                                                                                                      
                                                                                                                        
        dcl-proc Diagnostics ;                                                                                          
        //----------------------------------------------------------                                                    
        // Proc: Diagnostics                                                                                            
        // Desc: Check SQL diagnostics info                                                                             
        // Link: https://www.rpgpgm.com/2017/03/using-get-diagnostic-for-sql-errors.html                                
        //----------------------------------------------------------                                                    
                                                                                                                        
        // Save the sqlcode and sqlstate before running diagnostics                                                     
        LastSqlCode=SqlCode;                                                                                            
        LastSqlState=SqlState;                                                                                          
                                                                                                                        
         exec sql GET DIAGNOSTICS                                                                                       
                 :RowsCount = ROW_COUNT;                                                                                
                                                                                                                        
         exec sql GET DIAGNOSTICS CONDITION 1                                                                           
                  :ReturnedSqlCode = DB2_RETURNED_SQLCODE,                                                              
                  :ReturnedSQLState = RETURNED_SQLSTATE,                                                                
                  :MessageLength = MESSAGE_LENGTH,                                                                      
                  :MessageText = MESSAGE_TEXT,                                                                          
                  :MessageId = DB2_MESSAGE_ID,                                                                          
                  :MessageId1 = DB2_MESSAGE_ID1,                                                                        
                  :MessageId2 = DB2_MESSAGE_ID2 ;                                                                       
                                                                                                                        
         end-proc ;                                                                                                     
                                                                                                                        
