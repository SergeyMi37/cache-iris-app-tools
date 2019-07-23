Include App.LogMacro

Class App.LogInfo Extends App.AutoPage
{

Parameter CSPURL = "App.LogInfo.cls";

Parameter PAGENAME = "App.Tools";

Parameter PARENTPAGE = "App.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(App.LogInfoPane).%New()
}

/// Получить INPUT кнопку для очистки полей формы
/// fields - имена полей через запятую
/// w ##class(App.LogInfo).ClearFields("a,b")
ClassMethod ClearFields(fields = "", onclick)
{
	;set res="<input type=button name='clearFields' id='clearFields' onclick=""#"" value=X title='Очистить поля'>"
	set res="<span class='ui-icon ui-icon-trash' name='clearFields' id='clearFields' onclick=""#"" title='Очистить поля'></span>"
	for f=1:1:$l(fields,",") {
		continue:$p(fields,",",f)=""
		s onclick=$g(onclick)_"try{document.getElementById('"_$p(fields,",",f)_"').value=''}catch(e){};"
	}
	quit $replace(res,"#",$g(onclick,"alert('Нет полей');"))
}

/// Пометить красным контекст в исходной строки
/// Source - Исходная строка
/// Mark - контекст для пометки через запятую
/// w ##class(App.LogInfo).MarkRed("ssssazzzzbssss","a,b")
ClassMethod MarkRed(Source, Mark)
{
	set res=Source
	for f=1:1:$l(Mark,",") {
		continue:$p(Mark,",",f)=""
		s res=$replace(res,$p(Mark,",",f),"<font color=red>"_$p(Mark,",",f)_"</font>")
	}
	quit res
}

/// Включить в строку обрамление тэга
/// Source - Исходная строка
/// Mark - контекст из фраз для вставки это список
/// TagBeg, TagEnd - обрамление тэга для каждой фразы должен быть свой, список
/// w ##class(App.LogInfo).IncludTags("ssssazzzzbssss","a,b",")
ClassMethod IncludTags(Source, Mark, TagBeg, TagEnd)
{
	set res=Source
	for f=1:1:$ll(Mark) {
		continue:$lg(Mark,f)=""
		s res=$replace(res,$lg(Mark,f),$lg(TagBeg,f)_$lg(Mark,f)_$lg(TagEnd,f))
	}
	quit res
}

/// Получить набор инпут элементов для выгрузки потока в ексель и посылки по почте
/// w ##class(App.LogInfo).GetInputXLSTags()
/// Выгрузить в XLS <input type="checkbox" name="exportXLS" id="exportXLS" #($s($g(exportXLS):"checked",1:""))#>
ClassMethod GetInputXLSTags(exportXLS, exportXLSfile, exportXLSfileEmail)
{
 &html<
 Выгрузить в XLS <input type="checkbox" name="exportXLS" id="exportXLS" >
 В файл <input type="text" size=30 name="exportXLSfile" id="exportXLSfile" value="#($g(exportXLSfile))#">
 и послать на <input placeholder="email@mail.com,email2@mail.com" type="text" size=30 name="exportXLSfileEmail" id="exportXLSfileEmail" value="#($g(exportXLSfileEmail))#">
 >
 quit ""
}

