Include App.LogMacro

/// 
Class App.FormExplorer Extends App.LogInfoPane [ DependsOn = App.msg ]
{

/// Draw a shape for input information
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	write ##class(App.LogInfoPane).AddJsScripts("grid")
	set $ZT="errors"
	set nsp=%request.Get("NSP")
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)
	set SelClass=$tr(%request.Get("SelClass"),"_",".")
	// Navigator system
	if %request.Get("panel")="AccordionExp" {
	&html<
	 <div id="accordion" style='width: 100%; height: 100%'>
		<h3 id=aNSPh>Namespace: <span id=aNSPhead></span></h3>
		<div id=aNSP></div>
		
		<h3 id=aCLSh >Classes: <span id=aCLShead></span></h3>
		<div id=aCLS></div>
		
		<h3 id=aOBJh>Objects: <span id=aOBJhead></span></h3>
		<div id=aOBJ></div>
		
		<h3 id=aPROh>Propertis: <span id=aPROhead></span></h3>
		<div id=aPRO></div>
	 </div>
	>
	d ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
	$$$jsstart	// To load a list of fields
		w "$( '#accordion' ).accordion({"
	 	w " collapsible: true, icons: { header: ""ui-icon-zoomin"",  headerSelected: ""ui-icon-zoomout"" }"
		w "});"
	    w " var Namespace = ["
    	s ns=##class(App.sys).ListNS(.info)
    	f i=1:1:$l(ns,",") {
    		continue:$p(ns,",",i)="%All"
    		continue:$p(ns,",",i)=""
    		w "{ ""Namespace"": """_$p(ns,",",i)_""" }"_$s($p(ns,",",i+1)="":"",1:",")
    	}
   		w "];"
    
    $$$jsstop
 	&js< <script>
    $("#aNSP").jsGrid({
        width: "*",
        height: "auto",
 
        inserting: false,
        editing: false,
        sorting: true,
        paging: true,
  		rowClick: function(args) {
            console.log(args.item);
            $("#aNSPhead").html(args.item.Namespace);
            $("#aCLS").empty();
            $("#aCLShead").html("");
			$.blockUI( { message: '...Loading' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );
            $("#aCLS").load("App.Action.cls","appClass=App.FormExplorer&appMethod=Class2Grid&appNsp="+args.item.Namespace+"&appPar="+args.item.Namespace);
        },
        data: Namespace,
        fields: [
            { name: "Namespace", type: "text", width: 150, validate: "required" }
            
        ]
    });
	</script>>
	}
	/// Navigator of selectors
	else {
	&html<
		<!-- ui-dialog -->
	<div id="dialog" title="Dialog Title">
		<div id=dialogContent></div>
	</div>
		<form name="loginfo" id="loginfo">
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
		  <td>#(##class(App.LogInfo).GetInfoImg("search"))# 
			 <DIV id='MainNamespaces'></div>
			 <DIV id='MainClasses'></div>
			 <DIV style='overflow: auto;' id='MainObjects'></div>
			</td>
		 </tr>
		 <tr>
		   <td>
	 		<div id="MainContent">
	 		</div>
		   </td>
		 </tr>
		</table>
		>
		 d ##class(App.LogInfoPane).AddJS(NSpace,..%ClassName(1))
		 $$$jsstart	// To load a list of fields
		   	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
		 	w "$('#MainObjects').height(window.innerHeight-200);"

		 	write "$('#MainNamespaces').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectNsp&appNsp="_$zu(5)_"');"
		 	write "$('#MainClasses').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectClasses&appNsp="_$zu(5)_"&appPar="_$g(SelClass)_"');"
		 $$$jsstop
		write "<br><br><form>"
	}
	quit $$$OK

errors
 	write !,$ze
 	quit $$$OK
}

/// The list of classes in a table
ClassMethod Class2Grid(Par)
{
	set ListClasses=""
	do ..SelectClasses("",.ListClasses)
	$$$jsstart	// Download a list of classes
    write " var classes = ["
    	set i=""
    	for { s i=$o(ListClasses(i)) quit:i=""
    		write "{ ""ClassNames"": """_i_""",""SuperClass"": """_$lg(ListClasses(i),3)_""" }"_$s($o(ListClasses(i))="":"",1:",")
    	}
   		 write "];"
    
    $$$jsstop
 	&js< <script>
 	 console.log(classes);
    $("#aCLS").jsGrid({
        width: "*",
        height: "auto",
        inserting: false,
        editing: false,
        sorting: true,
        paging: true,
  		rowClick: function(args) {
            console.log(args.item);
            $("#aCLShead").html(args.item.ClassNames);
            $("#aOBJ").empty();
            $("#aOBJhead").html("");
			$.blockUI( { message: '...Loading' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );
            $("#aOBJ").load("App.Action.cls","appClass=App.FormExplorer&appMethod=Obj2Grid&appNsp="+$("#aNSPhead").html()+"&appPar="+args.item.ClassNames);
        },
        data: classes,
         fields: [
            { "name": "ClassNames", "type": "text", "width": "50%", "validate": "required" ,autosearch: true},
            { "name": "SuperClass", "type": "text", "width": "*", "validate": "required" }
                   
        ]
    });
      $("#aCLSh").click();
      $.unblockUI();
	</script>
	>
}

/// A list of instances of classes in a table
ClassMethod Obj2Grid(Par)
{
	#define tra(%s) $zconvert(%s,"O","JS")
	set count=..GetCountTab(Par,.tab)
	set sql="select * from "_tab
	set gn="^||tmpAppExpObj2Grid"
	do ##class(App.sys).SaveSQL(sql,gn)
	set nl=$c(13,10)
	$$$jsstart
   // To load the list of query fields
      set field = "["
    	for f=1:1:$ll(@gn@(0)) { 
    		set field=field_"{ name: """_$$$tra($lg(@gn@(0),f))_""", type: ""text"", validate: ""required"" }"_$s($ll(@gn@(0))'=f:",",1:"")
    	}
   		 set field=field_"]"
   	write !,nl,"var field = "_field_";",!,nl
   	;w "var field2=JSON.parse(field);",!,nl
    // Download a list of classes
    set max=$$$MAXSHOW
    write " var objects = [",!
    	set i="0"
    	for { s i=$o(@gn@(i)) q:i=""  q:i>max  ;limit
    		write "{ "
    		for f=1:1:$ll(@gn@(0)) {
	    		set val=$lg(@gn@(i),f)
	    		set:$l(val)>80 val=$e(val,1,50)_"..."
    			write """"_$$$tra($lg(@gn@(0),f))_""": """_$$$tra(val)_""" "_$s($ll(@gn@(0))'=f:",",1:"")
    		}
    		write "}"_$s($o(@gn@(i))'="":",",1:""),!
    	}
   		 write "];",!,nl
    	write "$('#aOBJhead').html('Total: "_+count_"');",!,nl
    $$$jsstop
 	&js< <script>
 	   $("#aPROhead").html("");
 	   console.log(objects);
    $("#aOBJ").jsGrid({
        width: "*",
        height: "auto",
        inserting: false,
        sorting: true,
        paging: true,
  		rowClick: function(args) {
            console.log(args.item);
            var pro='';
            for (var item in args.item) { // "foreach"
     		   console.log(args.item[ item ]);
     		   pro=pro+' '+args.item[ item ]
    		}
            $("#aPROhead").html(pro);
            $("#aPRO").load("App.Action.cls","appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="+$("#aNSPhead").html()+"&appPar="+args.item.ID+","+$("#aCLShead").html());
            $("#aPRO").click();
        },
        fields: field,
        data: objects
          
    });
 	$("#aOBJh").click();
  	$.unblockUI();
	$("#aPROhead").html("Create new");
	$("#aPRO").load("App.Action.cls","appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="+$("#aNSPhead").html()+"&appPar=,"+$("#aCLShead").html());
	</script>
	>
}

