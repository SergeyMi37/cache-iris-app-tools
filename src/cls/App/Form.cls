Include App.LogMacro

/// Представление хранимых классов для просмотра и редактирования
Class App.Form [ Abstract ]
{

/// префикс у имени поля объекта
Parameter PREFIXFIELD = "appfield";

/// Получить всех потомков для класса
ClassMethod GetSubclassOf(super = "App.Form")
{
 set query=##class(%Library.ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")
 set st=query.Execute(super)
 Q query
}

/// Получить расширенные свойства поля объекта
ClassMethod GetJsonProp(obj, propName, gn, out)
{
	set out("description")=..GetPropVal(obj,propName,.gn,"Description")
	set out("inputtype")=""
	if out("description")["{" {
		set json="{"_$p(out("description"),"{",2,*)
		try {
			;2017 set title={}.%FromJSON(json).title 
			;2016.1 set title={}.$fromJSON(json).title
			set out("title")={}.$$$jsonFromJSON(json).title
			set out("inputtype")={}.$$$jsonFromJSON(json).inputtype
			set out("displayname")={}.$$$jsonFromJSON(json).displayname
			set out("inputpattern")={}.$$$jsonFromJSON(json).inputpattern
			if $g(out("inputpattern"))="autocomplete" {
				s out("autocompleteMethod")={}.$$$jsonFromJSON(json).autocompleteMethod
			}
			elseif $g(out("inputpattern"))="files" {
				s out("filesMethod")={}.$$$jsonFromJSON(json).filesMethod
			}
			elseif $g(out("inputpattern"))["select" {
				s out("selectMethod")={}.$$$jsonFromJSON(json).selectMethod
			}
			set out("attr")={}.$$$jsonFromJSON(json).attr
			set out("onchange")={}.$$$jsonFromJSON(json).onchange
			set out("readOnly")={}.$$$jsonFromJSON(json).ReadOnly
			if out("displayname")'="" set out("description")=out("displayname")
			else  s out("description")=$p(out("description"),"{",1)
			// включим обработчик события
			if $g(out("onchange"))'="" {
				s out("attr")=out("attr")_" onchange='"_out("onchange")_"'" ;alert(this.value)'"
			}
			
		} catch e { w "Ошибка: "_$ze }
	}
	elseif out("description")="" {
		set out("description")=propName
	}
}

/// Получить все значения свойств
ClassMethod GetPropVal(obj, propName, gn, nameAttr)
{
	q $g(gn("Properties",propName,nameAttr))
	;set col=$g(@gn@(-1,nameAttr))
	;quit:'col ""
	;quit $lg($g(@gn@(row)),col)
}

/// Вывести строку свойств объекта
ClassMethod ShowProp(obj, propName, gn)
{
	set sysType=..GetPropVal(obj,propName,.gn,"Type")
	set Name=..GetPropVal(obj,propName,.gn,"Name")
	i Name="" q $$$ERROR($$$GeneralError,"No Exsist Property "_propName) 
	set Required=..GetPropVal(obj,propName,.gn,"Required")
	set ReadOnly=..GetPropVal(obj,propName,.gn,"ReadOnly")
	set Parameters=..GetPropVal(obj,propName,.gn,"Parameters")
	set Value=$property(obj,Name)
	set redstar="" i Required s redstar="<font color=red title='Обязательное поле'>*</font>"
	
	d ..GetJsonProp(obj, propName, .gn, .pr)
	i 'ReadOnly s ReadOnly=$g(pr("readOnly"))

	write "<tr title='"_$g(pr("title"))_"'>"
	set label=pr("description")_redstar
	if $g(pr("inputpattern"))="hidden" set label=""
	write "<td style='text-align: right;'><label>"_label_"</label></td>"
	write "<td style='text-align: left;'>"
	s pr("attr")=$g(pr("attr"))_" "_$s(Required:"Required",1:"")_$s(ReadOnly:"Disabled",1:"")
	s %id=..#PREFIXFIELD_Name
	s %val=$g(Value)
	s size=" size=50 " if pr("attr")["size" set size=""
	if sysType="%Boolean" {
		d ##class(App.Form).SelectFieldYesNo(%id,%val)
	}
	elseif sysType="%Date" {
	 	write $$$appText(%id," size=10 "_pr("attr"),%val)
	}
	else {  //%String
		if $g(pr("inputpattern"))="textarea" {
			if pr("attr")'["cols" s pr("attr")=pr("attr")_" cols=77 "
			if pr("attr")'["rows" s pr("attr")=pr("attr")_" rows=3 "
			w $$$appTextarea(%id,pr("attr"),%val)
		}
		elseif $g(pr("inputpattern"))="hidden" {
			w "<input type='hidden' id='"_%id_"' name='"_%id_"' "_$g(pr("attr"))_" value='"_%val_"'>"
		}
		elseif $g(pr("inputpattern"))="autocomplete" {
			s met=$g(pr("autocompleteMethod"))
			if met'=""  x "do "_met
			w $$$appAutocomplete(%id," "_pr("attr"),%val)
		}
		elseif $g(pr("inputpattern"))="files" {
			s met=$g(pr("filesMethod"))
			if met'="" 	s %obj=obj  x "do "_met
			w $$$appText(%id,size_pr("attr"),%val)
		}
		elseif $g(pr("inputpattern"))="select" {
			s met=$g(pr("selectMethod"))
			if met'="" {
				;;w met
				if (met["{") { //список из json
					;w 11111111
				}
				else { //список из функции
					x "do "_met
				}
			}
			;w $$$appInputHidden(.%id," "_attr,%val)
		}
		elseif $g(pr("inputpattern"))="selectize" {
			s met=$g(pr("selectMethod"))
			w "<input type='text' id='"_%id_"' name='"_%id_"' class='input-tags demo-default ui-corner-all ui-widget ui-widget-content' value='"_%val_"'>"
			if met'="" {
				x "do "_met
			}
		}
		elseif pr("inputtype")'="" {
			write $$$appInput(%id," type='"_pr("inputtype")_"' "_size_pr("attr"),%val)
		}
		elseif Parameters["{" {
			if {}.$$$jsonFromJSON(Parameters).VALUELIST'="" {
			  s vl={}.$$$jsonFromJSON(Parameters).VALUELIST
			  s dl={}.$$$jsonFromJSON(Parameters).DISPLAYLIST
			  ;	s ^tmpMSW(1,$i(^tmpMSW),"Parameters")=$lb(propName,vl,dl)
			  set:dl="" dl=vl
			  do ..SelectField($lfs(vl),,$lfs(dl),.gn2,,%id,%val,600)
			} else {
				w $$$appText(%id,size_pr("attr"),%val)
			}
		}
		else {w $$$appText(%id,size_pr("attr"),%val)
		}
	}
	write "</td></span>"
	write "</tr>"
	Quit $$$OK
}

/// Сохранить обхект по умолчанию
ClassMethod ObjectDelete(Param = "", Ref = 0)
{
	#dim obj As %Persistent
	set id=$p(Param,",")
	set Class=$p(Param,",",2)
	;m $$$AppL("MSW","req")=%request.Data
	if id="" w $$$appError("Неопределен идентификатор объекта")_"<br>" d:Ref ..ButtonRef() q
	set obj=$classmethod(Class,"%OpenId",id)
	if '$isobject(obj) w $$$appError("Неопределен объект")_"<br>" d:Ref ..ButtonRef() q
	set st=obj.%DeleteId(obj.%Id())
	if 'st w $$$appError($System.Status.GetErrorText(st)) w "<br>" d:Ref ..ButtonRef() q
	write $$$appMsg("Объект удален")
	write "<br>" d:Ref ..ButtonRef() 
	q
}

/// Создать объект как новый
ClassMethod ObjectSaveAsNew(Param = "")
{
 d ..ObjectSave(","_$p(Param,",",2))
}

/// Создать новый объект по умолчанию
ClassMethod ObjectNew(Param = "")
{
 s obj=..GetObj(Param)
 d ..Show(obj,$p(Param,",",3,99))
 q $$$OK
}

/// Получить объект из параметра
ClassMethod GetObj(Par) As %Status
{
	if $p(Par,",",1) = "" s obj=$classmethod($p(Par,",",2),"%New")
	else  s obj=$classmethod($p(Par,",",2),"%OpenId",$p(Par,",",1))
	q obj
}

/// Сохранить объект по умолчанию
ClassMethod ObjectSave(Param = "", Ref = 0)
{
	set id=$p(Param,",")
	set Class=$p(Param,",",2)
	if id="" s obj=$classmethod(Class,"%New")
	else  s obj=$classmethod(Class,"%OpenId",id)
	if '$isobject(obj) w $$$appError("Неопределен объект")_"<br>" d:Ref ..ButtonRef() q ""
	;set gn="%prop"
	set st=..GetPropertyDefinition(obj,.gn)
	if 'st w $$$appError($System.Status.GetErrorText(st))_"<br>" d:Ref ..ButtonRef() q ""
	set i=..#PREFIXFIELD
	;m $$$AppL("SPZ",".gn")=gn
	;m m=%request.Data	zw m
	for { set i=$o(%request.Data(i)) quit:i=""  quit:i'[..#PREFIXFIELD
			set nameProp=$p(i,..#PREFIXFIELD,2)

			s Value=$g(%request.Data(i,1))

			if ..GetPropVal(obj,nameProp,.gn,"Required"),Value="" {
				;получить свойство - описание pr("description")
				d ..GetJsonProp(obj, nameProp, .gn, .pr)
				s err=$g(err)_"<li>"_nameProp_" Обязательное поле пусто ("_$g(pr("description"))_")</li>" continue
			}
			;write "<li>"_nameProp_" "_$g(%request.Data(i,1))
			s $property(obj,nameProp)=Value
	}
	if $d(err) w "<br><br>"_$$$appError("Ошибки проверки свойств<hr>"_$g(err)) d:Ref ..ButtonRef() q ""
	set st=obj.%Save(1)
	if 'st w "<br><br>"_$$$appError($System.Status.GetErrorText(st))_"<br>" d:Ref ..ButtonRef() q ""
	write "<br><br>"_$$$appMsg("Сохранено")_"<br>" d:Ref ..ButtonRef()
	quit obj
}

/// Получить список свойств класса
ClassMethod GetPropertyDefinition(obj, gn)
{
	; Получим все свойства объекта
	;s sql="SELECT cls.Name, prop.Name, prop.Type, prop.Description FROM ""%Dictionary"".ClassDefinition cls  JOIN ""%Dictionary"".PropertyDefinition prop ON cls.Name = prop.parent WHERE cls.Name = '"_obj.%ClassName(1)_"'"
	set sql="SELECT * from ""%Dictionary"".PropertyDefinition where parent like '"_obj.%ClassName(1)_"'"
	;set st=##class(App.sys).SaveSQL(sql,gn,1)
	d ##class(App.LogInfoPane).GetClassDef(obj.%ClassName(1),"",.gn,0)
	;zw gn("Properties")
	quit 1
}

/// Вывод поля типа селект Да или нет
/// do ##class(App.Form).SelectFieldYesNo("test","0")
ClassMethod SelectFieldYesNo(idSelect = "selectmenu", dfltKey = "") As %Status
{
	do ..SelectField($lb(0,1),,$lb("Нет","Да"),.gn,,idSelect,dfltKey,100)
	q $$$OK
}

/// Вывод поля типа селект
/// do ##class(App.Form).SelectField($lb("",0,1),"alert(1);",$lb("","Нет","Да"),.gn,,"test","0",50) 
ClassMethod SelectField(KeyList = "", ONCHANGE = "", ValueList = "", gnRet, order = 1, idSelect = "selectmenu", dfltKey = "", width = 500, NoWrite = 0) As %Status
{
	kill gnRet
	set selectNS="<SELECT id='"_idSelect_"' name='"_idSelect_"' "_$s(NoWrite:"ONCHANGE='"_ONCHANGE_"'",1:"")_">"
	;set selectNS=selectNS_" <OPTION  VALUE=''></OPTION>"
	set gnRet($i(gnRet))=selectNS
	for i=1:1:$ll(KeyList) { 
		;continue:$lg(KeyList,i)=""
		set selected=""
		if dfltKey'="",dfltKey=$lg(KeyList,i) s selected="selected"
		set select=" <OPTION "_$g(selected)_" VALUE="""_$lg(KeyList,i)_""">"_$lg(ValueList,i)_"</OPTION>"
  		set gnRet($i(gnRet))=select
	}
	set gnRet($i(gnRet))="</SELECT>"
	if NoWrite q $$$OK
	for i=1:1 {q:'$DATA(gnRet(i))  write gnRet(i)}
	$$$jsstart
		w "$( '#"_idSelect_"' ).selectmenu({ change: function( event, data ) { "_ONCHANGE_" }, width:"_width_" }).selectmenu('menuWidget');" ;;.selectmenu('refresh') .addClass('overflow');"
		w "$( '#"_idSelect_"-menu' ).css( 'max-height','500px');"
	$$$jsstop
	q $$$OK
}

/// Получить объектов в селекторе для небольших выборок 
/// Возврат в одной строке или в глобале
/// sql - запрос
/// ONCHANGE = js функция на событие в селесторе ONCHANGE
/// ValueList = список полей для выводе в Value
/// gnRet - возвращаемый массив по ссылке
/// do ##class(App.Form).SelectObj("select * from Spgz_model.Packets","$('#MainContent').load('App.Action.cls','appClass=AsuPriz.MVK.ExportPackets&appMethod=ShowObj&appNsp="_$zu(5)_"&appPar='+this.options[this.selectedIndex].value);","segment1,segment1,Description,",.gn) 
ClassMethod SelectObj(sql, ONCHANGE = "", ValueList = "", gnRet, idSelect = "selectmenu") As %Status
{
	kill gnRet
	set gn="^||TempPack"
	set selectNS="<SELECT id='"_idSelect_"' > "
	set selectNS=selectNS_" <OPTION  VALUE=''></OPTION>"
	set gnRet($i(gnRet))=selectNS
	set st=##class(App.sys).SaveSQL(sql,gn)
	if 'st quit st
	if ValueList="" set ValueList=$lg(@gn@(0),1)_","_$lg(@gn@(0),1) ///Первое поле из запроса - должно быть идентификаторм
	set NameFieldVALUE=$p(ValueList,",",1)
	s ns=""
	for { s ns=$o(@gn@(ns)) Q:ns=""
		continue:ns<1
		set VALUE=$lg(##class(App.sys).GetValueGN(gn,ns,NameFieldVALUE),1)
		set OPTION=$e($lts(##class(App.sys).GetValueGN(gn,ns,$p(ValueList,",",2,*))," "),1,100)
		s select=" <OPTION "_$g(selected)_" VALUE="""_VALUE_""">"_OPTION_"</OPTION>"
  		set gnRet($i(gnRet))=select
	}
	set gnRet($i(gnRet))="</SELECT>"
	for i=1:1 {q:'$DATA(gnRet(i))  write gnRet(i)}
	$$$jsstart
		w "$( '#"_idSelect_"' ).selectmenu({ change: function( event, data ) { "_ONCHANGE_" }, width:1000 }).selectmenu('menuWidget');" ;;.selectmenu('refresh', true).addClass('overflow');"
		w "$( '#"_idSelect_"-menu' ).css( 'max-height','500px');"
	$$$jsstop
	quit $$$OK
}

/// Блокировать или деблокировать экран
/// do ##class(App.Form).BlockUI(1,"Загрузка формы")
ClassMethod BlockUI(mode = 1, msg = "Загрузка")
{
 $$$jsstart 
  w:mode $$$blockui(msg)
  w:'mode "$.unblockUI();"
 $$$jsstop
 q $$$OK
}

/// Показать объект 
/// Obj - экземпляр класса
/// Mode = 0 режим просмотра
/// Mode = 1 режим редактирования со всеми кнопками
/// Mode = "1,WithoutSave,WithoutDel,WithCreate" режим редактирования без кнопок
ClassMethod Show(obj, Mode = 0, PrefixIdDIV = "")
{
	if '$isobject(obj) w "Нет объекта" quit
	set st=..GetPropertyDefinition(obj,.gn)
	if 'st w $System.Status.GetErrorText(st) quit  ;##class(%Library.Global).Quote(
	set orderProp=obj.#AppORDERPROPERTY
	write "<table>"
	// Упорядоченный вывод полей
	if orderProp'="" {
		for i=1:1:$l(orderProp,",") { s nameProp=$ZStrip($p(orderProp,",",i),"<>WCP")
		 	continue:nameProp=""
			do ..ShowProp(obj,nameProp,.gn) ;gn("Properties")
		}
	} //вывод полей по умочанию
	else {
		set p=""
		for  { s p=$o(gn("Properties",p)) q:p=""  ;q:'$d(@gn@(p))  
			do ..ShowProp(obj,p,.gn)
		}
	}
	write "<tr><td style='text-align: right;'>"
		set onclick="$('#"_PrefixIdDIV_"MainContent').load('App.Action.cls',$('#"_PrefixIdDIV_"MainForm').serializeArray());"
		if Mode {
			write "<input type=hidden name=appNsp value='"_$zu(5)_"'>"
			write "<input type=hidden name=appClass id=appClass value='App.Form'>"
			write "<input type=hidden name='appMethod' id='appMethod' value=''>"
			write "<input type=hidden name=appPar value='"_obj.%Id()_","_obj.%ClassName(1)_"'>"

			if Mode'["WithoutSave" {
				set buttval=$s(obj.%Id()'="":"Сохранить",1:"Создать")
				do ..ButtonMake(buttval,"$('#appMethod').attr('value','ObjectSave');"_onclick,"appButtonSave")
			}
			if Mode'["WithoutDel" {
				if obj.%Id() w "&nbsp; " d ..ButtonMake("Удалить","if (confirm('Удалить, вы уверены ?')) {$('#appMethod').attr('value','ObjectDelete');"_onclick_"}","appButtonDelete")
			}
			if obj.%Id(),Mode["WithCreate" {
			  w "&nbsp; " do ..ButtonMake("Сохранить как новый","$('#appMethod').attr('value','ObjectSaveAsNew');"_onclick,"appButtonSaveAsNew")
			  ;do ..ButtonMake("Новый","$('#appMethod').attr('value','ObjectNew');$('#appPar').attr('value',',"_obj.%ClassName(1)_","_Mode_"');"_onclick,"appButtonNew")
			}
		}
		if Mode'["WithoutCancel" {
			write "</td><td style='text-align: left;'>"
				do ..ButtonMake("Отмена","","appButtonCancel")
			write "</td><tr>"
		}
	write "</table>"
	;do ##class(App.Form).BlockUI(0)
	quit $$$OK
}

/// Вывеcти кнопку сначало
ClassMethod ButtonRef(value = "Сначала", onclick = "top.document.location.reload();", id = "appButtonRef")
{
	do ..ButtonMake(value,onclick,id)
	quit $$$OK
}

/// Вывеcти кнопку назад
ClassMethod ButtonBack(value = "Назад", onclick = "window.history.back();", id = "appButtonBack")
{
	do ..ButtonMake(value,onclick,id)
	quit $$$OK
}

/// Вывеcти кнопку
ClassMethod ButtonMake(value = "", onclick = "", id)
{
  	write $$$appButton(id,"onclick="""_$g(onclick)_"""",value)
  	;w " <input id='appButtonSave' class='ui-button ui-corner-all ui-widget' type=button onclick='"_$g(onclick)_"' value='"_value_"'>"
	quit $$$OK
}

}

