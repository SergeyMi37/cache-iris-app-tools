# cache-iris-apptools
Solution for technical support and DBMS administrator. View globals arrays, execute queries (including JDBC/ODBC), 
sending results to email as XLS files. Viewer class instances with СRUD editing. A few simple graphs on the protocols of the system.

CSP application but based on jQuery-Ui, Uikit, chart.js, jsgrid.js

### Installation

Find the latest release and import XML file into Caché or IRIS by one of the next ways:

1. Just drag XML file over Studio window in any namespace for example APP;
2. Go to the Management Portal -> System Explorer -> Classes -> Import and select the XML file;
3. Execute `do $system.OBJ.Load("C:\path\cache-iris-apptools-master\src\xml\apptools.xml","ck")` in terminal.
4. During installation, mappig will be created in all namespace through namespace %All
5. If you have not installed utility 7z, copy the files from the directory C:\path\cache-iris-apptools-master\src\csp to c:\InterSystems\IRIS\CSP\app\
6. Load http://localhost:57772/apptools/App.LogInfo.cls?WHAT=%3F
