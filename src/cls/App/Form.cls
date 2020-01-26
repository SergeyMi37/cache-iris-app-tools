Include App.LogMacro

/// The representation of the stored classes for viewing and editing
Class App.Form [ Abstract, DependsOn = App.msg ]
{

/// prefix the field name of the object
Parameter PREFIXFIELD = "appfield";

/// To get all descendants for a class
ClassMethod GetSubclassOf(super = "App.Form")
{
 set query=##class(%Library.ResultSet).%New("%Dictionary.ClassDefinition:SubclassOf")
 set st=query.Execute(super)
 Q query
}

/// To obtain the extended properties of the field object
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
				s out("filesStore")={}.$$$jsonFromJSON(json).filesStore
				if out("filesMethod")="" set out("filesMethod")="##class(App.type).UploadFilesJS(%id)"
				if "TempDir"[out("filesStore") set out("filesStore")=##class(%File).GetDirectory(##class(%File).TempFilename())
				if "stream"=out("filesStore") set out("filesStore")=$$defdir^%SYS.GLO($ZU(5))_"stream"_$$$slash
			}
			elseif $g(out("inputpattern"))["select" {
				s out("selectMethod")={}.$$$jsonFromJSON(json).selectMethod
			}
			set out("attr")={}.$$$jsonFromJSON(json).attr
			set out("onchange")={}.$$$jsonFromJSON(json).onchange
			set out("readOnly")={}.$$$jsonFromJSON(json).ReadOnly
			if out("displayname")'="" set out("description")=out("displayname")
			else  s out("description")=$p(out("description"),"{",1)
			// enable the event handler
			if $g(out("onchange"))'="" {
				s out("attr")=out("attr")_" onchange='"_out("onchange")_"'" ;alert(this.value)'"
			}
			
		} catch e { w "Error: "_$ze }
	}
	elseif out("description")="" {
		set out("description")=propName
	}
}

