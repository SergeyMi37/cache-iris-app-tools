Include App.LogMacro

Class App.LogInfoPane Extends %CSP.Util.Pane [ DependsOn = App.msg ]
{

ClassMethod GetLink()
{
	if $$$JSLibLocal {
	s link="<link type=""text/css"" rel=""stylesheet"" href="""_$$$PATHCSP_"jqueryui/jsgrid/jsgrid.min.css"" />"_$c(13,10)_
			"<link type=""text/css"" rel=""stylesheet"" href="""_$$$PATHCSP_"jqueryui/jsgrid/jsgrid-theme.min.css"" />"_$c(13,10)_
			"<link type=""text/css"" rel=""stylesheet"" href="""_$$$PATHCSP_"uikit/css/uikit.min.css""/>"
		q " <link href="""_$$$PATHCSP_"jqueryui/jquery-ui.css"" rel=""stylesheet"">"_link_$c(13,10)
	} else {
	s link="<link type=""text/css"" rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.css"" />"_$c(13,10)_
			"<link type=""text/css"" rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid-theme.min.css"" />"_$c(13,10)_
			"<link type=""text/css"" rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/uikit/3.3.6/css/uikit.min.css""/>"
		q " <link href=""https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.css"" rel=""stylesheet"">"_link_$c(13,10)
	}
}

/// Add libraries and functions js to the panel
/// write ##class(App.LogInfoPane).AddJsScripts() 
ClassMethod AddJsScripts(mode)
{
	if $$$JSLibLocal {
	set scr="<script src="""_$$$PATHCSP_"jqueryui/external/jquery/jquery.js""></script>"_$c(13,10)_
			"<script src="""_$$$PATHCSP_"jqueryui/jquery-ui.js""></script>"_$c(13,10)_
			"<script src="""_$$$PATHCSP_"uikit/js/uikit.min.js""></script>"_
			"<script src="""_$$$PATHCSP_"uikit/js/uikit-icons.min.js""></script>"_
			"<script src="""_$$$PATHCSP_"uikit/js/asuikit-icons-material-all.min.js""></script>"_
			"<script src="""_$$$PATHCSP_"jqueryui/jquery.blockui.js""></script>"_$c(13,10)
			set:$g(mode)["grid" scr=scr_"<script type=""text/javascript"" src="""_$$$PATHCSP_"jqueryui/jsgrid/jsgrid.min.js""></script>"_$c(13,10)
			set:$g(mode)["chart" scr=scr_"<script type=""text/javascript"" src="""_$$$PATHCSP_"jqueryui/chart.js""></script>"_$c(13,10)
		q scr_$c(13,10)
	} else {
	set scr="<script src=""https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js""></script>"_$c(13,10)_
			"<script src=""https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js""></script>"_$c(13,10)_
			"<script src=""https://cdnjs.cloudflare.com/ajax/libs/uikit/3.1.6/js/uikit.min.js""></script>"_
			"<script src=""https://cdnjs.cloudflare.com/ajax/libs/uikit/3.1.6/js/uikit-icons.min.js""></script>"_
			"<script src=""https://cdnjs.cloudflare.com/ajax/libs/jquery.blockUI/2.70/jquery.blockUI.min.js""></script>"_$c(13,10)_
			"<script src=""https://cdn.asuikit.com/asuikit-material-icons/js/asuikit-icons-material-all.min.js""></script>"
			set:$g(mode)["grid" scr=scr_"<script type=""text/javascript"" src=""https://cdnjs.cloudflare.com/ajax/libs/jsgrid/1.5.3/jsgrid.min.js""></script>"_$c(13,10)
			set:$g(mode)["chart" scr=scr_"<script type=""text/javascript"" src=""https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.min.js""></script>"_$c(13,10)
		q scr_$c(13,10)
	}
}

/// add javascript
/// /// /*! \example d ##class(App.LogInfoPane).AddJS("MSW")*/
ClassMethod AddJS(ns = "", class = "")
{
 	$$$jsstart	
 &js<	
$('#tWHAT').keydown(function (e) {
  	if (e.ctrlKey && e.keyCode == 13) {
    // Ctrl-Enter pressed
    document.getElementById('WHAT').value=document.getElementById('tWHAT').value;
    document.forms['loginfo'].submit();
   }
});
// 
function ActionJs(FormId,ResultId,appClass,appMethod,appPar,appNsp){
	var $data =[];
	;var appNspace ='#(ns)#';
	;if (!appNsp) {appNsp =appNspace;}
	var classname ='#(class)#';
	if (!appClass) var appClass =classname;
	if (FormId) {
		$data = $('#'+FormId).serializeArray(); 
		//alert(FormId);
	}
	//Add to array
	$data.push({name:"appClass",value:appClass});
	$data.push({name:"appMethod",value:appMethod});
	$data.push({name:"appNsp",value:appNsp});
	$data.push({name:"appPar",value:appPar});
	$.ajax({
	  url: 'App.Action.cls',
	  type: 'post',
	  data: $data,
	  crossDomain: true,
	  success: function(result) {
	  if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
function AppAct(FormId,ResultId,appAct){
	var $data =[]; //json array initialization
	$data.push({name:"params",value:{}});
	if (FormId) { //if the form id is specified, then we collect all input elements from it
		// elements must have an id attribute matching the name.
		// For example <input type='text' id='elem2' name='elem2'>
		$data = $('#'+FormId).serializeArray();
	}
	$data.push({name:"appAct",value:appAct}); //add execution parameters that will be parsed in App.Action.cls
	//if (jsonExt) {
	//  if there is additional json, then add it
	//	$data.push({"jsonExt":jsonExt});
	//	}
	//var url1='App.Action.cls';	if (url2) { url1=url2;}
	//execute an asynchronous request to the App.Action.cls
	$.ajax({  
	  url: 'App.Action.cls',
	  type: 'post',
	  data: $data,
	  success: function(result) {  // if successful
	  	// if the resulting container is specified, put everything sent from the server into it
	  	if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
//     namespace:routine:label:par1=val1&par2=val2...&parX-valX
function AppRpc(FormId,ResultId,appAct,url,json){
	var data ={"jsonrpc":"2.0",params:{}};
	
	if (FormId) {
		data.params.formId=FormId;
		data.params.form=JSON.stringify($('#'+FormId).serializeArray());
	}
	if (json) {
		data.params.json = json;
	}

	data.method=appAct;
	$.ajax({
	  url: url,
	  type: 'post',
	  contentType:'application/json; charset=UTF-8',
	  dataType:'html', 
	  crossDomain: true,
	  data: JSON.stringify(data),
	  success: function(result) {
	  if (ResultId) {
		  $('#'+ResultId).html(result);
	  }
	  else {
		  return result;
	  	}
	  }
	});
}

// The function of opening the dialog box
function WinOpen(ns,classname,met,el,title,rest) {
	
	var titlename="Method "+met+" parameter "+decodeURIComponent(el);
	if (title) {titlename=title;}

	//$("#dialogContent").load("App.Action.cls","appClass="+classname+"&appMethod="+met+"&appNsp="+ns+"&appPar="+el);
	
	if (rest) {AppRpc('anyForm','dialogContent',ns+':'+classname+':'+met+':'+decodeURIComponent(el),rest);}
	else { ActionJs('anyForm',"dialogContent",classname,met,el,ns);}
	$( "#dialog" ).dialog({
		modal: true, 
        title: titlename, 
        autoOpen: true, 
        width:window.innerWidth-200, 
        height:window.innerHeight-300,
		position: { my: 'top', at: 'top+150' },
		buttons: [
		{
			text: "Cancel",
			click: function() {
				$( this ).dialog( "close" );
			}
		}
		]
		});
	try { event.preventDefault();
	} catch (e){};
}
>
	$$$jsstop
}

/// add javascript
/// /// /*! \example d ##class(App.LogInfoPane).AddStyle()*/
ClassMethod AddStyle()
{
 &html<
 <style type="text/css">
 
 	/* https://habr.com/ru/post/453744/
table {
  overflow: hidden;
}

tr:hover {
  background-color: #ffa;
}

td, th {
  position: relative;
}
td:hover::after,
th:hover::after {
  content: "";
  position: absolute;
  background-color: #ffa;
  left: 0;
  top: -5000px;
  height: 10000px;
  width: 100%;
  z-index: -1;
}
*/

 
 /*
	div {
  max-width: 400px;
  max-height: 150px;
  overflow: scroll;
}
*/

/* Use position: sticky to have it stick to the edge
 * and top, right, or left to choose which edge to stick to: */

thead th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  top: 0;
}

tbody th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  left: 0;
}

/* To have the header in the first column stick to the left: */

thead th:first-child {
  left: 0;
  z-index: 1;
}


/* Just to display it nicely: */

thead th {
  background: #E7EBF9;

}

tbody th {
  background: #E7EBF9;

}

table {
  border-radius: 10px; 
  border: 1px solid #72a7cf
}

td,
th {
  padding: 0.5em;
}

.bigbox { 
height: 20px; width: 20px 
}
 
</style>
>
}

/// The method initializes the developer in the system
/// /// /*! \example d ##class(App.LogInfoPane).Init(,"MSW")*/
ClassMethod Init(username = {$username}, fio = "DEV")
{
	set @$$$MgtPortalSettings@($Username,"DeveloperName")=$g(fio,"DEV")
}

/// Add libraries and functions js to the panel
Method DrawHEAD(pInstance As PageInstance) As %Status
{
	write ##class(App.LogInfoPane).GetLink()
	Quit $$$OK
}

/// Drawing the form to enter information
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
	write ##class(App.LogInfoPane).AddJsScripts() 
	set $ZT="errors"
	set color="red"
	if $zu(110)["test" s color="blue" 
	set lang=%request.Get("AppLang")
	if lang'="",lang'=$g(@$$$GNEnsConf@("Language")) {
		do ##class(%MessageDictionary).SetSessionLanguage(lang) 
		set $$$SessionLanguageNode=lang 
		set @$$$GNEnsConf@("Language")=lang ;^||%Language=lang
	}
	set nsp=%request.Get("NSP")
	set what=$zstrip(%request.Get("WHAT"),"<>WC")
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)
	set Next=%request.Get("Next"),Filtr=%request.Get("Filtr")
	set:Next="" Next=1
	set MaxNode=%request.Get("MaxNode") 
	if 'MaxNode set MaxNode=$$$MAXSHOW
	if what=($$$HISTORYGN_"-") KILL @$$$HISTORYGN
	set:$e(what,*)="-" what=$e(what,1,*-1),exp="-"
	set:$e(what,*)="+" what=$e(what,1,*-1),Next="-1"
	if $p(what,"-p",2)?1n.n set exp=$p(what,"-p",2),what=$p(what,"-p")
	s (%DSN,DSN)=%request.Get("selectDSN")
	s SDNum=%request.Get("SDNum")

	//code to use when displaying tables
	s ExecuteDraw=%request.Get("ExecuteDraw") 
	s:$e(ExecuteDraw,1)="(" ExecuteDraw="##class"_ExecuteDraw_"(.%AppLogInfoVal,%AppLogInfoCol,%AppLogInfoHead,.%AppLogInfoTemp,"""_NSpace_""","""_DSN_""")"

	// Preparing variables for export to Excel
	d ##class(App.LogInfo).GetInputXLSTagsVal(.exportXLS, .exportXLSfile, .exportXLSfileEmail)
	d ..AddHistory(what,NSpace,DSN,MaxNode,Next,Filtr)
	if ($e(what,1)="^"),what'="^" {
		set gn=""
		if $e(what)="^" { set gn=what }
	}
	elseif what="?" {
		do ..GetHelp(.%help)
		// ExecuteArray = code for ison when outputting arrays
		set gn="%help",what="",Message=$$$aText("help command","")
		set ExecuteDraw="##class(App.LogInfoPane).DrawHelp(.%AppLogInfoVal,%AppLogInfoCol,%AppLogInfoHead,.%AppLogInfoTemp,"""_NSpace_""","""_DSN_""")"
	}
	#; queries and query results
	elseif ",query,result,select,s,q,r,begin,"[(","_$zconvert($p(what," ",1),"L")_",") {
			set sql=what
			i sql["p.party_id( )" s sql=$replace(sql,"p.party_id( )","p.party_id(+)")
	}
	#; SQL table query 
	elseif $e($zconvert($p(what," ",1),"L"),1,3)="log" {
		#; Delete the protocol table
		if $g(exp)="-" Do ##class(App.Log).%KillExtent() set msg=" "_$$$aText("Cleaned the protocol","")
		set (what,sql)="select * FROM App.Log order by id desc"
	}
	#; Run class methods
	elseif $p($zconvert(what,"L")," ",1)="xec" {
		s execute=$e(what,5,*)
	}
	#; Description of the class or instance of the class
	elseif $p($zconvert(what,"L")," ",1)="obj" { ;,$zconvert($e(what,1,2),"L")="##"||($zconvert($e(what,1,2),"L")="=#") {
		set classname=$p($p(what,"(",2),")",1)
		set id=$p($p(what,"%OpenId(",2),")",1) set:id[$c(34) id=$tr(id,$c(34))
		s Message=$$$aText("Class description","")_classname_"<br> "_$$$aText("An example of obtaining an array of descriptions","")_"<br>"_$zu(5)_">do ##class(App.LogInfoPane).GetClassDef("""_classname_""",,.out)"
		try { if id="" set Obj=$classmethod(classname,"%New"),id=0 
			  else  set Obj=$classmethod(classname,"%OpenId",id)
			if $isobject(Obj) {
				do ##class(App.LogInfoPane).GetClassDef(classname,Obj,.out)
	 			if $e($p(what," ",2,99))'="=" {
		 			do ##class(App.LogInfoPane).GetValueObj(Obj,.out,.out) m %obj(id)=out
	 			}
	 			else {
		 			 do ##class(App.LogInfoPane).GetValueObj(Obj,.out,.res) m %obj(id)=res
	 			}
			} else { d ##class(App.LogInfoPane).GetClassDef(classname,"",.out)
				merge %obj=out
				set:id'="" %obj="<font color=red>"_$$$FormatText($$$aText("Object with id = %1 Does not exist",""),id)_"</font>" 
			}
			set gn="%obj"
		} catch e {set gn="%err",%err=$zconvert($ze,"O","HTML")
		}
	}
	set title=$$$aText("Get help","")_" ?"
	set ver=""
	// Get a list of namespaces
	s listNs=##class(App.sys).ListNS(.info)
	s selectNS="<SELECT title="""_$$$aText("Namespace","")_""" name=""NSP"" id=""NSP""  ONCHANGE=""document.forms['loginfo'].submit();""> "
	for ns=1:1:$l(listNs,",") { continue:$p(listNs,",",ns)=""
		continue:$p(listNs,",",ns)["%ALL"
  		s selected=$select(NSpace=$p(listNs,",",ns):"selected",1:"")
  		s selectNS=selectNS_" <OPTION "_selected_" VALUE="""_$p(listNs,",",ns)_""">"_$p(listNs,",",ns)_"</OPTION>"
	}
	set listDSN=##class(App.sys).getSQLConnection(.listDSN)
	s selectNS=selectNS_"</SELECT>"
	s selectDSN="<SELECT title="""_$$$aText("DSN ODBC/JDBC","")_""" name=""selectDSN"" id=""selectDSN"" ><OPTION></OPTION> "
	for ns=1:1:$l(listDSN,",") { continue:$p(listDSN,",",ns)=""
		continue:$p(listDSN,",",ns)["%"
  		s selected=$select(DSN=$p(listDSN,",",ns):"selected",1:"")
  		s selectDSN=selectDSN_" <OPTION "_$g(selected)_" VALUE="""_$p(listDSN,",",ns)_""">"_$p(listDSN,",",ns)_"</OPTION>"
	}
	s selectDSN=selectDSN_"</SELECT>"
	
	&html<
	<!-- ui-dialog -->
	<div id="dialog" title="Dialog Title">
		<div id=dialogContent></div>
	</div>
		<form name="loginfo" id="loginfo">
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
				 #(##class(App.LogInfoPane).GetSysinfo(color,"utl"))#
				 <a target='ccons' name='ccons' href='#("/csp/sys/op/UtilSysConsoleLog.csp#bottom")#' id='Param'>#($$$aText("Console log",""))#</a>
				 <a target='TabsPM' name='TabsPM' href='#("App.TabsPanelUikitPermissMatrx.cls?autoload=Matrix")#' title='#($$$aText("Sample Application Access Matrix",""))#' id='Param'>#($$$aText("Access Matrix",""))#</a>
			</td>
		</tr>
		<tr>
			<td>
				#(selectNS)# #(selectDSN)#
				 | <a name='Hist' href='#("App.LogInfo.cls?NSP="_$zu(5)_"&Next=-1&WHAT="_$zconvert($$$HISTORYGN,"O","URL")_"")#' id='Hist'>#($$$aText("History",""))#</a>
				 | <a target='Explore' name='Explore' href='#("App.FormExp.cls?NSP="_$zu(5))#' id='Explorer'>#($$$aText("Selection Classes",""))#</a>
				 | <a target='ExploreTab' name='ExploreTab' href='#("App.FormExp.cls?panel=AccordionExp&NSP="_$zu(5))#'  id='ExplorerTab'>#($$$aText("Explorer tables",""))#</a>
				 | <a target='Param' name='Param' href='#("App.FormExp.cls?NSP="_$zu(5)_"&SelClass=App.Parameter")#' title='#($$$aText("Go to the options table",""))#' id='Param'>#($$$aText("Parameters",""))#</a>
				 | <a target='Tabs' name='Tabs' href='#("App.TabsPanelSample.cls")#' id='Param'>#($$$aText("Sample Tabs Application",""))#</a>
				 
				 | <a target='Chart' name='Chart'  id='Chart' href='#("App.Chart.cls?panel=class(App.ChartPanel).ChartDbSize&NSP="_$zu(5))#'>#($$$aText("Database growth Chart",""))#</a>
				 | <a target='ChartAlert' name='ChartAlert'  id='ChartAlert' href='#("App.Chart.cls?panel=class(App.ChartPanel).ChartAlert&NSP="_$zu(5))#'>#($$$aText("Event Chart",""))#</a>
 			 | 
 			</td>
		</tr>
		<tr> 
			<td>
				#($$AddExp(title,what,$g(Next),$g(Filtr),$g(MaxNode)))#
			</td>
		</tr>
			#(##class(App.LogInfoPane).AddProdQuery($g(SDNum)))#
		<tr>
			<td>
				<span class='ui-icon ui-icon-play' name="show" id="show" onclick="document.forms['loginfo'].submit();" >#($$$aText("Execute",""))#</span>
				<input type="submit" name="show2" id="show2" value='#($$$aText("Execute",""))#'>
				#(##class(App.LogInfo).GetInfoImg("help"))# 
	 			#(##class(App.LogInfo).ClearFields("NSP,MaxNode,Filtr,Next,WHAT,tWHAT,exportXLS,exportXLSfile,exportXLSfileEmail,selectDSN,SDNum"))# 
		 		#($$$aText("Upload to file Excel",""))#  
		 		<input type="checkbox" name="exportXLS" id="exportXLS" #($s($g(exportXLS22222):"checked",1:""))#>
				<input type="text" size=30 name="exportXLSfile" id="exportXLSfile" value="#($g(exportXLSfile))#">
				#($$$aText("and send to",""))# 
				<input placeholder="email@mail.com,email2@mail.com" type="text" size=30 name="exportXLSfileEmail" id="exportXLSfileEmail" value="#($g(exportXLSfileEmail))#">
			</td>
		</tr>
		<tr> 
			<td>
				#($$$DRAWAllApp)#
			</td>
		</tr>	
		</table>
		</form>
	>
	d ##class(App.LogInfoPane).AddJS(NSpace) 
	if $g(execute)'="" {
		write "<H3>"_$$$aText("Executing the command","")_" "_execute_"</H3>"
		x execute
		q $$$OK
	}
	if what="trm" {
		if ##class(App.sys).ClassExist("WebTerminal.Engine") {
			write !,"<iframe style='width:95%; height:70%' id='terminal"_NSpace_"' src='/terminal/?ns="_NSpace_"&clean=1' ></iframe>"
		}
		quit $$$OK
	}
	#; Post request
	if $p($zconvert(what,"L")," ",1)="post" {
		set posturl=$p($p(what," ",2,*),$C(13,10),1)
		set server=$p(posturl,"/",3)
		if $p(server,"@")'="" set user=$p($p(server,"@"),":"),pass=$p($p(server,"@"),":",2),server=$p(server,"@",2)
		set postbody=$p($p(what," ",2,*),$C(13,10),2,*)
		s st=##class(App.net).PostHttp(server, $p($p(posturl,"/",4,*),"?"),user ,pass ,postbody,.out)
		w st w "<pre>" zw:$d(out("Data")) out("Data") w "</pre>" q $$$OK
	}
	if $p($zconvert(what,"L")," ",1)="get" {
		set url=$p($p(what," ",2,*),$C(13,10),1)
		s st=##class(App.net).GetHttp(url,.out)
		w "<pre>" zw out w ! if $d(out("content")) { while '(out("content").AtEnd) { w $zconvert(out("content").ReadLine(),"O","HTML") }} w "</pre>" q $$$OK
	}

	$$$SDNum
	
	set obj=""
	#; arbitrary query
	if $g(sql)'="" {
		if DSN'="" {
			set gnTemp=$na(@$$$TEMPORYGN@($username))
			KILL @gnTemp
			if $G(listDSN(DSN))'="" set st=##class(App.sys).SaveGateway(sql,$G(listDSN(DSN)),%request.Get("User"),%request.Get("Password"),gnTemp,MaxNode) 
			else  set st=##class(App.sys).SqlToDSN(sql,DSN,gnTemp,MaxNode)
			if $d(@gnTemp) {
				set st=..DrawSQL("result "_gnTemp,MaxNode,NSpace,"DSN: "_DSN_", Query: <br>"_$g(sql),$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
			}
		}
		else {
			if exportXLS=1 { ;Running in the background
				job ..DrawSQL(sql,MaxNode,NSpace,"NameSpace: "_NSpace_" "_$g(msg),$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))::1
				if $T W $$$aText("The request will be executed in the background","") s st=1
			} else {
				set st=..DrawSQL(sql,MaxNode,NSpace,"Namespace: "_NSpace_" "_$g(msg),$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
			}
		}
		if $$$ISERR(st) write "<br>Error :"_##class(%CSP.Page).EscapeHTML(sql_"; "_$SYSTEM.OBJ.DisplayError(st))_"<br>"
	}
	#; If the output of Global
	elseif $G(gn)'="" {
		s a=$lb(gn,MaxNode,NSpace,Next,$g(Message),$g(exp),Filtr,$g(ExecuteDraw),exportXLS,exportXLSfile,exportXLSfileEmail)
		;d ##class(App.LogInfoPane).DrawGN(a) ;debug 
		if exportXLS=1 { ;Running in the background
			job ..DrawGN(a)::1
			i $T W $$$aText("The request will be executed in the background","") s st=1
		} else {
			set st=..DrawGN(a)
		}
	}
	elseif (nsp'="")!(what'="") {
		&html<<center><b>#($$$aText("Commands not defined",""))#</b></center>>
	}
	write "<br><br>"
	quit $$$OK
  	///Extra options
AddExp(title,gn,Next="",Filtr="",MaxNode) 
	set sqlgn=..AddC1310($zconvert(gn,"O","HTML"))
	write "<textarea rows=5 cols=150 onblur=""document.getElementById('WHAT').value=document.getElementById('tWHAT').value;"" name='tWHAT' title='"_title_"' placeholder='? "_$$$aText("enter the command and","")_" Ctrl-Enter' id='tWHAT'>"_sqlgn_"</textarea>"
	write "<br><input size=80 type='hidden' name='WHAT' title='"_title_"' id='WHAT' value="""_(sqlgn)_""" placeholder='?'>"
	write " <input title="""_$$$aText("Number of nodes","")_""" type=""text"" name=""MaxNode"" id=""MaxNode"" value='"_MaxNode_"' size=""10px"" > "_
	" <input type=""hidden"" name=""Next"" id=""Next"" value='"_Next_"' size=""0px"" > "
	quit:$e(gn,1)'="^" ""
	if Next<1 set ButtNext=$$$aText("Reverse Lookup",""),NewVal=1
	else  set ButtNext=$$$aText("Direct View",""),NewVal=-1
	quit " <input type=""button"" name=""ButtNext"" id=""ButtNext"" onclick=""document.getElementById('Next').value="_NewVal_";document.forms['loginfo'].submit();"" value='"_$g(ButtNext)_"' size=""50px"" > "_
	"<input size='30px' type='text' placeholder='"_$$$aText("Filter: command argument if","")_"' name='Filtr' title='%gn - "_$$$aText("current reference global. For example:","")_" %gn[""3)""||(@%gn[""123"")' id='Filtr' value='"_Filtr_"' >"
errors
 	write !,$ze
 	quit $$$OK
}

// d ##class(App.LogInfoPane).AddC1310("")

ClassMethod AddC1310(a)
{
 q:a[$c(13)||($p(a," ")'="select") a
 f word="from","where","order","group","union" {
  	s a=$replace(a," "_word_" "," "_$c(13,10)_word_" ")
 }
 q a
}

/// d ##class(App.LogInfoPane).DrawGN(a)
ClassMethod DrawGN(a)
{
	s $lb(gn, MaxNode, NSpace, Next, Message ,exp, Filtr, ExecuteDraw, exportXLS, exportXLSfile, exportXLSfileEmail)=a
		if gn["*" {
			set mask=$e(gn,2,*)
			set ExecuteDraw="##class(App.LogInfoPane).AddRefViewEditGlob(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
		 	s sql="%SYS.GlobalQuery:NameSpaceList "_NSpace_" "_$s(mask="*":"",1:mask)
		 	s GN="^||tmpGList" k @GN
		 	d ##class(App.sys).SaveQuery(sql,GN,0)
		 	for i=1:1 { q:'$d(@GN@(sql,0,i))
		 		s nameGL=$g(@GN@(sql,0,i,1))
		 		s dir=$g(@GN@(sql,0,i,2))
		 		continue:nameGL[":"
		 		s order(nameGL)=i ;sorted
		 		s dir(dir)=$g(dir(dir))+1
		 		s dir(dir,nameGL)=i ;stored
		 	}
		 	if gn["**" {
			 	s dir="" ,query="%SYS.GlobalQuery:Size "_dir_" "_$s(mask="*":"",1:mask)
			 	s FastFlag=gn'["***"
			 	for { s dir=$o(dir(dir)) q:dir=""
			 		set s = ##class(%SQL.Statement).%New()
	 				do s.%PrepareClassQuery("%SYS.GlobalQuery","Size")
					set r = s.%Execute(dir,,mask,0,,FastFlag )
					s @GN@(sql,0,0,14)="Allocated MB"
					s:gn["***" @GN@(sql,0,0,15)="Used MB"
	 				while r.%Next() { 
						if $d(dir(dir,r.%Get("Name"))) { 
							s row=dir(dir,r.%Get("Name"))
							s @GN@(sql,0,row,14)=r.%Get("Allocated MB")
							s:gn["***" @GN@(sql,0,row,15)=r.%Get("Used MB")
							
						}
					}
			 	}
		 	}
		 	set st=..DrawSQL("result "_$na(@GN@(sql,0)),MaxNode,NSpace,"Namespace: "_NSpace_" on mask: "_mask,$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
		}
		else {
			set st=..DrawArray(gn,MaxNode,NSpace,Next,$g(Message),$g(exp),Filtr,$g(ExecuteDraw),$lb(exportXLS,exportXLSfile,exportXLSfileEmail))
		}
		q $$$OK
}

/// code for ison when outputting arrays
ClassMethod DrawHelp(Val, Col, Head, Temp, nspace, DSN)
{
	set res=Val
	if Head {
		 s %AppCol2="40%"
		 q:Col=1 ""  
		 if Col=2 {
			set res=$$$aText("Command","")
		 }
		 if Col=3 {
			set res=$$$aText("Discription","")
		 }
	}
	else {
		if Col=1 {
			set res=""
		}
		if Col=2 {
			set res=$p(Temp,"---",1)
		}
		if Col=3 {
			set res=$p(Temp,"---",2)
		}
	}
	quit res
}

/// Generate active links for viewing and editing globals
ClassMethod AddRefViewEditGlob(Val, Col, Head, Temp, nspace, DSN)
{
	set res=Val
	if $g(Head) {
		if $g(Val)="Name" s Temp("Name",Col)=""
		if $g(Val)="Permission" s Temp("Permission",Col)=""
	}
	else {
		if $D(Temp("Name",Col)) {
			set %globalName=$s($e(Val,1)="%":"%25"_$e(Val,2,*),1:Val)
			if $g(%globalName)[":" q res
			set href="App.LogInfo.cls?NSP="_nspace_"&selectDSN=&WHAT=^"_Val
			set res=$replace(Val,Val,"<a title='viewGlob' target='viewGlob' href='"_href_"'>"_Val_"</a>")
		}
		if $D(Temp("Permission",Col)) {
			if $g(%globalName)[":" q res
			set:Val["R" href2="<a title='View' target='View' href=""/csp/sys/exp/UtilExpGlobalView.csp?$ID2="_%globalName_"&$NAMESPACE="_nspace_""">R</a>"
			set:Val["W" href3="<a title='Edit' target='Edit' href=""/csp/sys/exp/UtilExpGlobalDrill.csp?$ID2="_%globalName_"&$NAMESPACE="_nspace_""">W</a>"
			set res=$g(href2)_$g(href3)
		}
	}
	quit res
}

/// Output a list of array elements
/// set st=##class(App.LogInfoPane).DrawArray(res,100,$zu(5),"Output a list 1111")
ClassMethod DrawArray(gn As %String = "", MaxNode = {$$$MAXSHOW}, NSpace = "", Next = "1", msg = "", exp = "", Filtr = "", Execute = "", fileXLS = "") As %Status
{
		; Check if there is a record of the stack
		if $e(gn,1,4)=($$$logdevGN)||($e(gn,1,6)=("^mtemp"))||($e(gn,1,4)="^tmp") {
			if $e($g(exp))="-" {
				set:gn[$$$logdevGN stackGN=($$$logdevGN)_$e(gn,5,7)_"stack"
				set:gn["mtemp" stackGN=("^mtemp")_$e(gn,7,9)_"stack"	
				set:gn["tmp" stackGN="astack"	
				set jo=$g(@gn@(0)) KILL @gn,exp,@stackGN set:jo @gn@(0)=jo  
			}
			#; Clean and initialize the debug isolation node
			if $g(exp)?1n.n set job=exp KILL @gn@(1) if job,$d(^$j(+job)) set @gn@(0)=+job
			if gn["stack(",$qs(gn,1)?1n.n,$g(@gn)'="",$lv(@gn) {
				;$ze,$h,$tl,$io,$j,$zu(110),stack,ipRemote
				set stack=$lfs($lg(@gn,7),"|")
				set href="href='App.LogInfo.cls?NSP="_NSpace_"&WHAT="_$na(@$replace($qs(gn,0),"stack","")@(1,$qs(gn,1)))_"'"
				set anc="<a  title='"_$$$aText("Go to the protocol node","")_"' "_href_" >"_gn_"</a>"
				&html<
				<h1>View stack : #(anc)# <font color=red>$ze:</font> #($lg(@gn,1))#<font color=red> $h: </font>#($$$LoggedDT($lg(@gn,2)))#<font color=red> $tl: </font>#($lg(@gn,3))#<font color=red> $io: </font>#($lg(@gn,4))#<font color=red> $j: </font>#($lg(@gn,5))#<font color=red>  $zu(110):</font> #($lg(@gn,6))# <font color=red> IP-Adress: </font> #($lg(@gn,8))#</h1>
				<table style="border-radius: 10px; border: 1px solid #72a7cf"  cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" ><tbody>
				<tr>
					<th align="left" width="5px">#</th>
					<th align="left" width="50px">Code Link</th>
					<th align="left" width="50px">Code string</th>
				</tr>
				>
				for line2=2:1:$ll(stack) {
					set line=$lg(stack,line2)
					try {	set code=$t(@$p(line," ")) }
					catch {	set code=""	}
					quit:code["s zsr=$zr,zsG=" ;not derive itself a trap
					&html<
					<tr>
						<td>#(line2)#</td>
						<td>#(line)#</td>
						<td>#(code)#</td>
					</tr>
					>
				}
				&html<</tbody></table>>
				set gn=$q(@gn)
			}
		} 
		if fileXLS'="",$lg(fileXLS,1) {
			d ..OpenXLSfile(fileXLS, .exportXLSfileEmail, .exportXLSfile, .io)
		}
		s num="#"
		s ref=$$$aText("reference","")
		s data=$$$aText("Data","")
		s %AppCol2="9%"
		if Execute'="" {
			s %AppLogInfoHead=1
			s %AppLogInfoTemp=data
			s num=..AddExecute(Execute,num, 1, NSpace = "",.countEx) 
			s ref=..AddExecute(Execute,ref, 2, NSpace = "",.countEx) 
			s data=..AddExecute(Execute,data, 3, NSpace = "",.countEx) 
		}
			&html<
			<h1>#($s(msg="":$$$aText("View array","")_" : "_gn_" "_$$$aText("in namespace","")_" "_$zu(5),1:msg))#</h1>
			<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" ><tbody>
			<tr>
				<th title='Edit nodes and values global' align="left" width="1%">#(num)#</th>
				<th align="left" width="#(%AppCol2)#">#(ref)#</th>
				<th align="left" width="*">#(data)#</th>
			</tr>
			>
			set (igg,ig)=gn
			set count=0,test=0
			#; The first line
			if ig'="",$g(@ig)'="",Execute="" d ..DrawNodeGN(ig,@ig,.count,,ig,$g(NSpace))
  			// For local interest arrays viewing - direct
  			set next=$s($e(gn,1)="%":1,Next["-1":-1,1:1)
  			if MaxNode<$$$MAXSHOW set MaxNode=$$$MAXSHOW
  			if $g(next)=-1 {	
  				for count2=1:1 { set ig=$q(@ig) quit:ig=""||(ig'[$e(igg,1,*-1))  set iglast=ig 
  					Quit:count2>(MaxNode*2) ##; Twice the limit
  				}
  				if $g(iglast)'="" set ig=iglast
  			}
  			if ig'="" {
	  			if next=-1 { 
	  				set NoDraw=0
		  			if $g(Filtr)'="" set NoDraw=$$ExpTestFiltr(ig,Filtr) 
		  			if $p(ig,"(",1)=$$$HISTORYGN,$g(NSpace)'="%SYS" set:$lg(@ig,2)'=$g(NSpace) NoDraw=1
		  			do:'NoDraw ..DrawNodeGN(ig,$g(@ig),.count,,ig,$g(NSpace),Execute)
	  			}
	  			for { set ig=$q(@ig,$g(next)) 
	  				quit:ig=""||(ig'[$e(igg,1,*-1))
	  				if $g(Filtr)'="" continue:$$ExpTestFiltr(ig,Filtr)
	  				set node=$e($p(ig,$e(igg,1,*-1),2),2,*)
					if $p(ig,"(",1)=$$$HISTORYGN,$g(NSpace)'="%SYS" continue:$lg(@ig,2)'=$g(NSpace)
					do ..DrawNodeGN(node,@ig,.count,$g(job),ig,$g(NSpace),Execute)
					Quit:count>MaxNode
	  			}
  			}
  			&html<</tbody></table>>
	if $g(exportXLSfile)'="" { 
		d ..CloseXLSfile(fileXLS, .exportXLSfileEmail, .exportXLSfile,.io, .count, .msg, .gn)
	}  	
	i '$d(%DrawArray) {
		$$$jsstart
		w "$('.trs').hover(function(){ " // set the function when you hover the cursor over the element and during its lead	ui-state-hover
		w "  $(this).toggleClass( 'ui-widget-content' )" 
		w " });"
		$$$jsstop
	 s %DrawArray=1
	}
  	quit $$$OK
	##; Filter conditions on a node and values
ExpTestFiltr(%gn,Filtr) set %test=0
	xecute "i '("_Filtr_") set %test=$t"   
 	quit %test
}

/// Add command history
ClassMethod AddHistory(what, NSpace, DSN, MaxNode, Next, Filtr) As %Status
{
	if $$$HISTORYGN_",?,trm,log"'[what {
		s val=$o(@$$$HISTORYGN@(""),-1),lastcmd=""
		i val'="",$lv($g(@$$$HISTORYGN@(val))) s lastcmd=$lg($g(@$$$HISTORYGN@(val)),1)
			i $g(lastcmd)'=what { // If the commands are not repeated
			s dt=$$$AppDT($h)
			set @$$$HISTORYGN@(dt)=$lb(what,NSpace,DSN,MaxNode,Next,Filtr)
		}
	}
}

/// Get global node
ClassMethod getNode(ByRef node, gn, NSpace = "") As %Status
{
	if $e(gn,1,4)=($$$logdevGN),$e(node,1)="(",$e(gn,*-4,*)'="stack" {	
		set gnSt=$$$logdevGN_$e(gn,5,7)_"stack"
		set lev2=$qs("a"_node,2)
		try {
			if lev2'="",$d(@gnSt@(lev2)) {
					set href="href='App.LogInfo.cls?NSP="_NSpace_"&WHAT="_$na(@gnSt@(lev2))_"'"
					set title=$$$aText("Show call stack","")
					try {
						set lv=@gnSt@(lev2)
						set title=title_$c(13,10)_$$$LoggedDT($lg(lv,2))
					} catch e {}
					set node=$replace(node,","_lev2_",","<a title='"_title_"' "_href_" >,"_lev2_",</a>")
			}
		} catch e {}
	}
}

/// Drawing the global node
ClassMethod DrawNodeGN(node As %String = "", val As %String = "", ByRef count, job = "", gn, NSpace = "", Execute = "") As %Status
{
	set count=count+1
	do ..getNode(.node, gn, NSpace)
	set node=..ShowCell(node,NSpace)
	if $e(gn,1,4)=($$$logdevGN) {
		if $qs(gn,3)["%%%$$LOG^%ETN" {	
			try { set d=$zd($lg(@gn,1),1),inc=$lg(@gn,2)
			} catch e { set d="",inc=""}
			set href="href='/csp/sys/op/UtilSysAppError.csp?$ID1="_$namespace_"&$ID2="_d_"&$ID3="_inc_"'"
			set title=$$$aText("Show stack and variables","")_$c(13,10)_d_" # "_inc
			set node=$replace(node,"%%%$$LOG^%ETN","<a  title='"_title_"' "_href_" >"_"%%%$$LOG^%ETN"_"</a>")
		} 
		// If there is a serialized object, then open the browse window.
		elseif $e(val,1)="{"&&($e(val,*)="}")||($e(val,1,4)="""\""{") {
			set href="style='"_$$$styleurl_"' onclick=""WinOpen('"_NSpace_"','','ShowJson','"_$zconvert(gn,"O","URL")_"','','"_##class(App.Action).WriteWinOpenREST(%request)_"');"""
			set title=$$$aText("Show formatted json","")
			set node="<a title='"_title_"' "_href_" >"_node_"</a> "
		}
		elseif $e(val,1)="<"&&($e(val,*)=">") {
			set href="style='"_$$$styleurl_"' onclick=""WinOpen('"_NSpace_"','','ShowXML','"_$zconvert(gn,"O","URL")_"','','"_##class(App.Action).WriteWinOpenREST(%request)_"');"""
			set title=$$$aText("Show","")_" XML"
			set node="<a title='"_title_"' "_href_" >"_node_"</a> "
			set val=$zconvert(val,"O","HTML")
		}
		elseif $e(val,1)="<" {
			set val=$zconvert(val,"O","HTML")
		}
	}
	#; for process detail and dashboard systems
	i job'="",val=job,node="(0)" {
		set url=$p($g(%request.CgiEnvs("HTTP_REFERER")),"/",1,3)_"/"
		set title=$$$aText("Process control","")
		set val=$replace(val,val,"<a title='"_title_"' target='process' href='"_url_"csp/sys/op/%25CSP.UI.Portal.ProcessDetails.cls?PID="_val_"&DISPLAYID=&$ID1="_val_"'>"_val_"</a>")
		set title=$$$aText("DBMS panel","")
		set val=val_" <a title='"_title_"' target='system' href='"_url_"csp/sys/op/UtilDashboard.csp?$NAMESPACE='>"_$zu(110)_"</a>"
	}
	elseif node["%AppLogId",$D(%request) {
		set url=$p($g(%request.CgiEnvs("HTTP_REFERER")),"/",1,3)_"/"
		set href="href='App.LogInfo.cls?NSP="_NSpace_"&WHAT="_$zconvert("select * from App.Log where id="_val,"O","URL")_"'"
		set node=$replace(node,"%AppLogId","<a title='Load record' "_href_">%AppLogId</a>")
	}
	else {	
		set val=..ShowCell(val,NSpace)	
	}
	set bgcolor="#c4d6d6"
	if node[",""="")" set bgcolor="white" 
	
	/// Parsing and coloring history
	if $p(gn,"(",1)=$$$HISTORYGN {
		set node=$replace(node,node,"<a href=""App.LogInfo.cls?NSP="_$lg(@gn,2)_"&Filtr="_$zconvert($lg(@gn,6),"O","URL")_"&Next="_$lg(@gn,5)_"&MaxNode="_$lg(@gn,4)_"&selectDSN="_$lg(@gn,3)_"&WHAT="_$zconvert($lg(@gn,1),"O","URL")_""" title='"_$$$aText("Load and run command","")_"'>"_node_"</a>")
		set val=$replace(val,"$lb(","$lb(<font color=red>")
		set val=$replace(val,$c(34)_","_$c(34),"</font>"_$c(34)_","_$c(34))
	}
	if Execute'="" {
		s %AppLogInfoHead=0
		s %AppLogInfoTemp=val
		s count=..AddExecute(Execute,count, 1, NSpace = "",.countEx) 
		s node=..AddExecute(Execute,node, 2, NSpace = "",.countEx) 
		s val=..AddExecute(Execute,val, 3, NSpace = "",.countEx) 
	}
	s count2="<span title='Edit' style='"_$$$styleurl_"' onclick=""WinOpen('"_NSpace_"','"_..%ClassName(1)_"','WinOpenEditNode','&node="_$zconvert(gn,"O","URL")_"','EditNode','"_##class(App.Action).WriteWinOpenREST(%request)_"');"" >"_count_"</span>"
	&html<
	<tr class=trs >
		<td align="left" >#(count2)#</td>
		<td align="left" >#(node)#</td>
		<td align="left" >#(val)#</td>
	</tr>
	>
}

/// WinOpenEditNode
ClassMethod WinOpenEditNode(Par) As %String
{
	set gn=$zconvert($g(Par("node")),"I","URL")
	if gn="" w $$$appError("Global link is empty") q
	if '$d(@gn) w $$$appError("Global node does not exist") q
	set PrefixIdDIV="WinOpenEdit"
	set Node=$$$appText(PrefixIdDIV_"Node","size=80",gn)
	set Value=@gn
	set:$lv(Value) Value=##class(%Global).Quote(Value)
	set Value=$$$appTextarea(PrefixIdDIV_"Value","rows=6 cols=80",Value)
	
	set onclick="ActionJs('"_PrefixIdDIV_"MainForm','"_PrefixIdDIV_"MainContent','"_..%ClassName(1)_"','WinOpenNodeSaveOrKill','~mode=*');"

	set bsave=$$$appButton(PrefixIdDIV_"idButtSave","onclick="""_$replace(onclick,"*","Save")_"""","Save")
	set bkill=$$$appButton(PrefixIdDIV_"idButtKill","onclick=""if (prompt('Delete you sure ?','Yes')) {"_$replace(onclick,"*","Kill")_"}""","Delete")
	&html<
	<center>
	<form id='#(PrefixIdDIV_"MainForm")#'>
		<table>
			<tr>
				<td style='text-align: right;'>Node</td>
				<td style='text-align: left;'>#(Node)#</td>
			</tr>
			<tr>
				<td style='text-align: right;'>Data</td>
				<td style='text-align: left;'>#(Value)#</td>
			</tr>
			<tr>
				<td style='text-align: right;'>#(bsave)#</td>
				<td style='text-align: left;'>#(bkill)#</td>
			</tr>
		</table>
	</form><div id='#(PrefixIdDIV_"MainContent")#'></div>
	</center>
	>
	q $$$OK
}

/// WinOpenNodeSaveOrKill
ClassMethod WinOpenNodeSaveOrKill(Par) As %String
{
	set gn=$g(Par("%request.Data","WinOpenEditNode"))
	set val=$g(Par("%request.Data","WinOpenEditValue"))
	if $g(Par("mode"))="Save" {
		s @gn=val
		w $$$appMsg("Saved") q
	}
	elseif $g(Par("mode"))="Kill" {
		k @gn	
		w $$$appMsg("Killed") q
	}
}

/// Add an active link for the terminal
ClassMethod AddExecute(Execute, data, col, NSpace = "", ByRef countEx) As %String
{
	set %AppLogInfoVal=data
	set %AppLogInfoCol=col
	try {
		xecute "set %AppLogInfoVal2="_Execute
		if %AppLogInfoVal'=%AppLogInfoVal2 set countEx=$g(countEx)+1
		set %AppLogInfoVal=%AppLogInfoVal2
	}
	catch e { w $ze}
	quit %AppLogInfoVal
}

/// Add an active link to view the class description.
ClassMethod AddClassRef(class, ByRef str, NSpace = "") As %String
{
	q:'$d(%request)
	if ##class(%Dictionary.ClassDefinition).%ExistsId(class) { 
		set url=$p($g(%request.CgiEnvs("HTTP_REFERER")),"/",1,3)_"/"
		set str=$replace(str,class,"<a title='"_$$$aText("Download class description","")_"' href='"_url_"csp/documatic/%25CSP.Documatic.cls?LIBRARY="_NSpace_"&CLASSNAME="_class_"'>"_class_"</a>")
	}
}

/// Add an active link to view a class instance.
ClassMethod AddClassId(classname, id, ByRef str, NSpace = "") As %String
{
	if ##class(%Dictionary.ClassDefinition).%ExistsId(classname) { 
		try {set Obj=$classmethod(classname,"%OpenId",id)
			if $isobject(Obj) {
				set what="obj =##class("_classname_").%OpenId("_id_")"
			}
		} catch e {	}
		quit:$g(what)=""
		set href="href='App.LogInfo.cls?NSP="_NSpace_"&WHAT="_$zconvert(what,"O","URL")_"'"
		set str=$replace(str,"_id"":"_id,"<a title='"_$$$aText("Download a class instance","")_"' "_href_">"_"_id"":"_id_"</a>")
	}
}

/// Cell drawing
ClassMethod ShowCell(str, NSpace = "") As %String
{
	set:$lv(str) str=##class(%Global).Quote(str)
	/*
	if $l(str,".")>2 {
		; TODO cycle through the line if there are a lot of classes
		if $p($p(str,"(",2),")",1)["." {
			set class=$p($p(str,"(",2),")",1)
			if class'="" d ..AddClassRef(class, .str, NSpace)
		}
	}*/
	if str["_class"":" {
			set class=$p($p(str,"_class"":",2),$c(34),2)
			set id=$p($p(str,"_id"":",2),",",1)
			if class'="" {
				if id'="" do ..AddClassId(class, id, .str, NSpace)
				else  d ..AddClassRef(class, .str, NSpace)
			}
	}
	;Add a link to go to the view stack
	elseif str["(",$e(str,1,4)=$$$logdevGN,str'["<a title" {
		set node="("_$p(str,"(",2,*)
		do ..getNode(.node, str, NSpace)
		quit $p(str,"(",1)_node
	}
	else {
		quit str
	}
	quit str
}

/// Open file XLS
ClassMethod OpenXLSfile(fileXLS, ByRef exportXLSfileEmail, ByRef exportXLSfile, io) As %Status
{
	s exportXLSfileEmail=$lg(fileXLS,3)
	s exportXLSfile=$lg(fileXLS,2)
	set io=$i
	if '##class(App.files).OpenFile(exportXLSfile,1) use io write !,$$$aText("Do not open file","")_" "_exportXLSfile quit
	use exportXLSfile	
	&html<
	<html xmlns:v="urn:schemas-microsoft-com:vml"
	xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:x="urn:schemas-microsoft-com:office:excel"
	xmlns="http://www.w3.org/TR/REC-html40">
	<head>
	<meta http-equiv=Content-Type content="text/html; charset=utf-8">
	<meta name=ProgId content=Excel.Sheet>
	<meta name=Generator content="Microsoft Excel 15">
	</head>
	<body>
	>
	quit
}

/// Close file XLS
ClassMethod CloseXLSfile(fileXLS, ByRef exportXLSfileEmail, ByRef exportXLSfile, io, count, msg, SQL) As %Status
{
	&html<	
	</body>
	</html>>
	use io close exportXLSfile
	s slash=##class(App.files).getSlash()
	s path=$p(exportXLSfile,slash,1,*-1)
	s sc=##class(App.files).zipFile(path,$p(exportXLSfile,slash,*),$p(exportXLSfile,slash,*)_".zip",path)
	if sc s exportXLSfile=exportXLSfile_".zip"
	;i 'sc ;s $$$AppL("APP","CloseXLSfile-zipFile")=$System.Status.GetErrorText(sc) 
	// Send file to e-mail
	i exportXLSfileEmail'="" {
		s sc=##class(App.LogInfo).SendEmail(exportXLSfileEmail, $$$aText("Send file","")_" "_exportXLSfile, $g(msg)_"<br> "_$$$aText("Namespace","")_" :"_$zu(5)_"<br> "_$$$aText("Query","")_": "_SQL, exportXLSfile)
		;i 'sc ;s $$$AppL("APP","CloseXLSfile-SendEmail")=$System.Status.GetErrorText(sc) 
		}
	write !,"<br><h3>"_$$$aText("Query result","")_" ("_(+count)_" "_$$$aText("lines) uploaded to file","")_" "_exportXLSfile_"</h3>"
	quit
}

/// Query table output
/// fileXLS - list of parameters for uploading to Excel and sending by mail
///  $lg(fileXLS,1) =1 flag 
/// 	s exportXLSfileEmail=$lg(fileXLS,3) - parcel addresses separated by commas, to which to send the file
/// 	s exportXLSfile=$lg(fileXLS,2) - full path to the file where to write the table
ClassMethod DrawSQL(SQL As %String = "", MaxNode = {$$$MAXSHOW}, NSpace = "", msg = "", Execute = "", fileXLS = "", Mode = "") As %Status
{
	if ($zconvert($e(SQL,1),"L")="q") {
		try { set st=1
			if $e($p(SQL," ",2,99),1,2)="##" {
				x "set %q2="_$p(SQL," ",2)
				set query=%q2
			}
			else {
				set query=##class(%Library.ResultSet).%New($p(SQL," ",2))
			}
			if $p(SQL," ",4)'="" {set st=query.Execute($p(SQL," ",3),$p(SQL," ",4))}
			elseif $p(SQL," ",3)'="" {set st=query.Execute($p(SQL," ",3))}
			else {set st=query.Execute()}
			set msg=SQL
		} catch e { 
			set errmsg=SQL_" "_$$$aText("Error","")_" "_$ze q ;$$$ERROR($$$GeneralError,msg) 
		}
		quit:'st st
		quit:$g(errmsg)'="" errmsg
	}
	elseif ($zconvert($e(SQL,1),"L")="r") {
		set resGN=$p(SQL," ",2,99)
		if '$d(@resGN) {
			set msg=SQL_" "_$$$aText("Link does not exist",""),ColCount=0
		}
		else {
			i $g(@resGN@(0))'="" {
				s ColCount=$ll(@resGN@(0)) //for local sql
			}
			else {
				 s ColCount=$o(@resGN@(0,""),-1)  //for sql via DSN
			}
		}
	}
	else {
		set query=##class(%ResultSet).%New()
		set st=query.Prepare(SQL)
		if 'st quit st
		set st=query.Execute()
		if 'st quit st
	}
	set (count)=0
	if $g(resGN)="" set ColCount=query.GetColumnCount()
	
	if fileXLS'="",$lg(fileXLS,1) {
		d ..OpenXLSfile(fileXLS, .exportXLSfileEmail, .exportXLSfile, .io)
	}

	&html<
	<h7>#($s(msg'="":msg,1:"Query: "_SQL))#</h7>
	<table style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" width="90%">
	<thead>
		<tr class=trs >
		>
	if 'Mode write "<th width=""1%"">#</th>"
	
	s %AppLogInfoHead=1 //Processing title
	For i=1:1:ColCount {
		&html<	<th width="5%">>
		set %AppLogInfoCol=i
		if $g(resGN)'="" {
			if $d(@resGN@(0,i)) {set %AppLogInfoVal=$g(@resGN@(0,i))	if $lv(%AppLogInfoVal) set %AppLogInfoVal=$lg(%AppLogInfoVal,1)
			}
			else { set %AppLogInfoVal=$lg($g(@resGN@(0)),i)
			}
		}
		else {
			set %AppLogInfoVal=query.GetColumnName(i)
		}
			if Execute'="" {
				try {
					xecute "set %AppLogInfoVal2="_Execute
					if %AppLogInfoVal'=%AppLogInfoVal2 set countEx=$g(countEx)+1
					set %AppLogInfoVal=%AppLogInfoVal2
				}
				catch e {
					set %AppLogInfoVal=$zconvert($ze,"O","HTML")
					}
			}
			else {set %AppLogInfoVal=..ShowCell(%AppLogInfoVal,NSpace)	
			}
			write %AppLogInfoVal
		&html<&nbsp;</th>>	
	}
	&html<	</tr></thead><tbody>	>
	s %AppLogInfoHead=0 //We process lines
	if $g(resGN)'="" { set i=0
		for { set i=$order(@resGN@(i))   quit:i=""
			for ii=1:1:ColCount set GetData(ii)=$s($lv($GET(@resGN@(i),"?")):$lg(@resGN@(i),ii),1:$GET(@resGN@(i,ii)))
			d qNext(.GetData) q:$g(stopWrite)
		}
	}
	else {
		while query.Next() { 
			for ii=1:1:ColCount set GetData(ii)=query.GetData(ii)
			d qNext(.GetData) q:$g(stopWrite)
		}
	}
	&html<</tbody></table>>
	if msg=" " {}
	else {
		Write !,$$$aText("Number of records found","")_" :"_+$g(count)
		if Execute'="" {
			Write !,$$$aText("Contextual changes or allotments","")_" :"_+$g(countEx)
		}
	}
	if $g(exportXLSfile)'="" { 
		d ..CloseXLSfile(fileXLS, .exportXLSfileEmail, .exportXLSfile,.io, .count, .msg, .SQL)
	}
	;Set the hover for table rows
	i '$d(%DrawSQL) {
	$$$jsstart
		w "$('.trs').hover(function(){ " // set the function when you hover the cursor over the element and during its lead	ui-state-hover
		w "  $(this).toggleClass( 'ui-widget-content' )" 
		w " });"
	$$$jsstop
	 s %DrawSQL=1
	}
	quit $$$OK
 // Handling one query string
qNext(GetData)
		set count=count+1
		write "<tr class=trs >"
		if 'Mode write "<th>"_(count)_"</th>"
		if count>MaxNode w "<th style='color:red'>... "_$$$aText("More entries","")_" "_MaxNode_"</th></tr>" s stopWrite=1 QUIT
		for ii=1:1:ColCount {	
			set %AppLogInfoVal=$g(GetData(ii))
			set %AppLogInfoCol=ii
			if Execute'="" {
				try {
					xecute "set %AppLogInfoVal2="_Execute
					if %AppLogInfoVal'=%AppLogInfoVal2 set countEx=$g(countEx)+1
					set %AppLogInfoVal=%AppLogInfoVal2
				}
				catch e {}
			}
			else {
				set %AppLogInfoVal=..ShowCell(%AppLogInfoVal,NSpace)	
			}
			if $g(exportXLSfile)'="",%AppLogInfoVal?1.N s %AppLogInfoVal="&nbsp;"_%AppLogInfoVal
			write "<t"_$s(ii=1:"h",1:"d")_">"_(%AppLogInfoVal)_"</t"_$s(ii=1:"h",1:"d")_">"	
		}
			&html<</tr> >
	quit
}

