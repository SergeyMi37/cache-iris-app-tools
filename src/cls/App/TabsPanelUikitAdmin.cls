Include App.LogMacro

/// Шаблон GUI приложения с селектором и вкладками на основе jQueryUi / Simple GUI Application Template based jQueryUi
Class App.TabsPanelUikitAdmin Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Заголовок приложения / Application title
Parameter HeaderText = "AdminTabsApplication";

/// есть ли право на работу с этой формой
ClassMethod IsPermiss(role) As %Status
{
	q $roles[role||($roles["%All")
}

/// Главный метод формирования содержимого страницы
/// TODO #2c3136 #3e454c - заменить на синие тона
ClassMethod OnPage() As %Status
{
 s NSpace=$tr(%request.Get("ns"),"#")
 s:NSpace="" NSpace=$zu(5)
 zn NSpace
 // Сохраним в параметрах сессии режим отладки (подразумевает расширенное информирование)
 s %session.Data("debug")=%request.Get("debug")
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
 	set menu=..DrawMenu() ;боковое меню
	set menuTop=..DrawMenuTop() ;верхнее мню
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
			<input type="search" placeholder="Искать..." id="searchstr" name="searchstr">
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
			<li id='t1' class="uk-active"><a href="#">О программе</a></li>
		</ul>
		<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
			<li id='ta1' >
			 <div class="uk-alert-success" uk-alert>
				<p title='#($username)#'> Если вам не доступен ни один пункт меню, то обратитесь к администратору</p>
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

/// отрисовка вернего меню 
ClassMethod DrawMenuTop(Par) As %String
{
	do ..GetAllApps(.opt) 
	do ..GetAllMenu(.opt,.menu,1)
	set m="",ret=""
	for { set m=$o(menu(m)) quit:m=""
		s i=""
		if m=99 { ;account - с подменю
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

/// отрисовка бокового меню 
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

/// Получить информацию по техподдержке
ClassMethod GetSupportInfo() As %String
{
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","Программный комплекс на отладке. Попробуйте войти попозже, или обратитесь тех.поддержку: ")
	q msg_"Support info mailto: sergey.mikhaylenko@gmail.com"
}

/// Добавить на форму  js код если режим разработки
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

/// отрисовка статуса пользователя
ClassMethod DrawStatus(Par) As %Status
{
	;do ##class(App.Form).BlockUI(0)
	s fio=##class(App.sys).GetFullName($username)
	s:fio="" fio="Пользователь"
	w $s(%request.Get("debug"):"<font color=red><b>Режим админа</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"-"_$zu(5)_"'>"_fio_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 	$$$jsstart
	w "$('.tip').tooltip();"
	$$$jsstop
 q $$$OK
}

/// Получить меню
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

/// какие доступны режимы
ClassMethod GetAllApps(opt) As %Status
{
	;сделать их зависымыми от области
	;------------ боковое меню
	s key="menu-first"
	s opt(key)="Поиск" ;Имя меню
	s opt(key,"id")="Find"
	s opt(key,"TabName")="Вкладка поиска" ;имя вкладки
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;разрабатывается
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Режимы",1) ;$lg(,3)=1 - раскрытое меню 1 уровня
	s opt(key,"Active")=1 ;активный пункт меню

	s key="menu-second"
	s opt(key)="Помощь"
	s opt(key,"id")="Help"
	s opt(key,"TabName")="Помощь"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrl")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;разрабатывается
	s opt(key,"Menu")=$lb(2,"О Программе",0)

	s key="menu-second2"
	s opt(key)="Автор"
	s opt(key,"id")="About"
	s opt(key,"TabName")="Об авторе"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;разрабатывается
	s opt(key,"Menu")=$lb(2,"О Программе")

	s key="menu-second3"
	s opt(key)="Поддержка"
	s opt(key,"id")="Support"
	s opt(key,"TabName")="ТехПоддержка"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrlNewWin")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;разрабатывается
	s opt(key,"Menu")=$lb(2,"О Программе")
	
	;------------ верхнее одноуровневое меню 
	s key="menu-topLern"
	s opt(key)="Обучение Курс 2"
	s opt(key,"id")="Lernen"
	s opt(key,"TabName")="Обучение технологиям 2"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(1,"Обучение") ;не имеет вложенные пункты

	s key="menu-topOpt"
	s opt(key)="Опции админики"
	s opt(key,"id")="Option"
	s opt(key,"TabName")="Опции сайта" 
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(2,"Опции") ;не имеет вложенные пункты

	;------------ верхнее меню top-accoun
	s key="menu-top-accoun"
	s opt(key)="Профиль"
	s opt(key,"id")="AccountProf"
	s opt(key,"TabName")="Профиль" 
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(99,"Учетка") ;только 99-account имеет вложенные пункты

	s key="menu-top-account3"
	s opt(key)="Выход"
	s opt(key,"id")="AccountExit"
	s opt(key,"TabName")="Выход" 
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="Logout"
	s opt(key,"MenuTop")=$lb(99,"Учетка") ;только 99-account имеет вложенные пункты
	
	;----- Настройка поиска в топ меню
	s key="Search"
	s opt(key)="Искать"
	s opt(key,"id")="Search-"
	s opt(key,"TabName")="Поиск-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabMenu","Mode")=0 ;1- для каждой новой поисковой строки делать новый таб, 0-таб всегда один
	
	q $$$OK
}

/// отрисовка Вкладки поиска
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTabSearch(key = "") As %Status
{
 ;do ..GetAllApps(.opt) 
 ;if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 ;set NSpace=$zu(5)
 w "Поиск по контексту :"_$g(key)
 ;set pref=$g(opt(key,"id"))
}

/// отрисовка Вкладки по пункту меню
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTab(Par) As %Status
{
	do ..GetAllApps(.opt) 
	if Par="Search" {
		s Searchstr=$g(Par("%request.Data","Searchstr"))
		if Searchstr="" q $$$OK
		s tr=$tr(##class(App.type).Transliteration(Searchstr)," №`()\/*;'"":%","_N---")
		s key=Searchstr
		MERGE opt(key)=opt(Par)
		s opt(key)=opt(key)_Searchstr
		i $g(opt(Par,"TabMenu","Mode"))=1 { ;режим добавления нового таба 
			s opt(key,"id")=opt(key,"id")_tr 
		} else { ;режим добавления нового замены старого 
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
 	if $DATA(opt(Par,"TabMenu","Close"))>9 { //есть еще пункты
 		;TODO
 	}
 	$$$jsstart
 	 if $g(opt(Par,"MethodUrlNewWin"))'="" {
	 	 if $g(opt(Par,"Disable")) { w "alert('Режим на отладке');"}
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

/// Возврат в одной строке
ClassMethod Logout(Par) As %Status
{
 do ##class(App.sys).logout()
 set onclick = "top.document.location.reload();"
 &html<
 <br>
 <div class="uk-align-center uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;'>
	<div class="uk-alert-warning" uk-alert>
		<p>Выход из сестему произведен</p>
	</div>
	<center><button class="uk-button uk-button-default uk-margin-small-right" type="button" onclick="#(onclick)#" ><span class="uk-margin-small-left uk-icon" uk-icon="sign-in"></span> Войти</button>
	</center>
</div><br><br>
>
 	quit $$$OK
}

/// Вывод кнопки Сначала
ClassMethod ButtonAgain(divId = "", key = "") As %Status
{
	set mhead=divId_"MainHeader"
	set mcont=divId_"MainContent"
	set onclick="$('#"_mcont_"').empty();AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	quit $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""","Сначала")
}

/// отрисовка Вкладки О программе"
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTabAbout(Par = "") As %Status
{
	do ..GetAllApps(.opt) 
	if $g(opt(Par,"Disable")) write ..GetSupportInfo() quit $$$OK
	set divId=$g(opt(Par,"id"))
	write "Hello world! Parameter: "_Par
	write ..ButtonAgain(divId,Par)
}

/// отрисовка Вкладки ранее переданных
/// Par - код пункта меню из ..GetAllApps
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
  	; вычислить высоту контейнера-результата как вычетание из выстоты контейнера-таба высоту контейнера-заголовка
  	w "ActionJs('"_pref_"MainForm','"_mhead_"','','"_pref_"FirstHead','divId="_pref_"~key="_key_"');"
	w "$('#"_mcont_"').height($(window).height()-($('#"_mhead_"').height()+$('#t1').height()+$('#MainNavbar').height()+300));"
  	w $$$blockui("Загрузка...")
 $$$jsstop
 quit $$$OK
}

/// загрузить шаблон формы поиска
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Ждите...")_";ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
			Контекст названия фильма
			</td>
			<td>
			#($$$appText(divId_"Name","","N"))#
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
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Поиск фильма в SAMPLES"))#
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

/// Результат поиска
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
		if Name="" w $$$appError("Контекст пустой") quit $$$OK
		zn "samples"
		set sql="select * from Cinema.Film where title is not null "
		if Name'="" s sql=sql_" and (title like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (Description like '%"_Desc_"%') "
		set msg="Запрос : "_sql
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

