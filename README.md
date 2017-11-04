# jdbc_demo

This project is designed to serve as a demonstration of how to call Oracle database procedures
from Java using object arrays as both input and output parameters. It comprises a Java driver script
and Brendan's HR demo web service procedure, which is called by the script.

It can form a template for other web service procedures to allow a database developer to do a JDBC 
integration test easily, and can also be used as a starting point for Java development.

The template procedure takes an input array of objects and has an output array of objects. It is
easy to update for any named object and array types, procedure and Oracle connection. Any other 
signature types would need additional changes.

See 'A Template Script for JDBC Calling of Oracle Procedures with Object Array Parameters'
    http://aprogrammerwrites.eu/?p=1676

Pre-requisites
==============
In order to run the demo, you must have installed Oracle's HR demo schema on your Oracle instance:

Oracle Database Sample Schemas
    https://docs.oracle.com/cd/E11882_01/server.112/e10831/installation.htm#COMSC001

You must also have Java installed and Oracle's JDBC driver jar file available, and, of course, an 
Oracle client installed.

Install steps
=============
	
 	Update the logon script HR.bat for your own credentials for the HR schema, if desired
	Run Install_HR_J.sql in HR schema from SQL*Plus, or other SQL client, to set up the database
	objects
 	Create the Java project with the single source file Driver.java, using Eclipse for example
	Build the project with a suitable Oracle jdbc jar file in the build path, eg ojdbc8.jar

Running the demo Java program
=============================
From Eclipse, just do 'Run As Java Application' on the file Driver.java. The output should be:

	Connected...
	Record 1: 209/TWO HUNDRED NINE
	Record 2: 210/TWO HUNDRED TEN