/// Get all property values
ClassMethod GetPropVal(obj, propName, gn, nameAttr)
{
	;q:nameAttr=""||(propName="")||('$g(gn)) "" 
	;i '$d(gn("Properties",propName)) q ""
	q $g(gn("Properties",propName,nameAttr))
	;set col=$g(@gn@(-1,nameAttr))
	;quit:'col ""
	;quit $lg($g(@gn@(row)),col)
}

/// Write the string object properties
ClassMethod ShowProp(obj, propName, gn, PrefixIdDIV, Mode)
{
	set sysType=..GetPropVal(obj,propName,.gn,"Type")
	if sysType["%Stream." q $$$OK ;TODO exception
	set Name=..GetPropVal(obj,propName,.gn,"Name")
	if Name="" q $$$ERROR($$$GeneralError,"No Exsist Property "_propName) 
	set Required=..GetPropVal(obj,propName,.gn,"Required")
	set ReadOnly=..GetPropVal(obj,propName,.gn,"ReadOnly")
	set Parameters=..GetPropVal(obj,propName,.gn,"Parameters")
	set Value=$property(obj,Name)
	set redstar="" if Required s redstar="<font color=red title='"_$$$aText("Required field","")_"'>*</font>"
	
	do ..GetJsonProp(obj, propName, .gn, .pr)
	if 'ReadOnly set ReadOnly=$g(pr("readOnly"))
	if 'Mode set ReadOnly=1
	
	set label=pr("description")_redstar
	if Mode["ShowFieldName" set label=label_"<br>("_propName_")"
	if $g(pr("inputpattern"))="hidden" set label=""
	write "<td style='text-align: right;' title='"_$g(pr("title"))_"' ><label>"_label_"</label></td>"
	write "<td style='text-align: left;' title='"_$g(pr("title"))_"' >"
	s pr("attr")=$g(pr("attr"))_" "_$s(Required:"Required",1:"")_" "_$s(ReadOnly:"disabled",1:"")
	
	s %id=$g(PrefixIdDIV)_..#PREFIXFIELD_Name
	s %val=$g(Value)
	s pr("WebComp-size")=" size=50 " if pr("attr")["size" set pr("WebComp-size")=""
	
	if sysType="%Boolean",pr("inputtype")'="checkbox" {
		d ##class(App.Form).SelectFieldYesNo(%id,%val)
	}
	elseif sysType="%Date" {
	 	write $$$appText(%id," size=10 "_pr("attr"),%val)
	}
	else {  //%String
		if $g(pr("inputpattern"))="textarea" {
			if pr("attr")'["cols" s pr("attr")=pr("attr")_" cols=77 "
			if pr("attr")'["rows" s pr("attr")=pr("attr")_" rows=3 "
			write $$$appTextarea(%id,pr("attr"),%val)
		}
		elseif $g(pr("inputpattern"))="hidden" {
			write "<input type='hidden' id='"_%id_"' name='"_%id_"' "_$g(pr("attr"))_" value='"_%val_"'>"
		}
		elseif $g(pr("inputpattern"))="autocomplete" {
			set met=$g(pr("autocompleteMethod"))
			if met'=""  xecute "do "_met
			write $$$appAutocomplete(%id," "_pr("attr"),%val)
		}
		elseif $g(pr("inputpattern"))="files" {
			write ..WebCompShowFiles(obj,.pr,Mode,%id,%val)
		}
		elseif $g(pr("inputpattern"))="select" {
			set met=$g(pr("selectMethod"))
			if met'="" {
				;;w met
				if (met["{") { //a list of json
					;TODO
				}
				else { //a list of functions
					xecute "do "_met
				}
			}
			;w $$$appInputHidden(.%id," "_attr,%val)
		}
		elseif $g(pr("inputpattern"))="selectize" {
			s met=$g(pr("selectMethod"))
			write "<input type='text' id='"_%id_"' name='"_%id_"' class='input-tags demo-default ui-corner-all ui-widget ui-widget-content' value='"_%val_"'>"
			if met'="" {
				xecute "do "_met
			}
		}
		elseif pr("inputtype")="checkbox" {
			;set onclick="$('#"_%id_"').attr('value',$('#"_%id_"checkbox').prop('checked') ? 1 : 0 );"
			;write $$$appInput(%id_"checkbox"," onclick="""_onclick_""" type='"_pr("inputtype")_"' "_pr("WebComp-size")_pr("attr")_" "_$s(%val:"checked ",1:""),%val)
			;write $$$appInputHidden(%id,"",%val)
			write ..WebCompShowCheckbox(,.pr,Mode,%id,%val)
		}
		elseif pr("inputtype")'="" {
			write $$$appInput(%id," type='"_pr("inputtype")_"' "_pr("WebComp-size")_pr("attr"),%val)
		}
		elseif Parameters["{" {
			if {}.$$$jsonFromJSON(Parameters).VALUELIST'="" {
			  set vl={}.$$$jsonFromJSON(Parameters).VALUELIST
			  set dl={}.$$$jsonFromJSON(Parameters).DISPLAYLIST
			  ;	s ^tmpMSW(1,$i(^tmpMSW),"Parameters")=$lb(propName,vl,dl)
			  set:dl="" dl=vl
			  do ..SelectField($lfs(vl),,$lfs(dl),.gn2,,%id,%val,600)
			} else {
				write $$$appText(%id,pr("WebComp-size")_pr("attr"),%val)
			}
		}
		else {write $$$appText(%id,pr("WebComp-size")_pr("attr"),%val)
		}
	}
	write "</td>"
	Quit $$$OK
}

/// Display checkbox
ClassMethod WebCompShowCheckbox(obj, ByRef pr, Mode, %id, %val, ByRef ext)
{
	set onclick="$('#"_%id_"').attr('value',$('#"_%id_"checkbox').prop('checked') ? 1 : 0 );"
	;set ret=$$$appInput(%id_"checkbox"," onclick="""_onclick_""" type='checkbox' "_$g(pr("WebComp-size"))_$g(pr("attr"))_" "_$s(%val:"checked ",1:""),%val)
	set ret=$$$appCheck(%id_"checkbox"," onclick="""_onclick_""" "_$g(pr("WebComp-size"))_$g(pr("attr"))_" "_$s(%val:"checked ",1:""),%val)
	set ret=ret_$$$appInputHidden(%id,"",%val)
	quit ret
}

/// Display component Files
ClassMethod WebCompShowFiles(obj, ByRef pr, Mode, %id, %val, ByRef ext)
{
	set ret=""
	set met=$g(pr("filesMethod"))
	set attr=$g(pr("WebComp-size"))_$g(pr("attr"))
	;if attr'["disabled" set attr=attr_" disabled "
	for ff="filesStore" set %id(ff)=$g(pr(ff))
	if Mode {
		if met'="" 	s %obj=obj  x "set %ret="_$e(met,1,*-1)_",.%id)"
		set ret=$g(%ret)_$$$appText(%id,attr,%val)
	} else {
		set ret=ret_$$$appText(%id,attr,%val)
	}
	;pr("sysType")
	if %val'="" {
		set fileName=$g(pr("filesStore"))_%val
		;W fileName
		if ##class(App.DownloadCSP).GetFileId(fileName,.url) { 
			set ext("aurl")="<a href='"_url_"'>"_$$$aText("DownLoad","")_"</a>"
			set ext("url")=url
			set ext("fileName")=fileName
			s ret=ret_" "_ext("aurl")
		}
	}
	quit ret
}

/// Keep object default
ClassMethod ObjectDelete(Param = "", Ref = 0)
{
	set id=$g(Param("objId")) ;$p(Param,",")
	set Class=$g(Param("ClassName")) ;$p(Param,",",2)
	set PrefixIdDIV=$g(Param("pref")) ;$p(Param,",",3)
	#dim obj As %Persistent
	if id="" w $$$appError($$$aText("Undefined object identifier",""))_"<br>" d:'Ref ..ButtonRef() q
	set obj=$classmethod(Class,"%OpenId",id)
	if '$isobject(obj) w $$$appError($$$aText("Undefined object",""))_"<br>" d:'Ref ..ButtonRef() q
	set st=obj.%DeleteId(obj.%Id())
	if 'st w $$$appError($System.Status.GetErrorText(st)) w "<br>" d:'Ref ..ButtonRef() q
	write $$$appMsg($$$aText("The object is removed",""))
	write "<br>" d:'Ref ..ButtonRef() 
	q
}

/// To create the object as new
ClassMethod ObjectSaveAsNew(Param = "")
{
	s Param("objId")=""
 d ..ObjectSave(.Param)
}

/// To create a new object by default
ClassMethod ObjectNew(Param = "")
{
 s obj=..GetObj(Param)
 d ..Show(obj,$p(Param,",",3,99))
 q $$$OK
}

/// To get the object from the argument
ClassMethod GetObj(Par) As %Status
{
	if $p(Par,",",1) = "" s obj=$classmethod($p(Par,",",2),"%New")
	else  s obj=$classmethod($p(Par,",",2),"%OpenId",$p(Par,",",1))
	q obj
}

/// Save the default object
ClassMethod ObjectSave(Param = "", Ref = 0)
{
	set id=$g(Param("objId")) ;$p(Param,",")
	set Class=$g(Param("ClassName")) ;$p(Param,",",2)
	set PrefixIdDIV=$g(Param("pref")) ;$p(Param,",",3)
	set Mode=$g(Param("mode"))
	if Mode["WithoutRef" s Ref=1
	if id="" s obj=$classmethod(Class,"%New")
	else  s obj=$classmethod(Class,"%OpenId",id)
	if '$isobject(obj) w $$$appError(..UikitNote($$$aText("Undefined object","")))_"<br>" d:'Ref ..ButtonRef() q ""
	;set gn="%prop"
	set st=..GetPropertyDefinition(obj,.gn)
	if 'st w $$$appError(..UikitNote($System.Status.GetErrorText(st)))_"<br>" d:'Ref ..ButtonRef() q ""
	set prefix=$g(PrefixIdDIV)_..#PREFIXFIELD
	set i=prefix
	;m $$$AppL("SPZ",".gn")=gn
	;m m=%request.Data	zw m
	;zw gn
	;zw Param
	if '$d(Param("%request.Data")) {
		for { set i=$o(%request.Data(i)) quit:i=""  quit:i'[prefix
			set nameProp=i
			s Value=$g(%request.Data(i,1))
			set:nameProp'="" Param("%request.Data",nameProp)=Value
		}
	} 
	s i=""
	for { set i=$o(Param("%request.Data",i)) quit:i=""
			set nameProp=$p(i,prefix,2)  
			continue:nameProp=""
			set Value=$g(Param("%request.Data",i))
			continue:'$d(gn("Properties",nameProp))
			
			if ..GetPropVal(obj,nameProp,.gn,"Required"),Value="" {
				;to get property - description of pr("description")
				d ..GetJsonProp(obj, nameProp, .gn, .pr)
				s err=$g(err)_"<li>"_nameProp_" "_$$$aText("Mandatory field is empty","")_" ("_$g(pr("description"))_")</li>" continue
			}
			if $d(gn("Properties",nameProp)) {
				;set sysType=..GetPropVal(obj,nameProp,.gn,"Type")
				; if the property is - the stream from the stored file
				if 0,sysType["%Stream." {
					set filename=##class(%File).GetDirectory(##class(%File).TempFilename())_Value
					Set file = ##class(%File).%New(filename)
  					set sc=file.Open("RU") // same flags as the OPEN command
					;Do $method(obj,nameProp,"CopyFrom",file)
					;write "<br>"_filename ;continue
					;s stream=##class(%Stream.FileBinary).%New()
					;Set sc=stream.LinkToFile(filename)
					if 'sc {
						;write $$$appError($System.Status.GetErrorText(sc))
					} else {
						set $property(obj,nameProp)=file ;stream
						set file=""
					}
				}
				else {
					set $property(obj,nameProp)=Value
				}
			}
	}
	if $d(err) w "<br><br>"_$$$appError(..UikitNote($$$aText("Error checking properties",""))_"<hr>"_$g(err)) d:'Ref ..ButtonRef() q ""
	set st=obj.%Save()
	if 'st w "<br><br>"_$$$appError(..UikitNote($System.Status.GetErrorText(st)))_" <br>" d:'Ref ..ButtonRef() q ""
	write "<br><br>"_$$$appMsg(..UikitNote($$$aText("Saved",""),"success"))_"<br>" d:'Ref ..ButtonRef()
	quit obj
}

/// To list the properties of a class
ClassMethod UikitNote(msg, status = "warning")
{
	$$$jsstart
	w "UIkit.notification({message: '"_msg_"', status: '"_status_"',pos: 'top-center'});"
	$$$jsstop
	q msg
}

/// To list the properties of a class
ClassMethod GetPropertyDefinition(obj, gn)
{
	; Get all object properties
	;s sql="SELECT cls.Name, prop.Name, prop.Type, prop.Description FROM ""%Dictionary"".ClassDefinition cls  JOIN ""%Dictionary"".PropertyDefinition prop ON cls.Name = prop.parent WHERE cls.Name = '"_obj.%ClassName(1)_"'"
	;set sql="SELECT * from ""%Dictionary"".PropertyDefinition where parent like '"_obj.%ClassName(1)_"'"
	;set st=##class(App.sys).SaveSQL(sql,gn,1)
	set st=##class(App.LogInfoPane).GetClassDef(obj.%ClassName(1),"",.gn,0)
	if 'st q st
	;zw gn("Properties")
	quit $$$OK
}

/// The output type field select Yes or no
/// do ##class(App.Form).SelectFieldYesNo("test","0")
ClassMethod SelectFieldYesNo(idSelect = "selectmenu", dfltKey = "") As %Status
{
	do ..SelectField($lb(0,1),,$lb($$$aText("No",""),$$$aText("Yes","")),.gn,,idSelect,dfltKey,100)
	q $$$OK
}

/// The output fields of type select
/// do ##class(App.Form).SelectField($lb("",0,1),"alert(1);",$lb("","No","Yes"),.gn,,"test","0",50) 
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

/// To objects in the selector for small samples 
/// Return in the same row or in the global
/// sql query
/// ONCHANGE = js function on the event in the ONCHANGE salestore
/// ValueList = list of fields for the output Value
/// gnRet - return the array by reference
ClassMethod SelectObj(sql, ONCHANGE = "", ValueList = "", gnRet, idSelect = "selectmenu") As %Status
{
	kill gnRet
	set gn="^||TempPack"
	set selectNS="<SELECT id='"_idSelect_"' > "
	set selectNS=selectNS_" <OPTION  VALUE=''></OPTION>"
	set gnRet($i(gnRet))=selectNS
	set st=##class(App.sys).SaveSQL(sql,gn)
	if 'st quit st
	if ValueList="" set ValueList=$lg(@gn@(0),1)_","_$lg(@gn@(0),1) ///The first field of the query should be identificator
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

/// To block or unblock the screen
/// do ##class(App.Form).BlockUI(1,"Loading form")
ClassMethod BlockUI(mode = 1, msg = "...Loading")
{
 $$$jsstart 
  w:mode $$$blockui(msg)
  w:'mode "$.unblockUI();"
 $$$jsstop
 q $$$OK
}

/// Show object 
/// Obj - the class instance
/// Mode = 0 safe mode
/// Mode = 1 edit mode with all buttons
/// Mode = "1,WithoutSave,WithoutDel,WithCreate,WithoutRef" edit mode without buttons
/// Mode = "1,ShowFieldName" - show the field names
ClassMethod Show(obj, Mode = 0, PrefixIdDIV = "", orderProp = "")
{
	if '$isobject(obj) w $$$aText("No object","") quit
	set st=..GetPropertyDefinition(obj,.gn)
	if 'st w $System.Status.GetErrorText(st) quit  ;##class(%Library.Global).Quote(
	if orderProp=""	set orderProp=obj.#AppORDERPROPERTY
	write "<table>"
	// An ordered display of fields
	if orderProp'="" {
		if orderProp[":" { ;In multiple columns
			for ii=1:1:$l(orderProp,":") { s col=$ZStrip($p(orderProp,":",ii),"<>WCP")
				continue:col=""
				write "<tr>"
				for i=1:1:$l(col,",") { s nameProp=$ZStrip($p(col,",",i),"<>WCP")
			 		if nameProp="" w "<td></td><td></td>" continue
					do ..ShowProp(obj,nameProp,.gn,PrefixIdDIV,Mode)
				}
				write "</tr>"
			}
		}
		else { ;in one column
			for i=1:1:$l(orderProp,",") { s nameProp=$ZStrip($p(orderProp,",",i),"<>WCP")
			 	continue:nameProp=""
			 	write "<tr>"
				do ..ShowProp(obj,nameProp,.gn,PrefixIdDIV,Mode) ;gn("Properties")
				write "</tr>"
			}
		}
	} //the output fields by default
	else {
		set p=""
		for  { s p=$o(gn("Properties",p)) q:p=""  ;q:'$d(@gn@(p))  
			write "<tr>"
			do ..ShowProp(obj,p,.gn,PrefixIdDIV,Mode)
			write "</tr>"
		}
	}
	write "<tr><td style='text-align: right;'>"
		;set onclick="AppAct('"_PrefixIdDIV_"MainForm','"_PrefixIdDIV_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":*:&objId="_obj.%Id()_"&ClassName="_obj.%ClassName(1)_"&pref="_PrefixIdDIV_"&mode="_Mode_"');"
		set onclick=##class(App.Action).WriteAppAct(%request,PrefixIdDIV_"MainForm",PrefixIdDIV_"MainContent",$zu(5),..%ClassName(1),"*","&objId="_obj.%Id()_"&ClassName="_obj.%ClassName(1)_"&pref="_PrefixIdDIV_"&mode="_Mode)
		
		if Mode {
			
			if Mode'["WithoutSave" {
				set buttval=$s(obj.%Id()'="":$$$aText("Save",""),1:$$$aText("Create",""))
				do ..ButtonMake(buttval,$replace(onclick,"*","ObjectSave"),"appButtonSave") ;ObjectSaveAsNew
			}
			if Mode'["WithoutDel" {
				if obj.%Id() w "&nbsp; " d ..ButtonMake($$$aText("Delete",""),"if (confirm('"_$$$aText("Delete, are you sure?","")_"')) { "_$replace(onclick,"*","ObjectDelete")_"}","appButtonDelete")
			}
			if obj.%Id(),Mode["WithCreate" {
			  w "&nbsp; " do ..ButtonMake($$$aText("Save As New",""),$replace(onclick,"*","ObjectSaveAsNew"),"appButtonSaveAsNew")
			}
		}
		if Mode'["WithoutCancel" {
			write "</td><td style='text-align: left;'>"
				do ..ButtonMake($$$aText("Cancel",""),"","appButtonCancel")
			write "</td><tr>"
		}
	write "</table>"
	;do ##class(App.Form).BlockUI(0)
	quit $$$OK
}

/// Bring the first button
ClassMethod ButtonRef(value = {$$$aText("Begin","")}, onclick = "top.document.location.reload();", id = "appButtonRef")
{
	do ..ButtonMake(value,onclick,id)
	quit $$$OK
}

/// Display back button
ClassMethod ButtonBack(value = {$$$aText("Back","")}, onclick = "window.history.back();", id = "appButtonBack")
{
	do ..ButtonMake(value,onclick,id)
	quit $$$OK
}

/// Withdraw button
ClassMethod ButtonMake(value = "", onclick = "", id, title = "")
{
  	write $$$appButton(id,"onclick="""_$g(onclick)_""" "_$s(title="":"",1:"title="""_title_""""),value)
  	;w " <input id='appButtonSave' class='ui-button ui-corner-all ui-widget' type=button onclick='"_$g(onclick)_"' value='"_value_"'>"
	quit $$$OK
}

/// To obtain the value of the parameter named 
/// ExtProp=1 to extended properties, for example for the type of file
/// if ##class(App.Form).GetValueByName("App.Parameter","TestFiles","Value",.Val,1) zwrite Val
ClassMethod GetValueByName(class, name, NameField = "Value", ByRef Val, ExtProp = 0) As %Status
{
	KILL Val
	set Val=""
	set st=$$$OK
	s gn="^||tmpGetValueName"
	set tab=##class(App.type).GetTableName(class)
	s st=##class(App.sys).SaveSQL("select top 1 * from "_tab_" where Name='"_name_"'",gn)
	if 'st quit st
	i $g(@gn@(-1,NameField))="" q $$$ERROR($$$GeneralError,"undefined field: "_NameField)
 	i '$d(@gn@(1)) q $$$ERROR($$$GeneralError,"undefined "_name)
 	s Val=$lg(@gn@(1),@gn@(-1,NameField))
 	if ExtProp {
	 	set id=##class(App.sys).GetValue(gn,1,"ID")
	 	set obj=##class(App.Form).GetObj(id_","_class)
	 	if $isobject(obj) {
			set st=..GetPropertyDefinition(obj,.prop)
			if 'st quit st
			m Val("Properties")=prop("Properties",NameField)
			d ..GetJsonProp(obj, NameField, .prop, .pr)
			m Val("PropJson")=pr
			m Val("obj")=obj
			if $g(pr("inputpattern"))="files" {
				set comp=..WebCompShowFiles(obj,.pr,0,NameField,Val,.Ext)
				m Val=Ext
			}
	 	}
 	}
	q st
}

/// To obtain the value of parameter ID 
/// ExtProp=1 to extended properties, for example for the type of file
/// if ##class(App.Form).GetValueByIdField("App.Parameter","15","ImageFile",.Val,1) zwrite Val
ClassMethod GetValueByIdField(class, id, NameField, ByRef Val, ExtProp = 0) As %Status
{
	KILL Val
	set Val=""
	set st=$$$OK
	s gn="^||tmpGetValueName"
	set tab=##class(App.type).GetTableName(class)
	s st=##class(App.sys).SaveSQL("select top 1 * from "_tab_" where id='"_id_"'",gn)
	if 'st quit st
	i $g(@gn@(-1,NameField))="" q $$$ERROR($$$GeneralError,"undefined field: "_NameField)
 	i '$d(@gn@(1)) q $$$ERROR($$$GeneralError,"undefined "_name)
 	s Val=$lg(@gn@(1),@gn@(-1,NameField))
 	if ExtProp {
	 	;set id=##class(App.sys).GetValue(gn,1,"ID")
	 	set obj=##class(App.Form).GetObj(id_","_class)
	 	if $isobject(obj) {
			set st=..GetPropertyDefinition(obj,.prop)
			if 'st quit st
			m Val("Properties")=prop("Properties",NameField)
			d ..GetJsonProp(obj, NameField, .prop, .pr)
			m Val("PropJson")=pr
		    m Val("obj")=obj
			if $g(pr("inputpattern"))="files" {
				set comp=..WebCompShowFiles(obj,.pr,0,NameField,Val,.Ext)
				m Val=Ext
			}
	 	}
 	}
	q st
}

/// Display a table from a matrix
/// do ##class(App.Form).DrawTable(.matrix) 
ClassMethod DrawTable(matrix) As %Status
{
	set r=$o(matrix(""))
	quit:r="" $$$OK
	&html<
 <table>
    <thead>
      <tr>
        <th></th>>
        s c=""
        for { set c=$o(matrix(r,c)) quit:c=""
        	write "<th>"_$g(matrix(r,c))_"</th>"
        }
      &html<
      </tr>
    </thead>
    <tbody>
>
     for { set r=$o(matrix(r)) quit:r=""
     	set c=""
     	set first=1
     	write "<tr>"
 		for { set c=$o(matrix(r,c)) quit:c=""
        	if first {
	        	write "<th>"_$g(matrix(r,c))_"</th>" set first=0
        	}
        	else {
         		write "<td>"_$g(matrix(r,c))_"</td>"
        	}
 		}
 		write "</tr>"
       }
    &html<
    </tbody>
   </table>
	>
}

}

