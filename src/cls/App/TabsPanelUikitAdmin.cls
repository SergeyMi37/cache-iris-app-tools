Include App.LogMacro

/// Шаблон GUI приложения с селектором и вкладками на основе jQueryUi / Simple GUI Application Template based jQueryUi
Class App.TabsPanelUikitAdmin Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

/// Заголовок приложения / Application title
Parameter HeaderText = "AdminTabsApplication";

/// Главный метод формирования содержимого страницы
ClassMethod OnPage() As %Status
{
 s NSpace=$zu(5)
 // Сохраним в параметрах сессии режим отладки (подразумевает расширенное информирование)
 s %session.Data("debug")=%request.Get("debug")
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
 &html<
	
<link rel="stylesheet" href="uikit-dark-admin/css/nav.css"> <!-- CSS reset -->
	
</head>
<body>
	<header class="cd-main-header">
		<a href="#" class="cd-logo">
			#(..#HeaderText)#
		</a>
		
		<div class="cd-search is-hidden">
			<form action="#0">
				<input type="search" placeholder="Search...">
			</form>
		</div> <!-- cd-search -->

		<a href="#" class="cd-nav-trigger"><span></span></a>

		<nav class="cd-nav">
			<ul class="cd-top-nav">
				<!--<li><a href="#events/calendar">Tour</a></li>
				<li><a href="#articles/comments">Support</a></li>-->
				<li class="has-children account">
					<a href="#">
						<img src="uikit-dark-admin/img/cd-avatar.png" alt="avatar">
						<span id='status_nav'></span>
					</a>
					<ul>
						<li><a href="#">My Account</a></li>
						<li><a href="#">Edit Account</a></li>
						<li><a href="#">Logout</a></li>
					</ul>
				</li>
			</ul>
		</nav>
	</header> <!-- .cd-main-header -->

	<main class="cd-main-content">
		<nav class="cd-side-nav">
			
			<ul class="uk-nav uk-nav-default">
				
				<li class="cd-label">Main</li>
				<li class="has-children overview active">
					<a href="#">Articles</a>
						<ul>
							<li><a href="#articles/new">Write a new article</a></li>
							<li><a href="#articles/manage">Manage Articles</a></li>
							<li><a href="#articles/comments">Manage Comments</a></li>
							<li><a href="#articles/categories">Manage Categories</a></li>
						</ul>
				</li>
				<li class="has-children overview">
					<a href="#">Images</a>
					
					<ul>
						<li><a href="#images/upload">Upload images</a></li>
						<li><a href="#images/gallery">Manage galleries</a></li>
						<li><a href="#images/albums">Manage albums</a></li>
						<li><a href="#images/settings">Gallery settings</a></li>
					</ul>
				</li>

			</ul>

		</nav>

		<div class="content-wrapper">
        <!-- Page Content -->
		<br />
		<br />
        <div id="page-content-wrapper uk-margin-top">
			<div class="uk-container uk-container-medium" id="content">
			
			</div>
        </div>

        <!-- /#page-content-wrapper -->
		</div> <!-- .content-wrapper -->
	</main> <!-- .cd-main-content -->

<script src="uikit-dark-admin/js/main.js"></script> <!-- Resource jQuery -->

	>
 // Режим отладки 1
 q:..IsDebugMode(0) $$$OK
 $$$jsstart
 	;w $$$blockui("Загрузка...")
    // Загрузить доступные режимы меню
 	;w "$('#MainControlgroup').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawMenu&appNsp="_NSpace_"&appPar=');"
 	//Загрузить статус
 	w "$('#status_nav').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawStatus&appNsp="_NSpace_"&appPar=');"
    //Загрузить табы
 	;w "$('#tabs').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=DrawTabs&appNsp="_NSpace_"&appPar=');"
 $$$jsstop
 
 &html< 	
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

/// отрисовка статуса пользователя
ClassMethod DrawStatus(Par) As %Status
{
	;do ##class(App.Form).BlockUI(0)
	w $s(%request.Get("debug"):"<font color=red><b>Режим админа</b></font>",1:"")_" <span class='tip' title='"_$username_"-"_$j_"'>Пользователь: "_##class(App.sys).GetFullName($username)_"</span>, "_$tr(##class(App.type).GetDateTime($h),"T"," ")
 	$$$jsstart
	w "$('.tip').tooltip();"
	$$$jsstop
 q $$$OK
}

/// какие доступны режимы
ClassMethod GetAllApps(opt) As %Status
{
	;TODO права доступа к страницам
	;TODO сохранить в БД таблицы
	s key="menu-first"
	s opt(key)="Поиск" ;Имя меню
	s opt(key,"id")="Find"
	s opt(key,"TabName")="Вкладка поиска" ;имя вкладки
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;разрабатывается

	s key="menu-second"
	s opt(key)="О программе"
	s opt(key,"id")="About"
	s opt(key,"TabName")="О программе"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;разрабатывается
	
	q $$$OK
}

/// отрисовка Вкладки О программе"
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTabAbout(Par = "") As %Status
{
	d ..GetAllApps(.opt) 
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	s divId=$g(opt(Par,"id"))
	w "Hello world! Parameter: "_Par
	w ..ButtonAgain(divId,,Par)
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
  	; вычислить высоту контейнера-результата как вычетание из выстоты контейнера-таба высоту контейнера-заголовка
 	w "$('#"_mcont_"').height($('#tabs-"_pref_"').height()-$('#"_pref_"MainHeader').height()-150);"
  	w $$$blockui("Загрузка...")
	w "ActionJs('"_pref_"MainForm','"_mhead_"','','"_pref_"FirstHead','divId="_pref_"~key="_key_"');"
 $$$jsstop
 ;d ..AddToForm()
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
	write ..ButtonAgain(divId,,key)
	if mode=1 {
		if Name="" w $$$appError("Контекст пустой") q $$$OK
		zn "samples"
		set sql="select * from Cinema.Film where title is not null "
		if Name'="" s sql=sql_" and (title like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (Description like '%"_Desc_"%') "
		set msg="Запрос : "_sql
		set exec="##class(App.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_Desc_""")"
		set st=##class(App.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		quit $$$OK
	} 
	elseif mode=2 {

	}
	w "<br>"

	;i 'st  w $$$appError($System.Status.GetErrorText(st))
	q $$$OK
}

