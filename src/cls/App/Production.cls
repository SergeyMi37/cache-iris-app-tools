Include App.LogMacro

/// Utilities for group work with Ensemble or Interoperability products of different Namespaces
Class App.Production [ Abstract ]
{

/// How long to wait for the product to stop before being stopped again by force (seconds)
Parameter TIMEOUTSTOP = 60;

Parameter SettingsGN = "^%App.Productions";

/// Create new Interoperability Production (from diashenrique.messageviewer.util.InstallerProduction)
/// https://openexchange.intersystems.com/package/IRIS-Interoperability-Message-Viewer
/// write $System.Status.GetErrorText(##class(App.Production).CreateProduction("USER","Test.TestProd","Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST"))
/// zn "USER" do ##class(Ens.Director).StartProduction("Test.TestProd")
ClassMethod CreateProduction(ns = {$Namespace}, pn = "TestProduction", ConfItem = "") As %Status
{
	New $Namespace
	Set $Namespace = ns
	d ..Init(ns)
	Set sc = $$$OK
	Try {
		#; create new production
		Set class = ##class(%Dictionary.ClassDefinition).%New(pn)
		Set class.ProcedureBlock = 1
		Set class.Super = "Ens.Production"
		Set class.GeneratedBy = $ClassName()
		Set xdata = ##class(%Dictionary.XDataDefinition).%New()
		Set xdata.Name = "ProductionDefinition"
		Do xdata.Data.Write("<Production Name="""_pn_""" LogGeneralTraceEvents=""true""></Production>")	
		Do class.XDatas.Insert(xdata)
		Set sc = $$$ADDSC(sc,class.%Save())
		Set sc = $$$ADDSC(sc,$System.OBJ.Compile(pn,"fck-dv"))
		if ConfItem'="" {
			Set production = ##class(Ens.Config.Production).%OpenId(pn)
			for i=1:1:$l(ConfItem,",") { continue:$p(ConfItem,",",i)=""
				Set item = ##class(Ens.Config.Item).%New()
				Set item.ClassName = $p(ConfItem,",",i)
				Do production.Items.Insert(item)
				Set sc = $$$ADDSC(sc,production.%Save())
			}
		}
	}
    Catch (err) {
		Set sc = $$$ADDSC(sc,err.AsStatus())
	}
	Return sc
}

///  Check and save settings and status of products in all Namespaces
///  d ##class(App.Production).SaveStat(1)
ClassMethod SaveStat(resave = 0) As %Status
{
	s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")
	s GN=..#SettingsGN
	i 'resave,$d(@GN) w !,"Settings have already been saved. Rewrite ? [Y/N] <N>" r r q:$zconvert(r,"L")'["y"
	KILL @GN
	MERGE @GN=inf
	w !,"Updated "_GN
	s ns=""
	f { s ns=$o(inf(ns)) q:ns=""
	 zw inf(ns,"Ens")
	}
 quit $$$OK
}

///  Save settings and status of products in all Namespaces; Stop all productions
///  d ##class(App.Production).SaveAndStop()
ClassMethod SaveAndStop() As %Status
{
	d ..SaveStat(1)
	d ..StopAll()
}

/// Remove autostart from all products; stop all products in Namespaces before restarting the OS
/// d ##class(App.Production).StopAll()
ClassMethod StopAll() As %Status
{
 d ..EnsAction("auto0")
 d ..EnsAction("stop")
 w !!,"ok"
 q
}

/// Check and restore autorun products in Namespaces, run all products that were launched
/// d ##class(App.Production).StartAll()
ClassMethod StartAll() As %Status
{
 	d ..EnsAction("auto1")
 	d ..EnsAction("start")
 	w !!,"ok"
 	q
}

/// Creating tasks message cleaning
/// d ##class(App.Production).CreateTasksPurgeMess(30)
ClassMethod CreateTasksPurgeMess(days = 90) As %Status
{
	s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")	
	set ns=""
	for { set ns=$o(inf(ns)) q:ns=""
		continue:'$d(inf(ns,"Ens"))
	 	write !,ns," ",..CreateTaskPurge("Cleaning productions messages "_ns,ns,days)
	}
 quit $$$OK
}

/// Create a task to clean productions messages
///  w ##class(App.Production).CreateTaskPurge("Cleaning production messages "_$zu(5),$zu(5),7) }
ClassMethod CreateTaskPurge(Name As %String = "", ns = {$zu(5)}, days = 90)
{
		Set Task=##Class(%SYSTEM.Task).%New()
		Set Task.Name=Name 
		Set Task.Type=0
		Set Task.Description=Name
		Set Task.TaskClass="Ens.Util.Tasks.Purge"
		#;Every day at 1:00 am
		Set Task.DailyStartTime=3600
		;Do Task.idSet(Number)
		Set Task.RunAsUser="SuperUser"
		Set Task.MirrorStatus=3
		s t=##class(Ens.Util.Tasks.Purge).%New()
		s t.KeepIntegrity=1
		s t.NumberOfDaysToKeep=days
		s t.BodiesToo=1
		s t.TypesToPurge="all"
		Set Task.Settings=t.GetSettings()
		s Task.NameSpace=ns
		q Task.%Save()
}

/// Initiate all Namespaces for the Ensemble\Interoperability
/// d ##class(App.Production).Init("USER")
ClassMethod Init(nsList = "") As %Status
{
 if nsList="" set nsList=##class(App.sys).ListNS(.inf,"NotPref")
	for i=1:1:$l(nsList) {
		continue:$p(nsList,",",i)=""
		do ##class(%EnsembleMgr).EnableNamespace($p(nsList,",",i),1) 
	}
	q $$$OK
}

/// Change products status in Namespaces
/// d ##class(App.Production).EnsAction("restart")
/// ex= "auto0" - clean all Namespaces of auto start products
/// ex= "auto1" - enable auto start products, restore from #SettingsGN(ns)
/// ex= "stop"  - stop all products
/// ex= "restart"  - reload all products
/// ex= "start"  - run the ones that were started, restore from #SettingsGN(ns)
/// ex= "status" - output statuses
/// ex= "info" - output of additional information about products and services with parameters d ##class(App.Production).EnsAction("info",,.out)
/// out - result ;d ##class(App.Production).EnsAction("status",$zu(5),.out)
ClassMethod EnsAction(ex = "", nsOnly = "", out) As %Status [ PublicList = (tProductionName, inf) ]
{
	;get all namespace with ensemble
	s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")
	$$$forAll(ns,inf)
	i nsOnly'="",nsOnly'=ns continue
	$$$NspGoto(curN,ns)
	i '$d(inf(ns,"Ens")) continue
	s GN=..#SettingsGN
	i ex'="info" w !!,"--- ",ns
	if ex="stop" {
		s sc=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP)
		i 'sc {
			s sc2=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP,1) 
			i 'sc2 w $System.Status.DisplayError(sc2)
		}
	}
	elseif ex="restart" {
		s sc=##class(Ens.Director).RestartProduction()
		i 'sc w $System.Status.DisplayError(sc)
	}
	elseif ex="start" {
		i '$d(@GN@(ns,"Ens")) w !," settings not saved, skip"
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:$lg(@GN@(ns,"Ens",tProductionName),1)'["Running"
			w !,ns," ",tProductionName
			Set sc = ##class(Ens.Director).StartProduction(tProductionName) ; Quit:$$$ISERR(tSC)
			i 'sc w $System.Status.DisplayError(sc)
		$$$forEnd	
	}
	if ex="auto0" {
		i '$d(@GN@(ns,"Ens")) w !," settings not saved, skip"
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart("")
			i 'sc w $System.Status.DisplayError(sc)
			e  w " clean auto start"
			$$$NspReturn(curNs)
	} elseif ex="auto1" {
		i '$d(@GN@(ns,"Ens")) w !," settings not saved, skip"
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart(tProductionName)
			i 'sc w $System.Status.DisplayError(sc)
			e  w " set auto start"
			$$$NspReturn(curNs)
		$$$forEnd		
	} elseif ex="status"||(ex="info") {
		i '$d(@GN@(ns,"Ens")) w !," settings not saved, skip"
		Set sc = ##class(Ens.Director).GetProductionSummary(.pInfo, ns)	if ex'="info" w ! zw pInfo
		Set sc = ##class(Ens.Director).GetProductionSettings("",.tSettings)	if ex'="info" w ! zw tSettings
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			;continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			if ex'="info" w !,"Name production :"_tProductionName
			Set sc = ##class(Ens.Director).GetProductionStatus(tProductionName,.Stat)
			s stat=$s(Stat=1:"Running",Stat=2:"Stopped",Stat=3:"Suspended",Stat=4:"Troubled",1:"?")
			if ex'="info" w " Status :"_stat
			i 'sc w $System.Status.DisplayError(sc)
			s out(ns,tProductionName)=stat
			if ex="info" k ou d ..ExtInfo(tProductionName,.ou) m out(ns,tProductionName)=ou
			$$$NspReturn(curNs)
		$$$forEnd		
	}
	$$$forEnd
	if $g(curN)'="" $$$NspReturn(curN)
 	quit $$$OK
}

/// Extended Product Information
/// w $System.Status.GetErrorText(##class(App.Production).ExtInfo("Spgz.SpgzProduction",.o))
ClassMethod ExtInfo(pClassName, ou, write = 0) As %Status
{
	Set tSC = ##Class(Ens.Util.XML.Reader).ObjectFromXData(.tObject,pClassName,"ProductionDefinition","Ens.Config.Production")
	if 'tSC q tSC
	;zw tObject
	s json=$$$AppObJs(tObject)
	;Analysis of products into elements
	set Description={}.$$$jsonFromJSON(json).Description
	set Name={}.$$$jsonFromJSON(json).Name
	write:write !,Name_" "_Description
	s ou(Name)=Description
	;s Items={}.$$$jsonFromJSON(json).Items
	s items=[].$$$jsonFromJSON(json)."Items"
	if items'="" {
		for i=0:1:items.$$$jsonSize()-1 {
			set item = items.$$$jsonGet(i)
			i $isobject(item) {
				s itemIn=item.$$$jsonToJSON()
				s Enabled={}.$$$jsonFromJSON(itemIn).Enabled
				continue:'Enabled
				s NameIten={}.$$$jsonFromJSON(itemIn)."Name"
				write:write !," "_NameIten
				s ClassName={}.$$$jsonFromJSON(itemIn).ClassName
				s ou(Name,NameIten)=$lb(ClassName,{}.$$$jsonFromJSON(itemIn).Category)
				s Settings=[].$$$jsonFromJSON(itemIn).Settings
				
				for ii=0:1:Settings.$$$jsonSize()-1 {
					set setts = Settings.$$$jsonGet(ii)
					i $isobject(setts) {
						s sett=setts.$$$jsonToJSON()
						s Target={}.$$$jsonFromJSON(sett).Target
						s NameSett={}.$$$jsonFromJSON(sett).Name
						s Value={}.$$$jsonFromJSON(sett).Value
						k ip
						if Value["http" {
							s host=$p($p($p(Value,"://",2),"/",1),":",1)
							if host'="" s ip=##class(App.net).GetIP(host)
						}
						if NameSett="HTTPServer" s:Value'="" ip=##class(App.net).GetIP(Value)
						write:write !,"  "_NameSett_" "_Value_" "_$g(ip)
						s ou(Name,NameIten,NameSett)=Value
						s:$g(ip)'="" ou(Name,NameIten,NameSett,"ip")=$g(ip)
					}
				}
			}
		}
	}
	q $$$OK
}

/// d ##class(App.Production).getModelTable("User.model.",.result)
ClassMethod getModelTable(like, all) As %Status
{
	set sql = "SELECT cls.Name as ""Class Name"", cls.Description as ""Description"", prop.Name ""Property"",  prop.Type ""Type"",  prop.Description ""Description property"" FROM ""%Dictionary"".ClassDefinition cls  JOIN ""%Dictionary"".PropertyDefinition prop ON cls.Name = prop.parent WHERE cls.Name LIKE '"_like_"%'"
	;Genaration table for HTML
	set result="^||tmpPackgetModelTable"
	set st=##class(App.sys).SaveSQL(sql,result)
	 	d ..addstr(.all,$$$appTab3("Table name, Description table","Property, Type","Description type"))
	s row="0",last=""
	for { s row=$o(@result@(row)) q:row=""
		s tab=$lg(@result@(row),1)_", "_$lg(@result@(row),2)
		s tabpro=$lg(@result@(row),3)_", "_$lg(@result@(row),4)
		d ..addstr(.all,$$$appTableTrTd3($s(last=tab:"",1:tab),tabpro,$lg(@result@(row),5)))
		s last=tab
	}
	s %DrawArray=1
	d ..addstr(.all,$$$appTableEnd3)
	q $$$OK
}

/// add string to array
ClassMethod addstr(ByRef all, s) As %Status
{
	s all($i(all))=s_$c(13,10)
    q
}

/// Automatic generate documenation
/// CategotyDoc = Category Elements
/// filename - report html
/// namespacelist - if empty then all
/// title - Discriptions report
/// d ##class(App.Production).GenDoc("/home/project/shared/gen-doc.xml")
/// d ##class(App.Production).GenDoc("G:/!/gen-doc.xml")
ClassMethod GenDoc(filename = "", namespacelist = "", title = "Productions ", CategotyItem = "", StatusProd = 1) As %Status
{
	#define appTableAttr "border=1"
	new $namespace
	d ##class(App.Production).SaveStat(1)
	set:title="" subtitle="Productions documentation"
	if '##class(App.files).OpenFile(filename) quit:$$$ERROR($$$GeneralError,"Error open file "_filename)
	use filename		
	&html<
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<title>Productions</title>
	</head>
	<body><a name='0'>
			<h1>#(title)#</h1>
		>
	s bk=$c(13,10)
	;get information about active productions
	do ##class(App.Production).EnsAction("info",namespacelist,.proj)
	if $d(proj) {
		 set aNs=""
			 for { s aNs=$o(proj(aNs)) q:aNs=""
			 	d ..addstr(.all,bk_"<H2>Namespace "_aNs_"</H2>"_bk)
			 	d ..addstr(.all,$$$appTable3("Productions Name","Productions Item","Configuration"))
			 	set aNp="",lastprod=""
			 	for { s aNp=$o(proj(aNs,aNp)) q:aNp=""	;Name Production
			 		set aCp=""	
			 		for { s aCp=$o(proj(aNs,aNp,aCp)) q:aCp=""	;Class Production
			 			set aNb=""	
			 			for { s aNb=$o(proj(aNs,aNp,aCp,aNb)) q:aNb=""	;Name Elements
			 				s aClass=$lg(proj(aNs,aNp,aCp,aNb),1) ;Class Elements
			 				s aCategory=$lg(proj(aNs,aNp,aCp,aNb),2) ;Category Elements
						 	i aCategory'="",(" "_aCategory_" ")'[(" "_CategotyItem_" ") continue ;
			 				s aNbp="",listProp="<ul>"
			 				for { s aNbp=$o(proj(aNs,aNp,aCp,aNb,aNbp)) q:aNbp=""	;Name Property
			 					s listProp=listProp_"<li>"_aNbp_" :"_$g(proj(aNs,aNp,aCp,aNb,aNbp))
			 					if $g(proj(aNs,aNp,aCp,aNb,aNbp,"ip"))'="" {
				 					s listProp=listProp_"<ul><li>IP :<font color=red>"_$g(proj(aNs,aNp,aCp,aNb,aNbp,"ip"))_"</font></li></ul>"
			 					}
			 				}
			 				s listProp=listProp_"</ul>"
			 				s valprod=$$NoRepit(aNp,aCp)
			 				d ..addstr(.all,$$$appTableTrTd3($s(lastprod=(valprod):"",1:valprod),$$NoRepit(aNb,aClass)_", "_aCategory,listProp))
			 				s lastprod=valprod
			 			}
			 			
			 		}
			 	}
			 	d ..addstr(.all,$$$appTableEnd3)
			 }
	}
	w "<hr>"	
 	s a=""
 	for { s a=$o(all(a)) q:a=""
 		w $g(all(a))
 	}
 &html<
	</body></html>
	>
	close filename
	write !,"Output documentation in "_filename
	q $$$OK
NoRepit(a,b)
	q a_$s(a=b:"",1:", "_b)
}

}

