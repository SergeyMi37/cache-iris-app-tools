Include App.LogMacro

/// Шаблон GUI приложения на основе Uikit / Simple GUI Application Template based Uikit
Class App.TabsPanelUikit Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Библиотеки javascript
Parameter JSLIB = "Uikit-3, jQueryUi-2";

/// Заголовок приложения / Application title
Parameter HeaderText = "Tabs Application title";

/// Главный метод формирования содержимого страницы
ClassMethod OnPage() As %Status
{
 set namespace=$zu(5)
 // Сохраним в параметрах сессии режим отладки (подразумевает расширенное информирование)
 set %session.Data("debug")=%request.Get("debug")
 set autoloadmenu=%request.Get("autoload")
 &html<
<html>
 <head>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
 <title>#(..#HeaderText)#</title>
>
	write ##class(App.LogInfoPane).GetLink()
	write ##class(App.LogInfoPane).AddJsScripts() 
   	   do ##class(App.LogInfoPane).AddJS(namespace,..%ClassName(1))
   	   do ##class(App.LogInfoPane).AddStyle()
   	set onclick="$('#MainBody').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=Logout&appNsp="_$zu(5)_"&appPar=Выход произведен');"
	set menu=..DrawMenu()
 &html<

</head>
<bogy>
<div id="MainBody">
<nav id=MainNavbar class="uk-navbar-container" uk-navbar>
    <div class="uk-navbar-left">
        <ul class="uk-navbar-nav">
			<li><a href="#"><span class="uk-margin-small-right uk-icon" uk-icon="album"></span></a></li>
            <li><a href="#">#(..#HeaderText)#</a></li>
            <li class="uk-active">
                <a href="#"><span class="uk-margin-small-left uk-icon" uk-icon="menu"></span> Режимы</a>
                <div class="uk-navbar-dropdown">
                    <ul class="uk-nav uk-navbar-dropdown-nav">
                    #(menu)#
                    </ul>
                </div>
            </li>
			<li><a href="#"><span id='status_nav'></span></a></li>
        </ul>
    </div>
    <div class="uk-navbar-right">
        <ul class="uk-navbar-nav">
            <li class="uk-active"><a href="#" onclick="#(onclick)#"><span class="uk-margin-small-left uk-icon" uk-icon="sign-out"></span> Выход</a></li>
        </ul>
    </div>
</nav>

<div class="uk-grid">
    <div class="uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;' id="mainApp" >
		<ul id='tabMenu' class="uk-tab uk-tab-grid uk-tab-top" data-uk-tab="{connect:'#tabList', animation: 'fade'}">
			<li id='t1' class="uk-active"><a href="#">Добро пожаловать в программу</a></li>
		</ul>
		<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
			<li id='ta1' >
			 <div class="uk-alert-success" uk-alert>
				<p> Программа шаблон для типового приложения</p>
			 </div>
			</li>
		</ul>
	</div>
</div>
>
 $$$jsstart
 	//Загрузить статус
 	write "$(document).ready(function(){"
 	write "$('#status_nav').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_namespace_"&appPar=');"
 	if autoloadmenu="" {
	 	d ..GetAllApps(.opt) 
	 	set i="" 
	 	for { set i=$o(opt(i)) q:i=""
	 		if $GET(opt(i,"Active")) write "$('#Menu"_opt(i,"id")_"').trigger('click');"
	 	}
 	} else {
	 	write "$('#Menu"_autoloadmenu_"').trigger('click');"
 	}
 	write "});"
 $$$jsstop
 
 &html< 	
 <script language="javascript">
///$( ".tip" ).tooltip();
</script>

<div id='MainHidden' style='display:none;'></div>
<div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
</div>
</div>
</body>
</html>
	>
 quit $$$OK
}

/// Получить информацию по техподдержке
ClassMethod GetSupportInfo() As %String
{
	set msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","Программный комплекс на отладке. Попробуйте войти попозже, или обратитесь тех.поддержку: ")
	quit msg_"Support info mailto: sergey.mikhaylenko@gmail.com"
}

/// отрисовка статуса пользователя
ClassMethod DrawStatus(Par) As %Status
{
 write $s(%request.Get("debug"):"<font color=red><b>Режим админа</b></font>",1:"")_" <span title='"_$username_"-"_$j_"'>Пользователь: "_##class(App.sys).GetFullName($username)_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 quit $$$OK
}

/// какие доступны режимы
ClassMethod GetAllApps(opt) As %Status
{
	;TODO права доступа к страницам
	;TODO сохранить в БД таблицы
	set key="menu-first"
	set opt(key)="Пример поиска в Samples" ;Имя меню
	set opt(key,"id")="Find"
	set opt(key,"TabName")="Пример поиска в Samples" ;имя вкладки
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabSample"
	set opt(key,"Disable")=0 ;разрабатывается
	set opt(key,"TabMenu","Close")=1

	set key="menuZ-about"
	set opt(key)="О программе"
	set opt(key,"id")="About"
	set opt(key,"TabName")="О программе"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabAbout"
	set opt(key,"Disable")=1 ;разрабатывается

	quit $$$OK
}

/// отрисовка Вкладки
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTab(Par) As %Status
{
	do ..GetAllApps(.opt) 
	set tabId="tab-"_opt(Par,"id")
	set tabIdMenu="tabMenu-"_opt(Par,"id")
	if $g(opt(Par,"TabMenu","Close"))'="" s IconMenu="<span class=""uk-margin-small-left uk-icon uk-close"" uk-icon=""close"" onclick=""$(\'#"_tabIdMenu_",#"_tabId_"\').remove();""></span>"
 	if $DATA(opt(Par,"TabMenu","Close"))>9 { //есть еще пункты
 		;TODO
 	}
 	$$$jsstart
 	 write "if (!$('li').is('#"_tabId_"')) { $('.uk-active').removeClass('uk-active');"
 		write " $('#tabList').append('<li id="_tabId_"></li>');"
 		write " $('#tabMenu').append('<li id="_tabIdMenu_"><a>"_$g(opt(Par,"TabName"))_$g(IconMenu)_"</a></li>');"
 		write " $('#t1,#ta1').hide();" //" $('#t1').prop('disabled',true);"
 		if $g(opt(Par,"Url"))'="" {
	 		write "$('#"_tabId_"').load('"_$g(opt(Par,"Url"))_"');"
 		}
 		else {
	 		write "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
 	 write "};"
 	write " UIkit.tab('#tabMenu').show($('#"_tabIdMenu_"'));"
	$$$jsstop
}

/// отрисовка меню
ClassMethod DrawMenu(Par) As %String
{
	do ..GetAllApps(.opt) 
	set i="",ret=""
	for { set i=$o(opt(i)) quit:i=""  
	   	set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
		set ret=ret_"<li><a id='Menu"_$g(opt(i,"id"))_"' href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
	}
  quit ret
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
		<p>#($g(Par))#</p>
	</div>
	<center><button class="uk-button uk-button-default uk-margin-small-right" type="button" onclick="#(onclick)#" ><span class="uk-margin-small-left uk-icon" uk-icon="sign-in"></span> Войти</button>
	</center>
</div>
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
	w "$('#"_mcont_"').height($(window).height()-($('#"_mhead_"').height()+$('#t1').height()+$('#MainNavbar').height()+200));"
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

