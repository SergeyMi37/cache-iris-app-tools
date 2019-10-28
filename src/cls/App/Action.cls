Include App.LogMacro

/// Withdraw the necessary actions
Class App.Action Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Main method generate the content of page
ClassMethod OnPage() As %Status
{
	set $zt="Err"
 	#dim %request as %CSP.Request

 	;set $$$AppL("MSW","req")=$$$AppObJs(%request)
 	;merge $$$AppL("MSW","%request.Data")=%request.Data
	;set $$$AppL("MSW","%request.AppData")=%request.AppData

 	if %request.Get("appAct")'="" { ;AppAct=NameSpace:Packet.ClassName:Method:@Par1=Val1@Par2=Val2...
 		set appPar=$p(%request.Get("appAct"),"AppAct=",2,*)
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			set:$o(%request.Data(i,""),-1)'="" appPar("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
		}
		d ..RunMethod($p(appPar,":",1),$p(appPar,":",2),$p(appPar,":",3),.appPar)
		q $$$OK
 	} else {
	 	set appNsp=%request.Get("appNsp")
		set appMethod=%request.Get("appMethod")
		set appClass=%request.Get("appClass")
		set appPar=%request.Get("appPar")
		set appJson=%request.Get("appJson")
		set i=""
		for { set i=$o(%request.Data(i)) quit:i=""
			if i["appNsp",appNsp="" s appNsp=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appMethod",appMethod="" s appMethod=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appClass",appClass="" s appClass=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appPar",appPar="" s appPar=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			if i["appJson" s appJson=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
			set:$o(%request.Data(i,""),-1)'="" appPar("%request.Data",i)=$g(%request.Data(i,$o(%request.Data(i,""),-1)))
		}
		;if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		;set NSpace=$zu(5)

	 	if $isobject(%request.Content) { 
		 	set stream=%request.Content
			set sc=##class(App.files).Stream2String(%request.Content,.str)
			if 'sc quit sc
		 	if $g(str)["{" d ..ParseJson(.str,.appClass,.appMethod,.appPar) ;m appPar("%request.Content")=str  m appPar("%request")=$$$AppObJs(%request)
		 	;merge $$$AppL("MSW","Content")=str
	 	}
	  	i $g(appJson)["{" d ..ParseJson(.appJson,.appClass,.appMethod,.appPar) ;m appPar("%request")=$$$AppObJs(%request)
  	}
 	
	if appMethod="" {
		$$$jsstart
 		write "alert('"_$$$aText("The appMethod parameter is empty","")_"');"
 		$$$jsstop
		quit $$$OK
	}
	elseif appMethod="ShowJson" {
		if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		d ..ShowJson(appPar)
	}
	elseif appMethod="ShowXML" {
		if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
		d ..ShowXML(appPar)
	}
	else {
		d ..RunMethod(appNsp,appClass,appMethod,.appPar)
	}
	
	quit $$$OK
Err 
	write $zconvert($ze,"O","HTML")
	quit $$$OK
}

/// To execute the method
ClassMethod RunMethod(appNsp, appClass, appMethod, appPar) As %Status
{
	if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
	set NSpace=$zu(5)
		set:appClass="" appClass="App.Action"
		if $e(appPar,1)="{" {
			;Parse json TODO
		}
		elseif appPar["~" {
			do ##class(App.type).ParseURL(appPar,.appPar,"~")  ;parse in array
		}
		elseif appPar["&" {
			d ##class(App.type).ParseURL(appPar,.appPar,"&")
		}
		Do $CLASSMETHOD(appClass,appMethod,.appPar)
}

/// Show a formatted json 
ClassMethod ShowJson(appPar) As %Status
{
	set gn=$zconvert(appPar,"I","URL")
	try {
		write "<h3>"_gn_" in NameSpace :"_$zu(5)_"</h3>"
		if '$d(@gn) w $$$appError("Global node does not exist") q
		write "<pre>" write $g(@gn) write "</pre>" 
	} catch e { w $ze }
	quit $$$OK
}

/// Show formatted XNL
ClassMethod ShowXML(appPar) As %Status
{
	set gn=$zconvert(appPar,"I","URL")
	try {
		write "<h3>"_gn_" in NameSpace "_$zu(5)_"</h3>"
		if '$d(@gn) w $$$appError("Global node does not exist") q
		write $zconvert($g(@gn),"O","HTML")
	} catch e { write $ze }
	quit $$$OK
}

/// To disassemble the drain to Json
ClassMethod Test(appPar) As %Status
{
	write "ClassMethod Test."
	zwrite appPar
	quit $$$OK
}

/// To disassemble the drain to Json
ClassMethod ParseJson(jsonStr, appClass, appMethod, appPar) As %Status
{
 try {
	set appClass={}.$$$jsonFromJSON(jsonStr).appClass
	set appMethod={}.$$$jsonFromJSON(jsonStr).appMethod
	set appPar={}.$$$jsonFromJSON(jsonStr).appPar
	set appPar("jsonStr")=jsonStr
	}
 catch e { 
 	write $zconvert($ze,"O","HTML")
 }
 quit $$$OK
}

}

