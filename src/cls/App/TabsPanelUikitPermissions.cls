Include App.LogMacro

Class App.TabsPanelUikitPermissions Extends App.TabsPanelUikitAdmin [ ClassType = "", ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Permissions";

/// Global Name Store Referens files
Parameter GNStore = "^App.Permissions";

Parameter AppRoles = "ui_Permissions";

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	if ..IsPermiss("%All") {	
	s LeftMenuName="Permission",LeftMenuNumer=1
	s key="MenuMatrix"
	s opt(key)=$$$aText("The matrix","") ;The name of the menu
	s opt(key,"id")="Matrix"
	s opt(key,"TabName")=$$$aText("The matrix","") ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(LeftMenuNumer,LeftMenuName,1) ;$lg(,3)=1 - level 1 open menu
	s opt(key,"Active")=1 ;active menu item

	s LeftMenuName="Account",LeftMenuNumer=99
	
	s key="menu-top-account3"
		s opt(key)="Exit"
		s opt(key,"id")="AccountExit"
		s opt(key,"TabName")="Logoit" 
		s opt(key,"ClassName")=..%ClassName(1)
		s opt(key,"Method")="Logout"
		s opt(key,"MenuTop")=$lb(LeftMenuNumer,LeftMenuName) ; 99-account has nested items
		
	}
	q $$$OK
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")
	s %ui=1
	;set onclick=$$$blockui($$$aText("Loading...",""))_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&mode=*');"
	set onclick=$$$blockui("Load...")_";"_##class(App.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"

	&html<
		<table>
		<tr>
			<td>
 	Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
			</td>
			<td>
	Roles <br>#($$$appText(divId_"roles","title='"_$$$aText("Roles separated by a comma or by context","")_"'","d"))#
			</td>
			<td> <br>
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

	;Geting elements from form and prepare array Par
	s name=##class(App.Action).GetElemForm(%request,.Par,divId_"name")	
	set roles=$g(Par("%request.Data",divId_"roles"))


	write ..ButtonAgain(divId,key)
	d ##class(App.security).UiMatrixPermission(name,roles,divId,key,"App.security","UiSavePermiss")
	q $$$OK
}

}