/// Получить значения инпут элементов для выгрузки потока в ексель и посылки по почте
/// d ##class(App.LogInfo).GetInputXLSTagsVal(.exportXLS, .exportXLSfile, .exportXLSfileEmail)
ClassMethod GetInputXLSTagsVal(exportXLS, exportXLSfile, exportXLSfileEmail, SDNum)
{
	set:$d(%request) exportXLSfile=%request.Get("exportXLSfile")
	if $g(exportXLSfile)="" s exportXLSfile=$$$EMAILXLSPATH_$zd($h,3)_"_"_$p($h,",",2)_".xls"
	set:$d(%request) exportXLS=%request.Get("exportXLS")["on"
	set:$d(%request) exportXLSfileEmail=%request.Get("exportXLSfileEmail")
	if $g(exportXLSfileEmail)="" s exportXLSfileEmail=$$$EMAILSUPPORT
	set:$d(%request) SDNum=%request.Get("SDNum")
	quit ""
}

/// Послать пользователю файл с сообщением
/// w ##class(App.LogInfo).SendEmail("mihaylenko_sv@mosvodokanal.ru", "Тест", "Тестовое сообщ", "c:\temp\2019-01-16_32309.xls")
ClassMethod SendEmail(supportemail = "", subj = "", msg = "", file = "") As %Status
{
		set subj="Сервер : "_$zu(110)_", "_subj
		set text="<html><head></head><body color=greay><h4>Здравствуйте</h4><br><br>"_$g(msg)
		set text=text_"</body></html>"
		// support
		if supportemail="" set supportemail=$$$EMAILSUPPORT		
		; Определение адреса
		set email=supportemail //только 
		
		; Учетка для авторизации todo - ВЗЯТЬ из параметров
		set authFrom=$$$EMAILAUTH
		set authFromPass=$$$EMAILAUTHPASS
		if file'="" {
			s slash=##class(App.files).getSlash()
			s path=$p(file,slash,1,*-1)
			s file=$lb($p(file,slash,1,*-1)_slash,$p(file,slash,*))
		}
		set sc=##class(App.net).SendMail($$$EMAILSERVERIP,$$$EMAILSERVERPORT, 0, 0, "", authFrom, authFromPass, authFrom, email_","_supportemail, subj, text,file)
		if 'sc w !,"Ошибка "_$System.Status.GetErrorText(sc) $$$AppLogTab("ERROR","()",$System.Status.GetErrorText(sc))
		else  w !,"Направлено по адресу "_email $$$AppLogTab("INFO","()","Отправление на адрес "_email_" файла "_file)
		quit sc
}

/// w ##class(App.LogInfo).GetInfoImg("tools")
ClassMethod GetInfoImg(code)
{
	quit "<a title='to tools' target=tools href=""App.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert("?","O","URL")_""">"_##class(App.LogInfo).GetImg(code)_"</a>"
}

/// w ##class(App.LogInfo).GetImg("help")
ClassMethod GetImg(code)
{
	quit:code="help" "<span class='ui-icon ui-icon-help'></span>"
	quit:code="search" "<span class='ui-icon ui-icon-search'></span>"
	;quit:code="apptools" "<img src="""_$$$PATHCSP_"jqueryui/img/apptools-ico-lofel.ico"" width=""1%""/>" 
	;quit:code="apptools" "<img src="""_$$$PATHCSP_"jqueryui/img/apptools-ico.ico"" width=""1%""/>" ;gear
	quit:code="tools" "<span class='ui-icon ui-icon-wrench'></span>" ;gear
	quit:code="trash" "<span class='ui-icon ui-icon-trash'></span>"
	quit:code="check" "<span class='ui-icon ui-icon-check'></span>"
	quit:code="closethick" "<span class='ui-icon ui-icon-closethick'></span>"
	quit ""
}

/// Export all projects to XML
ClassMethod ExportProjects(Dir, files) As %Status
{
	$$$NspGoto(curNs,"AAA")
	d ..ExportAppProj(Dir,"app",.files)
	$$$NspReturn(curNs)
	d ##class(App.net).SendFilesToEmail($zn,Dir,.files)
	q $$$OK
}

/// Export all projects to XML
/// d ##class(App.LogInfo).ExportProj("/backup/source/","app")
ClassMethod ExportAppProj(Dir, proj = "", files) As %Status
{
	s pFileName=Dir_$zu(110)_"-"_$zu(5)_"-"_proj_"-"_$tr(##class(App.type).GetDateTime($h),":T","-_")_".xml"
	w !,pFileName s files(pFileName)=""
	/*
The items to export.
Each of the items must have a type determined by an extension selected from the following list of basic types, additional types are supported under the abstract routine interface so this list is not exhaustive.

CLS - Classes
CSP - Cache Server Pages
CSR - Cache Rule files
MAC - Macro routines
INT - Non-macro routines
BAS - Basic routines
INC - Include files
GBL - Globals
PRJ - Studio projects
OBJ - Compiled object code
PKG - Package definitions
If exporting multiple items, separate them with commas, pass the items("item")="" as an array. You can also use ? or * wild cards and if you wish to exclude items pass ' before the item name which also supports wild card, e.g. "User.*.cls,'User.T*.cls".
	*/
	s list("App*.CLS")=""
	s list("App*.INC")=""
	Write $SYSTEM.OBJ.Export(.list, pFileName)
	k list
	s list("/apptools/*.*")=""
	s pFileName=Dir_$zu(110)_"-"_$zu(5)_"-"_proj_"-CSP-"_$tr(##class(App.type).GetDateTime($h),":T","-_")_".xml"
	w !,pFileName s files(pFileName)=""
}

}