/// Get call stack
ClassMethod GetPathStack() As %String
{
	set $ECODE=""
	set Path=""
	for loop=0:1:$STACK	{
		if Path'="" set Path=Path_"~"
		set Path=Path_$case(Path,"":"",:"|")_$STACK(loop,"PLACE")
		if $l(Path)>32000 quit
	}
	set Path=$tr(Path,$c(9),"")
	quit Path
}

/// /*! \brief The method implements getting values
/// <br>\defgroup class_definition Class definition
/// <br>\ingroup class_definition
/// <br>\param in - class property description
/// <br>\param out - result of values 
/// <br>\example 	d ##class(App.LogInfoPane).GetClassDef(classname,Obj,.out)
/// <br>	 				d ##class(App.LogInfoPane).GetValueObj(Obj,.out,.res) */
ClassMethod GetValueObj(obj, in, out)
{
	set p="" for  { set p=$o(in(p)) quit:p=""
		set n="" for { set n=$o(in(p,n)) quit:n=""
			try {
				set val=$c(1,2,3)
				if p="Methods" { i n'="getname" continue:$e(n,*-2,*)'="Get"
					set val=$METHOD(obj,n)
				}
				elseif p="Parameters" { 
					set val=$PARAMETER(obj,n)
				}
				elseif p="Properties" { 
					set val=$PROPERTY(obj, n)
				}
				set:val'=$c(1,2,3) out(p,n,"=")=val
			}
			catch (e) {
			}
		}
	}
	quit $$$OK
}

