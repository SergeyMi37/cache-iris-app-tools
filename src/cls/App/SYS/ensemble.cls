Include (App.LogMacro, Ensemble)

/// Утилиты для групповой работы с продукциями ансамбля разных областей
Class App.SYS.ensemble [ Abstract ]
{

/// Сколько ожидать останов продукции, до повтороного останова форсажем (секунд)
Parameter TIMEOUTSTOP = 120;

///  Проверить и сохранить настройки и состояния продукций в областях
///  d ##class(App.SYS.ensemble).EnsConfSave()
ClassMethod EnsConfSave(resave = 0) As %Status
{
	s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")
	;for ns="TEST","AISGSASUMS","EIS","EIS2","TMCASUMS","POOL","INFOSERVICE","MVK","MVK2" {
	s GN="^%Mvk.Setting"
	i 'resave,$d(@GN) w !,"Настройки уже сохранялись. Перезапишем ? [Y/N] <N>" r r q:$zconvert(r,"L")'["y"
	KILL @GN
	MERGE @GN=inf
	s ns=""
	f { s ns=$o(inf(ns)) q:ns=""
	 zw inf(ns,"Ens")
	}
 quit $$$OK
}

/// Убрать автостарт у всех продукций отсановить все продукции в областях
/// Перед серьезными работами с ОС
/// d ##class(App.SYS.ensemble).EnsDown()
/// d ##class(App.SYS.ensemble).EnsAction("stop")
/// d ##class(App.SYS.ensemble).EnsAction("start") ;запустить все продукции с минутной задержкой
/// sudo ccontrol stop ensemble
ClassMethod EnsDown() As %Status
{
 d ..EnsAction("auto0")
 d ..EnsAction("stop")
 w !!,"ok"
 q
}

/// Проверить и восстановить автозапуск продукций в областях
/// Запустить все продукции, которые были запущены
/// d ##class(App.SYS.ensemble).EnsConfRest()
/// d ##class(App.SYS.ensemble).EnsAction("start")
ClassMethod EnsConfRest() As %Status
{
 	d ..EnsAction("auto1")
 	d ..EnsAction("start")
 	w !!,"ok"
 	q
}

/// Инициализация ансамбля в разных областях и создание задач на чистку протоколов
ClassMethod initEns() As %Status
{
	for ns="AISGSASUMS","EIS","EIS2","TMCASUMS","POOL","INFOSERVICE","MVK","MVK2" {
		 write !,ns," ",##class(mvk.utils.misc).CreateTaskPurge("Чистка сообщений ансамбля",ns,7)
		 do ##class(%EnsembleMgr).EnableNamespace(ns,1) 
	}
 quit $$$OK
}

/// ;Инициировать все области для Ансамбля
ClassMethod InitEnsNS(nsList = "aisgsasums,infoservice,mvk,mvk2,poll,eis,tmcasums") As %Status
{
	for i=1:1:$l(nsList) {
		continue:$p(nsList,",",i)=""
		do ##class(%EnsembleMgr).EnableNamespace($p(nsList,",",i),1) 
	}
	q $$$OK
}

/// Инициализация ансамбля в разных областях и создание задач на чистку протоколов
/// Изменить состояния продукций в областях
/// d ##class(App.SYS.ensemble).EnsAction("restart")
/// ex= "auto0" - убрать во всех областях автостарт продукций
/// ex= "auto1" - включить автостарт продукций, восстановить из ^%Mvk.Setting(ns)
/// ex= "stop"  - остановить все
/// ex= "restart"  - перезагрузить все продукции
/// ex= "start"  - запустить те которые были запущены, восстановить из ^%Mvk.Setting(ns)
/// ex= "status" - вывод статусов продукций d ##class(App.SYS.ensemble).EnsAction("status")
ClassMethod EnsAction(ex = "", nsOnly = "") As %Status [ PublicList = (tProductionName, inf) ]
{
	s listns=##class(App.sys).ListNS(.inf,"NotPref,Ens")
	$$$forAll(ns,inf)
	i nsOnly'="",nsOnly'=ns continue
	$$$NspGoto(curN,ns)
	i '$d(inf(ns,"Ens")) continue
	s GN="^%Mvk.Setting"
	w !!,"--- ",ns
	if ex="stop" {
		s sc=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP)
		i 'sc {
			s sc2=##class(Ens.Director).StopProduction(..#TIMEOUTSTOP,1) 
			i 'sc2 w $System.Status.DisplayError(sc2)
		}
	}
	elseif ex="restart" {
		s sc=##class(Ens.Director).RestartProduction()
		i 'sc w $System.Status.DisplayError(sc)
	}
	elseif ex="start" {
		i '$d(@GN@(ns,"Ens")) w !," не сохранены настройки, пропускаем"
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			// Пропускаем невыполняющиеся
			continue:$lg(@GN@(ns,"Ens",tProductionName),1)'["Выполняется"
			;w !,tProductionName
			Set sc = ##class(Ens.Director).StartProduction(tProductionName) ; Quit:$$$ISERR(tSC)
			i 'sc w $System.Status.DisplayError(sc)
			h 60 ;минуту приостановимся
		$$$forEnd	
	}
	if ex="auto0" {
		i '$d(@GN@(ns,"Ens")) w !," не сохранены настройки, пропускаем"
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart("")
			i 'sc w $System.Status.DisplayError(sc)
			e  w " очистим автостарт"
			$$$NspReturn(curNs)
	} elseif ex="auto1" {
		i '$d(@GN@(ns,"Ens")) w !," не сохранены настройки, пропускаем"
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			Set sc = ##class(Ens.Director).SetAutoStart(tProductionName)
			i 'sc w $System.Status.DisplayError(sc)
			e  w " установим автостарт"
			$$$NspReturn(curNs)
		$$$forEnd		
	} elseif ex="status" {
		i '$d(@GN@(ns,"Ens")) w !," не сохранены настройки, пропускаем"
		Set sc = ##class(Ens.Director).GetProductionSummary(.pInfo, ns)
		w ! zw pInfo
		w ! Set sc = ##class(Ens.Director).GetProductionSettings("",.tSettings)	zw tSettings
		;w ! Set sc = ##class(Ens.Director).GetProductionSettingValue("",tSetting,.tStatus)	zw tSetting
		$$$forAll(tProductionName,@GN@(ns,"Ens"))
			continue:'$lg(@GN@(ns,"Ens",tProductionName),4)
			$$$NspGoto(curNs,ns)
			w !,"Имя продукции "_tProductionName
			Set sc = ##class(Ens.Director).GetProductionStatus(tProductionName,.Stat)
			w " Статус="_$s(Stat=$$$eProductionStateRunning:"Running",Stat=$$$eProductionStateStopped:"Stopped",Stat=$$$eProductionStateSuspended:"Suspended",Stat=$$$eProductionStateTroubled:"Troubled",1:"?")
			i 'sc w $System.Status.DisplayError(sc)
			$$$NspReturn(curNs)
		$$$forEnd		
	}
	$$$forEnd
	$$$NspReturn(curN)
 	quit $$$OK
}

}

