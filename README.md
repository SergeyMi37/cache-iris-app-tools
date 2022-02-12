![](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/favicon.ico)
# cache-ensemble-iris-apptools
[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/cache-iris-app-tools)

Application tools for technical support and DBMS administrator. View globals arrays, execute queries (including JDBC/ODBC), 
sending results to email as XLS files. Viewer class instances with СRUD editing. A few simple graphs on the protocols of the system.
CSP application but based on jQuery-Ui, Uikit, chart.js, jsgrid.js


## Installation

Find the latest release and import XML file into Caché or IRIS by one of the next ways:
The namespace must be enabled for Intorparbilty (Ensemble) enabled!

1. X -- Just drag XML file over Studio window in any Interopeability enabled namespace for example APP;
2. X -- Go to the Management Portal -> System Explorer -> Classes -> Import and select the XML file;
3. Execute `do $system.OBJ.LoadDir("C:\path\cache-iris-apptools\src\","ck",,1)` in terminal.
4. During installation, mappig will be created in all namespace through namespace %All
5. For Windowqs, if you have not installed utility 7z.exe, copy the files from the directory C:\path\cache-iris-apptools-master\src\csp to c:\InterSystems\IRIS\CSP\app\
   For linux CSP files should be installed automatically.

## Panel for admins & developers

 Load http://your-host:your-port/apptools/App.LogInfo.cls
 - view the list of globals by mask with count blocks occupied by them.
 - viewing global and direct and reverse with a possible filter by links and node data. Edit global nodes. Export a selection of nodes and global data to an XLS file and send the archive to an email.
 - execution of queries and SQL statements with the ability to connect via JDBC / ODBC. Export the results to an XLS file and send the archive to an email.
 - code execution by XECUTE command in the interface panel.
 - saving commands and queries in the program history with the ability to run them again.
 - there is a module for implementing the LockedDown mode - ##class(App.security).LockDown(...)
 - multilanguage interface supported (install the global from C:\path\cache-iris-apptools-master\src\glb\appcachemsg.xml).

## Charts admins

 Load http://your-host:your-port/apptools/App.Chart.cls?panel=class(App.ChartPanel).ChartAlert
  - output of the DBMS events using the iris.log protocol (cconsole.log)

 Load http://your-host:your-port/apptools/App.Chart.cls?panel=class(App.ChartPanel).ChartDbSize
  - output of the growth dynamics of DBMS database files using the iris.log protocol (cconsole.log)

## Class explorer
 Load http://your-host:your-port/apptools/App.FormExp.cls?panel=AccordionExp
  - Navigation by namespaces, class, and class instance. Create, edit, and delete class instances in the on-screen form interface.

##  Matrix permissions
 Load http://your-host:your-port/apptools/apptools/App.TabsPanelUikitPermissMatrx.cls?autoload=Matrix
  - Group assignment of roles to users by selecting them by filter in the screen panel
![Matrix permissions](https://github.com/SergeyMi37/cache-iris-app-tools/blob/master/acc-matrix.gif)

## Templates & Samples  
 Load http://your-host:your-port/apptools/App.TabsPanelSample.cls   
 - jQuery-Ui.js based application template.
  
 Load http://your-host:your-port/apptools/App.TabsPanelUikit.cls
 - UiKit.js based application template
   
 Load http://your-host:your-port/apptools/App.TabsPanelUikitAdmin.cls
  - UiKit.js based application template for admin panels
   
