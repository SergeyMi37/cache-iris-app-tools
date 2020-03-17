Include App.LogMacro

/// The template GUI of the application selector and tabs on the basis jQueryUi, Uikit
Class App.UikitAdmin Extends %CSP.Page [ ClassType = "", DependsOn = App.msg, ProcedureBlock ]
{

/// The application title
Parameter HeaderText = "AdminTabsApplication";

/// Global Name Store Referens files and id sessions
Parameter GNStore = "^%App.ui";

/// For Redirect 
Parameter PreLoad;

/// is there a right to work with this form
ClassMethod IsPermiss(role) As %Status
{
	q $roles[role||($roles["%All")
}

/// Icons for the application
ClassMethod GetAppIcon(path) As %String
{
 	q "<link rel=""icon"" type=""image/x-icon"" href=""data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8AJCQk/yQkJP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/0ZGRv8XFxf/////AP///wD///8A////AP///////////////+7u7v9OTk7/sbGx/11dXf9KSkr///////////+lpaX/4eHh/////wD///8A////AAAAAP8AAAD///////////+8vLz///////X19f/t7e3/gICA/5eXl////////////wAAAP8AAAD/////AKysrP8AAAD/AAAA/wAAAP+enp7/////////////////////////////////5OTk/wAAAP8AAAD/AAAA/6ysrP////8A////AP///wCurq6PlJSUzP///wD///8A////AP///wD///8A////AJSUlMyQkJDY////AP///wD///8A////AP///wD///8AAAAA/wAAAP////8A////AP///wD///8A////AP///wAAAAD/AAAA/////wD///8A////AP///wD///8AAAAA/wAAAP8AAAD/////AP///wD///8A////AP///wD///8AAAAA/wAAAP8AAAD/////AP///wD///8ACwsL/wAAAP8AAAD/lJSU2AAAAP8AAAD/cnJy/1hYWP8AAAD/AAAA/2FhYdgHBwf/AAAA/wAAAP////8A////AP///wD///8A////AP///wAAAAD/s7Oz/wAAAP8AAAD/x8fH/wAAAP////8A////AP///wD///8A////AP///wD///8A////AP///wAAAAD/AAAA/////wAAAAD/AAAA/////wAAAAD/AAAA/////wD///8A////AP///wD///8A////AP///wD///8AAAAA/wAAAP+qqqqlAAAA/wAAAP9lZWXjAAAA/wAAAP////8A////AP///wD///8A////AP///wD///8A////ALa2tv////8A9vb2UQAAAP8AAAD/////Uf///wDAwMD/////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wBcXFz/AAAA/////wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A//8AAP//AADAAwAAwAMAAIABAAAAAAAA5+cAAOfnAADH4wAAgAEAAPgfAADyTwAA8A8AAPZvAAD+fwAA//8AAA==""/>"
}

ClassMethod PreLoad(path) As %String
{
 q $$$OK
}

/// Main method generate the content of page
ClassMethod OnPage(parameter = "") As %Status
{
	
 set NSpace=##class(App.Action).GetParam(.%request,"ns",parameter)
 s:$g(NSpace)="" NSpace=$zu(5)
 zn NSpace
 // Save the session parameters debugging mode (implies extended disclosure)
 ;s %session.Data("debug")=%request.Get("debug")

 if ..#PreLoad'="" {
  &html< <!doctype html> <html>>
	 d ..PreLoad(.%request)
  &html<</html>>
	q $$$OK
 }
 
 // http://cip.mvk.ru/csp/spgz/App.MVK.gisui.cls?ns=MVK&autoload=Find# - Find the first startup
 // http://localhost:57773/apptoolsrest/get-html/App.TabsPanelUikitAdmin?ns=APP&autoload=Find
 ;if $d(%request) {  set autoloadmenu=$p(%request.Get("autoload"),"#")
 set autoload=##class(App.Action).GetParam(.%request,"autoload",parameter)
 
 ;do ##class(App.Log).AddRecord(..%ClassName(1), "OnPage", "Login", "INFO", "","")
 
 set path=$$$PATHCSP_"apptools-uikit-dark-admin/"
 ;get full html
 s html=##class(App.rest).getStatic(..%ClassName(1)_"Static:html")
 s html=$replace(html,"href=""css","href="""_path_"css")
 s html=$replace(html,"src=""js","src="""_path_"js")
 s html=$replace(html,"TitleUIKitDarkAdmin",..#HeaderText)
 s html=$replace(html,"HeaderUIKitDarkAdmin",..#HeaderText)
 
 ;s link=##class(App.LogInfoPane).GetLink() ;already load
 ;s jsrc=##class(App.LogInfoPane).AddJsScripts() 
 
 s js=##class(App.rest).getStatic("App.UikitAdminStatic:javascript")
 s css=##class(App.rest).getStatic("App.UikitAdminStatic:css")
 
 set menu=..DrawMenu() ;sidebar
 set menuTop=..DrawMenuTop() ;top think
	
 s icon=..GetAppIcon(path)
 
 s html=$replace(html,"<!--head-end-->",icon_js_css)
 s html=$replace(html,"<!--#(menuTop)#-->",menuTop)
 s html=$replace(html,"<!--#(menu)#-->",menu)
 
 s par="<p title='"_$username_"'> "_($$$aText("If you are not available to any single menu item",""))_"</p>"
 s html=$replace(html,"<!--#($username)#-->",par)

 write $p(html,"<!--js-end-->",1)
  $$$jsstart
 	;w "$('#account_status').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_NSpace_"&appPar=');"_$c(13,10)
 	;w "$('#searchstr').keydown(function (e) { if (e.keyCode == 13) { $('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar=Search&Searchstr='+document.getElementById('searchstr').value); }});"_$c(13,10)
 	write ##class(App.Action).WriteActJs(%request,"","account_status",..%ClassName(1),"DrawStatus","")_$c(13,10)
 	set enter=##class(App.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar=Search&Searchstr='+document.getElementById('searchstr').value")_$c(13,10)
 	write "$('#searchstr').keydown(function (e) { if (e.keyCode == 13) { "_enter_" }});"_$c(13,10)
  	if autoload="" {
	 	do ..GetAllApps(.opt) 
	 	set i="" 
	 	for { set i=$o(opt(i)) q:i=""
	 		if $GET(opt(i,"Active")) write "$('#Menu"_opt(i,"id")_"').trigger('click');"_$c(13,10)
	 	}
 	} else {
	 	write "$('#Menu"_autoload_"').trigger('click');"_$c(13,10)
 	}
 $$$jsstop
 &html< </body></html>>
 q $$$OK
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
		   		;set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
				set onclick=##class(App.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar="_i)
				set ret=ret_"<li><a id='Menu"_$g(opt(i,"id"))_"' href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
			}
			s ret=ret_"</ul></li>"
		}
		else {
			for { set i=$o(menu(m,i)) quit:i=""
		   		;set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
		   		set onclick=##class(App.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar="_i)
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
	   		;set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
	   		set onclick=##class(App.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar="_i)
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
	;w $s(%request.Get("debug"):"<font color=red><b>"_$$$aText("Administrator mode","")_"</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"-"_$zu(5)_"'>"_$$$aText("User","")_": "_fio_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
	write "<span class='tip' title='"_fio_"-"_$j_"-"_$zu(5)_"'>"_$username_"</span>"
 	;$$$jsstart
	;	w "$('.tip').tooltip();"
	;$$$jsstop
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
	s opt(key)="Find users" ;The name of the menu
	s opt(key,"id")="Find" ;use methods: FindFirstHead FindResult
	s opt(key,"TabName")="finding users" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	s opt(key,"Active")=1 ;active menu item

	s key="menu-first2"
	s opt(key)="Sample gallery" ;The name of the menu
	s opt(key,"id")="Lighbox" ;use methods: LighboxFirstHead LighboxResult
	s opt(key,"TabName")="Gallery" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	
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
	if $g(Par("appPar"))'="" set Par=Par("appPar")
	do ..GetAllApps(.opt) 
	d ..ShowTabApps(.Par,.opt)
}

/// the render Tab on the menu
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabApps(Par, opt) As %Status
{
	if Par="Search" {
		s Searchstr=$g(Par("%request.Data","Searchstr"),Par("Searchstr"))
		if Searchstr="" q $$$OK
		;s tr=$tr(##class(App.MSW.type).Transliteration(Searchstr)," №`()\/*;'"":%","_N---")
		;s tr=$tr($zts,".,") 
		s tr=$e($tr(Searchstr," №`()\/*;'"":%?$@&.,",""),1,10)_$i(@..#GNStore@("jobs",$j))
		s key=tr ;Searchstr
		MERGE opt(key)=opt(Par)
		s opt(key)=opt(key)_tr ;Searchstr
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
		s opt(key,"CGIvar")="&Searchstr="_Searchstr ;$zconvert(Searchstr,"O","URI")
		s opt(key,"TabName")=opt(key,"TabName")_tr 
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
 	 write "if (!$('li').is('#"_tabId_"')) { $('.uk-active').removeClass('uk-active');"_$c(13,10)
 		write " $('#tabList').append('<li id="_tabId_"></li>');"_$c(13,10)
 		write " $('#tabMenu').append('<li id="_tabIdMenu_"><a>"_$g(opt(Par,"TabName"))_$g(IconMenu)_"</a></li>');"_$c(13,10)
 		write " $('#t1,#ta1').hide();"_$c(13,10) //" $('#t1').prop('disabled',true);"
 		if $g(opt(Par,"Disable")) {
	 		;write "$('#"_tabId_"').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTabAbout&appNsp="_$zu(5)_"&appPar="_Par_"');"
	 		write ##class(App.Action).WriteActJs(%request,"",tabId,..%ClassName(1),"ShowTabAbout","&appPar="_Par_$g(opt(Par,"CGIvar")))
 		}
 		elseif $g(opt(Par,"MethodUrl"))'="" {
	 		write "$('#"_tabId_"').load('"_$g(opt(Par,"MethodUrl"))_"');"
 		}
 		else {
	 		;write "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
	 		write ##class(App.Action).WriteActJs(%request,"",tabId,$g(opt(Par,"ClassName")),$g(opt(Par,"Method")),"&appPar="_Par_$g(opt(Par,"CGIvar")))
 		}
 	 write "};"
 	 write " UIkit.tab('#tabMenu').show($('#"_tabIdMenu_"'));"
	}
	$$$jsstop
}

/// Return in a single string
ClassMethod Logout(Par) As %Status
{
 if $g(Par("appPar"))'="" set Par=Par("appPar")
 do ##class(App.sys).logout()
 set onclick = "top.document.location.reload();"
 do ..GetAllApps(.opt) 
 $$$jsstart
 set i=""
 for { set i=$o(opt(i)) q:i=""
 	continue:i=Par
 	set tabId="tab-"_opt(i,"id")
	set tabIdMenu="tabMenu-"_opt(i,"id")
 	write "$('#"_tabIdMenu_",#"_tabId_"').remove();"
 }
 $$$jsstop
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
	set onclick="$('#"_mcont_"').empty();"_##class(App.Action).WriteActJs(%request,divId_"MainForm",mhead,..%ClassName(1),divId_"FirstHead","&key="_key_"&divId="_divId)
	;AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	quit $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""",$$$aText("Again",""))
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabAbout(key = "") As %Status
{
	if $g(key("appPar"))'="" set key=key("appPar")
	do ..GetAllApps(.opt) 
	if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
	set divId=$g(opt(key,"id"))
	write "Hello world! Parameter: "_key
	write ..ButtonAgain(divId,key)
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowInIFrame(key = "") As %Status
{
 if $g(key("appPar"))'="" set key=key("appPar")
 do ..GetAllApps(.opt) 
 if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 set NSpace=$zu(5)
 set pref=$g(opt(key,"id"))
 set mhead=pref_"MainHeader"
 set mcont=pref_"MainContent"
 &html<
<form id="#(pref_"MainForm")#">
<div class="uk-grid">
    <iframe id="#(mcont)#" width="100%" height="100%" style='overflow: auto;' src='#($g(opt(key,"InFrameUrl")))#' ></iframe>
    </div>
</div>
</form>
>
 $$$jsstart
  ;	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
 	w "$('#"_mcont_"').height($(window).height()-($('#t1').height()+$('#MainNavbar').height()+150));"
  ;	w $$$blockui($$$aText("Loading...",""))
 $$$jsstop
 quit $$$OK
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSample(key = "") As %Status
{
 if $g(key("appPar"))'="" set key=key("appPar")
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
    w ##class(App.Action).WriteActJs(%request,pref_"MainForm",mhead,..%ClassName(1),pref_"FirstHead","&divId="_pref_"&key="_key)
	w "$('#"_mcont_"').height($(window).height()-($('#"_mhead_"').height()+$('#t1').height()+$('#MainNavbar').height()+300));"_$c(13,10)
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
	set onclick=$$$blockui("Load...")_";"_##class(App.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
	;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
		Context name users
			</td>
			<td>
				#($$$appText(divId_"textName","title='context in Name'","s"))#
			</td>		
			<td>
				#($$$appText(divId_"textDesc","title='context in FullName'","m"))#
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
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find USERS"))#
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
 $$$jsstart
 	//for all identifiers starting with "_divId_"text by pressing Enter, click on the button (ending with $("[id$='txtTitle']"))
 	w "$('[id^="""_divId_"text""]').keydown(function (e) { if (e.keyCode == 13) { $('#"_divId_"appButtonResult1').click(); }});"_$c(13,10)
 $$$jsstop
	
	quit $$$OK
}

/// Search result
ClassMethod FindResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	s Name=##class(App.Action).GetElemForm(%request,.Par,divId_"textName")	
	set Desc=$g(Par("%request.Data",divId_"textDesc"))
	set st=$$$OK
	if mode=1 {
		write ..ButtonAgain(divId,key)
		if Name="" w $$$appError($$$aText("Context is empty","")) quit $$$OK
		zn "%sys"
		set sql="select ID,name,EmailAddress,fullName from Security.Users where Enabled [ '1' "
		if Name'="" s sql=sql_" and (name like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (fullName like '%"_Desc_"%') "
		set msg="Query: "_sql

		set exec="##class(App.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_Desc_""")"
		set st=##class(App.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		if 'st  w $$$appError($System.Status.GetErrorText(st))
		quit $$$OK

	} 
	write "<br>"
	quit $$$OK
}

/// download template forms search
ClassMethod LighboxFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Load...")_";"_##class(App.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
	Set path=$p($p($zu(86),"*",1),$$$slash,1,*-1)
	Set path1=path_$tr("\csp\broker\images\","\",$$$slash)
	Set path2=path_$tr("\docs\","\",$$$slash)
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
				#($$$appText(divId_"path1","size=50 title='path to images'",path1))#
			</td>
			<td>
				#($$$appText(divId_"path2","size=50 title='path to images docs'",path2))#
			</td>
		</tr>
		<tr>
			<td>
			#($$$appButton(divId_"appButtonResult1"," onclick="""_$tr(onclick,"*",1)_"""","Generate gallery via App /csp/broker"))#			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult2"," onclick="""_$tr(onclick,"*",2)_"""","Generate gallery dinamic rest"))#			
			</td>
		</tr>
		</table>
	>
 $$$jsstart
 	;for all identifiers starting with "_divId_"text by pressing Enter, click on the button (ending with $("[id$='txtTitle']"))
 	w "$('[id^="""_divId_"path""]').keydown(function (e) { if (e.keyCode == 13) { $('#"_divId_"appButtonResult2').click(); }});"_$c(13,10)
 $$$jsstop
	
	quit $$$OK
}

/// Its result
ClassMethod LighboxResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	s path1=##class(App.Action).GetElemForm(%request,.Par,divId_"path1")	
	set path2=$g(Par("%request.Data",divId_"path2"))
	set st=$$$OK
	s wc=##class(App.filesMimeTypes).GetTypesWildcards("image")_##class(App.filesMimeTypes).GetTypesWildcards("video")
	if mode=1 {
	 d ##class(App.files).GetList(path1,wc,.List)
	 s cspappstatic="/csp/broker/images/"
	 $$$jsstart
 		w "UIkit.lightboxPanel({"
   		w "items: [ "
		  d ..LighboxDrawJson(.List,cspappstatic)
  		w " ] }).show();"
	 $$$jsstop
	} 
	elseif mode=2 {
	 d ##class(App.files).GetList(path2,wc,.List)
	 s appdinamic=%request.Application_"get-files/"
	 $$$jsstart
 		w "UIkit.lightboxPanel({"
   		w "items: [ "
		  d ..LighboxDrawJson(.List,,appdinamic,..#GNStore)
  		w " ] }).show();"
	 $$$jsstop
	}
	write "<br>"
	quit $$$OK
}

/// Lighbox Draw JSON
/// List - files array 
/// subdir - application static
ClassMethod LighboxDrawJson(List, subdir = "", appdynamic, gn = "") As %Status
{
 s i=""
 for { s i=$o(List(i)) q:i=""
 	if $lv($g(List(i))),$lg($g(List(i)),2)="F" {
		 	s fullpath=$lg($g(List(i)),1)
		 	s ItemName=$lg($g(List(i)),4)
 	} else {
 		s ItemName=$g(List(i,"ItemName"))
 		s fullpath=$g(List(i,"Name"))
 	}
 	set ext=$p(ItemName,".",*)
 	s mimetype=##class(App.filesMimeTypes).GetMimeTypes4ext(ext)
 	s type=$s(mimetype[("video"):"video",(mimetype)[("image"):"image",1:"iframe")
 	if subdir'="" {
 		w "{source: '"_subdir_ItemName_"', caption: '"_ItemName_"', type: '"_type_"'}",$c(13,10)
 	} else {
	 	set fileId=##class(App.files).GetFileIdView(fullpath,gn) 
		w "{source: '"_appdynamic_fileId_"', caption: '"_ItemName_"', type: '"_type_"'}",$c(13,10)
 	}
	w:$o(List(i))'="" ","
 }
}

/// Encode string to URL
ClassMethod EnCode(s) As %Status
{
	s s=$zconvert(s,"O","URL")
	q s
}

/// Decode string from URL
ClassMethod DeCode(s) As %Status
{
	q $zconvert(s,"I","URL")
}

/// Draw Tables UiKit
ClassMethod DrawTableUi(mode = "beg", divId = "tab2", attr = "", ByRef Enum) As %Status
{
	if mode="beg" {
	&html<
 <div #(attr)# id="#(divId)#" >
    <table class="uk-table uk-table-hover uk-table-middle uk-table-divider">
        <thead>
           <tr>
          >
          s i=""  for {  s i=$o(Enum(i)) q:i=""
            write " <th "_$GET(Enum(i,"attr"))_" >"_$g(Enum(i))_"</th>"
          }
               /* <th class="uk-table-shrink">Preserve</th>
                <th class="uk-table-expand">Expand + Link</th>
                <th class="uk-width-small">Truncate</th>
                <th class="uk-table-shrink uk-text-nowrap">Shrink + Nowrap</th> */
    &html<
            </tr>
        </thead>
        <tbody>
        >
	}
    elseif mode="tr" {
			w "<tr>"
            s i=""  for {  s i=$o(Enum(i)) q:i=""
				w "<td "_$GET(Enum(i,"attr"))_">"_$GET(Enum(i))_"</td>"
               
               /* <td><input class="uk-checkbox" type="checkbox"></td>
               <td><img class="uk-preserve-width uk-border-circle" src="image/msw.jpg" width="40" alt=""></td>
                <td class="uk-table-link">
                    <a class="uk-link-reset" href="">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.</a>
                </td>
                <td class="uk-text-truncate">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.</td>
                <td class="uk-text-nowrap">Lorem ipsum dolor</td>*/
            } 			
            w "</tr>"
	}
	elseif mode="end" {
		&html<
		   </tbody>
 	 	 </table>
 		</div>
    	>
	} else {
	}
}

}

