Include App.LogMacro

/// The template GUI of the application selector and tabs on the basis jQueryUi / Simple GUI based Application Template jQueryUi
Class App.TabsPanelUikitAdmin Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// The application title / Application title
Parameter HeaderText = "AdminTabsApplication";

/// is there a right to work with this form
ClassMethod IsPermiss(role) As %Status
{
	q $roles[role||($roles["%All")
}

/// Main method generate the content of page
/// TODO #2c3136 - 6699CC , 33383e - #6FA6DE , ffffff - #0048BA
/// #3e454c - 2185D0 , 1c1f22 - 0FC0FC , 656a70 - 
ClassMethod OnPage() As %Status
{
 s NSpace=$tr(%request.Get("ns"),"#")
 s:NSpace="" NSpace=$zu(5)
 zn NSpace
 // Save the session parameters debugging mode (implies extended disclosure)
 s %session.Data("debug")=%request.Get("debug")
 // http://cip.mvk.ru/csp/spgz/App.MVK.gisui.cls?ns=MVK&autoload=Find# - Find the first startup
 set autoloadmenu=$p(%request.Get("autoload"),"#")
 do ##class(App.Log).AddRecord(..%ClassName(1), "OnPage", "Login", "INFO", "","")
 &html<
 <!doctype html>
 <html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>#(..#HeaderText)#</title>
>
 	write ##class(App.LogInfoPane).GetLink()
 	write ##class(App.LogInfoPane).AddJsScripts() 
   	   do ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
   	   do ##class(App.LogInfoPane).AddStyle()
 	set menu=..DrawMenu() ;sidebar
	set menuTop=..DrawMenuTop() ;top think
	s path=$$$PATHCSP
 &html<
	
<link rel="stylesheet" href="#(path)#/uikit-dark-admin/css/nav.css"> <!-- CSS reset -->
	
</head>
<body>
	<header class="cd-main-header">
		<a href="#" class="cd-logo">
			<font color=#E4F2FB>#(..#HeaderText)#</font>
		</a>
		
		<div class="cd-search is-hidden">
			<input type="search" placeholder="search.." id="searchstr" name="searchstr">
		</div> <!-- cd-search -->

		<a href="#" class="cd-nav-trigger"><span></span></a>

		<nav class="cd-nav">
			<ul class="cd-top-nav">
				#(menuTop)#
			</ul>
		</nav>
	</header> <!-- .cd-main-header -->

	<main class="cd-main-content">
		<nav class="cd-side-nav">
			
			<ul class="uk-nav uk-nav-default">
				<li class="cd-label">...</li>
					#(menu)#
			</ul>

		</nav>

		<div id=MainBody class="content-wrapper">
        <!-- Page Content -->
		<br />
			
<div class="uk-grid">
    <div class="uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;' id="mainApp" >
		<ul id='tabMenu' class="uk-tab uk-tab-grid uk-tab-top" data-uk-tab="{connect:'#tabList', animation: 'fade'}">
			<li id='t1' class="uk-active"><a href="#">About</a></li>
		</ul>
		<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
			<li id='ta1' >
			 <div class="uk-alert-success" uk-alert>
				<p title='#($username)#'> #($$$aText("If you are not available to any single menu item",""))#</p>
			 </div>
			</li>
		</ul>
	</div>
</div>
        <!-- /#page-content-wrapper -->
		</div> <!-- .content-wrapper -->
	</main> <!-- .cd-main-content -->

<script src="#(path)#/uikit-dark-admin/js/main.js"></script> <!-- Resource jQuery -->

 <script language="javascript">

(function($) {
    var $window = $(window),
        $html = $('#wrapper');

    function resize() {
        if ($window.width() < 768) {
            return $html.removeClass('toggled');
        }
		
        $html.addClass('toggled');
    }

    $window
        .resize(resize)
        .trigger('resize');
})(jQuery);

</script>
<div id='MainHidden' style='display:none;'></div>
<div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
</div>
>
 $$$jsstart
 	w "$('#account_status').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_NSpace_"&appPar=');"_$c(13,10)
 	w "$('#searchstr').keydown(function (e) { if (e.keyCode == 13) { $('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar=Search&Searchstr='+document.getElementById('searchstr').value); }});"_$c(13,10)
  	if autoloadmenu="" {
	 	d ..GetAllApps(.opt) 
	 	set i="" 
	 	for { set i=$o(opt(i)) q:i=""
	 		if $GET(opt(i,"Active")) write "$('#Menu"_opt(i,"id")_"').trigger('click');"_$c(13,10)
	 	}
 	} else {
	 	write "$('#Menu"_autoloadmenu_"').trigger('click');"_$c(13,10)
 	}
 $$$jsstop
 
 &html<
</body>
</html>
	>
 quit $$$OK
}

/// the rendering top menu 
ClassMethod DrawMenuTop(Par) As %String
{
	do ..GetAllApps(.opt) 
	do ..GetAllMenu(.opt,.menu,1)
	set m="",ret=""
	for { set m=$o(menu(m)) quit:m=""
		s i=""
		if m=99 { ;account - with submenu
			s ret=ret_"<li class='has-children account'><a href='#'><span id='account_status'>"_$lg(menu(m),2)_"</span></a><ul>"
			for { set i=$o(menu(m,i)) quit:i=""
		   		set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
				set ret=ret_"<li><a id='Menu"_$g(opt(i,"id"))_"' href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
			}
			s ret=ret_"</ul></li>"
		}
		else {
			for { set i=$o(menu(m,i)) quit:i=""
		   		set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
				set ret=ret_"<li><a id='Menu"_$g(opt(i,"id"))_"' href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
			}
		}
	}
  quit ret
}

/// render side menu 
ClassMethod DrawMenu(Par) As %String
{
	do ..GetAllApps(.opt) 
	do ..GetAllMenu(.opt,.menu)
	set m="",ret=""
	for { set m=$o(menu(m)) quit:m=""
		s i=""
		s active=$s($lg(menu(m),3):"active",1:"")
		s ret=ret_"<li class='has-children overview "_active_"'><a href='#'>"_$lg(menu(m),2)_"</a><ul>"
		for { set i=$o(menu(m,i)) quit:i=""
	   		set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
			set ret=ret_"<li><a id='Menu"_$g(opt(i,"id"))_"' href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
		}
		s ret=ret_"</ul></li>"
	}
  quit ret
}

/// To obtain information on the support
ClassMethod GetSupportInfo() As %String
{
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","")
	q msg_"Support info mailto: sergey.mikhaylenko@gmail.com"
}

/// To add to the form js code if development mode
ClassMethod IsDebugMode(mode = 0) As %Status
{
 i mode,'%request.Get("debug") { 
	$$$jsstart
	  w $$$blockui(..GetSupportInfo())
	$$$jsstop
  q $$$OK
 }
	q 0
}

/// rendering status of the user
ClassMethod DrawStatus(Par) As %Status
{
	;do ##class(App.Form).BlockUI(0)
	s fio=##class(App.sys).GetFullName($username)
	s:fio="" fio=$$$aText("The user","")
	w $s(%request.Get("debug"):"<font color=red><b>"_$$$aText("Administrator mode","")_"</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"-"_$zu(5)_"'>"_$$$aText("User","")_": "_fio_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 	$$$jsstart
	w "$('.tip').tooltip();"
	$$$jsstop
 q $$$OK
}

/// To menu
ClassMethod GetAllMenu(opt, menu, top = 0) As %Status
{
 s i="" for { s i=$o(opt(i)) q:i=""
	if 'top,$d(opt(i,"Menu")) { 
		s m=$lg(opt(i,"Menu"),1)
		s:'$d(menu(m)) menu(m)=opt(i,"Menu")
		s menu(m,i)=""
	}
	if top,$d(opt(i,"MenuTop")) { 
		s m=$lg(opt(i,"MenuTop"),1)
		s:'$d(menu(m)) menu(m)=opt(i,"MenuTop")
		s menu(m,i)=""
	} else {
		;s:'$d(menu(99)) menu(99)=$lb(0,"---",0)
		;s menu(99,i)=""
	}
  }
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
	;make them zavisimye from the area
	;------------ sidebar
	s key="menu-first"
	s opt(key)="Find" ;The name of the menu
	s opt(key,"id")="Find"
	s opt(key,"TabName")="Tab finding" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	s opt(key,"Active")=1 ;active menu item

	s key="menu-second"
	s opt(key)="Help"
	s opt(key,"id")="Help"
	s opt(key,"TabName")="Help"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrl")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program",0)

	s key="menu-second2"
	s opt(key)="Menu 3"
	s opt(key,"id")="About"
	s opt(key,"TabName")="Menu 3"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program")

	s key="menu-second3"
	s opt(key)="Support"
	s opt(key,"id")="Support"
	s opt(key,"TabName")="Support"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrlNewWin")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program")
	
	;------------ one-level upper menu 
	s key="menu-topLern"
	s opt(key)="Menu 2"
	s opt(key,"id")="Menu2"
	s opt(key,"TabName")="Menu 2"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(1,"Menu 2") ;has no sub-items

	s key="menu-topOpt"
	s opt(key)="Option"
	s opt(key,"id")="Option"
	s opt(key,"TabName")="Option"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(2,"Option") ;has no sub-items

	;------------ top menu the top-accoun
	s key="menu-top-accoun"
	s opt(key)=$$$aText("Profile","")
	s opt(key,"id")="AccountProf"
	s opt(key,"TabName")=$$$aText("Profile","")
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items

	s key="menu-top-account3"
	s opt(key)=$$$aText("Exit","")
	s opt(key,"id")="AccountExit"
	s opt(key,"TabName")=$$$aText("Exit","")
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="Logout"
	s opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items
	
	;----- Setup the search in the top menu
	s key="Search"
	s opt(key)=$$$aText("Search","")
	s opt(key,"id")="Search-"
	s opt(key,"TabName")=$$$aText("Search","")_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	
	q $$$OK
}

