Include App.LogMacro

/// The template GUI of the application selector and tabs on the basis jQueryUi
Class App.TabsPanel Extends %CSP.Page [ ClassType = "", DependsOn = App.msg, ProcedureBlock ]
{

/// The application title
Parameter HeaderText = "Tabs Application title";

/// Main method generate the content of page
ClassMethod OnPage() As %Status
{
 s NSpace=$zu(5)
 // Save the session parameters debugging mode (implies extended disclosure)
 s %session.Data("debug")=%request.Get("debug")
 &html<
 <html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>#(..#HeaderText)#</title>
>
	write ##class(App.LogInfoPane).GetLink()
	write ##class(App.LogInfoPane).AddJsScripts() 
   	   do ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
   	   do ##class(App.LogInfoPane).AddStyle()
 &html< 
</head>
<body>
 <div id="MainBody">
  <nav style='background: #d7ebf9;' > 
  &nbsp;&nbsp;&nbsp;  
  <span class="uk-margin-small-right uk-icon" uk-icon="album"></span>
  &nbsp;&nbsp;&nbsp; 
 	<div id="MainControlgroup" > </div>
 	<span id='status_nav'> Status session </span>
  </nav> 
 <div id="tabs"> </div>
</div>
>
 // Debug mode 1
 q:..IsDebugMode(0) $$$OK
 $$$jsstart
    // Download available modes menu
 	w "$('#MainControlgroup').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawMenu&appNsp="_NSpace_"&appPar=');"
 	//Download status
 	w "$('#status_nav').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_NSpace_"&appPar=');"
    //To download Taba
 	w "$('#tabs').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawTabs&appNsp="_NSpace_"&appPar=');"
 $$$jsstop
 
 &html< 	
 <script language="javascript">
$( ".tip" ).tooltip();
</script>
<div id='MainHidden' style='display:none;'></div>
<div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
</div>
</body>
</html>
	>
 quit $$$OK
}

/// To obtain information on the support
ClassMethod GetSupportInfo() As %String
{
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","")
	q msg_"Support info mailto: sergey.mikhaylenko@gmail.com <div id=test></div><button onclick=""$('#test').load('/apprest/getrpc/aaa:::label%5EApp.routine(3333,%22green%22)');"" >test</button>"
}

/// To add to the form js code if development mode
ClassMethod IsDebugMode(mode = 0) As %Status
{
 i mode,'%request.Get("debug") { 
	$$$jsstart
	  w $$$blockui(..GetSupportInfo())
	$$$jsstop
	w "</body></html>"
  q $$$OK
 }
	q 0
}