/// To open an instance of the class
ClassMethod PRO2Grid(Par)
{
	write "<form id='MainForm'><div id='MainContent'>"
	set class=$p(Par,",",2)
	set id=$p(Par,",",1)
	set obj=##class(App.Form).GetObj(Par)
	if '$isobject(obj) { 
		write $$$appError($$$aText("Failed to open object",""))
	}
	else {
		set mode=($roles["%All")_",WithoutCancel,WithCreate"
		do ##class(App.Form).Show(obj,mode)
	}
	$$$jsstart
	write "$('#aPRO').height('80%');"
	write:id'="" "$('#aPROh').click();"
 	$$$jsstop
	write "</div></form>"
	quit $$$OK
}

/// To get a list of fields in the select
ClassMethod SelectNsp(Par)
{
	set NSpace=$zu(5)
	// To get a list of fields
	set listNs=##class(App.sys).ListNS(.info)
	set onc="$('#MainClasses').empty();$('#MainObjects').empty();$('#MainClasses').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectClasses&appNsp='+this.options[this.selectedIndex].value+'&appPar='+this.options[this.selectedIndex].value);"
	set selectNS="<SELECT title="""_$$$aText("NameSpace","")_""" name=""NSP"" id=""NSP""  > "
	for ns=1:1:$l(listNs,",") { continue:$p(listNs,",",ns)=""
		continue:$p(listNs,",",ns)["%ALL"
  		set selected=$select(NSpace=$p(listNs,",",ns):"selected",1:"")
  		set selectNS=selectNS_" <OPTION "_selected_" VALUE="""_$p(listNs,",",ns)_""">"_$p(listNs,",",ns)_"</OPTION>"
	}
	set selectNS=selectNS_"</SELECT>"
	write selectNS
	$$$jsstart
		w "$( '#NSP' ).selectmenu({ change: function( event, data ) { "_onc_" }, width:1000 }).selectmenu('menuWidget');" ;;.selectmenu('refresh', true).addClass('overflow');"
		w "$( '#NSP-menu' ).css( 'max-height','500px');"
	$$$jsstop
	quit $$$OK
}

/// To obtain a list of classes in the form of select
ClassMethod SelectClasses(SelectClass = "", ListClasses)
{
	set query=##class(%Library.ResultSet).%New("%Dictionary.ClassDefinition:Summary")
 	set st=query.Execute() ;"%Persistent")
	set onc="$('#MainObjects').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectObjects&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
 	set selectNS="<SELECT title="""_$$$aText("Classes","")_""" name=""SelClass"" id=""SelClass"" > "
 	while query.Next() { 
 		if 'query.Get("Persistent") continue
		set class=query.Get("Name"),f1=""
		if $zu(5)'="%SYS" continue:$e(class,1)="%"  
		if $e($zu(5),1,3)'="ENS" continue:$e(class,1,3)="Ens"
		set selected=""
		if class=SelectClass s selected="selected",forceONC=1
		if query.Get("Super")["App.Form" s f1="style='color:red;' title='Inheritor App.Form'"
		set selectNS=selectNS_" <OPTION "_$g(selected)_" "_f1_" VALUE="""_class_""">"_class_"</OPTION>"
		if $D(ListClasses) s ListClasses(class)=$lb($g(selected),f1,query.Get("Super"),query.Get("System"),query.Get("TimeChanged"),,query.Get("SqlTableName"))
	}
	quit:$D(ListClasses) $$$OK
	
	set selectNS=selectNS_"</SELECT>"
	write selectNS
	$$$jsstart
		write "$( '#SelClass' ).selectmenu({ change: function( event, data ) { "_onc_" }, width:1000 }).selectmenu('menuWidget');" ;;.selectmenu('refresh', true).addClass('overflow');"
		write "$( '#SelClass-menu' ).css( 'max-height','500px');"
	$$$jsstop
	if $g(forceONC) {
		$$$jsstart
			write "$('#MainObjects').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectObjects&appNsp="_$zu(5)_"&appPar="_SelectClass_"');"
		$$$jsstop
	}
	quit $$$OK
}

/// To obtain the Number of records in the table
ClassMethod GetCountTab(SelectClass, ByRef tab)
{
	set tab=##class(App.type).GetTableName(SelectClass)
	set sql="select * from "_tab
	set gn="^||tmpAppExpCount"
	do ##class(App.sys).SaveSQL("select count(*) from "_tab,gn)
	set count=+$lg($g(@gn@(1)),1)
	quit count
}

/// To obtain a list of instances of a class in a table
ClassMethod SelectObjects(SelectClass, sql = "", exec = "")
{
	set count=..GetCountTab(SelectClass,.tab)
	set:sql="" sql="select * From "_tab
	set add=" <span style='"_$$$styleurl_"' onclick=""WinOpen('"_$zu(5)_"','"_..%ClassName(1)_"','WinOpenEditObj','SelectClass="_SelectClass_"&ID=','','"_##class(App.Action).WriteWinOpenREST(%request)_"');"" title='"_$$$aText("To create an object","")_"' >"_$$$aText("To create","")_"</span>"_sql
	$$$jsstart
		write "$('#MainObjEdit').empty();"
	$$$jsstop
	set %SelectClass=SelectClass
	if exec="" set exec="##class(App.FormExplorer).WinEditObj(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
	set st=##class(App.LogInfoPane).DrawSQL(sql,$$$MAXSHOW,$zu(5),$$$FormatText($$$aText("Instances of class %1 in namespace %2",""),SelectClass,$zu(5))_" "_add,exec)
	quit st
}

/// To form active links for editing
ClassMethod EditObj(Val, Col, Head, Temp, nspace, DSN)
{
	set res=Val
	if $g(Head) {
		i $g(Val)="ID" s Temp("ID",Col)=""
	}
	else {
		if $D(Temp("ID",Col)) {
			set res=$replace(Val,Val,"<span style='"_$$$styleurl_"' onclick=""$('#MainObjEdit').load('App.Action.cls','appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="_nspace_"&appPar="_Val_","_%SelectClass_"');"" >"_Val_"</span>")
		}
	}
	quit res
}

/// Forming an active link for editing in the window
ClassMethod WinEditObj(Val, Col, Head, Temp, nspace, DSN)
{
	set res=Val
	if $g(Head) {
		if $g(Val)="ID" s Temp("ID",Col)=""
	}
	else {
		if $D(Temp("ID",Col)) {
			s %id=Val
		}
		set res=$replace(Val,Val,"<span title='"_$$$aText("Edit","")_"' style='"_$$$styleurl_"' onclick=""WinOpen('"_nspace_"','"_..%ClassName(1)_"','WinOpenEditObj','&SelectClass="_%SelectClass_"&ID="_$zconvert(%id,"O","URL")_"','','"_##class(App.Action).WriteWinOpenREST(%request)_"');"" >"_Val_"</span>")
	}
	quit res
}

/// To open the window to edit the object instance
ClassMethod WinOpenEditObj(Par, json)
{
	set id=$g(Par("ID"))
	set ClassName=$tr($get(Par("SelectClass")),"_",".")
	set obj=##class(App.Form).GetObj(id_","_ClassName)
	set PrefixIdDIV="WinOpenEditObj"
	write "<form id='"_PrefixIdDIV_"MainForm'>"
		do ##class(App.Form).Show(obj,"1,WithoutCancel,WithoutRef",PrefixIdDIV) 
	write "</form><div id='"_PrefixIdDIV_"MainContent'></div>"
	q $$$OK
}

}