/// отрисовка Вкладки
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTab(Par) As %Status
{
	d ..GetAllApps(.opt) 
	s tabId="tabs-"_opt(Par,"id")
 	$$$jsstart
 		w "var a = $('#li-"_tabId_"'); a.show();" ; откроем вкладку
 		w "var index = $('#tabs a[href=""#"_tabId_"""]').parent().index();"
		w "$('#tabs').tabs({'active':index});" ;сделаем ее активной
 		;w "alert('"_tabId_"');"
 		if $g(opt(Par,"Url"))'="" {
	 		w "$('#"_tabId_"').load('"_$g(opt(Par,"Url"))_"');"
 		}
 		else {
	 		w "$('#"_tabId_"').load('App.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
 		}
	$$$jsstop
}

/// отрисовка меню
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

/// отрисовка табов
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

/// Вывод кнопки Сначала
ClassMethod ButtonAgain(Prefix = "", Method = "", appPar = "") As %Status
{
	i Method="" s Method="ShowTab"
	s onc="$('#MainHidden').load('App.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTab&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
	set onclick="$('#MainHidden').load('App.Action.cls','"_Prefix_"appClass="_..%ClassName(1)_"&"_Prefix_"appMethod="_Method_"&"_Prefix_"appNsp="_$zu(5)_"&"_Prefix_"appPar="_appPar_"');"
	q $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""","Сначала")
}

}

