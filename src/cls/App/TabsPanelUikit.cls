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
		<ul id='tab0' class="uk-tab uk-tab-grid uk-tab-top" data-uk-tab="{connect:'#tabslist', animation: 'fade'}">
			<li id='t1' class="uk-active"><a href="#">Добро пожаловать в программу</a></li>
		</ul>
		<ul id="tabslist" class="uk-switcher uk-margin uk-tab-content">
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
 	w "$('#status_nav').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_namespace_"&appPar=');"
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
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","Программный комплекс на отладке. Попробуйте войти попозже, или обратитесь тех.поддержку: ")
	q msg_"Support info mailto: sergey.mikhaylenko@gmail.com"
}

/// отрисовка статуса пользователя
ClassMethod DrawStatus(Par) As %Status
{
	write $s(%request.Get("debug"):"<font color=red><b>Режим админа</b></font>",1:"")_" <span title='"_$username_"-"_$j_"'>Пользователь: "_##class(App.sys).GetFullName($username)_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 q $$$OK
}

/// какие доступны режимы
ClassMethod GetAllApps(opt) As %Status
{
	;TODO права доступа к страницам
	;TODO сохранить в БД таблицы
	s key="menu-first"
	s opt(key)="Пример поиска в Samples" ;Имя меню
	s opt(key,"id")="Find"
	s opt(key,"TabName")="Пример поиска в Samples" ;имя вкладки
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;разрабатывается
	s opt(key,"TabMenu","Close")=1

	s key="menuZ-about"
	s opt(key)="О программе"
	s opt(key,"id")="About"
	s opt(key,"TabName")="О программе"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;разрабатывается
	
	q $$$OK
}

/// отрисовка Вкладки
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTab(Par) As %Status
{
	d ..GetAllApps(.opt) 
	s tabId="tab-"_opt(Par,"id")
	s tabIdMenu="tabMenu-"_opt(Par,"id")
	if $g(opt(Par,"TabMenu","Close"))'="" s IconMenu="<span class=""uk-margin-small-left uk-icon uk-close"" uk-icon=""close"" onclick=""$(\'#"_tabIdMenu_",#"_tabId_"\').remove();""></span>"
 	if $DATA(opt(Par,"TabMenu","Close"))>9 { //есть еще пункты
 		;TODO
 	}
 	$$$jsstart
 	 w "if (!$('li').is('#"_tabId_"')) { $('.uk-active').removeClass('uk-active');"
 		w " $('#ta1').after('<li id="_tabId_"></li>');"
 		;w " $('#t1').after('<li id="_tabIdMenu_"><a>"_$g(opt(Par,"TabName"))_$g(IconMenu)_"</a></li>');"
 		w " $('#tab0').append('<li id="_tabIdMenu_"><a>"_$g(opt(Par,"TabName"))_$g(IconMenu)_"</a></li>');"
 		w " $('#t1').hide();" //" $('#t1').prop('disabled',true);"
 		if $g(opt(Par,"Url"))'="" {
	 		w "$('#"_tabId_"').load('"_$g(opt(Par,"Url"))_"');"
 		}
 		else {
	 		w "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
 	 w "};"
 	w " UIkit.tab('#tab0').show($('#"_tabIdMenu_"'));"
	$$$jsstop
}

/// отрисовка меню
ClassMethod DrawMenu(Par) As %String
{
	do ..GetAllApps(.opt) 
	set i="",ret=""
	for { set i=$o(opt(i)) quit:i=""  
	   	set onclick="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar="_i_"');"
		set ret=ret_"<li><a href='#' onclick="""_onclick_""">"_$g(opt(i))_"</a></li>"
	}
  q ret
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
 	q $$$OK
}

/// Вывод кнопки Сначала
ClassMethod ButtonAgain(divId = "", key = "") As %Status
{
	s mhead=divId_"MainHeader"
	s mcont=divId_"MainContent"
	set onclick="$('#"_mcont_"').empty();AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""","Сначала")
}

/// отрисовка Вкладки О программе"
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTabAbout(Par = "") As %Status
{
	d ..GetAllApps(.opt) 
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	s divId=$g(opt(Par,"id"))
	w "Hello world! Parameter: "_Par
	w ..ButtonAgain(divId,Par)
}

/// отрисовка Вкладки ранее переданных
/// Par - код пункта меню из ..GetAllApps
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
	s key=Par("key")
	s divId=Par("divId")
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
	q $$$OK
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
		if Name="" w $$$appError("Контекст пустой") q $$$OK
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
	w "<br>"
	q $$$OK
}

}

