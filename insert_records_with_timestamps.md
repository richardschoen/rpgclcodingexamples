# Example RPG and DDL to create table with timestamp fields

## Creating a row change timestamp column
https://www.ibm.com/docs/en/i/7.1?topic=language-creating-row-change-timestamp-column

## Create ORDERS1 table in QGPL  
```
CREATE TABLE QGPL.ORDERS1
   (ORDERNO SMALLINT,
    SHIPPED_TO VARCHAR(36),
    ORDER_DATE DATE,
    STATUS CHAR(1),
    CHANGE_TS TIMESTAMP FOR EACH ROW ON UPDATE AS ROW CHANGE TIMESTAMP NOT NULL);
```

## Insert sample record to table with SQL  
```
INSERT INTO QGPL.ORDERS1  (ORDERNO,SHIPPED_TO,ORDER_DATE,STATUS) VALUES(1,'A','2024-01-01','A');
```

## Query Table to See Records   
```
SELECT * FROM QGPL.ORDERS1;
```

## Write record via RPG and record level access
```
**free                                                       
                                                             
  Dcl-F ORDERS1              usage(*input:*output)           
                             RENAME(ORDERS1:ORDERS1R);       
                                                             
  // Set fields and write record                             
  // Timestamp value is inherently set                       
  ORDERNO=3;                                                 
  SHIPPED_TO='C';                                            
  ORDER_DATE= %date('2024-06-10');                           
  STATUS='A';                                                
  WRITE ORDERS1R;                                            
                                                             
  *INLR = *ON;                                               
  RETURN;
```
