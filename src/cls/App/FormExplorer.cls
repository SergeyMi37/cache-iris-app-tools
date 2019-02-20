Include App.LogMacro

/// 
Class App.FormExplorer Extends App.LogInfoPane
{

/// Отрисовка формы для ввода информации
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	do ##class(App.LogInfoPane).AddJsScripts("grid")
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
	/// Навигатор из ниспадающих списков
	else {
	&html<
		<!-- ui-dialog -->
	<div id="dialog" title="Dialog Title">
		<div id=dialogContent></div>
	</div>
		<form name="loginfo" id="loginfo">
		<table width="90%" border="0" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
		  <td>#(##class(App.LogInfo).GetInfoImg("search"))# 
			 <DIV id=MainNamespaces></div>
			 <DIV id=MainClasses></div>
			 <DIV id=MainObjects></div>
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
		 $$$jsstart	// Загрузить список областей
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
	s ListClasses=""
	d ..SelectClasses("",.ListClasses)
	$$$jsstart	// Загрузить список классов
    w " var classes = ["
    	s i=""
    	f { s i=$o(ListClasses(i)) q:i=""
    		w "{ ""ClassNames"": """_i_""",""SuperClass"": """_$lg(ListClasses(i),3)_""" }"_$s($o(ListClasses(i))="":"",1:",")
    	}
   		 w "];"
    
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
	s count=..GetCountTab(Par,.tab)
	s sql="select * from "_tab
	s gn="^Obj2Grid"
	d ##class(App.sys).SaveSQL(sql,gn)
	s nl=$c(13,10)
	$$$jsstart
   // Загрузить список полей запроса
      s field = "["
    	f f=1:1:$ll(@gn@(0)) { 
    		s field=field_"{ name: """_$$$tra($lg(@gn@(0),f))_""", type: ""text"", validate: ""required"" }"_$s($ll(@gn@(0))'=f:",",1:"")
    	}
   		 s field=field_"]"
   	w !,nl,"var field = "_field_";",!,nl
   	;w "var field2=JSON.parse(field);",!,nl
    // Загрузить список классов
    s max=$$$MAXSHOW
    w " var objects = [",!
    	s i="0"
    	f { s i=$o(@gn@(i)) q:i=""  q:i>max  ;ограничим
    		w "{ "
    		f f=1:1:$ll(@gn@(0)) {
	    		s val=$lg(@gn@(i),f)
	    		s:$l(val)>80 val=$e(val,1,50)_"..."
    			w """"_$$$tra($lg(@gn@(0),f))_""": """_$$$tra(val)_""" "_$s($ll(@gn@(0))'=f:",",1:"")
    		}
    		w "}"_$s($o(@gn@(i))'="":",",1:""),!
    	}
   		 w "];",!,nl
    	w "$('#aOBJhead').html('Total: "_+count_"');",!,nl
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
	w "<form id='MainForm'><div id='MainContent'>"
	s class=$p(Par,",",2)
	s id=$p(Par,",",1)
	s obj=##class(App.Form).GetObj(Par)
	if '$isobject(obj) { 
		w $$$appError("Не удалось открыть объект")
	}
	else {
		;s mode="1,WithoutSave,WithoutDel,WithoutCancel"
		;if $g(%session.Data("debug")) 
		s mode=($roles["%All")_",WithoutCancel,WithCreate"
		d ##class(App.Form).Show(obj,mode)
	}
	$$$jsstart
	w "$('#aPRO').height('80%');"
	w:id'="" "$('#aPROh').click();"
 	$$$jsstop
	w "</div></form>"
	q $$$OK
}

/// Получить список областей в виде селекта
ClassMethod SelectNsp(Par)
{
	set NSpace=$zu(5)
	// Получить список областей
	set listNs=##class(App.sys).ListNS(.info)
	s onc="$('#MainClasses').empty();$('#MainObjects').empty();$('#MainClasses').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectClasses&appNsp='+this.options[this.selectedIndex].value+'&appPar='+this.options[this.selectedIndex].value);"
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
	s onc="$('#MainObjects').load('App.Action.cls','appClass=App.FormExplorer&appMethod=SelectObjects&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);"
 	set selectNS="<SELECT title=""Классы"" name=""SelClass"" id=""SelClass"" > "
 	while query.Next() { 
 		i 'query.Get("Persistent") continue
		s class=query.Get("Name"),f1=""
		i $zu(5)'="%SYS" continue:$e(class,1)="%"  
		i $e($zu(5),1,3)'="ENS" continue:$e(class,1,3)="Ens"
		set selected=""
		if class=SelectClass s selected="selected",forceONC=1
		if query.Get("Super")["App.Form" s f1="style='color:red;' title='Наследник App.Form'"
		set selectNS=selectNS_" <OPTION "_$g(selected)_" "_f1_" VALUE="""_class_""">"_class_"</OPTION>"
		i $D(ListClasses) s ListClasses(class)=$lb($g(selected),f1,query.Get("Super"),query.Get("System"),query.Get("TimeChanged"),,query.Get("SqlTableName"))
	}
	q:$D(ListClasses) $$$OK
	
	set selectNS=selectNS_"</SELECT>"
	write selectNS
	$$$jsstart
		w "$( '#SelClass' ).selectmenu({ change: function( event, data ) { "_onc_" }, width:1000 }).selectmenu('menuWidget');" ;;.selectmenu('refresh', true).addClass('overflow');"
		w "$( '#SelClass-menu' ).css( 'max-height','500px');"
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
	s (tab,table)=$p(SelectClass,".",*)
	//Если имя таблицы - ключевое слов, обрамим в кавычки
	s:$SYSTEM.SQL.IsReservedWord(table) table = """"_table_""""
	s tab=$tr($p(SelectClass,"."_tab,1),".","_")_"."_table
	s sql="select * from "_tab
	s gn="^||tmpCount"
	d ##class(App.sys).SaveSQL("select count(*) from "_tab,gn)
	s count=+$lg($g(@gn@(1)),1)
	q count
}

/// Получить список экземпляров класса в виде таблицы
ClassMethod SelectObjects(SelectClass)
{

	s count=..GetCountTab(SelectClass,.tab)
	s sql="select * from "_tab
	s add=" <span style='"_$$$styleurl_"' onclick=""$('#MainObjEdit').load('App.Action.cls','appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="_$zu(5)_"&appPar=,"_SelectClass_"');"" title='Создать объект' >Создать</span><DIV id=MainObjEdit></div>"
	$$$jsstart
		write "$('#MainObjEdit').empty();"
	$$$jsstop
	s %SelectClass=SelectClass
	set exec="##class(App.FormExplorer).EditObj(.%AppLogInfoVal, %AppLogInfoCol, %AppLogInfoHead, .%AppLogInfoTemp,"""_$zu(5)_""")"
	set st=##class(App.LogInfoPane).DrawSQL(sql,$$$MAXSHOW,$zu(5),sql_" <a target=SelectQ href='App.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_sql_"' title='Перейти на панель запросов'>Запрос</a> count(*)="_count_" "_add,exec)
	quit $$$OK
}

/// Формировать активные ссылки для редактирования
ClassMethod EditObj(Val, Col, Head, Temp, nspace, DSN)
{
	s res=Val
	if $g(Head) {
		i $g(Val)="ID" s Temp("ID",Col)=""
	}
	else {
		i $D(Temp("ID",Col)) {
			s res=$replace(Val,Val,"<span style='"_$$$styleurl_"' onclick=""$('#MainObjEdit').load('App.Action.cls','appClass=App.FormExplorer&appMethod=PRO2Grid&appNsp="_nspace_"&appPar="_Val_","_%SelectClass_"');"" >"_Val_"</span>")
		}
	}
	q res
}

}

