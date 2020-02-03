/// Ping remote service 
Class App.Task.Ping Extends %SYS.Task.Definition
{

/// http://localhost:57772/apptoolsrest/get-html/App.netping
Property URL As %String [ Required ];

Method OnTask() As %Status
{
	If ..URL="" Quit $$$ERROR($$$GeneralError,"Invalid - URL - not supplied")
	s st=$$$OK	
	s st=##class(App.net).GetHttp(..URL,.out)
    q st
}

}

