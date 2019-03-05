# cache-iris-apptools
Solution for technical support and DBMS administrator. View globals arrays, execute queries (including JDBC/ODBC), sending results to email as XLS files. Viewer class instances with СRUD editing. A few simple graphs on the protocols of the system.

CSP application but based on jQuery-Ui, chart.js, jsgrid.js

### Installation

Find the latest release and import XML file into Caché by one of the next ways:

1. Enter in namespace where you want to install
2. During installation, mappig will be created in all namespace through namrspace %All
3. Execute `%SYS>do $system.OBJ.ImportDir("c:\path\to\project","*.*","ck",,1)` in terminal.
4. http://localhost:57772/apptools/App.LogInfo.cls?WHAT=%3F