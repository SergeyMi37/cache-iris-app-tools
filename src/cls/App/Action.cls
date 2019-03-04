Include App.LogMacro

/// Выводить необходимые действия
Class App.Action Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Главный метод формирования содержимого страницы
ClassMethod OnPage() As %Status
{
	s $zt="Err"
 	#dim %request as %CSP.Request
 	set appNsp=%request.Get("appNsp")
	set appMethod=%request.Get("appMethod")
	set appClass=%request.Get("appClass")
	set appPar=%request.Get("appPar")
	set appJson=%request.Get("appJson")
	s i=""
	for { set i=$o(%request.Data(i)) quit:i=""
			if i["appNsp" s appNsp=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appMethod" s appMethod=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appClass" s appClass=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appPar" s appPar=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appJson" s appJson=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
	}
	if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
	set NSpace=$zu(5)

 	;s $$$AppL("MSW","req")=$$$AppObJs(%request)
 	i $isobject(%request.Content) { //POST
	 	s stream=%request.Content
		s sc=##class(App.files).Stream2String(%request.Content,.str)
		i 'sc q sc
	 	i $g(stt)["{" d ..ParseJson(.str,.appClass,.appMethod,.appPar) ;m appPar("%request.Content")=str  m appPar("%request")=$$$AppObJs(%request)
	 	m $$$AppL("MSW","Content")=str
 	}
  	i $g(appJson)["{" d ..ParseJson(.appJson,.appClass,.appMethod,.appPar) ;m appPar("%request")=$$$AppObJs(%request)
 	
 	;m $$$AppL("MSW","%request.Data")=%request.Data
	;s $$$AppL("MSW","%request.AppData")=%request.AppData

	if appMethod="" {
		$$$jsstart
 		w "alert('Параметр appMethod пустой');"
 		;w "console.log('Параметр appMethod пустой');"
 		$$$jsstop
		q $$$OK
	}
	
	if appMethod="ShowJson" {
		set gn=appPar
		try {
			write "<h3>"_gn_"</h3>"
			write "<pre>" write $g(@gn) write "</pre>" 
		} catch e { w $ze }
	}
	elseif appMethod="ShowXML" {
		set gn=appPar
		try {
			write $zconvert($g(@gn),"O","HTML")
		} catch e { w $ze }
	}
	else {
		set:appClass="" appClass="App.Action"
		;s $$$AppL("MSW","OnPage")=$lb(appPar,appClass,appMethod)
		if $e(appPar,1)="{" {
			;Разбор json TODO
		}
		elseif appPar["~" {
			d ##class(App.type).ParseURL(appPar,.appPar,"~")  ;разбор в массив 
		}
		Do $CLASSMETHOD(appClass,appMethod,.appPar)
	}
	
	quit $$$OK
Err 
	write $zconvert($ze,"O","HTML")
	quit $$$OK
}

/// Разобрать стоку в Json
ClassMethod Test(appPar) As %Status
{
	w "ClassMethod Test."
	zw appPar
	q $$$OK
}

/// Разобрать стоку в Json
ClassMethod ParseJson(jsonStr, appClass, appMethod, appPar) As %Status
{
 try {
	set appClass={}.$$$jsonFromJSON(jsonStr).appClass
	set appMethod={}.$$$jsonFromJSON(jsonStr).appMethod
	set appPar={}.$$$jsonFromJSON(jsonStr).appPar
	}
 catch e { 
 	write $zconvert($ze,"O","HTML")
 }
 quit $$$OK
}

/// Получить js функцию
ClassMethod getActionJs(jsonStr, appClass, appMethod, appPar) As %Status
{
	$$$jsstart
	w "function ActionJs(FormId,ResultId,appClass,appMethod,appPar,appNs){"
		w "var $data ={};"
		w "if (FormId) {$data = $('#'+FormId).serializeArray();}"
		w "$data.push({name:""appClass"",value:appClass});"
		w "$data.push({name:""appMethod"",value:appMethod});"
		w "$data.push({name:""appNs"",value:appNs});"
		w "$data.push({name:""appPar"",value:appPar});"
	    w "$.ajax({"
	    w "  url: 'App.Action.cls',"
	    w "  type: 'post',"
	    w "  data: $data,"
	    w "  success: function(result) {"
	    w "   if (ResultId) {$('#'+ResultId).html(result);}"
	    w "  }"
	    w "});"
	w "}"
	$$$jsstop
}

}

