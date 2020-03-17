Include App.LogMacro

Class App.security [ Abstract, DependsOn = App.msg ]
{

/// Increase system security to LockDown
/// The method disables services and applications as in LockDown. Deletes the areas "DOCBOOK", "ENSDEMO", "SAMPLES"
/// The method enables auditing and configures registration of all events in the portal, except for switching the log
/// and modification of system properties
/// For all predefined users, change the password and change the properties as in LockDown
/// 	newPassword - new single password instead of SYS. For LockDown security level, it has an 8.32ANP pattern
/// 	sBindings = 1 Service% service_bindings enable
/// 	sCachedirect = 1 Service% service_cachedirect enable
/// 	InactiveLimit=90  
/// 	DemoDelete=0 Demoens,Samples namespaces are being deleted 
/// 	AuditOn=1 
/// 	sECP = 1 Service% service_ecp enable
/// 	sBindingsIP - list of ip addresses with a semicolon for which to allow CacheStudio connection.
/// 
/// For ECP configurations, you need to add the addresses of all servers and clients to allow connection on% Net.RemoteConnection to remove "abandoned" tasks
/// 	sCachedirectIP - list of ip addresses with a semicolon for which to allow CIMModeler connection.
/// 	sECPIP - list of ip addresses with a semicolon for which to allow connection to the ECP server.
/// 	AuthLDAP = 1 In addition to the password, also enable LDAP authentication
/// 	Application example:
/// 	d ##class(App.security).LockDown("qwe123!@#",.msg,1,1,0,0,0,0,"127.0.0.1","127.0.0.1")
/// 	d ##class(App.security).LockDown("qwe123!@#",.msg,1,1,0,0,1,0,"127.0.0.1","127.0.0.1",,1)
ClassMethod LockDown(newPassword = "", Warn, sBindings = "", sCachedirect = "", InactiveLimit = 90, DemoDelete = 0, AuditOn = 1, sECP = "", sBindingsIP = "", sCachedirectIP = "", sECPIP = "", AuthLDAP = 0) As %Status
{
	set ons = $zu(5)
	write !,"Applications and services will be authenticated by "_$s('AuthLDAP:"password",1:"password and LDAP")
	set AutheEnabled=$s(AuthLDAP:2080,1:32)
	if DemoDelete,$zv["IRIS" set DemoDelete=0	
	zn "%sys"
	if newPassword'="" {
		if newPassword'?8.32ANP s text="Password does not match the pattern 8.32ANP" write !,text QUIT $$$ERROR(text)
		write !,"Password is reset to predefined users"
		set tSC=##class(App.security).ChangePassword(newPassword, ##class(App.security).GetPreparedUsers())
		if '$$$ISOK(tSC) QUIT $$$ERROR(tSC)
	}
	write !,"Modification of service properties:"
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare("select NameLowerCase,ClientSystems FROM Security.Services")
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
		set text="Service configuration error :"_$SYSTEM.Status.GetErrorText(tSC) write !,text
		QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			set name=result.Data("NameLowerCase")
			#;skipping network services
			continue:(name="%service_mirror")||(name="%service_shadow")||(name="%service_datacheck")
			kill prop
			set prop("Enabled")=0
			if name="%service_csp"||(name="%service_console")||(name="%service_login") {
				set prop("Enabled")=1 ; turn on
				if name'="%service_csp" s prop("AutheEnabled")=AutheEnabled
				else  s prop("AutheEnabled")=96
			}
			if $G(sBindings),name="%service_bindings" {
				set prop("Enabled")=1
				set prop("AutheEnabled")=AutheEnabled
				set Warn($i(Warn))="If the current system does not intend to develop or edit the source code in CacheStudio, then it is better to turn off the service "_name
				set prop("ClientSystems")=sBindingsIP
			}
			if $G(sCachedirect),name="%service_cachedirect" {
				set prop("Enabled")=1 ; turn on
				set prop("AutheEnabled")=96
				set Warn($i(Warn))="If the current system does not intend to edit the transformation templates using the CIMModeler utility, then it is better to turn off the service "_name
				set prop("ClientSystems")=sCachedirectIP
			}
			if $G(sECP),name="%service_ecp" {
				set prop("Enabled")=1
				set Warn($i(Warn))="If the ECP configuration is not enabled on the current system, it is better to turn off the service "_name
				set:$g(sECPIP)="" Warn($i(Warn))="If ECP configuration is enabled, it is best to limit the connection of ECP clients to the ECP server"
				set prop("ClientSystems")=sECPIP
			}
			set tSC=##class(Security.Services).Modify(name,.prop)
			if '$$$ISOK(tSC) write !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}
	write !,"Passwords are created for all CSP applications."
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare("select Name FROM Security.Applications")
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
		set text="Application setup error :"_$SYSTEM.Status.GetErrorText(tSC)  write !,text QUIT $$$ERROR(text)
	}
	else {
		#; List of disconnected applications
		set appDisabled("/csp/ensdemo")=1
		set appDisabled("/csp/samples")=1
		set appDisabled("/csp/user")=1
		set appDisabled("/isc/studio/usertemplates")=1
		set appDisabled("/csp/docbook")=1  
		set appDisabled("/csp/documatic")=1
		set appDisabled("/isc/studio/rules")=1
		set appDisabled("/isc/studio/templates")=1
		while result.Next() {
			set CSP=result.Data("Name")
			set csp=$zconvert(CSP,"L")
			kill prop
			if $g(appDisabled(csp)) {
				set prop("Enabled")=0
			} else {
				  set prop("Enabled")=1
			}
		 set prop("AutheEnabled")=AutheEnabled 
		 set tSC=##class(Security.Applications).Modify(CSP,.prop)
		 if '$$$ISOK(tSC) write !,csp_" : Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}
	if DemoDelete {
		write !,"Demo namespaces are being deleted."
		for name="ENSDEMO","SAMPLES" {
			do:##class(%Dictionary.CompiledClass).%ExistsId("%Library.EnsembleMgr")
			set tSC = ##class(Config.Namespaces).Delete(name)
			if $$$ISERR(tSC) set text="Delete Error "_name_" :"_$system.Status.GetErrorText(tSC) w !,text
			if $$$ISOK(tSC) write !,"Deleted "_name
		}
	}
	write !,"There is a modification of the basic system settings"
	#dim ss As Security.System  = ##class(Security.System).%OpenId("SYSTEM")
	set ss.PasswordPattern="8.32ANP"
	set ss.AuditEnabled=+AuditOn
	set ss.InactiveLimit=InactiveLimit
	set tSC=ss.%Save()
	if '$$$ISOK(tSC) s text="Error setting basic security settings :"_$SYSTEM.Status.GetErrorText(tSC)  write !,text QUIT $$$ERROR(text)
	if AuditOn {
		write !,"Event Setup AUDIT :"
		Set rs = ##class(%ResultSet).%New("Security.Events:ListActivate")
		Set tSC = rs.Execute()
		if $$$ISERR(tSC) set text="Event setting error AUDIT:"_$system.Status.GetErrorText(tSC) write !,text QUIT $$$ERROR(text)
		set On("%Ensemble/%Message/ViewContents")=1
		set On("%System/%DirectMode/DirectMode")=1
		set On("%System/%Login/Login")=1
		set On("%System/%Login/LoginFailure")=1
		set On("%System/%Login/Logout")=1
		set On("%System/%Login/Terminate")=1
		set On("%System/%Security/ApplicationChange")=1
		set On("%System/%Security/AuditChange")=1
		set On("%System/%Security/AuditReport")=1
		set On("%System/%Security/DBEncChange")=1
		set On("%System/%Security/DomainChange")=1
		set On("%System/%Security/LoginRuleChange")=1
		set On("%System/%Security/Protect")=1
		set On("%System/%Security/ResourceChange")=1
		set On("%System/%Security/RoleChange")=1
		set On("%System/%Security/ServiceChange")=1
		set On("%System/%Security/SSLConfigChange")=1
		set On("%System/%Security/SystemChange")=1
		set On("%System/%Security/UserChange")=1
		set On("%System/%System/AuditRecordLost")=1
		set On("%System/%System/ConfigurationChange")=1
		set On("%System/%System/JournalChange")=0
		set On("%System/%System/RoutineChange")=1
		set On("%System/%System/Start")=1
		set On("%System/%System/Stop")=1
		set On("%System/%System/SuspendResume")=1
		set On("%System/%System/UserEventOverflow")=1
		While rs.Next() {
			set name = $G(rs.Data("Source"))_"/"_$G(rs.Data("Type"))_"/"_$G(rs.Data("Name"))
			if $DATA(On(name)) {
				kill pro
				do ##class(Security.Events).Get($g(rs.Data("Source")),$G(rs.Data("Type")),$G(rs.Data("Name")),.pro)
				if $d(pro) {
					if pro("Enabled")'=(+$G(On(name))) {
						if ##Class(Security.Events).Exists(name,,,.Event,.Status) {
							set Event.Enabled=+$G(On(name))
							set tSC=Event.%Save()
							if '$$$ISOK(tSC) w !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
							else  write !,name_" changed"
						}
					}
				}
			}
		}
		do rs.Close()
	}
	zn ons
	quit $$$OK
}

/// Save Access Rights
/// d ##class(App.security).UiSavePermiss(.Par)
ClassMethod UiSavePermiss(Par = "") As %Status
{
	do ##class(App.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")

	;Geting elements from form and prepare array Par
	s name=##class(App.Action).GetElemForm(%request,.Par,divId_"name")	
	;set roles=$g(Par("%request.Data",divId_"roles"))
	
	set i=""
	for { set i=$o(Par("%request.Data",i)) quit:i=""
		if i[(divId_"Matr0") {
			set val=$g(Par("%request.Data",i))
			if val'["unchecked" {
				set chk(i)=val
				set us=$p(i,"0",2)
				set ro=$p(i,"0",3)
				if $e(ro,1)="p" s ro="%"_$e(ro,2,*)
				if ro["_pD" s ro=$replace(ro,"_pD","_%D")
				set users(us,ro)=val
			}
		}
	}

	new $NAMESPACE
  	set $NAMESPACE = "%SYS"
	set us=""
	for { set us=$o(users(us)) quit:us=""
			set tSC=##class(Security.Users).Get(us,.prop)
			if '$$$ISOK(tSC)  write $$$appError(us_": Error="_$SYSTEM.Status.GetErrorText(tSC)) quit
			set roles=","_prop("Roles")_","
			kill prop
			set ro=""
			for { set ro=$o(users(us,ro)) quit:ro=""
				if $g(users(us,ro)) {
					if roles'[(","_ro_",") set roles=roles_ro_","
				}else {
					if roles[(","_ro_",") set roles=$replace(roles,ro_",","") set:$e(roles,*)'="," roles=roles_","
				}
			}
			set:$e(roles,1)="," roles=$e(roles,2,*)
			set:$e(roles,*)="," roles=$e(roles,1,*-1)
			set prop("Roles")=roles
			;zw prop
			;##class(App.form).UikitNote($$$aText("Saved",""),"success")
			set tSC=##class(Security.Users).Modify(us,.prop)
			if '$$$ISOK(tSC) write $$$appError(##class(App.Form).UikitNote(us_": Error="_$SYSTEM.Status.GetErrorText(tSC))) quit
			;Check
			set tSC=##class(Security.Users).Get(us,.pro)
			if '$$$ISOK(tSC) write $$$appError(##class(App.Form).UikitNote(us_": Error="_$SYSTEM.Status.GetErrorText(tSC))) quit
			write $$$appMsg(##class(App.Form).UikitNote(us_": "_pro("Roles"),"success"))
	}
	Quit $$$OK
}

/// do ##class(App.security).GetPreparedUsers()
ClassMethod GetPreparedUsers() As %String
{
  q "Admin,CSPSystem,IAM,SuperUser,UnknownUser,_Ensemble,_SYSTEM"
}

/// Change password for userlist
/// do ##class(App.security).ChangePassword("msw", ##class(App.security).GetPreparedUsers())
ClassMethod ChangePassword(newPassword = "", UsersList = "") As %Status
{
	zn "%sys"
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set sql="select NameLowerCase FROM Security.Users where NameLowerCase in ('"_$replace($zconvert(UsersList,"L"),",","','")_"')"
	;w !,sql
	set tSC=result.Prepare(sql)
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
		set text="User configuration error :"_$SYSTEM.Status.GetErrorText(tSC) write !,text
		QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			set name=result.Data("NameLowerCase")
			;w !,name continue
			kill prop
			set prop("Password")=newPassword
			if name="_system" s prop("Enabled")=0
			if name="unknownuser" s prop("Roles")="" ; delete all roles
			set tSC=##class(Security.Users).Modify(name,.prop)
			if '$$$ISOK(tSC) w !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}
	q tSC
}

/// Get HTML content of access matrix form
/// d ##class(App.security).UiMatrixPermission("sm","sp","Ui","AnyKey","App.security","Ui"_"SavePermiss")
ClassMethod UiMatrixPermission(name = "", rolesmask = "", divId = "", key = "", class = "", Method = "", blockui = 1) As %Status
{
		if name="" write $$$appError($$$aText("Select the filter by user option Login blank (Names separated by commas or by the context","")) q 1
		if rolesmask="" write $$$appError($$$aText("Select the filter control","")) q 1
		set msg=$$$aText("Matrix of access rights","")
		set:blockui onclick=$$$blockui($$$aText("Loading...",""))
		;set onclick=$g(onclick)_";ActionJs('"_divId_"FormContentSave','"_divId_"ContentSave','"_class_"','"_Method_"','key="_key_"~divId="_divId_"~mode=Save');"
		
		set onclick=$$$blockui("Load...")_";"_##class(App.Action).WriteActJs(%request,divId_"FormContentSave",divId_"ContentSave",class,Method,"&key="_key_"&divId="_divId_"&mode=Save")
		;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"

		set butt=$$$appButton(divId_"appButtonSavePermiss","onclick="""_onclick_"""",$$$aText("Save access rights",""))
		write butt_"<br><br>"
		write "<form id='"_divId_"FormContentSave' >"
		do ##class(App.sys).GetRoles(rolesmask,.roles)
		if '$d(roles) write $$$appError($$$aText("This filter was","")) quit 1
		;set roles("%all")=$lb("%All","The Super-User Role")
		do ##class(App.sys).GetUsers(name,.users)
		if '$d(users) write $$$appError($$$aText("This filter users not found","")) quit 1
		set r="UserName"
  		set gn="matrix"
 	    set @gn@(0,1)=$lb(r)
 		set @gn@(-1,r)=1
  		set col(1)=r
  		set r=""
        for col=2:1 { set r=$o(roles(r)) quit:r=""
        	set NameRole=$lg(roles(r),1)
   		    set @gn@(0,col)=$lb(NameRole)
	  		set @gn@(-1,NameRole)=col
	  		set col(col)=NameRole
        }
        set col=col-1
		set u=""		
		for row=1:1 { set u=$o(users(u)) quit:u=""
			set usroles=$lg(users(u),3)
			;zwrite usroles
			set @gn@(row)=$g(@gn@(row))_$lb(u)
			for c=2:1:col {
				set yes="unchecked"
				if $LISTFIND(usroles,col(c)) set yes="1unchecked"
				set ret=##class(App.Form).WebCompShowCheckbox(,,,divId_"Matr0"_u_"0"_$tr(col(c),"%","p")_"0",yes)
				set @gn@(row)=$g(@gn@(row))_$lb(ret)
			}
		}
		;write "$('#"_pref_"MainContent').height($('#tabs-"_pref_"').height()-$('#"_pref_"MainHeader').height()-150);"
		;write "<div id='TabViewCont' style='overflow: scroll;   max-width: 1200px;  max-height: 500px;'>"
		set st=##class(App.LogInfoPane).DrawSQL("result "_gn,100000,$zu(5),$g(msg),$g(exec),,1)
		;write "</div>"
		;TODO do ##class(App.Form).DrawTable(.matrix) 
		write "</form><div id='"_divId_"ContentSave'></div>"
		quit $$$OK
}

}

