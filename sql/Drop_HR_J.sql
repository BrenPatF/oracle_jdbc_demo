SPOOL Drop_HR_J.log
/***************************************************************************************************

Author:      Brendan Furey
Description: Script to drop the common objects from demo JDBC procedure calls

Further details: 'TRAPIT - TRansactional API Testing in Oracle'
                 http://aprogrammerwrites.eu/?p=1723

Modification History
Who                  When        Which What
-------------------- ----------- ----- -------------------------------------------------------------
Brendan Furey        04-May-2016 1.0   Created
Brendan Furey        11-Sep-2016 1.1   

***************************************************************************************************/

REM Run this script from Oracle's standard HR schema to drop objects from demo JDBC procedure calls

PROMPT Input types
DROP TYPE ty_emp_in_arr
/
DROP TYPE ty_emp_in_obj
/
PROMPT Output types
DROP TYPE ty_emp_out_arr
/
DROP TYPE ty_emp_out_obj
/
PROMPT Package
DROP PACKAGE Emp_WS
/
SPOOL OFF