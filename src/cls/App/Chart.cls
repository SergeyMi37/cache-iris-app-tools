Class App.Chart Extends App.AutoPage
{

Parameter CSPURL = "App.Chart.cls";

Parameter PAGENAME = {$s($mvv(58)="ru":"График",1:"Chart")};

Parameter PARENTPAGE = "App.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(App.ChartPanel).%New()
}

}

