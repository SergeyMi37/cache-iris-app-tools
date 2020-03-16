Include App.LogMacro

Class App.sys [ Abstract, DependsOn = App.msg ]
{

/// Sign Out
/// d ##Expression(##class(App.sys).logout()
ClassMethod logout() As %Status
{
    #dim %session As %CSP.Session
    set st = %session.Logout(1)
    set %session.EndSession = 1
    return st
}

/// Create a task to clean the messages of the ensemble
/// for ns="AISGSASUMS","M112","SPGZ","RDID","RDIDPROD" try {zn ns w !,ns," ",##class(App.sys).CreateTaskPurge("Ensemble message cleaning",ns,90)}catch{}
ClassMethod CreateTaskPurge(Name = "", ns, days = 90) As %Status
{
	Set Task=##Class(%SYSTEM.Task).%New()
	Set Task.Name=Name
	Set Task.Type=0
	Set Task.Description="task to clean the messages of the ensemble"
	Set Task.TaskClass="Ens.Util.Tasks.Purge"
	#;Every day at 1:00 am
	Set Task.DailyStartTime=3600
	;Do Task.idSet(Number)
	Set Task.RunAsUser="SuperUser"
	Set Task.MirrorStatus=3
	Set t=##class(Ens.Util.Tasks.Purge).%New()
	Set t.KeepIntegrity=0
	Set t.NumberOfDaysToKeep=days
	Set t.BodiesToo=1
	Set t.TypesToPurge="all"
	Set Task.Settings=t.GetSettings()
	Set Task.NameSpace=ns
	quit Task.%Save()
}

/// Get system user properties
/// w ##class(App.sys).GetSysUserProp("Login",.Prop)
ClassMethod GetSysUserProp(Name, Prop) As %String
{
	$$$NspGoto(curNs,"%SYS")
	set Status=##Class(Security.Users).Get(Name,.Prop)
	$$$NspReturn(curNs)
	quit Status
}

/// Check whether the database is prepared
/// w ##class(App.sys).IsPreparedDB("ENSDEMO")
ClassMethod IsPreparedDB(name)
{
	i (",ENSDEMO,ENSEMBLE,ENSEMBLEENSTEMP,ENSEMBLESECONDARY,ENSLIB,CACHESYS,CACHELIB,CACHETEMP,CACHE,CACHEAUDIT,DOCBOOK,USER,SAMPLES,IRISSYS,IRISLIB,IRISTEMP,IRISLOCALDATA,IRISAUDIT")[(","_$zconvert(name,"U")_",") q 1
	Q 0
}

/// Get a list of products in namespace
/// w ##class(App.sys).getEnsProd("ENSDEMO",.info)
ClassMethod getEnsProd(name, info)
{
	s sc=$$$OK
	try {
		$$$NspGoto(curNs,name) KILL info
		DO ##CLASS(Ens.Director).GetProductionSummary(.info,name)
	}
	catch e { s sc=$$$ERROR($$$GeneralError,$ze)}
	$$$NspReturn(curNs)
	Q sc
}

/// Check whether the namespace is prepared
/// w ##class(App.sys).IsPreparedNS("%SYS")
ClassMethod IsPreparedNS(name)
{
	i (",%SYS,%ALL,DOCBOOK,ENSDEMO,ENSEMBLE,SAMPLES,USER,")[(","_$zconvert(name,"U")_",") q 1
	Q 0
}

/// //get csp apps 
/// w ##class(App.sys).getCSPapps("/apptools","Path")
ClassMethod getCSPapps(csppapp, prop)
{
		
 $$$NspGoto(curNs,"%SYS")
	s result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s tSC=result.Prepare("select * FROM Security.Applications where Name=?")
	s:tSC tSC=result.Execute(csppapp)
	i '$$$ISOK(tSC) {
		 QUIT tSC
	}
	else {
		while result.Next() {
			set res=result.Data(prop)
		}
	}
	d result.Close()
	$$$NspReturn(curNs)	
	Q $g(res)
}

/// d ##class(App.sys).CreateResourse(.res,"NotPre")
ClassMethod CreateResourse(res, type = "")
{
	$$$NspGoto(curNs,"%SYS")
	d ..ListDB(.info,type)
	s r=""
	for { s r=$o(info(r)) q:r=""
		s ResourceName="%DB_"_r
    	if (##class(Security.Resources).Exists(ResourceName) = 0) {
        	set st = ##class(Security.Resources).Create(ResourceName,
            "Grants access to DB "_r_".", "")
            s res(ResourceName)=st
    	}
	}
	$$$NspReturn(curNs)	
 q $$$OK
}

/// Get a list of database names separated by commas
/// w ##class(App.sys).ListDB(.info,"NotPre")
/// Flag = "NotPre" - exclude prepared
/// Flag = "NotTemp" - exclude tempory
ClassMethod ListDB(info, Flag = "")
{
	$$$NspGoto(curNs,"%SYS")
	s list=""
	s rss=##class(%ResultSet).%New("Config.Databases:List")
	d rss.Execute()
	while rss.Next(.sc) { 
		s name=rss.Data("Name")
		if Flag["NotPre" continue:##class(App.sys).IsPreparedDB(name)
		if Flag["NotTemp" continue:(name_",")["SECONDARY,"||((name_",")["TEMP,")
		s list=list_","_name 
		m info(name)=rss.Data
	}
	
	d rss.Close()
	$$$NspReturn(curNs)	
	Q $g(list)
}

/// Get a list of domain namespaces separated by commas
/// w ##class(App.sys).ListNS(.info,"NotPre")
/// Flag = "Ens" - only where the ensemble is installed
/// Flag = "NotPre" - exclude prepared
ClassMethod ListNS(info, Flag = "")
{
	s disp=""
	$$$NspGoto(curNs,"%SYS")	
	set tRS = ##class(%ResultSet).%New("Config.Namespaces:List")
	if '$isobject(tRS) q ""
	set tSC = tRS.Execute()
	While tRS.Next() {	
		s name=tRS.GetData(1) KILL ens
		if Flag["NotPre" continue:##class(App.sys).IsPreparedNS(name)
		if Flag["Ens",##class(App.sys).getEnsProd(name,.ens) k info("Ens") m info(name,"Ens")=ens
		s disp=disp_","_name
		m info(name)=tRS.Data
	}
	d tRS.Close()
	$$$NspReturn(curNs)	
	Q $g(disp)
}

/// Function to call the OS command in the result output
/// %SYS>d ##class(App.sys).RunCmd("sudo du -sm /opt/isc/ensemble/mgr/*| sort -nr",$na(^%App.Cmd("mgr",$zd($h,3))),1,"/backup/temp/snmp/")
ClassMethod RunCmd(cmdOs = "free", gn = "^TaskGN", AddDateTime = 0, dir = "/backup/temp/")
{
	s gnTask=gn
	set filename=dir_"RunCmd.log"
	if AddDateTime set datetime=$tr($$$AppDT($h)," ","_") set gnTask=$na(@gn@(datetime)),filename=dir_"RunCmd"_datetime_".log"
	if cmdOs'="",$zf(-1,cmdOs_" > "_filename)
	if ##class(App.files).ReadFile2Arr(filename,"RSK",,"^||tmpFile") MERGE @gnTask=^||tmpFile
	q $$$OK
}

/// Function to call from a regular task
/// %SYS>d ##class(App.sys).RunTask("snmpwalk -v 1 server.ru -c public 1.3.6.1.4.1.16563.1.1.1.1.10","^%App.TaskLic","%SYSTEM.License:Counts","/backup/temp/snmp/")
ClassMethod RunTask(cmdOs = "free", gn = "^TaskGN", query = "%SYSTEM.License:Counts", dir = "/backup/temp/")
{
	set datetime=$tr($$$AppDT($h)," ","_")
	set gnTask=$na(@gn@(datetime))
	set filename=dir_"RunTask"_datetime_".txt"
	if cmdOs'="",$zf(-1,cmdOs_" > "_filename)
	if query'="" d ##class(App.sys).SaveQuery(query,gn,datetime)
	q $$$OK
}

///   w ##class(App.sys).getSQLConnection(.list)
ClassMethod getSQLConnection(ByRef List As %String = "")
{
	set res=""
	$$$NspGoto(curNs,"%SYS")	
	Set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	Set tSC=result.Prepare("select Connection_Name,isJDBC,DSN from %Library.sys_SQLConnection") ; where isJDBC=1")
	Set:tSC tSC=result.Execute()
	
	if '(tSC) {
		s text=$$$aText("Application Setup Error","")_" :"_$SYSTEM.Status.GetErrorText(tSC)  w !,text QUIT $$Error^%apiOBJ(text)
	}
	else {
		while result.Next() {
			if result.Data("Connection_Name")'="" {
				set List(result.Data("Connection_Name"))=$s('result.Data("isJDBC"):result.Data("DSN"),1:"")
				set res=res_result.Data("Connection_Name")_","
			}
		}
	}
	$$$NspReturn(curNs)	
	Q $g(res)
}

/// Get the value of a field by its name from GN or a list of values
/// Format $listbuild
/// w a=##class(App.sys).GetValueGN(gn,2,"QUANTITY,PRIMARY_UNIT_OF_MEASURE")
ClassMethod GetValueGN(gn, row, NameFields) As %Status
{
	i NameFields'["," q $lb(..GetValue(gn,row,NameFields))
	set ret=""
	for i=1:1:$l(NameFields,",") { continue:$p(NameFields,",",i)=""
		set ret=ret_$lb(..GetValue(gn,row,$p(NameFields,",",i)))
	}
	q ret
}

/// Get one field value by its name from GN
/// w a=##class(App.sys).GetValue(gn,2,"QUANTITY")
ClassMethod GetValue(gn, row, NameField) As %Status
{
 i $g(@gn@(-1,NameField))="" q "" ;undefined field: "_NameField
 i '$d(@gn@(row)) q "undefined row: "_row
 q $lg(@gn@(row),@gn@(-1,NameField))
}

/// Procedure for calling from a regular job and storing reports in the global
/// %SYS>d ##class(App.sys).SaveQuery("SYS.Database:FreeSpace")
/// %SYS>d ##class(App.sys).SaveQuery("%SYSTEM.License:Counts")
ClassMethod SaveQuery(query = "%SYSTEM.License:Counts", gn = "^%App.Task", datetime = "")
{
	set:datetime="" datetime=$$$AppDT($h)
	set gnTask=$na(@gn@(query,datetime))
	Set rset=##class(%Library.ResultSet).%New($p(query," ",1))
	If rset="" s @gnTask@("Create Query failed")= $System.Status.DisplayError(%objlasterror) q %objlasterror
	if $p(query," ",3)'=""	{Set status=rset.Execute($p(query," ",2),$p(query," ",3))}
	elseif $p(query," ",2)'=""	{Set status=rset.Execute($p(query," ",2))}
	else { Set status=rset.Execute()}
	If $$$ISERR(status) s @gnTask@("Execute Query failed:")= $System.Status.DisplayError(status) q status
	Set colcnt=rset.GetColumnCount()
	For i=1:1:colcnt s @gnTask@(0,i)=rset.GetColumnName(i)
	while rset.Next() {	if $I(row)
	   For i=1:1:colcnt s @gnTask@(row,i)=rset.GetData(i)
	}
	q $$$OK
}

/// /*! \brief Procedure query executing and storing reports in the global
/// <br>\ingroup query
/// <br>\param ext=1 add saving column and row positions
/// <br>\return count rows
/// <br>\example d ##class(App.sys).SaveSQL("select * from Ens.MessageHeader where id=1461","^logMSW2") */
ClassMethod SaveSQL(SQL, gn = "^mtempSQLGN", ext = 0) As %String
{
	s st=$$$OK,hr=$h,ts=$$$AppDT(hr)
	s myQuery = ##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s st=myQuery.Prepare(SQL)
	i 'st q st
	s st=myQuery.Execute()
	i 'st q st
	s (count)=0
	k @gn
	s ColCount=myQuery.GetColumnCount()
	F i=1:1:ColCount {	s @gn@(0)=$g(@gn@(0))_$lb(myQuery.GetColumnName(i))	
		s @gn@(-1,$ZStrip(myQuery.GetColumnName(i),"<>WCP"))=i //Name = Number
	}
	while (myQuery.Next())	{
		s count=count+1
		if ext s @gn@(-2,$ZStrip(myQuery.Get("Name"),"<>WCP"))=count  ; w "<li>"_myQuery.Get("Name")_" "_count_" "_$zr
		f ii=1:1:ColCount {
			s @gn@(count)=$g(@gn@(count))_$lb(myQuery.GetData(ii))
			}
	}
	s @gn@(-3,"sql")=$lb(SQL)
	s @gn@(-3,"timestamp")=$lb(ts,$$$AppDT($h),##class(App.type).GetCountSec($h)-##class(App.type).GetCountSec(hr))
	q count
}

/// Is there such a class
/// w ##class(App.sys).ClassExist("Spgz.model.spgz")
ClassMethod ClassExist(class) As %String
{
	q:class="" ""
	try {
		s st=$d($$$comClassRaw(class))
	} catch e { s st=$ze }
  q $g(st)
}

/// Global list
/// d ##class(App.sys).GlobalList("SAMPLES",.L)
ClassMethod GlobalList(ns, ByRef list, SystemGlobals = 0, Mapped = 1) As %Status
{
/// Returns a list of the Globals in a Cache NameSpace (used for GUI display)<br>
/// <br>
/// <b>Parameters:</b> <br>
/// NameSpace - a Cache namespace. Default is current namespace. <br>
/// Mask - a mask, or comma-separated list of masks, to select globals. Default is "*" for all.<br>
/// SystemGlobals - boolean flag to include system globals in the results. Default is "0".<br>
/// UnavailableDatabases - a returned local array of any databases not currently accessible, i.e. array(name)=status.<br>
/// Index - Internal use only.<br>
/// IgnoreHasData - For faster list of Globals set this to 1 and the HasData column will always be FALSE.<br>
/// Mapped - Return all mapped global nodes when set to 1, the default value of this parameter is 1.
/// <br>
/// Valid masks are as follows:
/// <br>
/// ABC* - All strings starting with ABC<br>
/// A:D - All strings between A and D<br>
/// A:D,Y* - All strings between A and D, and all strings starting with Y<br>
/// A:D,'C* - All strings between A and D, except those starting with C
/// Query NameSpaceList(  NameSpace As %String,  Mask As %String,  SystemGlobals As %Boolean,  ByRef UnavailableDatabases As %String,  Index As %Integer,  IgnoreHasData As %Boolean = 0,  Mapped As %Boolean = 1) As %Query(ROWSPEC = "Name:%String,Location:%String,ResourceName:%String,Permission:%String,Empty:%String,Keep:%String,Collation:%String,PointerBlock:%String,GrowthBlock:%String,HasData:%Boolean,Journal:%String,LockLocation:%String,HasSubscripts:%Boolean") [ SqlProc ]
 set s = ##class(%SQL.Statement).%New()
 do s.%PrepareClassQuery("%SYS.GlobalQuery", "NameSpaceList")
 set r = s.%Execute(ns, "*",SystemGlobals,,,,Mapped)
 ;set $namespace = ns
 while r.%Next() { 
	;w !,r.%Get("Name")
	s list(r.%Get("Name"))=""
 }
}

/// Global list
/// d ##class(App.sys).GlobalList("SAMPLES",.L)
ClassMethod GlobalSize(dir, ByRef list, SystemGlobals = 0, FastFlag = 1) As %Status
{
/// Size(Directory As %String, System As %String = "", Mask As %String, SystemGlobals As %Boolean, Index As %Integer, FastFlag As %Boolean)
/// Selects Name As %String, Allocated MB As %Float, Used MB As %Float
 set s = ##class(%SQL.Statement).%New()
 do s.%PrepareClassQuery("%SYS.GlobalQuery", "Size")
 set r = s.%Execute(dir,,"*",SystemGlobals,,FastFlag )
 ;set $namespace = ns
 while r.%Next() { 
	;w !,r.%Get("Name")
	s list(r.%Get("Name"))=""
 }
}

/// s a=##class(App.sys).GetObj("select top 1 * from model.SP where deletedDate is null order by importDate desc") zw a
ClassMethod GetObj(Query)
{
	#dim rs As %ResultSet.SQL = ##class(%ResultSet.SQL).%Prepare(Query)
	if 'rs.%Next() q $$$NULLOREF
	q rs
}

/// Get a DSN request
/// w $System.Status.GetErrorText(##class(App.sys).SqlToDSN("SELECT * FROM xxmv.xx_t359_pzn","OEBS-Daily","^tmMSWq"))
ClassMethod SqlToDSN(sql, DSN, result, top = 100000) As %Status
{
	#dim %JDBCGateway As %Net.Remote.Java.JDBCGateway
	s hr=$h,ts=$$$AppDT(hr)
	set conn = $system.SQLGateway.GetJDBCConnection(DSN)
	if (conn = "") quit 0
	set st = %JDBCGateway.prepareStatement(conn, sql)
	set %JDBCGateway.StatementCache(conn) = st
	set query = %JDBCGateway.execQuery(st)
	
	if (query = -1)	{
		;w %JDBCGateway.getErrorText() q 0
		set sc = $$$ERROR($$$GeneralError, %JDBCGateway.getErrorText())
		do %JDBCGateway.removeStatement(conn)
		;if $isObject($g(%JDBCGateway)) do %JDBCGateway.closeAll()
		quit sc
	}
	i $g(result)'="" s gn=result k @gn
	e  s gn="result" 
	
	set columns = %JDBCGateway.getColumnCount(st)
	
	;set pos = 0
	for i=1:1:columns 
	{
	  set name = $ZStrip(%JDBCGateway.getColumnName(st,i),"<>WCP")
	  set size = %JDBCGateway.getColumnDisplaySize(st,i)
	  set Type= %JDBCGateway.getColumnType(st,i)
	  set TypeName= %JDBCGateway.getColumnTypeName(st,i)
	  s @gn@(0,i)=$lb(name,size,Type,TypeName)
	  set @gn@(-1,name)=i //	  ;s @gn@(-1)=$g(@gn@(-1))_$lb($lb(size,Type,TypeName))
	  ;set pos(i) = pos
	  ;set pos = pos + size + 1
	  ;w name,!
	}

	set cnt = 1
	while %JDBCGateway.next(st)
	{
		;write !
		for i=1:1:columns {
			;write "!",%JDBCGateway.getString(st, i) 
			s @gn@(cnt)=$g(@gn@(cnt))_$lb(%JDBCGateway.getString(st, i))
		}
		set cnt = cnt + 1
		q:cnt>top
	}
	;w !,cnt,!
	;if $isObject($g(%JDBCGateway)) do %JDBCGateway.closeAll()
	do %JDBCGateway.removeStatement(conn)
	s @gn=cnt-1
	s @gn@(-3,"sql")=$lb(sql,DSN,top)
	s @gn@(-3,"timestamp")=$lb(ts,$$$AppDT($h),##class(App.type).GetCountSec($h)-##class(App.type).GetCountSec(hr))
	quit $$$OK
}

/// s a=##class(App.sys).SaveGateway("select * from Sample.Person","Ensemble Samples","_system","") zw a
/// TODO save to gn
ClassMethod SaveGateway(sql, pDSN, usr, pwd, result, top = 100000)
{
 #include %occInclude
 	s hr=$h,ts=$$$AppDT(hr)
 	//Create new Gateway connection object
 	set gc=##class(%SQLGatewayConnection).%New()
 	If gc=$$$NULLOREF quit $$$ERROR($$$GeneralError,"Cannot create %SQLGatewayConnection.")
 		  
 	//Make connection to target DSN
 	set sc=gc.Connect(pDSN,usr,pwd,0) 
 	If $$$ISERR(sc) quit sc
 	if gc.ConnectionHandle="" quit $$$ERROR($$$GeneralError,"Connection failed")
 		  
 	set sc=gc.AllocateStatement(.hstmt) 
 	if $$$ISERR(sc) quit sc
		  
 	//Prepare statement for execution
 	set sc=gc.Prepare(hstmt,sql) 
 	if $$$ISERR(sc) quit sc
 	//Execute statement
 	set sc=gc.Execute(hstmt)
 	if $$$ISERR(sc) quit sc
 	//Get list of columns returned by query
 	set sc=gc.DescribeColumns(hstmt, .columnlist) 
 	if $$$ISERR(sc) quit sc
 	
 	if $g(result)'="" s gn=result k @gn
	else  s gn="result" 
 	//display column headers delimited by ":"
 	set numcols=$listlength(columnlist)-1  //get number of columns
 	for colnum=2:1:numcols+1 {
 		    ;Write $listget($listget(columnlist,colnum),1),":"
 		    set name=$listget($listget(columnlist,colnum),1)
 		    set @gn@(0,colnum-1)=$lb(name)
	  		set @gn@(-1,name)=colnum-1 
 	  		}
 	;write !
 	 
 	//Return first 200 rows	  
 	set sc=gc.Fetch(hstmt)
 	if $$$ISERR(sc) quit sc
 	set rownum=1
 	while((gc.sqlcode'=100) && (rownum<=top)) {
 	      	for ii=1:1:numcols {
 		      	set sc=gc.GetData(hstmt, ii, 1, .val)
 		      	;w " "_val
 		      	set @gn@(rownum)=$g(@gn@(rownum))_$lb(val)
 		      	if $$$ISERR(sc) break
 	      	}
 	      	set rownum=rownum+1
 	 		;write !
 	 		set sc=gc.Fetch(hstmt)
 			if $$$ISERR(sc) break
 
 	  		}
 	    
 	  //Close cursor and then disconnect
 	set sc=gc.CloseCursor(hstmt)
 	if $$$ISERR(sc) quit sc
 	set sc=gc.Disconnect()
	set @gn=rownum-1
	set @gn@(-3,"sql")=$lb(sql,pDSN,top,usr,pwd)
	set @gn@(-3,"timestamp")=$lb(ts,$$$AppDT($h),##class(App.type).GetCountSec($h)-##class(App.type).GetCountSec(hr))
 	Quit sc
}

/// Sample  w ##class(App.sys).GetFullName("superuser")
ClassMethod GetFullName(login) As %String
{
 try {
	$$$NspGoto(curNs,"%SYS")
	if ##class(Security.Users).Exists(login,.User,.Status) {
			if $isobject(User) {
				s fullName=User.FullName 
			}
		}
  $$$NspReturn(curNs) 
 } catch e {}
  q $g(fullName)
}

/// Sample  w ##class(App.sys).GetRoles(mask,.roles)
ClassMethod GetRoles(mask = "", ByRef list) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  set mask=$zconvert(mask,"L")
  set sql="select NameLowerCase,Description,Name FROM Security.Roles"
  if mask["," { set mask=$replace($ZStrip(mask,"<>W"),",","','")
  	set sql=sql_" where ID in ('"_mask_"')"
  } 
  elseif mask'="" {
	  set sql=sql_" where NameLowerCase like '%"_mask_"%'"
  }
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare(sql)
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
	 	QUIT tSC
	}
	else {
		while result.Next() {
			set list(result.Data("NameLowerCase"))=$lb(result.Data("Name"),result.Data("Description"))
		}
	}
	quit $$$OK
}

/// Get system users
/// w ##class(App.sys).GetUsers("super",.users)
ClassMethod GetUsers(mask = "", ByRef list) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  set mask=$zconvert(mask,"L")
  set sql="select NameLowerCase,FullName,Comment,Roles,EmailAddress FROM Security.Users"
  if mask["," { set mask=$replace($ZStrip(mask,"<>W"),",","','")
  	set sql=sql_" where NameLowerCase in ('"_mask_"')"
  } 
  elseif mask'="" {
	  set sql=sql_" where NameLowerCase like '%"_mask_"%'"
  }
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare(sql)
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
	 	QUIT tSC
	}
	else {
		while result.Next() {
			set list(result.Data("NameLowerCase"))=$lb(result.Data("FullName"),result.Data("Comment"),result.Data("Roles"),result.Data("EmailAddress"))
		}
	}
	quit $$$OK
}

/// Delete and Export the table in oeBS when the match is in Description
/// Sample d ##class(App.sys).Export("OEBS",.msg,"Mvk.model.Characteristic")
/// s class="Spgz.model.PP.Files" d ##class(App.sys).Export("OEBS",.msg,class,1,"select * from "_##class(App.type).GetTableName(class)_" where FileID='127'")
ClassMethod Export(jdbc = "OEBS", msg, class, NoDel = 0, sql = "", write = 0)
{
	#define addQuote(%s) $replace(%s,"'","''")
	d ##class(App.LogInfoPane).GetClassDef(class,"",.out,0)
	;zw out
	q:'$d(out) 1
	s gn="^||tmpExp"_$p(class,".",*)  ;^||
	kill @gn	
	s:sql="" sql="select * from "_##class(App.type).GetTableName(class)
	s st=##class(App.sys).SaveSQL(sql,gn)
	i 'st q st
	s rowcount=$o(@gn@(""),-1) 
	w:write !,$$$FormatText($$$aText("On request %1 found %2 records",""),sql,rowcount)_" "_gn_" "_$System.Status.GetErrorText(st)
	i 'rowcount w:write !,$$$aText("there is nothing to export","") q 1

	s tab=$g(out("Parameters","OEBSTAB","Default"))
	w:write !,tab
	if 'NoDel { ;do not delete the table
		s del="delete "_tab
		s gnDel="^||tmpExpDel"
		s st=##class(App.sys).SqlToDSN(del,jdbc,gnDel)
		;i 'st s err=$System.Status.GetErrorText(st) q st
		kill @gnDel
	}
	i write { ;check the types in oeBS
		s sqltest="select * from "_tab_" where 1=0"
		s gnD="^||tmpExpD"
		s st=##class(App.sys).SqlToDSN(sqltest,jdbc,gnD)
		zw @gnD
	}
	s f="" ;Create an array of unequivocal conformity between oeBS and instrumentation fields
	f ff=1:1 { s f=$o(out("Properties",f)) q:f=""
		i $e(out("Properties",f,"Description"))="=" {
			w:write !,ff_". "_$$$aText("field","")_" ",f
			s desc=$p(out("Properties",f,"Description"),";",1)
			w:write " "_$$$aText("review","")_" ",desc
			s oefield=$p($p(desc,"=",2)," ")
			s oetype=$ZStrip($p(desc," ",2,*),"<>WCP")
			
			if " "[oefield {	s oefield=f	}
			if oetype="" {	s oetype="NUMBER"	}
			if $zconvert(oefield,"L")["date" {	s oetype="DATE"	}
			
			i write {w " -> "_oefield_" "_oetype_" "
			 s num=$g(@gnD@(-1,$zconvert(oefield,"U")))
			 if 'num {w $$$aText("not found","")_" "_$zconvert(oefield,"U")}
			 else { s typ=$lg(@gnD@(0,num),4) w typ
			 	i oetype'[typ w $$$aText("not the same","")
			 }
			}
			s array(f)=oefield
			s array(f,"type")=oetype
		}
	}
	i '$d(array) w !,$$$aText("Not configured-to-one correspondence","") q 1
	s f="" ;A new pass through the array, sorting may differ
	s pattIns="insert into "_tab_"("
	f { s f=$o(array(f)) q:f=""
		s pattIns=pattIns_array(f)_$s($o(array(f))="":"",1:",")_" "
	}	
	s pattIns=pattIns_") values "
	;w !,pattIns 
	s ins="",coun=0,gnIns="^||tmpExpIns"
	s chank=2000 ;1000 batch of transmission records
	m fields=@gn@(-1)
	for row=1:1:rowcount { 
		s coun=coun+1
		
		s f="" ;Get the values to be written
		s values="("
		f { s f=$o(array(f)) q:f=""
			 s val=$$$addQuote($lg(@gn@(row),fields(f))) 
			 if array(f,"type")["DATE" {
				 s val="TO_DATE('"_val_"','YYYY-MM-DD HH24:MI:SS')"
			 } else {
				 s val="'"_val_"'"
			 }
			s values=values_val_$s($o(array(f))="":"",1:",")_" "
		}	
		s ins=ins_pattIns_values_");"		
		;w:row=1 !,ins ;q:row=1
		i '(coun#chank) {
			w:write !,ins
			s st=##class(App.sys).SqlToDSN("BEGIN "_ins_" COMMIT; END;",jdbc,gnIns)
			s ins=""
		}
	}
	;q 1
	i ins'="" w:write !,ins s st=##class(App.sys).SqlToDSN("BEGIN "_ins_" COMMIT; END;",jdbc,gnIns)
	s st=##class(App.sys).SqlToDSN("select count(*) from "_tab,jdbc,gnIns)
	i $d(%objlasterror) w:write !,$System.Status.GetErrorText(%objlasterror)
	s inscount=$lg($g(@gnIns@(1)),1) ;from the first record to take the first field
	s msg=$$$FormatText($$$aText("Unloaded %1 from %2",""),inscount,rowcount)
	k @gnIns,@gn
	w:write !,msg
	q $$$OK
}

/// zn "app" w $System.Status.GetErrorText(##class(App.sys).DismountListDB("DOJO"))
ClassMethod DismountListDB(Database, write = 0) As %Status
{
	s st=##class(App.sys).DismountDB(Database)
	if st {
		s st1=##class(App.sys).DismountDB(Database_"ENSTEMP")
		if 'st1 q st1
		s st2=##class(App.sys).DismountDB(Database_"SECONDARY")
		if st2 q st2
	} else { q st }
	q $$$OK
}

/// w $System.Status.GetErrorText(##class(App.sys).DismountDB("ASURPROD"))
ClassMethod DismountDB(Database) As %Status
{
	new $namespace
	zn "%sys"
	s st=$$$OK
	If ##Class(Config.Databases).Get(Database,.Properties) {
		Set Directory = $G(Properties("Directory"))
  		Set st = ##class(SYS.Database).DismountDatabase(Directory)
	}
	q st
}

/// zn "app" w ##class(App.sys).MountDB("DOJO")
ClassMethod MountDB(Database) As %Status
{
	new $namespace
	zn "%sys"
	If ##Class(Config.Databases).Get(Database,.Properties) {
		Set Directory = $G(Properties("Directory"))
  		q ##class(SYS.Database).MountDatabase(Directory)
	}
	q $$$OK
}

/// zn "app" w $System.Status.GetErrorText(##class(App.sys).MountListDB("DOJO"))
ClassMethod MountListDB(Database) As %Status
{
	s st=##class(App.sys).MountDB(Database)
	if st {
		s st1=##class(App.sys).MountDB(Database_"ENSTEMP")
		if 'st1 q st1
		s st2=##class(App.sys).MountDB(Database_"SECONDARY")
		if st2 q st2
	} else { q st }
	q $$$OK
}

}

