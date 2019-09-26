Include App.LogMacro

/// 
Class App.FormExplorer Extends App.LogInfoPane
{

/// Отрисовка формы для ввода информации
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	write ##class(App.LogInfoPane).AddJsScripts("grid")
	set $ZT="errors"
	set nsp=%request.Get("NSP")
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)
	set SelClass=$tr(%request.Get("SelClass"),"_",".")
	// Навигатор по системе
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
	$$$jsstart	// Загрузить список областей
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
			$.blockUI( { message: 'Идет загрузка' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );
            $("#aCLS").load("App.Action.cls","appClass=App.FormExplorer&appMethod=Class2Grid&appNsp="+args.item.Namespace+"&appPar="+args.item.Namespace);
        },
        data: Namespace,
        fields: [
            { name: "Namespace", type: "text", width: 150, validate: "required" }
            
        ]
    });
	</script>>
	}
	/// Навигатор из selectors
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
		 $$$jsstart	// Загрузить список областей
		   	; вычислить высоту контейнера-результата как вычетание из выстоты контейнера-таба высоту контейнера-заголовка
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

/// Cписок классов в виде таблицы
ClassMethod Class2Grid(Par)
{
	set ListClasses=""
	do ..SelectClasses("",.ListClasses)
	$$$jsstart	// Загрузить список классов
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
			$.blockUI( { message: 'Идет загрузка' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );
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

/// Cписок экземпляров классов в виде таблицы
ClassMethod Obj2Grid(Par)
{
	#define tra(%s) $zconvert(%s,"O","JS")
	set count=..GetCountTab(Par,.tab)
	set sql="select * from "_tab
	set gn="^||tmpAppExpObj2Grid"
	do ##class(App.sys).SaveSQL(sql,gn)
	set nl=$c(13,10)
	$$$jsstart
   // Загрузить список полей запроса
      set field = "["
    	for f=1:1:$ll(@gn@(0)) { 
    		set field=field_"{ name: """_$$$tra($lg(@gn@(0),f))_""", type: ""text"", validate: ""required"" }"_$s($ll(@gn@(0))'=f:",",1:"")
    	}
   		 set field=field_"]"
   	write !,nl,"var field = "_field_";",!,nl
   	;w "var field2=JSON.parse(field);",!,nl
    // Загрузить список классов
    set max=$$$MAXSHOW
    write " var objects = [",!
    	set i="0"
    	for { s i=$o(@gn@(i)) q:i=""  q:i>max  ;ограничим
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
	$("#aPROhead").html("Создать новый");
	$("#aPRO").load("App.Action.cls","appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="+$("#aNSPhead").html()+"&appPar=,"+$("#aCLShead").html());
	</script>
	>
}

/// Открыть экземпляр класса
ClassMethod PRO2Grid(Par)
{
	write "<form id='MainForm'><div id='MainContent'>"
	set class=$p(Par,",",2)
	set id=$p(Par,",",1)
	set obj=##class(App.Form).GetObj(Par)
	if '$isobject(obj) { 
		write $$$appError("Не удалось открыть объект")
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

/// Получить список областей в виде селекта
ClassMethod SelectNsp(Par)
{
	set NSpace=$zu(5)
	// Получить список областей
	set listNs=##class(App.sys).ListNS(.info)
	set onc="$('#MainClasses').empty();$('#MainObjects').empty();$('#MainClasses').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectClasses&appNsp='+this.options[this.selectedIndex].value+'&appPar='+this.options[this.selectedIndex].value);"
	set selectNS="<SELECT title=""Область"" name=""NSP"" id=""NSP""  > "
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

/// Получить список классов в виде селекта
ClassMethod SelectClasses(SelectClass = "", ListClasses)
{
	set query=##class(%Library.ResultSet).%New("%Dictionary.ClassDefinition:Summary")
 	set st=query.Execute() ;"%Persistent")
	set onc="$('#MainObjects').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectObjects&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
 	set selectNS="<SELECT title=""Классы"" name=""SelClass"" id=""SelClass"" > "
 	while query.Next() { 
 		if 'query.Get("Persistent") continue
		set class=query.Get("Name"),f1=""
		if $zu(5)'="%SYS" continue:$e(class,1)="%"  
		if $e($zu(5),1,3)'="ENS" continue:$e(class,1,3)="Ens"
		set selected=""
		if class=SelectClass s selected="selected",forceONC=1
		if query.Get("Super")["App.Form" s f1="style='color:red;' title='Наследник App.Form'"
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

/// Получить Количество записей таблицы
ClassMethod GetCountTab(SelectClass, ByRef tab)
{
	set tab=##class(App.type).GetTableName(SelectClass)
	set sql="select * from "_tab
	set gn="^||tmpAppExpCount"
	do ##class(App.sys).SaveSQL("select count(*) from "_tab,gn)
	set count=+$lg($g(@gn@(1)),1)
	quit count
}

/// Получить список экземпляров класса в виде таблицы
ClassMethod SelectObjects(SelectClass, sql = "", exec = "")
{
	set count=..GetCountTab(SelectClass,.tab)
	set:sql="" sql="select * from "_tab
	;set add=" <span style='"_$$$styleurl_"' onclick=""$('#MainObjEdit').load('App.Action.cls','appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="_$zu(5)_"&appPar=,"_SelectClass_"');"" title='Создать объект' >Создать</span><DIV id=MainObjEdit></div>"
	set add=" <span style='"_$$$styleurl_"' onclick=""WinOpen('"_$zu(5)_"','"_..%ClassName(1)_"','WinOpenEditObj','SelectClass="_SelectClass_"&ID=');"" title='Создать объект' >Создать</span>"
	$$$jsstart
		write "$('#MainObjEdit').empty();"
	$$$jsstop
	set %SelectClass=SelectClass
	;if exec="" set exec="##class(App.FormExplorer).EditObj(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
	if exec="" set exec="##class(App.FormExplorer).WinEditObj(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
	;set st=##class(App.LogInfoPane).DrawSQL(sql,$$$MAXSHOW,$zu(5),sql_" <a target=SelectQ href='App.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_sql_"' title='Перейти на панель запросов'>Запрос</a> count(*)="_count_" "_add,exec)
	set st=##class(App.LogInfoPane).DrawSQL(sql,$$$MAXSHOW,$zu(5),"Экземпляры класса "_SelectClass_" в области "_$zu(5)_" "_add,exec)
	quit st
}

/// Формировать активные ссылки для редактирования
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

/// Формировать активные ссылки для редактирования в окне
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
		set res=$replace(Val,Val,"<span title='Редактировать' style='"_$$$styleurl_"' onclick=""WinOpen('"_nspace_"','"_..%ClassName(1)_"','WinOpenEditObj','SelectClass="_%SelectClass_"&ID="_$zconvert(%id,"O","URL")_"');"" >"_Val_"</span>")
	}
	quit res
}

/// Открыть окно для редактирования экземпляра объекта
ClassMethod WinOpenEditObj(Par)
{
	set id=$g(Par("ID"))
	set ClassName=$tr($get(Par("SelectClass")),"_",".")
	//
	set obj=##class(App.Form).GetObj(id_","_ClassName)
	set PrefixIdDIV="WinOpenEditObj"
	write "<form id='"_PrefixIdDIV_"MainForm'>"
		do ##class(App.Form).Show(obj,"1,WithoutCancel,WithoutRef",PrefixIdDIV) 
	write "</form><div id='"_PrefixIdDIV_"MainContent'></div>"
	q $$$OK
}

}

