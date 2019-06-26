Include App.LogMacro

Class App.security [ Abstract ]
{

/// Повышение безопасности системы до уровня LockDown, кроме параметра InactiveLimit=90
/// Метод отключает сервисы и приложения как в LockDown. Удаляет области "DOCBOOK","ENSDEMO","SAMPLES"
/// Метод включает аудит и настраивает регистрацию в портале всех событий, кроме переключения журнала
///  и модификацию системных свойств
/// Всем предустановленным пользователям сменим пароль и поменяем свойства как в LockDown
/// 	newPassword - новый единый пароль вместо SYS. Для уровня безопасности LockDown он имеет шаблон 8.32ANP
/// 	sBindings =1 Сервис %service_bindings включить
/// 	sCachedirect =1 Сервис %service_cachedirect включить
/// 	sECP =1 Сервис %service_ecp включить
/// 	sBindingsIP - список ip адресов через точку с запятой для которых разрешить подключение CacheStudio.
/// 		Для ECP конфигураций нужно добавить адреса всех серверов и клиентов для разрешения подключения по %Net.RemoteConnection для снятия "брошенных" заданий
/// 	sCachedirectIP - список ip адресов через точку с запятой для которых разрешить подключение CIMModeler.
/// 	sECPIP - список ip адресов через точку с запятой для которых разрешить подключение к серверу ECP.
///     AuthLDAP=1 Включить дополнительно к парольному еще и LDAP аутотентификацию
///  Пример применения: 
/// 	d ##class(App.security).LockDown("qwe123!@#",.msg,1,1,0,"127.0.0.1","127.0.0.1")
/// 	d ##class(App.security).LockDown("qwe123!@#",.msg,1,1,0,"127.0.0.1","127.0.0.1",,1)
ClassMethod LockDown(newPassword = "", Warn, sBindings = "", sCachedirect = "", sECP = "", sBindingsIP = "", sCachedirectIP = "", sECPIP = "", AuthLDAP = 0) As %Status
{
	I newPassword'?8.32ANP s text="Пароль не удовлетворяет шаблону 8.32ANP" w !,text QUIT $$$ERROR(text)
	s ons = $zu(5) ;текущая область
	w !,"Для приложений и служб будет установлена аутентификация по "_$s('AuthLDAP:"паролю",1:"паролю и LDAP")
	s AutheEnabled=$s(AuthLDAP:2080,1:32) ;с паролем = 32, паролем и LDAP =2080
	zn "%sys"
	w !,"Происходит смена пароля предустановленным пользователям"
	s result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s tSC=result.Prepare("select NameLowerCase FROM Security.Users") ;!!! prefered !!!
	s:tSC tSC=result.Execute()
	i '$$$ISOK(tSC) {
		s text="Ошибка настройки пользователей :"_$SYSTEM.Status.GetErrorText(tSC) w !,text
		QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			s name=result.Data("NameLowerCase")
			k prop
			s prop("Password")=newPassword
			i name="_system" s prop("Enabled")=0 ; отключим
			i name="unknownuser" s prop("Roles")="" ; удалим все роли
			s tSC=##class(Security.Users).Modify(name,.prop)
			i '$$$ISOK(tSC) w !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}
	w !,"Происходит модификация свойств сервисов:"
	s result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s tSC=result.Prepare("select NameLowerCase,ClientSystems FROM Security.Services")
	s:tSC tSC=result.Execute()
	i '$$$ISOK(tSC) {
		s text="Ошибка настройки сервисов :"_$SYSTEM.Status.GetErrorText(tSC) w !,text
		QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			s name=result.Data("NameLowerCase")
			#;пропускаем сетевые сервисы
			continue:(name="%service_mirror")||(name="%service_shadow")||(name="%service_datacheck")
			k prop
			s prop("Enabled")=0 ;все остальные выключим
			i name="%service_csp"||(name="%service_console")||(name="%service_login") {
				s prop("Enabled")=1 ; включим
				i name'="%service_csp" s prop("AutheEnabled")=AutheEnabled ##; MSW4951b ;вход парольный
				e  s prop("AutheEnabled")=96 ;вход беспарольный и с паролем
			}
			i $G(sBindings),name="%service_bindings" {
				s prop("Enabled")=1 ; включим
				s prop("AutheEnabled")=AutheEnabled ;вход парольный
				s Warn($i(Warn))="Если на текущей системе не предполагается разработка или редактирование исходного кода в CacheStudio, то лучше выключить сервис "_name
				s prop("ClientSystems")=sBindingsIP
			}
			i $G(sCachedirect),name="%service_cachedirect" {
				s prop("Enabled")=1 ; включим
				s prop("AutheEnabled")=96 ;вход беспарольный и с паролем
				s Warn($i(Warn))="Если на текущей системе не предполагается редактирование шаблонов трансформации утилитой CIMModeler, то лучше выключить сервис "_name
				s prop("ClientSystems")=sCachedirectIP
			}
			i $G(sECP),name="%service_ecp" {
				s prop("Enabled")=1 ; включим
				s Warn($i(Warn))="Если на текущей системе не включена ECP конфигурация, то лучше выключить сервис "_name
				s:$g(sECPIP)="" Warn($i(Warn))="Если ECP конфигурация включена, то лучше ограничить подключение ECP-клиетов к ECP-серверу"
				s prop("ClientSystems")=sECPIP
			}
			;k pro d ##class(Security.Services).Get("%service_console",.pro)	zw pro
			s tSC=##class(Security.Services).Modify(name,.prop)
			i '$$$ISOK(tSC) w !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}


	
	w !,"Проиcходит создание парольного входа всем CSP приложениям"
	s result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	s tSC=result.Prepare("select Name FROM Security.Applications")
	s:tSC tSC=result.Execute()
	i '$$$ISOK(tSC) {
		s text="Ошибка настройки приложений :"_$SYSTEM.Status.GetErrorText(tSC)  w !,text QUIT $$$ERROR(text)
	}
	else {
		#; Список отключаемых приложений
		s appDisabled("/csp/ensdemo")=1
		s appDisabled("/csp/samples")=1
		s appDisabled("/csp/user")=1
		s appDisabled("/isc/studio/usertemplates")=1
		;s appDisabled("/csp/docbook")=1  
		s appDisabled("/csp/documatic")=1
		s appDisabled("/isc/studio/rules")=1
		s appDisabled("/isc/studio/templates")=1
		while result.Next() {
			s CSP=result.Data("Name")
			s csp=$zconvert(CSP,"L")
			k prop
			;w !,csp,"-----" d ##class(Security.Applications).Get(csp,.prop)	zw prop
			if $g(appDisabled(csp)) {
				s prop("Enabled")=0
			} else {
				  s prop("Enabled")=1
			}
		 s prop("AutheEnabled")=AutheEnabled 
		
			s tSC=##class(Security.Applications).Modify(CSP,.prop) ; MSW4343d
			i '$$$ISOK(tSC) w !,csp_" : Error="_$SYSTEM.Status.GetErrorText(tSC)
		}
	}
	WRITE !,"Происходит удаление демо областей"
	for name="ENSDEMO","SAMPLES" {
		#; Удаление Ensemble-области
		d:##class(%Dictionary.CompiledClass).%ExistsId("%Library.EnsembleMgr")
		
		#; Удаление области
		s tSC = ##class(Config.Namespaces).Delete(name)
		if $$$ISERR(tSC) s text="Ошибка удаления "_name_" :"_$system.Status.GetErrorText(tSC) w !,text
		if $$$ISOK(tSC) w !,"Удалили "_name
	}
	WRITE !,"Происходит модификация основных настроек системы"
	#dim ss As Security.System  = ##class(Security.System).%OpenId("SYSTEM")
	#;Изменение шаблона пароля
	s ss.PasswordPattern="8.32ANP"
	#;Включение аудита
	s ss.AuditEnabled=1
	#;количество дней простоя после которой система выключит основных пользователей и их нужно будет включать в аварийном режиме
	s ss.InactiveLimit=0
	#;Сохраним настройки
	s tSC=ss.%Save()
	i '$$$ISOK(tSC) s text="Ошибка настройки основых параметров безопасности :"_$SYSTEM.Status.GetErrorText(tSC)  w !,text QUIT $$$ERROR(text)
	w !,"Настройка событий AUDITa :"
	Set rs = ##class(%ResultSet).%New("Security.Events:ListActivate")
	Set tSC = rs.Execute()
	If $$$ISERR(tSC) s text="Ошибка настройки событий AUDIT:"_$system.Status.GetErrorText(tSC) w !,text QUIT $$$ERROR(text)
	#; Список событий ктр должны быть переключены
	s On("%Ensemble/%Message/ViewContents")=1
	s On("%System/%DirectMode/DirectMode")=1
	s On("%System/%Login/Login")=1
	s On("%System/%Login/LoginFailure")=1
	s On("%System/%Login/Logout")=1
	s On("%System/%Login/Terminate")=1
	s On("%System/%Security/ApplicationChange")=1
	s On("%System/%Security/AuditChange")=1
	s On("%System/%Security/AuditReport")=1
	s On("%System/%Security/DBEncChange")=1
	s On("%System/%Security/DomainChange")=1
	s On("%System/%Security/LoginRuleChange")=1
	s On("%System/%Security/Protect")=1
	s On("%System/%Security/ResourceChange")=1
	s On("%System/%Security/RoleChange")=1
	s On("%System/%Security/ServiceChange")=1
	s On("%System/%Security/SSLConfigChange")=1
	s On("%System/%Security/SystemChange")=1
	s On("%System/%Security/UserChange")=1
	s On("%System/%System/AuditRecordLost")=1
	s On("%System/%System/ConfigurationChange")=1
	s On("%System/%System/JournalChange")=0 ;выключим аудит переключения журнала
	s On("%System/%System/RoutineChange")=1
	s On("%System/%System/Start")=1
	s On("%System/%System/Stop")=1
	s On("%System/%System/SuspendResume")=1
	s On("%System/%System/UserEventOverflow")=1
	While rs.Next() {
		Set name = $G(rs.Data("Source"))_"/"_$G(rs.Data("Type"))_"/"_$G(rs.Data("Name"))
		;w !,name d ##class(Security.Events).Get($g(rs.Data("Source")),$G(rs.Data("Type")),$G(rs.Data("Name")),.pro) w " = ",pro("Description"),!!
		If $DATA(On(name)) {
			k pro
			d ##class(Security.Events).Get($g(rs.Data("Source")),$G(rs.Data("Type")),$G(rs.Data("Name")),.pro)
			i $d(pro) {
				if pro("Enabled")'=(+$G(On(name))) {
					;s Status=##class(Security.Events).Set($g(rs.Data("Source")),$G(rs.Data("Type")),$G(rs.Data("Name")),+$G(On(name)))
					;s Status=##class(Security.Events).Modify($g(rs.Data("Source")),$G(rs.Data("Type")),$G(rs.Data("Name")),.pro)
					i ##Class(Security.Events).Exists(name,,,.Event,.Status) {
						s Event.Enabled=+$G(On(name))
						s tSC=Event.%Save()
						i '$$$ISOK(tSC) w !,name_": Error="_$SYSTEM.Status.GetErrorText(tSC)
						e  w !,name_" изменили"
					}
				}
			}

		}
	}
	d rs.Close()
	zn ons ; вернемся в исходную область
	q $$$OK
}

}