/// rendering status of the user
ClassMethod DrawStatus(Par) As %Status
{
	;do ##class(App.Form).BlockUI(0)
	w $s(%request.Get("debug"):"<font color=red><b>"_$$$aText("Administrator mode","")_"</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"'>"_$$$aText("User","")_": "_##class(App.sys).GetFullName($username)_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 	$$$jsstart
	w "$('.tip').tooltip();"
	$$$jsstop
 q $$$OK
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
	;TODO access rights to pages
	;TODO save in database table
	s key="menu-first"
	s opt(key)="Finding" ;The name of the menu
	s opt(key,"id")="Find"
	s opt(key,"TabName")="Tab Finding out" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed

	s key="menu-second"
	s opt(key)="About the program"
	s opt(key,"id")="About"
	s opt(key,"TabName")="About the program"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;developed
	
	q $$$OK
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabAbout(Par = "") As %Status
{
	d ..GetAllApps(.opt) 
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	s divId=$g(opt(Par,"id"))
	w "Hello world! Parameter: "_Par
	w ..ButtonAgain(divId,,Par)
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSample(key = "") As %Status
{
 d ..GetAllApps(.opt) 
 i $g(opt(key,"Disable")) w ..GetSupportInfo() q $$$OK
 s NSpace=$zu(5)
 s pref=$g(opt(key,"id"))
 s mhead=pref_"MainHeader"
 s mcont=pref_"MainContent"
 &html<
<form id="#(pref_"MainForm")#">


<table id="tbpage" cellspacing="0" width='100%' >
  <tbody>
   <tr height='10%' >
   	<td>
   		<DIV id="#(mhead)#"></div>
	</td>
   </tr>
   <tr height='90%' >
   	<td>
 		<div style='overflow: auto;' id="#(mcont)#"></div>
	</td>
 </tr>
</tbody>
</table>
</form>
>
 ;d ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
 $$$jsstart
  	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
 	w "$('#"_mcont_"').height($('#tabs-"_pref_"').height()-$('#"_pref_"MainHeader').height()-150);"
  	w $$$blockui($$$aText("Loading...",""))
	w "ActionJs('"_pref_"MainForm','"_mhead_"','','"_pref_"FirstHead','divId="_pref_"~key="_key_"');"
 $$$jsstop
 ;d ..AddToForm()
 quit $$$OK
}

/// download template forms search
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")
	set onclick=$$$blockui("Loading...")_";ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
			Context film name
			</td>
			<td>
			#($$$appText(divId_"Name","","New"))#
			</td>
			<td>

			</td>
			<td>

			</td>
			<td>
		
			</td>
			<td>

			</td>
		</tr>
		<tr>
			<td>
			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find in table"))#
			</td>
			<td>

			</td>
			<td>
			</td>
			<td>
			
			</td>
			<td>

			</td>
		</tr>
		</table>
	>
	q $$$OK
}

/// Search result
ClassMethod FindResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set Name=$g(Par("%request.Data",divId_"Name"))
	write ..ButtonAgain(divId,,key)
	if mode=1 {
		if Name="" w $$$appError($$$aText("Context is empty","")) q $$$OK
		if $zv["IRIS" {
			zn "USER"
			set sql="select * from Demo.Address where City is not null "
			if Name'="" s sql=sql_" and (City like '%"_Name_"%') "

		} else {
			zn "samples"
			set sql="select * from Cinema.Film where title is not null "
			if Name'="" s sql=sql_" and (title like '%"_Name_"%') "
		}
		set msg="Query: "_sql
		set exec="##class(App.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_Desc_""")"
		set st=##class(App.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		quit $$$OK
	} 
	elseif mode=2 {

	}
	w "<br>"
	q $$$OK
}

/// rendering Tabs
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTab(Par) As %Status
{
	d ..GetAllApps(.opt) 
	s tabId="tabs-"_opt(Par,"id")
 	$$$jsstart
 		w "var a = $('#li-"_tabId_"'); a.show();" ; open the tab
 		w "var index = $('#tabs a[href=""#"_tabId_"""]').parent().index();"
		w "$('#tabs').tabs({'active':index});" ;make it active
 		if $g(opt(Par,"Url"))'="" {
	 		w "$('#"_tabId_"').load('"_$g(opt(Par,"Url"))_"');"
 		}
 		else {
	 		w "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
	$$$jsstop
}

/// rendering menu
ClassMethod DrawMenu(Par) As %Status
{
	
	d ..GetAllApps(.opt) 
	s onc="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
	w "<select id=""menu-spgz"" >"
	s i="" w "<option VALUE=0> </option>"
	f { s i=$o(opt(i)) q:i=""  
		w "<option VALUE="""_i_""">"_opt(i)_"</option>"
	}
 	w "</select>"
 	w ..ButtonExit("MainBody")
 	$$$jsstart
		w "$( ""#MainControlgroup"" ).controlgroup();"
 		w "$( ""#menu-spgz"" ).selectmenu({ change: function( event, data ) { "_onc_" }, width:600 }).selectmenu('menuWidget');"
	$$$jsstop
  q $$$OK
}

/// rendering tabs
ClassMethod DrawTabs(Par) As %Status
{
	d ..GetAllApps(.opt)
	w "<ul>"
	s i="" f { s i=$o(opt(i)) q:i=""  
		s tabs(i)="tabs-"_$g(opt(i,"id"))
		w "<li id=""li-"_tabs(i)_"""><a href=""#"_tabs(i)_""">"_opt(i,"TabName")_"</a></li>"
	}
 	w "</ul>"
 	s i="" f { s i=$o(tabs(i)) q:i=""  
 		w "<div id='"_tabs(i)_"' style='height: 85%' ></div>"
 	}
 	$$$jsstart
		w "$( ""#tabs"" ).tabs();"
		;All tabs will immediately hide after initialization, they will be open as a choice
		s i="" f { s i=$o(tabs(i)) q:i=""  
			w "var a = $('#li-"_tabs(i)_"'); a.hide();"
		}
	$$$jsstop
	q $$$OK
}

/// Output exit button
ClassMethod ButtonExit(formName) As %Status
{
	set onclick="$('#"_formName_"').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=Logout&appNsp="_$zu(5)_"&appPar="_$$$aText("Exit complete","")_"');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""",$$$aText("Exit",""))
}

/// To add to the form js code
ClassMethod AddToForm() As %Status
{
	q $$$OK
}

/// Return in a single string
ClassMethod Logout(Par) As %Status
{
	d ##class(App.sys).logout()
	w $$$appMsg($g(Par)) w "<br>"
	d ##class(App.Form).ButtonRef($$$aText("Entrance",""))
  	q $$$OK
}

/// The output of the First button
ClassMethod ButtonAgain(Prefix = "", Method = "", appPar = "") As %Status
{
	i Method="" s Method="ShowTab"
	s onc="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
	set onclick="$('#MainHidden').load('App.Action.cls','"_Prefix_"appClass="_..%ClassName(1)_"&"_Prefix_"appMethod="_Method_"&"_Prefix_"appNsp="_$zu(5)_"&"_Prefix_"appPar="_appPar_"');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""",$$$aText("Again",""))
}

}

