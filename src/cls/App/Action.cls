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
	if appNsp'="" try {zn appNsp set NSpace=appNsp } catch e {}
	set NSpace=$zu(5)
	set appMethod=%request.Get("appMethod")
	set appClass=%request.Get("appClass")
 	;s $$$AppL("MSW","req")=$$$AppObJs(%request)
 	;m $$$AppL("MSW","rrr")=%request.Data
	;m $$$AppL("MSW","rrr2")=%request.Data("appForm")
	quit:appMethod="" $$$OK
	set appPar=%request.Get("appPar")

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
		Do $CLASSMETHOD(appClass,appMethod,appPar)
	}
	
	quit $$$OK
Err 
	write $zconvert($ze,"O","HTML")
	quit $$$OK
}

}