/// /*! \brief Parse class description into methods and properties
/// <br>\ingroup class_definition
/// \example d ##class(App.LogInfoPane).GetClassDef("utils.Log","",.out) */
ClassMethod GetClassDef(aClassName As %String = "", doc, ByRef out, inSuper = 1)
{
	if $g(doc)'="", $isobject(doc) set aClassName=doc.%ClassName(1)
	set classDefinition=##class(%Dictionary.ClassDefinition).%OpenId(aClassName)
	if ('$isobject(classDefinition)) {
		quit $g(%objlasterror)
	}

	// class description
	set classDescription=$zstrip(classDefinition.Description,"<>W")
	set out("ClassName",aClassName)=classDescription
	if classDefinition.Super'="" {
		set out("ClassName",aClassName,"super")=classDefinition.Super
		if inSuper {
			for sup=1:1:$l(classDefinition.Super,",") {  continue:$p(classDefinition.Super,",",sup)=""
				do ..GetClassDef($p(classDefinition.Super,",",sup),,.out)
			}
		}
	}
	// description of methods
	if (classDefinition.Methods.Count()>0) {
		set key=""
		while(1) {
			set methodDefinition=classDefinition.Methods.GetNext(.key)
			quit:(key="")
			set out("Methods",methodDefinition.Name,"Description")=methodDefinition.Description
		} 
	}
	// Property descriptions
	if (classDefinition.Properties.Count()>0) {
		set key=""
		while(1) {
			set propertyDefinition=classDefinition.Properties.GetNext(.key)
			quit:(key="")
			set out("Properties",propertyDefinition.Name,"Description")=propertyDefinition.Description
			set out("Properties",propertyDefinition.Name,"Name")=propertyDefinition.Name
			set out("Properties",propertyDefinition.Name,"Type")=propertyDefinition.Type
			set out("Properties",propertyDefinition.Name,"ReadOnly")=propertyDefinition.ReadOnly
			set out("Properties",propertyDefinition.Name,"Required")=propertyDefinition.Required
			set out("Properties",propertyDefinition.Name,"Parameters")=$$$AppObJs(propertyDefinition.Parameters)
		}
	}
	// Parameter Descriptions
	if (classDefinition.Parameters.Count()>0) {
		set key=""
		while(1) {
			set parameterDefinition=classDefinition.Parameters.GetNext(.key)
			quit:(key="")
			set out("Parameters",parameterDefinition.Name,"Description")=parameterDefinition.Description
			set out("Parameters",parameterDefinition.Name,"Default")=parameterDefinition.Default
		}
	}
	q $$$OK
}

