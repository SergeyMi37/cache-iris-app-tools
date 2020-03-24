Include App.LogMacro

/// The template GUI of the application selector and tabs
Class App.TabsPanelUikitPermissMatrx Extends App.TabsPanelUikit [ DependsOn = App.msg ]
{

/// The application title
Parameter HeaderText = "Tabs Application Matrix of Permission";

/// what are the available applications
ClassMethod GetAllApps(opt) As %Status
{
	do ##super(.opt)
	s key="AmenuMatrix"
	s opt(key)=$$$aText("The matrix","") ;The name of the menu
	s opt(key,"id")="Matrix"
	s opt(key,"TabName")=$$$aText("The matrix","") ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabItem"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1

	s key="menuUser"
	s opt(key)=$$$aText("An example of a user search","") ;The name of the menu
	s opt(key,"id")="FindUsers"
	s opt(key,"TabName")=$$$aText("The search tab users","") ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabItem"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1

	s key="menuZ-about"
	s opt(key)="About the program"
	s opt(key,"id")="About"
	s opt(key,"TabName")="About the program"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=0 ;developed
	
	s key="menu2-param"
	s opt(key)="Parameter"
	s opt(key,"id")="Param"
	s opt(key,"TabName")="Edit Parameter"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabItem"
	s opt(key,"Disable")=0
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Active")=1 ;Download the tab immediately

	q $$$OK
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabAbout(Par = "") As %Status
{

	d ..GetAllApps(.opt) 
	i $g(opt(Par,"Disable")) w ..GetSupportInfo() q $$$OK
	s divId=$g(opt(Par,"id"))
	w "Sample Program Based on jQueryUI, Uikit<br>"
	w ..ButtonAgain(divId,Par)
	;w "<pre>" w  w "</pre>"
}

/// rendering Tabs
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabItem(key = "") As %Status
{
 d ..GetAllApps(.opt) 
 i $g(opt(key,"Disable")) w ..GetSupportInfo() q $$$OK
 s NSpace=$zu(5)
 s divId=$g(opt(key,"id"))
 s mhead=divId_"MainHeader"
 s mcont=divId_"MainContent"
 &html<
<form id="#(divId_"MainForm")#">
<div class="uk-grid">
    <div class="uk-width-1-1 " style='overflow: auto;' id="#(mhead)#" ></div>
    <div class="uk-width-1-1 uk-margin-top uk-margin-bottom" style='overflow: auto;' id="#(mcont)#"></div>
</div>
</form>

>
 $$$jsstart
 	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
 	w "$('#"_mcont_"').height($(window).height()-($('#"_mhead_"').height()+$('#t1').height()+$('#MainNavbar').height()+200));"
 	;Dimming of the screen that says Download
  	w $$$blockui($$$aText("Loading...",""))
	
	;For the organization of execution by clicking on the apply button AppAct js function(From,To,Act), where
	;From - the ID of the container where will we get the items from the form method serialize
	;To - ID container where we deduce resultat run
	;AppAct=NameSpace:Packet.ClassName:Method:&Par1=Val1&Par2=Val2...
	w "AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	
 $$$jsstop
 quit $$$OK
}

/// to download a form for editing
ClassMethod ParamFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set class="App.Parameter"
	
	set sql="select * from "_class_" where Name is not null order by id desc"
	;The list of fields displayed in the Value attribute of the Option tag, 
	;The first field of the query must be an identifier
	set listFields="ID,ID,Name,Description"
	write $$$aText("Select settings","")
	s ONCHANGE=";$('#"_divId_"SelectId').attr('value',data.item.value);"
	do ##class(App.Form).SelectObj(sql,ONCHANGE,listFields,.gn,divId_"Select")
	
	write "<br>"_$$$appInputHidden(divId_"SelectId","","")_"<br>"
	
	set onclick=$$$blockui($$$aText("Loading...",""))_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&class="_class_"&mode=*');"
	write $$$appTable1(class)
	set butt1=$$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""",$$$aText("Preview mode in two columns",""))
	set butt2=$$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",2)_"""",$$$aText("Edit mode in one column",""))
	set butt3=$$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",3)_"""",$$$aText("The view mode from table",""))
	write $$$appTableTrTd1(butt1_butt2_butt3)
	write $$$appTableEnd1
	quit $$$OK
}

// The result of selecting the edit mode settings

ClassMethod ParamResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set class=Par("class")
	set SelectId=$g(Par("%request.Data",divId_"SelectId"))
	write ..ButtonAgain(divId,key)
	if mode=1 {
		;the order of the fields in two columns by the delimiter :
		set order="Name,Description:Value,Types:DateStart,DateFinish:isEnabled,isEnabledCheck:File,OfficeFile:ImageFile,ImageGlobal::,"
		do Show(0,order)
		quit $$$OK
	} 
	elseif mode=2 {
		;the order of fields by default
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
		set msg=$$$aText("Failed to open object ","")_SelectId_","_class
		write $$$appError(msg) q $$$ERROR($$$GeneralError,msg)
	}
	do ##class(App.Form).Show(obj,modeShow,divId,order)
 q
}

/// download template forms search
ClassMethod FindUsersFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")
	set onclick=$$$blockui($$$aText("Loading...",""))_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&mode=*');"
	&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
			Login
			</td>
			<td>
			#($$$appText(divId_"Name","","su"))#
			</td>
			<td>
			fullname
			</td>
			<td>
			#($$$appTextarea(divId_"fullName","rows=5",""))#
			</td>
			<td>
			Date
			</td>
			<td>
			#($$$appDate(divId_"Date","",""))#
			</td>
		</tr>
		<tr>
			<td>
			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find user"))#
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult2","onclick="""_$tr(onclick,"*",2)_"""","Get items from the form"))#
			</td>
			<td>
			#($g(fileDownload))#
			</td>
			<td>
			date time
			</td>
			<td>
			#($$$appDateTime(divId_"DateTime","",""))#
			</td>
		</tr>
		</table>
	>
	q $$$OK
}

/// Search result
ClassMethod FindUsersResult(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set Name=$g(Par("%request.Data",divId_"Name"))
	set fullName=$g(Par("%request.Data",divId_"fullName"))
	set Date=$g(Par("%request.Data",divId_"Date"))
	set DateTime=$g(Par("%request.Data",divId_"DateTime"))
	write ..ButtonAgain(divId,key)
	if mode=1 {
		if Name="" w $$$appError($$$aText("Context is empty","")) q $$$OK
		zn "%SYS"
		set sql="select ID,name,EmailAddress,fullName from Security.Users where Enabled [ '1' "
		if Name'="" s sql=sql_" and (name like '%"_Name_"%') "
		if fullName'="" s sql=sql_" and (fullName like '%"_fullName_"%') "
		set msg="Query: "_sql
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

/// To obtain information on the support
ClassMethod GetSupportInfo() As %String
{
	s msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","")
	q msg_"Support info mailto: sample@server.com"
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")
	s %ui=1
	set onclick=$$$blockui($$$aText("Loading...",""))_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&mode=*');"
	&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
 	Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
			</td>
			<td>
	Roles <br>#($$$appText(divId_"roles","title='"_$$$aText("Roles separated by a comma or by context","")_"'","db"))#
			</td>
			<td>
	#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""",""_$$$aText("User roles","")))#
			</td>
		</tr>
		</table>
	>
	q $$$OK
}

/// Search result 
ClassMethod MatrixResult(Par = "") As %Status
{
	s %ui=1
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set name=$g(Par("%request.Data",divId_"name"))
	set roles=$g(Par("%request.Data",divId_"roles"))
	write ..ButtonAgain(divId,key)
	d ##class(App.security).UiMatrixPermission(name,roles,divId,key,"App.security","UiSavePermiss")
	q $$$OK
}

}

