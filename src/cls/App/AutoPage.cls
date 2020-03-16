/// Updated at 12/08/2017 16:19:10
Class App.AutoPage Extends %CSP.Util.AutoPage
{

/// Default Localization Domain
Parameter DOMAIN = "portalutils";

/// Specify a custom error page to call if there are any problems with generating this page.
/// If this is not specified it will use the default error page specified for this CSP
/// application, and if this is not specified it will use the system default error page.
/// For example this could be set to '/csp/samples/error.csp' to display the sample error
/// page.
Parameter ERRORPAGE = "App.errorpage.cls";

/// Name of the external style sheet file
Parameter STYLESHEET = "intersystems.css";

ClassMethod OnCompile() [ CodeMode = generator, Internal, ServerOnly = 1 ]
{
	s tSC=$$$OK
	// Skip the test if the compiled template class
	s isTemplate=%class="App.AutoPage"
	q:isTemplate $$$OK
	
	s cspurl=%class_".cls"
	s pvalue=$$$comMemberKeyGet(%class,$$$cCLASSparameter,"CSPURL",$$$cPARAMdefault)
	i (pvalue'=cspurl) {
		$$$defMemberKeySet(%class,$$$cCLASSparameter,"CSPURL",$$$cPARAMdefault,cspurl)
		s updateClass=##class("%Dictionary.ClassDefinition").%OpenId(%class)
		s updateClass.Modified=0
		d updateClass.%Save()
		d updateClass.%Close()
 	}

	f param="PAGENAME","PARENTPAGE" {
		s pvalue=$$$comMemberKeyGet(%class,$$$cCLASSparameter,param,$$$cPARAMdefault)
		i (pvalue="") {
			$$$defMemberKeySet(%class,$$$cCLASSparameter,param,$$$cPARAMdefault," ")
			s updateClass=##class("%Dictionary.ClassDefinition").%OpenId(%class)
			s updateClass.Modified=0
			d updateClass.%Save()
			d updateClass.%Close()
	 	}
	}
	q tSC
}

ClassMethod GetTitlePane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane [ CodeMode = objectgenerator ]
{
	Do %code.WriteLine(" Set tPane = ##class(%CSP.Util.SMTitlePane).%New()")
	Do %code.WriteLine(" Set tPane.Text =  $$$Text("""_$G(%parameter("PAGENAME"),"N/A")_""")")
	Do %code.WriteLine(" Quit tPane")
	q $$$OK
}

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	Set tDetailPane = ""
	Quit tDetailPane
}

ClassMethod OnPage(parameter = "") As %Status
{
	Quit ..DrawHTML()
}

}