///  d ##class(App.LogInfoPane).GetSysinfo()
ClassMethod GetSysinfo(color, code = "") As %String
{
	set sys=" <a target='license' href=""/csp/sys/op/UtilDashboard.csp?$NAMESPACE=%25SYS""> "_$$$aText("System Dashboard","")_"</a>"
	set sysinfo="<font color="_color_">"_##class(App.LogInfo).GetImg("tools")_"</font> "_$$$aText("Server","")_": <font color="_color_">"_$zu(110)_"</font> "_$$$aText("NameSpace","")_": <font color="_color_">"_$zu(5)_"</font> $JOB: <font color="_color_">"_$j_"</font> "_$g(sys)
	if $$$MultiLang {
		set lang=$g(@$$$GNEnsConf@("Language"))
		if lang="" s lang=##class(%MessageDictionary).GetSessionLanguage()
		set list=##class(%MessageDictionary).GetLanguages()
		set key=$lb(""),gGN=""
		for i=1:1:list.Count() {
			s key=key_$lb(list.GetAt(i))
		}
		if 'list.Count() s key=$lb($mvv(58))
		do ##class(App.Form).SelectField(key,"document.getElementById(""AppLang"").value=this.options[this.selectedIndex].value;document.forms[""loginfo""].submit();",key,.gGN,,"ChangeLang",lang,50,1)
		set key="" for i=1:1 {q:'$DATA(gGN(i))  s key=key_gGN(i)}
		set langselect=" <input type='hidden' id='AppLang' name='AppLang'>"_key
	}
	q sysinfo_$g(langselect)
}

/// /*! \example d ##class(App.LogInfoPane)AddAction()*/
ClassMethod AddAction(nameElem = "NSP,MaxNode,Filtr,Next,WHAT,tWHAT,exportXLS,exportXLSfile,exportXLSfileEmail,selectDSN,SDNum")
{
	&html<
	<table>
	 <tr style='vertical-align: middle;' >
	   <td>
		<span class='ui-icon ui-icon-play' name="show" id="show" onclick="document.forms['loginfo'].submit();" title='#($$$aText("Execute and Show",""))#'></span>
		<input type="submit" name="show" id="show" value='#($$$aText("Execute",""))#'>
		<span class='ui-icon ui-icon-arrowreturnthick-1-w' onclick='window.history.back(); return false' title='#($$$aText("Go back",""))#'></span>
		#(##class(App.LogInfo).ClearFields(nameElem))# 
	  </td>
	  <td>
	  	#(##class(App.LogInfo).GetInfoImg("tools"))# 
	 </td>
    </tr>
   </table>
	>
	q ""
}

/// 
/// /*! \example ##class(App.LogInfoPane).AddProdQuery() */
ClassMethod AddProdQuery(SDNum, csp = "csp")
{
	&html< <tr style='vertical-align: middle;' >
	<td> | <a target="ensprod" href='#("/"_csp_"/"_$zconvert($zu(5),"L")_"/EnsPortal.ProductionConfig.zen?$NAMESPACE="_$zu(5))#' > #($$$aText("Production",""))#</a> 
	 | <a target="ensproderr" href='#("/"_csp_"/"_$zconvert($zu(5),"L")_"/EnsPortal.EventLog.zen?$NAMESPACE="_$zu(5))#' > #($$$aText("Production Errors",""))#</a> 
	 | <a target="ensqueues" href='#("/"_csp_"/"_$zconvert($zu(5),"L")_"/EnsPortal.Queues.zen?$NAMESPACE="_$zu(5))#' > #($$$aText("Production Queues",""))#</a> 
	 | <a target="query" href='#("/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE="_$zu(5))#' > #($$$aText("Query",""))# </a> 
	 | <a target="globals" href='#("/csp/sys/exp/%25CSP.UI.Portal.GlobalList.zen?$NAMESPACE="_$zu(5))#' > #($$$aText("Globals",""))# </a> 
	#($s(##class(App.sys).ClassExist("WebTerminal.Engine"):" | "_$$$addAppLog($$$aText("WebTerminal",""),$$$aText("Load WebTerminal",""),"trm",""),1:""))#
	 | 
	</td></tr>>
	q ""
}

ClassMethod ExportProjects(Dir, files) As %Status
{
	q $$$OK
}

ClassMethod GetHelp(help)
{
	#define sH(%msg) set help($i(help))=%msg
	$$$sH($$$aText("Call examples",""))
	$$$sH(" ")
	$$$sH(" "_$$$addAppLog("^%App.Setting","","^%App.Setting","")_" --- "_$$$aText("View global with the basic settings panel",""))
	$$$sH(" "_$$$addAppL("obj ##class(App.Log).%New()")_" --- "_$$$aText("To obtain information on the class",""))
	$$$sH(" "_$$$addAppL("obj ##class(App.Log).%OpenId(2)")_" --- "_$$$aText("To obtain information on class and object",""))
	$$$sH(" "_$$$addAppL("obj =##class(App.Log).%OpenId(2)")_" --- "_$$$aText("To obtain information only on the object values",""))
	$$$sH(" ")
	$$$sH(" "_$$$addAppL("xec set obj=##class(App.Log).%OpenId(2) write ""<pre>"" zw obj w ""</pre>"" ")_"--- "_$$$aText("Execute command : to Show dump of the object ",""))
	$$$sH(" "_$$$addAppL("xec do ##class(App.sys).SaveQuery(""%SYSTEM.License:Counts"",""^GN"",0)")_"--- "_$$$aText("Run the command : Save the query result in the global ^GN",""))
	$$$sH(" "_$$$addAppL("result ^GN(""%SYSTEM.License:Counts"",0)")_" --- "_$$$aText("Bring recorded in the global result of the query","")_" ##class(App.sys).SaveQuery")
	$$$sH(" ")
	$$$sH(" "_$$$addAppL("query ##class(%Library.ResultSet).%New(""%SYS.Portal.Users:List"")")_"--- "_$$$aText("Run the query and show the favorites page for the user",""))
	$$$sH(" "_$$$addAppL("query ##class(%Library.ResultSet).%New(""%SYSTEM.License:Counts"")")_"--- "_$$$aText("Run the query and show license usage",""))
	$$$sH(" "_$$$addAppL("query %SYSTEM.License:Counts")_"--- "_$$$aText("Run the query and show license usage",""))
	$$$sH(" "_$$$addAppL("query %SYS.GlobalQuery:NameSpaceList USER")_" --- "_$$$aText("show the list globalaw in the USER area",""))
	$$$sH(" "_$$$addAppL("query %SYS.GlobalQuery:Size /opt/isc/ensemble/mgr/USER/")_" --- "_$$$aText("to calculate the size globalaw our database USER",""))
	$$$sH(" ")
	$$$sH(" "_$$$addAppL("select * FROM App.Log order by id desc")_" --- "_$$$aText("To execute arbitrary sql query",""))
	$$$sH(" ")
	set fio=$g(@$$$MgtPortalSettings@($Username,"DeveloperName"),"DEV")
	set gn=$$$logdevGN_fio
	$$$sH(" "_$$$addAppLog("^*","","^*","")_" --- "_$$$aText("show a list of all globalaw in the current scope",""))
	$$$sH(" "_$$$addAppLog("^log*","","^log*","")_" --- "_$$$aText("show the list globalaw mask",""))
	$$$sH(" "_$$$addAppLog("^log**","","^log**","")_" --- "_$$$aText("show the list globalaw with the occupied size Allocated MB",""))
	$$$sH(" "_$$$addAppLog("^log***","","^log***","")_" --- "_$$$aText("show the list globalaw with the occupied size Allocated MB Used MB and",""))
	$$$sH(" "_$$$addAppLog("^tmp**","","^tmp**","")_" --- "_$$$aText("show the list globalaw with the occupied size Allocated MB",""))
	$$$sH(" "_$$$addAppLog("^ISCSOAP","","^ISCSOAP","")_" --- "_$$$aText("Global SOAP (on the prod should be removed)",""))
	
	$$$sH(" ")
	if ##class(App.sys).ClassExist("WebTerminal.Engine") {
		$$$sH(" "_$$$addAppLog("trm","","trm","")_" --- "_$$$aText("Open the built-in Web Terminal ",""))
	}
	$$$sH("--- "_$$$aText("If this macro is to insert in the test program","")_" $$$LogDebug(""Debug info"") "_$$$aText("table App.Log pojawia new record",""))
	$$$sH("---  $$$AppL("""_fio_""",""node"")=$$$AppObJs(object) "_$$$aText("will record in global","")_" "_gn_" "_$$$aText("an object in the format","")_" json")
	
	$$$sH("--- "_$$$aText("To run in the background scanning logs to collect information about modifiable globalaw yesterday",""))
	$$$sH(" "_$$$addAppL("xec job ##class(App.files).OneDayJournalCount()::0 if $test write ""Processing""")_" --- "_$$$aText("Attention! The process can be long. Information about globalo default written in ","")_$$$TEMPJRNL)
	$$$sH(" "_$$$addAppL("xec do ##class(App.files).Export2CSV()")_" --- "_$$$aText("Display information about globalo of","")_" "_$$$TEMPJRNL_" in "_$$$EMAILXLSPATH_"JrnCount*.csv")
	$$$sH(" "_$$$addAppL("xec Set tSC = ##class(%SYS.Portal.Users).%AddFavorite(""AppTools"",""/apptools/App.LogInfo.cls?WHAT=%3F"") zw tSC")_" --- "_$$$aText("Add a link to AppTools in the management portal",""))
	;$$$sH(" "_$$$addAppL("post http://User:pass@localhost:57772/apptoolsrest/jsonrpc"_$c(13,10)_"{""jsonrpc"":""2.0"",""method"":""server.shutdown"",""params"":{""server"":""42""},""id"":1}")_" --- Perform http request with POST method with a JSON body")
	;$$$sH(" "_$$$addAppL("get https://openexchange.intersystems.com/index.html")_" --- to Perform http request with POST method with a JSON body")
	$$$sH(" ")
}

}