/// drawing Tabs search
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSearch(key = "") As %Status
{
 ;do ..GetAllApps(.opt) 
 ;if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 ;set NSpace=$zu(5)
 w $$$aText("Context","")_" :"_$g(key)
 ;set pref=$g(opt(key,"id"))
}

/// the render Tab on the menu
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTab(Par) As %Status
{
	do ..GetAllApps(.opt) 
	if Par="Search" {
		s Searchstr=$g(Par("%request.Data","Searchstr"))
		if Searchstr="" q $$$OK
		;s tr=$tr(##class(App.MSW.type).Transliteration(Searchstr)," №`()\/*;'"":%","_N---")
		s tr=$tr(Searchstr," №`()\/*;'"":%","_N---")
		s key=Searchstr
		MERGE opt(key)=opt(Par)
		s opt(key)=opt(key)_Searchstr
		i $g(opt(Par,"TabMenu","Mode"))=1 { ;mode add a new tab 
			s opt(key,"id")=opt(key,"id")_tr 
		} else { ;mode add a new replace the old 
			set tabId="tab-"_opt(Par,"id")
			set tabIdMenu="tabMenu-"_opt(Par,"id")
			$$$jsstart
		  	 w "$('#"_tabId_"').remove();"
		  	 w "$('#"_tabIdMenu_"').remove();"
		  	$$$jsstop
		}
		s opt(key,"TabName")=opt(key,"TabName")_Searchstr
		s Par=key 
	}
	set tabId="tab-"_opt(Par,"id")
	set tabIdMenu="tabMenu-"_opt(Par,"id")
	if $g(opt(Par,"TabMenu","Close"))'="" s IconMenu="<span class=""uk-margin-small-left uk-icon uk-close"" uk-icon=""close"" onclick=""$(\'#"_tabIdMenu_",#"_tabId_"\').remove();""></span>"
 	if $DATA(opt(Par,"TabMenu","Close"))>9 { //there are more points
 		;TODO
 	}
 	$$$jsstart
 	 if $g(opt(Par,"MethodUrlNewWin"))'="" {
	 	 if $g(opt(Par,"Disable")) { w "alert('"_$$$aText("Mode debugging","")_"');"}
	 	 else {write "window.open('"_$g(opt(Par,"MethodUrlNewWin"))_"','_blank');"
	 	 }
 	}
	else {
 	 write "if (!$('li').is('#"_tabId_"')) { $('.uk-active').removeClass('uk-active');"
 		write " $('#tabList').append('<li id="_tabId_"></li>');"
 		write " $('#tabMenu').append('<li id="_tabIdMenu_"><a>"_$g(opt(Par,"TabName"))_$g(IconMenu)_"</a></li>');"
 		write " $('#t1,#ta1').hide();" //" $('#t1').prop('disabled',true);"
 		if $g(opt(Par,"Disable")) {
	 		write "$('#"_tabId_"').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTabAbout&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
 		elseif $g(opt(Par,"MethodUrl"))'="" {
	 		write "$('#"_tabId_"').load('"_$g(opt(Par,"MethodUrl"))_"');"
 		}
 		else {
	 		write "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
 	 write "};"
 	 write " UIkit.tab('#tabMenu').show($('#"_tabIdMenu_"'));"
	}
	$$$jsstop
}

/// Return in a single string
ClassMethod Logout(Par) As %Status
{
 do ##class(App.sys).logout()
 set onclick = "top.document.location.reload();"
 &html<
 <br>
 <div class="uk-align-center uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;'>
	<div class="uk-alert-warning" uk-alert>
		<p>#($$$aText("The output of Sistema produced",""))#</p>
	</div>
	<center><button class="uk-button uk-button-default uk-margin-small-right" type="button" onclick="#(onclick)#" ><span class="uk-margin-small-left uk-icon" uk-icon="sign-in"></span>#($$$aText("Log in",""))#</button>
	</center>
</div><br><br>
>
 	quit $$$OK
}

/// The output of the First button
ClassMethod ButtonAgain(divId = "", key = "") As %Status
{
	set mhead=divId_"MainHeader"
	set mcont=divId_"MainContent"
	set onclick="$('#"_mcont_"').empty();AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	quit $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""",$$$aText("First",""))
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabAbout(Par = "") As %Status
{
	do ..GetAllApps(.opt) 
	if $g(opt(Par,"Disable")) write ..GetSupportInfo() quit $$$OK
	set divId=$g(opt(Par,"id"))
	write "Hello world! Parameter: "_Par
	write ..ButtonAgain(divId,Par)
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSample(key = "") As %Status
{
 do ..GetAllApps(.opt) 
 if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 set NSpace=$zu(5)
 set pref=$g(opt(key,"id"))
 set mhead=pref_"MainHeader"
 set mcont=pref_"MainContent"
 &html<
<form id="#(pref_"MainForm")#">
<div class="uk-grid">
    <div class="uk-width-1-1 "id="#(mhead)#" ></div>
    <div style='overflow: auto;' class="uk-width-1-1 uk-margin-top uk-margin-left" id="#(mcont)#"></div>
</div>
</form>
>
 ;d ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
 $$$jsstart
  	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
  	w "ActionJs('"_pref_"MainForm','"_mhead_"','','"_pref_"FirstHead','divId="_pref_"~key="_key_"');"
	w "$('#"_mcont_"').height($(window).height()-($('#"_mhead_"').height()+$('#t1').height()+$('#MainNavbar').height()+300));"
  	w $$$blockui($$$aText("Loading...",""))
 $$$jsstop
 quit $$$OK
}

/// download template forms search
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Load...")_";ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
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
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find film in namespase SAMPLES"))#
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
	quit $$$OK
}

/// Search result
ClassMethod FindResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set Name=$g(Par("%request.Data",divId_"Name"))
	set Desc=$g(Par("%request.Data",divId_"Desc"))
	set Date=$g(Par("%request.Data",divId_"Date"))
	set st=$$$OK
	write ..ButtonAgain(divId,key)
	if mode=1 {
		if Name="" w $$$appError($$$aText("Context is empty","")) quit $$$OK
		zn "samples"
		set sql="select * from Cinema.Film where title is not null "
		if Name'="" s sql=sql_" and (title like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (Description like '%"_Desc_"%') "
		set msg="Query: "_sql
		set exec="##class(App.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_Desc_""")"
		set st=##class(App.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		if 'st  w $$$appError($System.Status.GetErrorText(st))
		quit $$$OK

	} 
	elseif mode=2 {

	}
	write "<br>"
	quit $$$OK
}

}

