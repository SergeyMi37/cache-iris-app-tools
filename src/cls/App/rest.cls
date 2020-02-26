Include App.LogMacro

/// // The REST interface: class that routes HTTP requests
Class App.rest Extends %CSP.REST [ DependsOn = App.msg ]
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/get-html/:text" Method="GET" Call="Index"/>
<Route Url="/post-json" Method="POST" Call="jsonrpc"/>
<Route Url="/get-files/:text" Method="GET" Call="Files"/>

<Route Url="/testpost" Method="POST" Call="Test"/>
<Route Url="/testget/:text" Method="GET" Call="Test"/>  
<Route Url="/finduser/:text" Method="GET" Call="FindUser"/>

<Route Url="/auth" Method="GET" Call="Auth"/>
<Route Url="/css/index.css" Method="GET" Call="GetCss"/>
<Route Url="/css/themes/:theme" Method="GET" Call="GetTheme"/>
<Route Url="/js/index.js" Method="GET" Call="GetJs"/>
</Routes>
}

/*
/// sample servise JSON-RPC 2.0 https://www.jsonrpc.org/specification

{"jsonrpc": "2.0", "result": {"likes": 123}, "id": 1}
If error:
{"jsonrpc": "2.0", "error": {"code": 666, "message": "Post not found"}, "id": "1"}
Request:
[
  {"jsonrpc":"2.0","method":"server.shutdown","params":{"server":"42"},"id":1},
  {"jsonrpc":"2.0","method":"server.remove","params":{"server":"24"},"id":2}
]
Response:
[
  {"jsonrpc":"2.0","result":{"status":"down"},"id":1}
  {"jsonrpc":"2.0","error":{"code":1234,"message":"Server not found"},"id": 2}
]
*/
/// post http://server:57772/rest/jsonrpc
/// {"jsonrpc":"2.0","method":"GetInfo","params":{"code":"5007092465"},"id":123}
ClassMethod jsonrpc(ns = "", class = "", meth = "") As %Status
{
	set sc = $$$OK
	try {
	 	;merge $$$AppL("MML","%request.Data")=%request.Data
		;set $$$AppL("MML","%request.AppData")=%request.AppData
		;set $$$AppL("MML","req")=$$$AppObJs(%request)
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	;set %response.Status = "401 Unauthorized" quit
		; 	d ..jsonrpcError(401,"Unauthorized "_%request.Content) 
		;}
		if $isobject(%request.Content) { //POST
			d %request.Content.Rewind() 
			set json=%request.Content.Read($$$MaxStringLength) 
			set json = $ZCVT(json,"I","UTF8") 
			s $$$AppL("MML","jsonrpc-json")=json
	 		if ($g(json)["{") {
	 			set method={}.$$$jsonFromJSON(json).method
	 			set params={}.$$$jsonFromJSON(json).params
	 			set jsonrpc={}.$$$jsonFromJSON(json).jsonrpc
	 			set id={}.$$$jsonFromJSON(json).id
	 			if jsonrpc'="2.0" w ..jsonrpcError(2,"Version not supported "_jsonrpc) q
	 			s appPar=""
	 			if method[":" { if $p(method,":",1)'="" s ns=$p(method,":",1)
					if $p(method,":",2)'="" s class=$p(method,":",2)
					if $p(method,":",3)'="" s meth=$p(method,":",3)
					if $p(method,":",4)'="" s appPar=$p(method,":",4,*)
				}
				if ns'="" zn ns
				if $e(class,1)="^" {
					do @(meth_class_"(.par,.json)") ;??? xec public 
				} else {
					if appPar["~" {
						do ##class(App.type).ParseURL(appPar,.appPar,"~")  ;parse in array
					}
					elseif appPar["&" {
						d ##class(App.type).ParseURL(appPar,.appPar,"&")
					}
				   ;set %response.CharSet = "utf-8"
    			;	set %response.ContentType = "text/html"
    				;s appPar("params")=params
    				if $isobject(params) d ##class(App.Action).GetElemParseForm(params.form,.appPar,"z",0)
      				do $classmethod(class,meth,.appPar) 
					quit
				}
				;w "{""text"":""Hello world"",""inn"":"""_params.inn_"""}" q
				;w $ZCVT(str,"O","UTF8") 
				;w resjson
	 			
	 		}
		} else {
			;s $$$AppL("MML","%request")=$$$AppObJs(%request)
			;m $$$AppL("MML","%request.Data")=%request.Data
			;m $$$AppL("MML","%request.Content")=%request.Content
			;set $$$AppL("MML","%request.AppData")=%request.AppData
			 d ..jsonrpcError(3,"Bad request "_%request.Content)
			 q
		}
	} catch ex {
		set sc = ex.AsStatus()
		;s $$$AppL("MML","jsonrpc-err")=$System.Status.GetErrorText(sc)
		d ..jsonrpcError(4,"exception: "_$zconvert($System.Status.GetErrorText(sc),"O","HTML"))
	}
	return $$$OK
}

ClassMethod Authorize(user, password) As %String
{
	q $SYSTEM.Security.Login(user, password)
}

ClassMethod jsonrpcError(code, message) As %Status
{
	;w "{""jsonrpc"":""2.0"",""error"":{""code"":"""_code_""",""message"":"""_message_"""}}"
	Set json = $$$NewDynObj
 	s json.jsonrpc="2.0"
	s json.code=code
	s json.message=message
	$$$DynObjToJSON(json)
	q $$$OK
}

/// Method writes files.
/// /apptoolsrest/get-files/fileId
ClassMethod Files(fileId) As %Status
{
 s file=##class(App.DownloadCSP).GetfileName(fileId,,,.ContentType)
 ;get date modification	file
 set dh=$zu(140,2,file)
 if dh<0 set dh=$now(0)
 set date=$zd(dh, 11) _ ", "_ $zdt(dh, 2,1) _ " GMT"
 
 ;do %response.SetHeader("Last-Modified", date)
 if (%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=date) {
	        set %response.Status = "304 Not Modified"
	    } 
 else {
	set %response.CharSet="raw"
	;d %response.SetHeader("Expires", "0")
	;d %response.SetHeader("Accept-Ranges","bytes")

	if $g(ContentType)'="" {
		s mimetype=ContentType
	} else {
		set ext=$p(file,".",*)
		set mimetype=##class(App.filesMimeTypes).GetMimeTypes4ext(ext)
	}
	set %response.ContentType=mimetype
	
	set stream=##class(%FileBinaryStream).%New()
	set stream.Filename=file
	set size=stream.Size
	do %response.SetHeader("Content-Length",size)

	if ContentType["application/force-download" {
		set name=$p(file,$$$slash,*)
		set name=$ZCVT($ZCVT(name,"O","UTF8"),"O","URL")
		d %response.SetHeader("Content-Disposition","attachment;filename="_name)
	}

	while 'stream.AtEnd {
		set line=stream.Read()
		write line
	}
 }
  return $$$OK
}

ClassMethod Test(parameter) As %Status
{
	set %response.CharSet = "utf-8"
    set %response.ContentType = "text/html"
	&html<<h1>Status: OK!</h1><br>>
	zw %request
	&html<<br><br>>
	zw %response
	quit $$$OK
}

/// Search users by context
/// http://localhost:57772/apptoolsrest/finduser/super
ClassMethod FindUser(text = "") As %Status
{
 i $l(text)<3 d ..jsonrpcError(5,$$$aText("Search string must be at least 3 characters","")) q $$$OK
 zn "%SYS"
 s sql="select Name,FullName,Comment,EmailAddress,Enabled,CreateDateTime,LastModifiedDateTime from Security.Users where UPPER(FullName) [ '"_$zconvert(text,"U")_"'"
	#if $$$comClassDefined("%ZEN.Auxiliary.jsonSQLProvider")
		set Provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
		set Provider.sql = sql
		Set Provider.%Format = $$$formatJSONSQL
		Set Provider.maxRows = 10000
		set st = Provider.%DrawJSON()
	#else
		set st = $$$ERROR($$$GeneralError,"Class %ZEN.Auxiliary.jsonSQLProvider does not exist")
	#endif
	return st
}

/// Calls StaticContent.Write method or sends not modified header. Type have to be "css" or "js"
ClassMethod WriteStatic(type As %String, ContentType As %String = "", xDataClass = "App.rest", ClassCSPPage = "", IsCached = 0) [ Private ]
{
    #define CompileTime ##Expression("""" _ $zd($h, 11) _ ", "_ $zdt($NOW(0), 2,1) _ " GMT""")
    set %response.CharSet = "utf-8"
    set %response.ContentType = $case(type,
        "css": "text/css",
        "js": "text/javascript",
        "html": "text/html",
        : $case(ContentType="", 1:"text/plain", :ContentType)
    )
    do %response.SetHeader("Last-Modified", $$$CompileTime)
    try{
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	set %response.Status = "401 Unauthorized" quit
		;}
	    if IsCached,(%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=$$$CompileTime) {
	        set %response.Status = "304 Not Modified"
	    } 
	    elseif ClassCSPPage'="" {
		    s param=$p(ClassCSPPage,"?",2,*)
		    s ClassCSPPage=$p(ClassCSPPage,"?")
		    s:ClassCSPPage[".cls" ClassCSPPage=$p(ClassCSPPage,".cls",1)
		    ;set $$$AppL("MMM","WriteStatic")=$lb(type,ClassCSPPage) ;$$$AppObJs(id)
		    ;set $$$AppL("MMM","%request")=$$$AppObJs(%request)
		    s method="OnPage"
		    s:ClassCSPPage[":" method=$p(ClassCSPPage,":",2,*),ClassCSPPage=$p(ClassCSPPage,":",1)
		    do:method["OnPage" $classmethod(ClassCSPPage,method,param)
	    }
	    else {
	        do ..WriteStaticContent(xDataClass,type)
	    }
    }
    catch e { 
    	w $ze
    	set %response.Status = "501 Not Implemented" ;"405 Method Not Allowed" ;"400 Bad Request"
    }
}

/// Method writes application CSS.
ClassMethod GetCss(class) As %Status
{
    do ..WriteStatic("css")
    return $$$OK
}

/// Method writes application theme.
ClassMethod GetTheme(Theme As %String) As %Status
{
    do ..WriteStatic("Theme"_$REPLACE(Theme, ".css", ""),"text/css")
    return $$$OK
}

/// Method writes application JavaScript.
ClassMethod GetJs() As %Status
{
    do ..WriteStatic("js")
    return $$$OK
}

/// Method writes application HTML.
ClassMethod Index(class) As %Status
{
    do ..WriteStatic("html","","",class)
    return $$$OK
}

/// Write the contents of xData tag
ClassMethod WriteStaticContent(Class As %String, Const As %String) As %Status
{
    set obj = ##class(%Dictionary.CompiledXData).%OpenId(Class_"||"_Const)
    return:(obj = "") $$$OK
    set xdata = obj.Data
    set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
    while textreader.Read() { if (textreader.NodeType="chars") {
        write textreader.Value
    } }
    return $$$OK
}

ClassMethod getStatic(name As %String, ByRef Description) As %String
{
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set Description=""
	set str = ""	
	if ##class(%Dictionary.XDataDefinition).IDKEYExists(class, queryName) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata,i))
		}
		set str = stream.Read($$$MaxLocalLength)
		set Description=$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdescription)
		
	}
	return str
}

XData Themecache
{
<data>
<![CDATA[<!-- @include client/css/themes/cache.css -->]]>
</data>
}

XData html
{
<data>
<![CDATA[
<!-- @include client/index.html -->]]>
</data>
}

XData css
{
<data>
<![CDATA[<!-- @include client/css/index.css -->]]>
</data>
}

XData js
{
<data>
<![CDATA[<!-- @include client/js/index.js -->]]>
</data>
}

}

