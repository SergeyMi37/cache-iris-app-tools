Class App.FormExp Extends App.AutoPage
{

Parameter CSPURL = "App.FormExp.cls";

Parameter PAGENAME = {$s($mvv(58)="ru":"Навигатор",1:"Explorer")};

Parameter PARENTPAGE = "App.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(App.FormExplorer).%New()
}

}

