Include (App.LogMacro, Ensemble)

/// Utilities for group work with Ensemble or Interoperability products of different Namespaces
Class App.Production [ Abstract ]
{

/// How long to wait for the product to stop before being stopped again by force (seconds)
Parameter TIMEOUTSTOP = 120;

Parameter SettingsGN = "^%App.Productions";

///  Check and save settings and status of products in all Namespaces
///  d ##class(App.Production).EnsConfSave(1)
ClassMethod EnsConfSave(resave = 0) As %Status
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

/// Remove autostart from all products; stop all products in Namespaces before restarting the OS
/// d ##class(App.Production).EnsDown()
ClassMethod EnsDown() As %Status
{
 d ..EnsAction("auto0")
 d ..EnsAction("stop")
 w !!,"ok"
 q
}

/// Check and restore autorun products in Namespaces, run all products that were launched
/// d ##class(App.Production).EnsConfRest()
ClassMethod EnsConfRest() As %Status
{
 	d ..EnsAction("auto1")
 	d ..EnsAction("start")
 	w !!,"ok"
 	q
}

/// Creating message cleaning tasks
/// d ##class(App.Production).CreateTaskPurgeEns()
ClassMethod CreateTaskPurgeEns(days = 7) As %Status
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
/// d ##class(App.Production).InitEnsNS("APP,AAA")
ClassMethod InitEnsNS(nsList = "") As %Status
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
			h 60 
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
			s stat=$s(Stat=$$$eProductionStateRunning:"Running",Stat=$$$eProductionStateStopped:"Stopped",Stat=$$$eProductionStateSuspended:"Suspended",Stat=$$$eProductionStateTroubled:"Troubled",1:"?")
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
	q $$$OK
}

/// Automatic generate documenation
/// w $System.Status.GetErrorText(##class(App.Production).GenDoc("/home/project/shared/gen-doc.xml"))
ClassMethod GenDoc(filename = "", namespacelist = "", title = "", title2 = "", ByRef shortcode, ByRef shortulink, ByRef all) As %Status
{
	if '##class(App.files).OpenFile(filename) quit:$$$ERROR($$$GeneralError,"Error open file "_filename)
	use filename		
	&html<
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<title>#(title)#</title>
	</head>
	<body><a name='0'>
		#(title2)#
		>
	if '$d(shortcode) {
		s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")
		d ##class(App.Production).EnsAction("info",listns,.out)
		 s aNs=""
			 for { s aNs=$o(proj(pr,pro,aNs)) q:aNs=""   continue:aNs="href"
			 	s aNp="",lastprod=""
			 	for { s aNp=$o(proj(pr,pro,aNs,aNp)) q:aNp=""	;Name Production
			 		s aCp=""	
			 		for { s aCp=$o(proj(pr,pro,aNs,aNp,aCp)) q:aCp=""	;Class Production
			 			s aNb=""	
			 			for { s aNb=$o(proj(pr,pro,aNs,aNp,aCp,aNb)) q:aNb=""	;Name Elements
			 				s aClass=$lg(proj(pr,pro,aNs,aNp,aCp,aNb),1) ;Class Elements
			 				s aCategory=$lg(proj(pr,pro,aNs,aNp,aCp,aNb),2) ;Category Elements
						 	i aCategory'="",(" "_aCategory_" ")'[(" "_pr_" ") continue ;
			 				s aNbp="",listProp="<ul>"
			 				for { s aNbp=$o(proj(pr,pro,aNs,aNp,aCp,aNb,aNbp)) q:aNbp=""	;Name Property
			 					s listProp=listProp_"<li>"_aNbp_" :"_$g(proj(pr,pro,aNs,aNp,aCp,aNb,aNbp))
			 					if $g(proj(pr,pro,aNs,aNp,aCp,aNb,aNbp,"ip"))'="" {
				 					s listProp=listProp_"<ul><li>IP :<font color=red>"_$g(proj(pr,pro,aNs,aNp,aCp,aNb,aNbp,"ip"))_"</font></li></ul>"
			 					}
			 				}
			 				s listProp=listProp_"</ul>"
			 				d ..addstr(.all,$$$appTableTrTd3($s(lastprod=(aNp_", "_aCp):"",1:aNp_", "_aCp),aNb_", "_aClass_", "_aCategory,listProp))
			 				s lastprod=aNp_", "_aCp
			 			}
			 			
			 		}
			 	}
			 }
		
	}	
 	s a=""
 	for { s a=$o(shortcode(a)) q:a=""
 		w "<li>"_a_" "_$g(shortcode(a))
 	}
	w "<hr>"
 	s a=""
 	for { s a=$o(shortulink(a)) q:a=""
 		w "<li>"_$g(shortulink(a))
 	}
	w "<hr>"	
	if '$d(all) 
 	s a=""
 	for { s a=$o(all(a)) q:a=""
 		w $g(all(a))
 	}
 &html<
	</body></html>
	>
	use io
	close filename
	write !,"Output documentation in "_filename
	q $$$OK
}

}

