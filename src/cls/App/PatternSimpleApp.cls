Include App.LogMacro

/// Шаблон простого GUI приложения / Simple GUI Application Template
Class App.PatternSimpleApp Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Заголовок приложения / Application title
Parameter HeaderText = "Application title";

/// Префикс идентификатора контейнера
Parameter PrefixIdDIV = "Exp";

/// Главный метод формирования содержимого страницы
ClassMethod OnPage() As %Status
{
 s NSpace=$zu(5)
 // Сохраним в параметрах сессии режим отладки (подразумевает расширенное информирование)
 s %session.Data("debug")=%request.Get("debug")
 &html<
 <html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>#(..#HeaderText)#</title>
<script src="/csp/spgz/jqueryui/external/jquery/jquery.js"></script>
<script src="/csp/spgz/jqueryui/jquery-ui.js"></script>
<script src="/csp/spgz/jqueryui/jquery.blockui.js"></script>

<!-- Контрол Множественного выбора -->
<script src="/csp/spgz/jqueryui/selectize.js"></script>
<link rel="stylesheet" type="text/css" href="/csp/spgz/jqueryui/selectize.default.css"/>

<link rel="stylesheet" type="text/css" href="/csp/spgz/jqueryui/css/main.css"/>
<link href="/csp/spgz/jqueryui/jquery-ui.css" rel="stylesheet">
<link rel="icon" href="/favicon.ico" type="image/x-icon"/>
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
 <style type="text/css">

</style>
</head>
<body>
 <div id="MainBody">
  <nav style='background: #d7ebf9;' > 
    &nbsp;&nbsp;&nbsp;  
    	<img  title='заголовок' style='vertical-align: middle;' src="???.png" />  &nbsp;&nbsp;&nbsp; 
 	<div id="MainControlgroup" > </div>
 	<span id='status_nav'> Статус сессии </span>
 	<div id="logo" style='text-align: right;'>
 		<img  title='#(..GetSupportInfo())#' src="???.png" />
 	</div>
  </nav> 
 <div id="tabs"> </div>
</div>
>
 // Режим отладки 1
 q:..IsDebugMode(0) $$$OK
 $$$jsstart
 	;w $$$blockui("Загрузка...")
    // Загрузить доступные режимы меню
 	w "$('#MainControlgroup').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawMenu&appNsp="_NSpace_"&appPar=');"
 	//Загрузить статус
 	w "$('#status_nav').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_NSpace_"&appPar=');"
    //Загрузить табы
 	w "$('#tabs').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawTabs&appNsp="_NSpace_"&appPar=');"
 $$$jsstop
 
 &html< 	
 <script language="javascript">
$( ".tip" ).tooltip();
</script>
<div id='MainHidden' style='display:none;'></div>
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

/// Добавить на форму  js код если режим разработки
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

/// отрисовка меню
ClassMethod DrawStatus(Par) As %Status
{
	;do ##class(App.Form).BlockUI(0)
	w $s(%request.Get("debug"):"<font color=red><b>Режим админа</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"'>Пользователь: "_##class(App.MVK.EISinfo).GetFIO($username)_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 	$$$jsstart
	w "$('.tip').tooltip();"
	$$$jsstop
 q $$$OK
}

/// какие доступны режимы
ClassMethod Permiss(opt) As %Status
{
	;TODO права доступа к страницам
	;TODO сохранить в БД таблицы
	s key="zspr"
	s opt(key)="Справочники"
	s opt(key,"id")="Class"
	s opt(key,"TabName")="Справочники"
	s opt(key,"ClassName")="App.PatternSimpleApp"
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;разрабатывается

	s key="zspr2"
	s opt(key)="Справочники2"
	s opt(key,"id")="Class2"
	s opt(key,"TabName")="Справочники2"
	s opt(key,"ClassName")="App.PatternSimpleApp"
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=1 ;разрабатывается
	
	q $$$OK
}

/// отрисовка Вкладки ранее переданных
/// Par - код пункта меню из ..Permiss
ClassMethod ShowTabSample(Par = "") As %Status
{
	d ..Permiss(.opt) 
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	w "Hello world! Parameter: "_Par
	w ..ButtonAgain()
}

/// отрисовка Вкладки
/// Par - код пункта меню из ..Permiss
ClassMethod ShowTab(Par) As %Status
{
	d ..Permiss(.opt) 
	s tabId="tabs-"_opt(Par,"id")
 	$$$jsstart
 		w "var a = $('#li-"_tabId_"'); a.show();" ; откроем вкладку
 		w "var index = $('#tabs a[href=""#"_tabId_"""]').parent().index();"
		w "$('#tabs').tabs({'active':index});" ;сделаем ее активной
 		;w "alert('"_tabId_"');"
 		if $g(opt(Par,"Url"))'="" w "$('#"_tabId_"').load('AsuPriz.MVK.Export.cls');"
 		else  w "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
	$$$jsstop
}

/// отрисовка меню
ClassMethod DrawMenu(Par) As %Status
{
	
	d ..Permiss(.opt) 
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

/// отрисовка табов
ClassMethod DrawTabs(Par) As %Status
{
	d ..Permiss(.opt)
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
		;Все табы сразу скроем после инициализации, будем их открывать по мере выбора
		s i="" f { s i=$o(tabs(i)) q:i=""  
			w "var a = $('#li-"_tabs(i)_"'); a.hide();"
		}
	$$$jsstop
	q $$$OK
}

/// Вывод кнопки выхода
ClassMethod ButtonExit(formName) As %Status
{
	set onclick="$('#"_formName_"').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=Logout&appNsp="_$zu(5)_"&appPar=Выход произведен');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""","Выход")
}

/// Добавить на форму  js код
ClassMethod AddToForm() As %Status
{
	q $$$OK
}

/// Возврат в одной строке
ClassMethod Logout(Par) As %Status
{
	d ##class(App.sys).logout()
	w $$$appMsg($g(Par)) w "<br>"
	d ##class(App.Form).ButtonRef("Вход")
  	q $$$OK
}

/// Вывод кнопки Сначала для Вкладки TmcMainForm ShowTabTmc 
ClassMethod ButtonAgain() As %Status
{
   	s formName=..#PrefixIdDIV_"MainContent"
	s Method="ShowTab"_..#PrefixIdDIV
	set onclick="$('#"_formName_"').load('App.Action.cls','"_..#PrefixIdDIV_"appClass="_..%ClassName(1)_"&"_..#PrefixIdDIV_"appMethod="_Method_"&"_..#PrefixIdDIV_"appNsp="_$zu(5)_"&"_..#PrefixIdDIV_"appPar=1');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""","Сначала")
}

}

