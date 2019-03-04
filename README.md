# cache-iris-apptools
Solution for technical support and DBMS administrator. View globals arrays, execute queries (including JDBC/ODBC), sending results to email as XLS files. Viewer class instances with СRUD editing. A few simple graphs on the protocols of the system.

CSP application but based on jQuery-Ui, chart.js, jsgrid.js

### Installation

Find the latest release and import XML file into Caché by one of the next ways:

1. Just drag XML file over Studio window;
2. Go to the Management Portal -> System Explorer -> Classes -> Import and select the XML file;
3. Execute `do $system.OBJ.Load("C:\path\to\file\FileToImport.xml","ck")` in terminal.