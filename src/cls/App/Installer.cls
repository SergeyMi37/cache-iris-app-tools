Include App.LogMacro

/// Importing this class will install App Tools properly.
/// fork from 
Class App.Installer Extends %Projection.AbstractProjection
{

Parameter DispatchClass = "App.RestMetrics";

Parameter ResourceName = "%AppTools";

Parameter Repository = "cache-iris-app-tools";

Parameter RoleName = "AppTools";

Parameter AppRest = "apptoolsrest";

Parameter AppCSP = "apptools";

Parameter AppName = "AppTools";

Projection Reference As Installer;

Parameter VERSION = 1.0;

/// This method is invoked when a class is compiled.
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
	m $$$AppL("MSW","cls")=cls
	m $$$AppL("MSW","params")=params
	s $$$AppL("MSW","cls")=$$LOG^%ETN
	new $Namespace
	set ns = $Namespace // ought to be package home namespace!
	if $g(@$$$GNEnsConf@("HomeNamespace"))'="",$g(@$$$GNEnsConf@("HomeNamespace"))'=ns {
		 QUIT $$$OK
	}
	if $g(@$$$GNEnsConf@("HomeNamespace"))="" {
	;Заполнение глобала значениями по умолчанию
	 set @$$$GNEnsConf@("DBCACHESizeMon")="CACHESYS,CACHEAUDIT"
	 set @$$$GNEnsConf@("EMAILAUTH")="mail@server.com"
	 set @$$$GNEnsConf@("EMAILAUTHPASS")=12345
	 set @$$$GNEnsConf@("EMAILSERVERIP")="127.0.0.1"
	 set @$$$GNEnsConf@("EMAILSERVERPORT")=25
	 set @$$$GNEnsConf@("EMAILSUPPORT")="admin@server.com"
	 set @$$$GNEnsConf@("EMAILXLSPATH")="c:\temp\"
	 set @$$$GNEnsConf@("EXPORDPROJPATH")="c:\temp\source\"
	 set @$$$GNEnsConf@("Language")="en"
	}
    set @$$$GNEnsConf@("HomeNamespace") = ns
    write !, "Installing "_..#AppName_" application to " _ ns
    set dbdir = $$$defdir
    try {
        set $Namespace = "%SYS"
    } catch (e) {
        set mes = "<PROTECT> The user " _ $Username _ " has no privileges"
            _ " to enter the %SYS namespace. Please, log in as a privileged user"
            _ " to set up the "_..#AppName_" application."
        set err = $$$ERROR($$$GeneralError, mes)
        write !, mes
        return err
    }
    
   	s result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s tSC=result.Prepare("select * FROM Security.Applications where Name=?")
	s:tSC tSC=result.Execute("/csp/"_ns)
	i '$$$ISOK(tSC) {
		s text="Ошибка настройки приложений :"_$SYSTEM.Status.GetErrorText(tSC)  w !,text QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			set cspProperties("Path")=result.Data("Path")
		}
	}
    ;zw cspProperties
    set cspProperties("AutheEnabled") = $$$AutheCache
    set cspProperties("NameSpace") = ns
    set cspProperties("Description") = "A WEB application for "_..#AppName_"."
    set cspProperties("IsNameSpaceDefault") = $$$NO
    set st = ..RegisterWebApplication("/"_..#AppCSP, .cspProperties)
    return:$$$ISERR(st) st
    
    d ##class(App.net).ImportCSPFromGitHub("https://codeload.github.com/SergeyMi37/"_..#Repository_"/zip/master",..#Repository,cspProperties("Path"))
    
	s @$$$GNEnsConf@("CSP-Path")=cspProperties("Path")
	KILL cspProperties("Path")
	
    set cspProperties("AutheEnabled") = $$$AutheCache
    set cspProperties("NameSpace") = ns
    set cspProperties("Description") = "A WEB application for "_..#AppName_"."
    set cspProperties("IsNameSpaceDefault") = $$$NO
    set cspProperties("DispatchClass") = ..#DispatchClass
    set st = ..RegisterWebApplication("/"_..#AppRest, .cspProperties)
    return:$$$ISERR(st) st
 
    do ..CreateAllNamespace()
    
    write !, "Mapping "_..#AppName_" package into all namespaces:"
    set st = ..Map(ns)
    if ($$$ISERR(st)) {
        do $System.Status.DisplayError(st)
    } else {
	    write !, ""_..#AppName_" package successfully mapped into all namespaces."
    }

    if (##class(Security.Resources).Exists(..#ResourceName) = 0) {
        set st = ##class(Security.Resources).Create(..#ResourceName,
            "Grants access to "_..#AppName_" if set up.", "")
    }

    if (##class(Security.Roles).Exists(..#RoleName) = 0) {
        set st = ##class(Security.Roles).Create(..#RoleName,
            "AppTools user role which may grant access to /"_..#AppCSP_" application if set up.",
            ..#ResourceName_":RWU")
    }
    
    return st
}

ClassMethod RegisterWebApplication(name As %String, spec) As %Status
{
    new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK
    if ('##class(Security.Applications).Exists(name)) {
        write !,"Creating WEB application """_name_"""..."
        set st = ##class(Security.Applications).Create(name, .spec)
        write !, "WEB application """_name_""" is created."
    } else { // ensure configuration matches in case of updating from old terminal versions
        write !, "Updating web application """_name_"""..."
        set st = ##class(Security.Applications).Modify(name, .spec)
        write !, "WEB application """_name_""" is updated."
    }
    return st
}

ClassMethod RemoveWebApplication(name As %String)
{
    new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK
    if (##class(Security.Applications).Exists(name)) {
        do ##class(Security.Applications).Get(name, .props)
        if (props("DispatchClass") '= ..#DispatchClass) && (name = "/"_..#AppCSP) {
            write !, "Won't delete WEB-application """_name_""" because it does not refer to dispatch class anymore."
        } else {
            write !, "Deleting WEB application """_name_"""..."
            set st = ##class(Security.Applications).Delete(name)
            write !, "WEB application """_name_""" was successfully deleted."
        }
    }
    return st
}

/// This method is invoked when a class is 'uncompiled'.
ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
	new $Namespace

	write:(recompile) !, "Recompiling "_..#AppName_", skipping the deletion..."
    return:(recompile) $$$OK

	set ns = $get(@$$$GNEnsConf@("HomeNamespace"), $Namespace)
    write !, "Uninstalling "_..#AppName_" application from ", ns
    zn "%SYS"
    set st = ..RemoveWebApplication("/"_..#AppCSP)
    return:($$$ISERR(st)) st
    
    set st = ..RemoveWebApplication("/"_..#AppRest)
    return:($$$ISERR(st)) st
    
    if (##class(Security.Resources).Exists(..#ResourceName) = 1) {
        set st = ##class(Security.Resources).Delete(..#ResourceName)
        return:($$$ISERR(st)) st
    }
    if (##class(Security.Roles).Exists(..#RoleName) = 1) {
        set st = ##class(Security.Roles).Delete(..#RoleName)
        return:($$$ISERR(st)) st
    }

    kill:st @$$$GNEnsConf
    write !, "Global "_$$$GNEnsConf_" removed."

    write !, "Unmapping App package from all namespaces:"
	set st = ..UnMap(ns)
    if ($$$ISERR(st)) {
        do $System.Status.DisplayError(st)
       
    } else {
	    write !, "Unmapping complete."
    }

    return st
}

ClassMethod CreateAllNamespace() As %Status
{
	new $Namespace
    set $Namespace = "%SYS"
	set ns = "%All"
	set st = $$$OK
	if ('##Class(Config.Namespaces).Exists(ns)) {

        if ($system.Version.GetISCProduct() >= 4) {
            set Properties("Globals") = "IRISTEMP"
            set Properties("Library") = "IRISLIB"
            set Properties("Routines") = "IRISTEMP"
            set Properties("SysGlobals") = "IRISSYS"
            set Properties("SysRoutines") = "IRISSYS"
            set Properties("TempGlobals") = "IRISTEMP"
        } else {
            set Properties("Globals") = "CACHETEMP"
            set Properties("Library") = "CACHELIB"
            set Properties("Routines") = "CACHETEMP"
            set Properties("SysGlobals") = "CACHESYS"
            set Properties("SysRoutines") = "CACHESYS"
            set Properties("TempGlobals") = "CACHETEMP"
        }
		
		set st = ##Class(Config.Namespaces).Create(ns, .Properties)
		if ($$$ISERR(st)) {
        	do $System.Status.DisplayError(st)
    	} else {
        	write !, "%All namespace is created."
    	}
	}
	return st
}

ClassMethod Map(fromNS = "") As %Status
{
	new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK

    set mapTo = $LISTBUILD("%All", "SAMPLES", "DOCBOOK")
    do ##Class(Config.Namespaces).Get(fromNS, .InstallNSProps)
    set Properties("Database") = $get(InstallNSProps("Routines"))
    set ptr = 0
    while $LISTNEXT(mapTo, ptr, namespace) {
        continue:(fromNS = namespace)
        continue:('##Class(Config.Namespaces).Exists(namespace))
        write " ", namespace
        if ('##Class(Config.MapPackages).Exists(namespace, "App")) {
        	set st1 = ##Class(Config.MapPackages).Create(namespace, "App", .Properties)
        }
        if ('##Class(Config.MapGlobals).Exists(namespace, "App")) {
	        set st2 = ##Class(Config.MapGlobals).Create(namespace, "App", .Properties)
        }
        set st = $$$ADDSC(st,$$$ADDSC($get(st1,$$$OK),$get(st2,$$$OK)))
    }
    return st
}

ClassMethod UnMap(fromNS As %String) As %Status
{
	new $Namespace
    set $Namespace = "%SYS"
    set st = $$$OK
    
	set mapTo = $LISTBUILD("%All", "SAMPLES", "DOCBOOK")
    set ptr = 0
    while $LISTNEXT(mapTo, ptr, namespace) {
	    continue:(fromNS = namespace)
	    continue:('##Class(Config.Namespaces).Exists(namespace))
        write " ", namespace
        if (##Class(Config.MapPackages).Exists(namespace, "App")) {
        	set st1 = ##Class(Config.MapPackages).Delete(namespace, "App", .Properties)
        }
        if (##Class(Config.MapGlobals).Exists(namespace, "App")) {
	        set st2 = ##Class(Config.MapGlobals).Delete(namespace, "App", .Properties)
        }
        set st = $$$ADDSC(st,$$$ADDSC($get(st1,$$$OK),$get(st2,$$$OK)))
    }
    return st
}

}

