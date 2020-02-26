/// Ping remote service 
Class App.Task.Ping Extends %SYS.Task.Definition
{

/// url- finden ip  https://pr-cy.ru/browser-details/
Property URL As %String(MAXLEN = "") [ Required ];

/// url send   https://52773b-00145437.labs.learning.intersystems.com/apptoolsrestask/get-html/App.MSW.Sunduk:OnPageSetIp?ip=111.222.333.444
Property URLsend As %String(MAXLEN = "") [ Required ];

Method OnTask() As %Status
{
	If ..URL="" Quit $$$ERROR($$$GeneralError,"Invalid - URL - not supplied")
	s st=$$$OK 
	s cur=$io ;u "/dev/null"
	s st=##class(App.net).GetHttp(..URL,.out)
	if st {
		d ##class(App.files).Stream2String(out("content"),.str)
		;s out("stream")=str
		s ip=$p($p($p(str,"<input type=""text"" name=""host"" ",2),"value=""",2),$c(34),1)
		
		if ip["." {
			s st=##class(App.net).GetHttp(..URLsend_"?ip="_ip)
		}
	}
    q st
}

}

