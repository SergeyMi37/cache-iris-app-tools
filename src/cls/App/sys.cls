Include App.LogMacro

Class App.sys [ Abstract ]
{

/// Create a task to clean the messages of the ensemble
/// for ns="AISGSASUMS","MVK112","SPGZ","RDID","RDIDPROD" try {zn ns w !,ns," ",##class(App.sys).CreateTaskPurge("Ensemble message cleaning",ns,90)}catch{}
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
	i (",ENSDEMO,ENSEMBLE,ENSEMBLEENSTEMP,ENSEMBLESECONDARY,ENSLIB,CACHESYS,CACHELIB,CACHETEMP,CACHE,CACHEAUDIT,DOCBOOK,USER,SAMPLES,")[(","_$zconvert(name,"U")_",") q 1
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
/// %SYS>d ##class(App.sys).RunTask("snmpwalk -v 1 cip.mvk.ru -c public 1.3.6.1.4.1.16563.1.1.1.1.10","^%App.TaskLic","%SYSTEM.License:Counts","/backup/temp/snmp/")
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
		s text=$$$aText("Application Setup Error","Ошибка настройки приложений")_" :"_$SYSTEM.Status.GetErrorText(tSC)  w !,text QUIT $$Error^%apiOBJ(text)
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
/// В формате $listbuild
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
	q $d($$$comClassRaw(class))
}

/// Add two languages to global translation
/// Samples ##Expression(##class(App.sys).AddLangMsg(%en,%ru))
ClassMethod AddLangMsg(en, ru) As %String
{
	s @$$$GNLang@($$$GNLangDOMAIN) = "ru"
	s @$$$GNLang@($$$GNLangDOMAIN,"en",$zcrc(en,7)) = en
	s @$$$GNLang@($$$GNLangDOMAIN,"ru",$zcrc(en,7)) = ru
	q "$g("_$$$GNLang_"("""_$$$GNLangDOMAIN_""",$get("_$$$GNEnsConf_"(""Language""),$mvv(58)),"_$zcrc(en,7)_"),"""_en_""")"
}

/// Sign Out
/// d ##Expression(##class(App.sys).logout()
ClassMethod logout() As %Status
{
    #dim %session As %CSP.Session
    set st = %session.Logout(1)
    set %session.EndSession = 1
    return st
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

/// s a=##class(App.sys).GetObj("select top 1 * from Mvk_model.SPGZ where IdSPGZ=3620277 and deletedDate is null order by importDate desc") zw a
ClassMethod GetObj(Query)
{
	#dim sql As %ResultSet.SQL = ##class(%ResultSet.SQL).%Prepare(Query)
	s obj=$$$NULLOREF
	while sql.%Next() {
		s obj=sql
		q
	}
	q obj
}

/// Get a DSN request
/// w $System.Status.GetErrorText(##class(App.sys).SqlToDSN("SELECT * FROM xxmv.xxmvk_t359_pzn","OEBS-Daily","^tmMSWq"))
ClassMethod SqlToDSN(sql, DSN, result, top = 100000) As %Status
{
	#dim %JDBCGateway As %Net.Remote.Java.JDBCGateway
	s hr=$h,ts=$$$AppDT(hr)
	set conn = $system.SQLGateway.GetJDBCConnection(DSN)
	if (conn = "") quit 0
	set st = %JDBCGateway.prepareStatement(conn, sql)
	set %JDBCGateway.StatementCache(conn) = st
	set query = %JDBCGateway.execQuery(st)
	
	if (query = -1)
	{
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
 	
 	i $g(result)'="" s gn=result k @gn
	e  s gn="result" 
 	//display column headers delimited by ":"
 	set numcols=$listlength(columnlist)-1  //get number of columns
 	for colnum=2:1:numcols+1 {
 		    ;Write $listget($listget(columnlist,colnum),1),":"
 		    s name=$listget($listget(columnlist,colnum),1)
 		    s @gn@(0,colnum-1)=$lb(name)
	  		set @gn@(-1,name)=colnum-1 
 	  		}
 	;write !
 	 
 	//Return first 200 rows	  
 	set sc=gc.Fetch(hstmt)
 	if $$$ISERR(sc) quit sc
 	s rownum=1
 	while((gc.sqlcode'=100) && (rownum<=top)) {
 	      	for ii=1:1:numcols {
 		      	s sc=gc.GetData(hstmt, ii, 1, .val)
 		      	;w " "_val
 		      	s @gn@(rownum)=$g(@gn@(rownum))_$lb(val)
 		      	if $$$ISERR(sc) break
 	      	}
 	      	s rownum=rownum+1
 	 		;write !
 	 		set sc=gc.Fetch(hstmt)
 			if $$$ISERR(sc) break
 
 	  		}
 	    
 	  //Close cursor and then disconnect
 	set sc=gc.CloseCursor(hstmt)
 	if $$$ISERR(sc) quit sc
 	set sc=gc.Disconnect()
	s @gn=rownum-1
	s @gn@(-3,"sql")=$lb(sql,pDSN,top,usr,pwd)
	s @gn@(-3,"timestamp")=$lb(ts,$$$AppDT($h),##class(App.type).GetCountSec($h)-##class(App.type).GetCountSec(hr))
 	Quit sc
}

}

