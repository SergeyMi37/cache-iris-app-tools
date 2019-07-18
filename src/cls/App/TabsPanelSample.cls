Include App.LogMacro

/// Шаблон GUI приложения с селектором и вкладками / Simple GUI Application Template
Class App.TabsPanelSample Extends App.TabsPanel
{

/// Заголовок приложения / Application title
Parameter HeaderText = "Tabs Application Sample";

/// какие доступны приложения
ClassMethod GetAllApps(opt) As %Status
{
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
	
	s key="menu-param"
	s opt(key)="Параметры"
	s opt(key,"id")="Param"
	s opt(key,"TabName")="Редактировать параметры"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0
	q $$$OK
}

/// отрисовка Вкладки О программе"
/// Par - код пункта меню из ..GetAllApps
ClassMethod ShowTabAbout(Par = "") As %Status
{
	d ..GetAllApps(.opt) 
	$$$AppLogTab("INFO","Загрузка файла","d:\!\wwww.txt")
	w "<pre>" w  w "</pre>"
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	s divId=$g(opt(Par,"id"))
	w "Hello world! Parameter: "_Par
	w ..ButtonAgain(divId,,Par)
}

/// отрисовка Вкладки
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
    <div class="uk-width-1-1 " style='overflow: auto;' id="#(mhead)#" ></div>
    <div class="uk-width-1-1 uk-margin-top uk-margin-bottom" style='overflow: auto;' id="#(mcont)#"></div>
</div>
</form>

>
 $$$jsstart
 	;Для вкладки Param изменим высоту контейнера
 	;if pref="Param" w "$('#"_pref_"MainHeader').height($('#tabs-"_pref_"').height());"
 	; вычислить высоту контейнера-результата как вычетание из выстоты контейнера-таба высоту контейнера-заголовка
 	w "$('#"_pref_"MainContent').height($('#tabs-"_pref_"').height()-$('#"_pref_"MainHeader').height()-150);"
  	;w "console.log($('#"_pref_"MainHeader').height());"
  	;Затемнение экрана с надписью Загрузка
  	w $$$blockui("Загрузка...")
	
	;Для организации выполнения по клику на кнопке применяем js функцию AppAct(From,To,Act), где
	;From - ид контейнера откуда возьмем элементы с формы методом serialize
	;To - ид контнейнера куда будем выводить резльтат выполнения
	;AppAct=NameSpace:Packet.ClassName:Method:&Par1=Val1&Par2=Val2...
	w "AppAct('"_pref_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_pref_"FirstHead:&divId="_pref_"&key="_key_"');"
	
 $$$jsstop
 quit $$$OK
}

/// загрузить форму редактирования
ClassMethod ParamFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set class="App.Parameter"
	
	set sql="select * from "_class_" where Name is not null order by id desc"
	;Список полей выводимых в атрибуте Value тага Option, 
	;Первое поле из запроса - должно быть идентификатором
	set listFields="ID,ID,Name,Description"
	write "Выберите параметров:"
	s ONCHANGE=";$('#"_divId_"SelectId').attr('value',data.item.value);"
	do ##class(App.Form).SelectObj(sql,ONCHANGE,listFields,.gn,divId_"Select")
	
	write "<br>"_$$$appInputHidden(divId_"SelectId","","")_"<br>"
	
	set onclick=$$$blockui("Ждите...")_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&class="_class_"&mode=*');"
	write $$$appTable1(class)
	set butt1=$$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Режим просмотра в две колонки")
	set butt2=$$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",2)_"""","Режим редактирования в одну колонку")
	set butt3=$$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",3)_"""","Режим просмотра из таблицы, редактирования из окна")
	write $$$appTableTrTd1(butt1_butt2_butt3)
	write $$$appTableEnd1
	quit $$$OK
}

// Результат выбора режима редактирования параметров

ClassMethod ParamResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set class=Par("class")
	set SelectId=$g(Par("%request.Data",divId_"SelectId"))
	write ..ButtonAgain(divId,,key)
	if mode=1 {
		;порядок вывода полей в две колонки по разделителю :
		set order="Name,Description:Value,Types:DateStart,DateFinish:isEnabled,isEnabledCheck:File,OfficeFile:ImageFile,ImageGlobal::,"
		do Show(0,order)
		quit $$$OK
	} 
	elseif mode=2 {
		;порядок вывода полей по умолчанию
		set order=""
		do Show("1,ShowFieldName",order)
		quit $$$OK
	} 
	elseif mode=3 {
		set sql="select * from "_class
		set exec="##class(App.FormExplorer).WinEditObj(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
		set st=##class(App.FormExplorer).SelectObjects(class,sql,exec)
		;write 'st w $$$appError($System.Status.GetErrorText(st)) 
	}
	q $$$OK
Show(modeShow,order)
	set obj=##class(App.Form).GetObj(SelectId_","_class)
	if '$isobject(obj) { 
		set msg="Не удалось открыть объект "_SelectId_","_class
		write $$$appError(msg) q $$$ERROR($$$GeneralError,msg)
	}
	do ##class(App.Form).Show(obj,modeShow,divId,order)
 q
}

/// загрузить шаблон формы поиска
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")

	set onclick=$$$blockui("Ждите...")_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&mode=*');"
	
	s fullPath="/opt/isc/ensemble/csp/spgz/template/samples-order-MSW-.docx"
	if ##class(App.DownloadCSP).GetFileId(fullPath,.url) {
		set fileDownload="<a href="""_url_"&log=App.Log"">fileDownload</a>"
	}
	&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
			Логин
			</td>
			<td>
			#($$$appText(divId_"Name","","su"))#
			</td>
			<td>
			Полное имя
			</td>
			<td>
			#($$$appTextarea(divId_"fullName","rows=5",""))#
			</td>
			<td>
			Дата
			</td>
			<td>
			#($$$appDate(divId_"Date","",""))#
			</td>
		</tr>
		<tr>
			<td>
			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Поиск пользователя"))#
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",2)_"""","Получить элементы с формы"))#
			</td>
			<td>
			#($g(fileDownload))#
			</td>
			<td>
			дата и время
			</td>
			<td>
			#($$$appDateTime(divId_"DateTime","",""))#
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
	set fullName=$g(Par("%request.Data",divId_"fullName"))
	set Date=$g(Par("%request.Data",divId_"Date"))
	set DateTime=$g(Par("%request.Data",divId_"DateTime"))
	write ..ButtonAgain(divId,,key)
	if mode=1 {
		if Name="" w $$$appError("Контекст пустой") q $$$OK
		zn "%SYS"
		set sql="select ID,name,EmailAddress,fullName from Security.Users where Enabled [ '1' "
		if Name'="" s sql=sql_" and (name like '%"_Name_"%') "
		if fullName'="" s sql=sql_" and (fullName like '%"_fullName_"%') "
		set msg="Запрос : "_sql
		set exec="##class(App.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_fullName_""")"
		set st=##class(App.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		if 'st  w $$$appError($System.Status.GetErrorText(st)) 
		quit $$$OK
	} 
	elseif mode=2 {
		w "<br>" w $$$appMsg(Name_" "_fullName_" "_Date_" "_DateTime)
	}
	q $$$OK
}

/// Добавить на форму  js код
ClassMethod AddToForm() As %Status
{
	q $$$OK
}

/// Получить информацию по техподдержке
ClassMethod GetSupportInfo() As %String
{
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","Программный комплекс на отладке. Попробуйте войти попозже, или обратитесь тех.поддержку: ")
	q msg_"Support info mailto: sample@server.com"
}

}

