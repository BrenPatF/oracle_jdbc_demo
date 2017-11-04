SET SERVEROUTPUT ON
SET TRIMSPOOL ON
SET PAGES 1000
SET LINES 500
SPOOL Install_HR_J.log
/***************************************************************************************************

Author:      Brendan Furey
Description: Script to create objects to demo JDBC procedure calls with object array parameters

         See 'A Template Script for JDBC Calling of Oracle Procedures with Object Array Parameters'
             http://aprogrammerwrites.eu/?p=1676

Modification History
Who                  When        Which What
-------------------- ----------- ----- -------------------------------------------------------------
Brendan Furey        04-May-2016 1.0   Created
Brendan Furey        04-Nov-2017 1.1   Extracted the JDBC demo code from the unit testing project, 
                                       and put into new GitHub project along with Java code

***************************************************************************************************/

REM Run this script from Oracle's standard HR schema to create objects to demo JDBC procedure calls

COLUMN "Database"	FORMAT A20
COLUMN "Time"		FORMAT A20
COLUMN "Version"	FORMAT A30
COLUMN "Session"	FORMAT 9999990
COLUMN "OS User"	FORMAT A10
COLUMN "Machine"	FORMAT A20
SELECT 'Start: ' || dbs.name "Database", To_Char (SYSDATE,'DD-MON-YYYY HH24:MI:SS') "Time", 
	Replace (Substr(ver.banner, 1, Instr(ver.banner, '64')-4), 'Enterprise Edition Release ', '') "Version"
  FROM v$database dbs,  v$version ver
 WHERE ver.banner LIKE 'Oracle%';

PROMPT Input types creation
DROP TYPE ty_emp_in_arr
/
CREATE OR REPLACE TYPE ty_emp_in_obj AS OBJECT (
        last_name       VARCHAR2(25),
        email           VARCHAR2(25),
        job_id          VARCHAR2(10),
        salary          NUMBER
)
/
CREATE TYPE ty_emp_in_arr AS TABLE OF ty_emp_in_obj
/
PROMPT Output types creation
DROP TYPE ty_emp_out_arr
/
CREATE OR REPLACE TYPE ty_emp_out_obj AS OBJECT (
        employee_id     NUMBER,
        description     VARCHAR2(500)
)
/
CREATE TYPE ty_emp_out_arr AS TABLE OF ty_emp_out_obj
/
CREATE OR REPLACE PACKAGE Emp_WS AS
/***************************************************************************************************
Description: HR demo web service code. Procedure saves new employees list and returns primary key
             plus same in words, or zero plus error message in output list

***************************************************************************************************/

PROCEDURE AIP_Save_Emps (p_ty_emp_in_lis ty_emp_in_arr, x_ty_emp_out_lis OUT ty_emp_out_arr);

END Emp_WS;
/
CREATE OR REPLACE PACKAGE BODY Emp_WS AS

PROCEDURE AIP_Save_Emps (p_ty_emp_in_lis           ty_emp_in_arr,     -- list of employees to insert
                         x_ty_emp_out_lis      OUT ty_emp_out_arr) IS -- list of employee results

  l_ty_emp_out_lis        ty_emp_out_arr;
  bulk_errors          EXCEPTION;
  PRAGMA               EXCEPTION_INIT (bulk_errors, -24381);
  n_err PLS_INTEGER := 0;

BEGIN

  FORALL i IN 1..p_ty_emp_in_lis.COUNT
    SAVE EXCEPTIONS
    INSERT INTO employees (
        employee_id,
        last_name,
        email,
        hire_date,
        job_id,
        salary
    ) VALUES (
        employees_seq.NEXTVAL,
        p_ty_emp_in_lis(i).last_name,
        p_ty_emp_in_lis(i).email,
        SYSDATE,
        p_ty_emp_in_lis(i).job_id,
        p_ty_emp_in_lis(i).salary
    )
    RETURNING ty_emp_out_obj (employee_id, To_Char(To_Date(employee_id,'J'),'JSP')) BULK COLLECT INTO x_ty_emp_out_lis;

EXCEPTION
  WHEN bulk_errors THEN

    l_ty_emp_out_lis := x_ty_emp_out_lis;

    FOR i IN 1 .. sql%BULK_EXCEPTIONS.COUNT LOOP
      IF i > x_ty_emp_out_lis.COUNT THEN
        x_ty_emp_out_lis.Extend;
      END IF;
      x_ty_emp_out_lis (SQL%Bulk_Exceptions (i).Error_Index) := ty_emp_out_obj (0, SQLERRM (- (SQL%Bulk_Exceptions (i).Error_Code)));
    END LOOP;

    FOR i IN 1..p_ty_emp_in_lis.COUNT LOOP
      IF i > x_ty_emp_out_lis.COUNT THEN
        x_ty_emp_out_lis.Extend;
      END IF;
      IF x_ty_emp_out_lis(i).employee_id = 0 THEN
        n_err := n_err + 1;
      ELSE
        x_ty_emp_out_lis(i) := l_ty_emp_out_lis(i - n_err);
      END IF;
    END LOOP;

END AIP_Save_Emps;

END Emp_WS;
/
SPOOL OFF