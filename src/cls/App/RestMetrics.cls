Include App.LogMacro

Class App.RestMetrics Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

Parameter ISCPREFIX = "isc_cache";

Parameter DASHPREFIX = {..#ISCPREFIX_"_dashboard"};

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/get-html/:text" Method="GET" Call="App.rest:Index"/>
<Route Url="/post-json" Method="POST" Call="App.rest:jsonrpc"/>
<Route Url="/get-files/:text" Method="GET" Call="App.rest:Files"/>

<Route Url="/finduser/:text" Method="GET" Call="App.rest:FindUser"/>
<Route Url="/jsonrpc" Method="POST" Call="App.rest:jsonrpc"/>
<Route Url="/getrpc" Method="GET" Call="App.rest:getrpc"/>
<Route Url="/index/:text" Method="GET" Call="App.rest:Index"/>

<Route Url="/cache" Method="GET" Call="getMetrics"/>
<Route Url="/mgstat/:delay" Method="GET" Call="getMgstat"/>
<Route Url="/db" Method="GET" Call="getDBsize"/>
<Route Url="/dirsize/:path" Method="GET" Call="getDirSize"/>
<Route Url="/proj/:proj/:metrics/:mode" Method="GET" Call="App.MVK.Metrics:getProj"/>

<Route Url="/test" Method="POST" Call="Test"/>  
</Routes>
}

/// To sorted sizes podkatalogu for Linux
/// w ##class(App.RestMetrics).getDirSize("/opt/isc/ensemble/mgr/")
ClassMethod getDirSize(path = "", ByRef res, minsize = 10) As %Status
{
	s gn = "^||tmpfile"
	d ##class(App.files).getPathcconsole(.dir,.logname)
	i $g(path)="" s path=dir ;location of default database
	i $zv'["Linux" q $$$OK  ;for other OS not implemented
	s st=$$$OK
	s curNs=$zu(5)
	zn "%sys"
	s prefix = ..#ISCPREFIX_"_dirsize"
	s tempfile=$SYSTEM.Util.InstallDirectory()_"mgr/Temp/dirsize.log"
	k @gn set nl = $c(10)
	try {
		s cmd="du -sm "_path_"*| sort -nr >"_tempfile
		set result = $zf(-1, cmd)
		if (result '= 0) { 
			w !,$System.Status.GetErrorText(result)
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Error:" _ result_", "_cmd)) 
		}
		else {
			s size=##class(App.files).File2Arr(tempfile,gn,"RSK\UTF8\")
			f i=1:1 { q:'$d(@gn@(i))   ;pass the loop through the entire report
				continue:$p(@gn@(i),$c(9))'>minsize ;eliminate small and empty directories
				s str=$g(@gn@(i))
				i $d(res) s res(i)=$P(str,$c(9),2)_" "_$P(str,$c(9),1)
				else  w prefix_"_"_$P(str,$c(9),2)_" "_$P(str,$c(9),1)_nl
			}
		}
	} catch ex {
		set st = ex.AsStatus()
		;$$$TRACE($system.Status.GetErrorText(st))
	}
	zn curNs
	quit st
}

