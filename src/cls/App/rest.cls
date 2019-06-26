Include App.LogMacro

/// шаблон сервиса jsonrpc
Class App.rest Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/finduser/:text" Method="GET" Call="FindUser"/>
<Route Url="/jsonrpc" Method="POST" Call="jsonrpc"/>
<Route Url="/test" Method="POST" Call="Test"/>  

</Routes>
}

/*
/// JSON-RPC 2.0 https://www.jsonrpc.org/specification

{"jsonrpc": "2.0", "result": {"likes": 123}, "id": 1}
Если возникает ошибка — ответ об ошибке:
{"jsonrpc": "2.0", "error": {"code": 666, "message": "Post not found"}, "id": "1"}
И это всё!
Бонусом поддерживаются batch-операции:
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
		if $isobject(%request.Content) { //POST
			d %request.Content.Rewind() 
			set json=%request.Content.Read($$$MaxStringLength) 
			set json = $ZCVT(json,"I","UTF8") 
	 		if ($g(json)["{") {
	 			set method={}.$$$jsonFromJSON(json).method
	 			set params={}.$$$jsonFromJSON(json).params
	 			set jsonrpc={}.$$$jsonFromJSON(json).jsonrpc
	 			set id={}.$$$jsonFromJSON(json).id
	 			if jsonrpc'="2.0" w ..jsonrpcError(2,"Version not supported "_jsonrpc) q
	 			
	 			;i method'="GetOrganisation" d ..jsonrpcError(4,"Method not supported "_method) q
	 			;s $$$AppL("MSW","jsonrpc-resjson")=resjson
				if method[":" { if $p(method,":",1)'="" s ns=$p(method,":",1)
					if $p(method,":",2)'="" s class=$p(method,":",2)
					if $p(method,":",3)'="" s meth=$p(method,":",3)
				}
				if ns'="" zn ns
				do $classmethod(class,meth,.json) quit
				;w "{""text"":""Привет"",""inn"":"""_params.inn_"""}" q
				;w $ZCVT(str,"O","UTF8") 
				;w resjson
	 			
	 		}
		} else {
			 d ..jsonrpcError(3,"Bad request "_%request.Content)
			 q
		}
	} catch ex {
		set sc = ex.AsStatus()
		d ..jsonrpcError(4,"exception: "_$System.Status.GetErrorText(sc))
	}
	return $$$OK
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

ClassMethod Test() As %Status
{
	&html<<h1>Status: OK!</h1><br>>
	zw %request
	&html<<br><br>>
	zw %response
	quit $$$OK
}

/// Поиск пользователей по контексту 
/// http://localhost:57772/apptoolsrest/finduser/super
ClassMethod FindUser(text = "") As %Status
{
 i $l(text)<3 d ..jsonrpcError(5,"Строка поиска должна быть не меньше 3 символов") q $$$OK
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

}

