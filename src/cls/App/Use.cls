Include App.LogMacro

Class App.Use [ CompileAfter = App.msg ]
{

/// do ##class(App.Use).Test()
ClassMethod Test(a As %Integer = 1, ByRef b = 2)
{
	$$$LogWarn("User message") // just place this macro in user code you wish to log
}

/// do ##class(App.Use).TestWithObjects()
ClassMethod TestWithObjects(a As %Integer = 1, b As %ZEN.proxyObject)
{
	$$$LogWarn("User message")
}

/// do ##class(App.Use).TestLogObjects(4)
ClassMethod TestLogObjects(id)
{
	set object=##class(%SYS.Task).%OpenId(id)
	set $$$AppL("MSW","taskObjId")=$$$AppObJs(id)
 	set $$$AppL("MSW","taskObj")=$$$AppObJs(object)
}

}