/// The size of the database in Gigabytes
/// d ##class(App.RestMetrics).getDBsize("dbsize",.list)
ClassMethod getDBsize(prefix = {..#ISCPREFIX_"_dbsize"}, dbname, int = 1, all = 0) As %Status
{
	set nl = $c(10)
	s curNs=$zu(5)
	zn "%sys"
	s st=##class(App.sys).SaveQuery("SYS.Database:FreeSpace","^||db")
	s r=$q(^||db("")) ;to the first link
	s r=$na(^||db($qs(r,1),$qs(r,2))) ;take the first 2 of the index in the link
	s listDb=$$$DBCACHESizeMon
	i listDb="" s listDb=##class(App.sys).ListDB(.info,"NotPre,NotTemp")
	f i=1:1 { q:'$d(@r@(i))   ;pass the loop through the entire report
		continue:$g(@r@(i,1))=""
		;by default, we give all sizes to Gigabytes
		s free=$g(@r@(i,8))
		s dir=$g(@r@(i,2))
		s name=$g(@r@(i,1))
		i 'all,(","_listDb_",")'[(","_name_",") continue
		i 'all,(dir)[("secondary/")||((dir)[("temp/")) continue
		s size=$g(@r@(i,4))
		if size["MB" {s size=$j(size/(1024),"",3) ;if in MB, then divide
		}
		elseif size["TB" {s size=size*1024  ;if TB then multiply
		}
		else {
			s size=+size  ;if GB then translate into the number
		}
		s dbname(dir)=size
		s dbname(dir,"name")=name
		s dbname(dir,"free")=+free
		;i $p(dir,"/")'=""  s total($p(dir,"/"))=$g(total($p(dir,"/")))+size
		w:'int prefix_"_"_name_" "_size_nl
		w:'int prefix_"_"_name_"_DiskFreeSpace "_(+free)_nl
	}
	zn curNs
	write nl
	quit $$$OK
}

/// Metrics databases Habra...
ClassMethod getMgstat(delay As %Integer = 2) As %Status
{
	// By default, we use 2 second interval for averaging
	quit ##class(App.MVK.Metrics).getSamples(delay)
}

/// Output should obey the Prometheus exposition formats. Docs:
/// https://prometheus.io/docs/instrumenting/exposition_formats/
/// 
/// The protocol is line-oriented. A line-feed character (\n) separates lines. 
/// The last line must end with a line-feed character. Empty lines are ignored.
ClassMethod getMetrics() As %Status
{
	set nl = $c(10)
	s curNs=$zu(5)
	zn "%sys"
	do ..getDashboardSample(.dashboard)
	do ..getClassProperties(dashboard.%ClassName(1), .propList, .descrList)
	
	for i=1:1:$ll(propList) {
		set descr = $lg(descrList,i)
		set propertyName = $lg(propList,i)
		set propertyValue = $property(dashboard, propertyName)
		
		// Prometheus supports time series database 
		// so if we get empty (for example, backup metrics) or non-digital metrics 
		// we just omit them.
		if ((propertyValue '= "") && ('$match(propertyValue, ".*[-A-Za-z ]+.*"))) {
			set metricsName = ..#DASHPREFIX_..camelCase2Underscore(propertyName)
			set metricsValue = propertyValue
			
			// Write description (help) for each metrics.
			// Format is that the Prometheus requires.
			// Multiline descriptions we have to join in one string.
			write "# HELP "_metricsName_" "_$replace(descr,nl," ")_nl
			write metricsName_" "_metricsValue_nl
		}
	}
	zn curNs
	write nl
	quit $$$OK
}

ClassMethod getDashboardSample(Output dashboard)
{
	new $namespace
	set $namespace = "%SYS"
	set dashboard = ##class(SYS.Stats.Dashboard).Sample()
}

ClassMethod getClassProperties(className As %String, Output propList As %List, Output descrList As %List)
{
	new $namespace
	set $namespace = "%SYS"
	
	set propList = "", descrList = ""
	set properties = ##class(%Dictionary.ClassDefinition).%OpenId(className).Properties
	
	for i=1:1:properties.Count() {
		set property = properties.GetAt(i)
		set propList = propList_$lb(property.Name)
		set descrList = descrList_$lb(property.Description)
	}
}

/// Converts metrics name in camel case to underscore name with lower case
/// Sample: input = WriteDaemon, output = _write_daemon
ClassMethod camelCase2Underscore(metrics As %String) As %String
{
	set result = metrics
	set regexp = "([A-Z])"
	set matcher = ##class(%Regex.Matcher).%New(regexp, metrics)
	while (matcher.Locate()) {
		set result = matcher.ReplaceAll("_"_"$1")
	}
	
	// To lower case
	set result = $zcvt(result, "l")
	
	// _e_c_p (_c_s_p) to _ecp (_csp)
	set result = $replace(result, "_e_c_p", "_ecp")
	set result = $replace(result, "_c_s_p", "_csp")
	
	quit result
}

ClassMethod Test() As %Status
{
	&html<<h1>Status: OK!</h1><br>>
	zw %request
	&html<<br><br>>
	zw %response
	quit $$$OK
}

}

