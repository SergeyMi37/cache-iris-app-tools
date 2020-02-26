Include App.LogMacro

Class App.FormExp Extends App.AutoPage
{

Parameter CSPURL = "App.FormExp.cls";

Parameter PAGENAME = "Objects Explorer";

Parameter PARENTPAGE = "App.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(App.FormExplorer).%New()
}

}

