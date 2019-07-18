Include App.LogMacro

/// Утилиты для восстановления баз данных
Class App.SYS.restore [ Abstract ]
{

///  ;Восстановить из репозитория
/// d ##class(utl.restore).RestFromRepo("EIS2")
ClassMethod RestFromRepo(nspace = "") As %Status
{
	// Запомнить текущую область
	i nspace="" s nspace=$zu(5)
	$$$NspGoto(curN,nspace)
	// если не перешли то выйдем
	if curN'=nspace,$zu(5)=curN set msg="Не перешли в область "_nspace write !,msg  quit $$$ERROR($$$GeneralError,msg)
	s dir=$g(^%Mvk.Proj(nspace,"RepositoryDir"))
	w !,"Восстановим последнюю версию из репозитория",!
	w "<",dir,"> " read path
	i path="" s path=dir
	i path="" w !," пустой путь" q
	w !,"Вы уверены ?",!," do $system.OBJ.ImportDir("""_path_""",""*.xml"",""ck"",,1)"
	read "[Y/N] <N>",r q:$zconvert(r,"L")'["y"
	s ^%Mvk.Proj(nspace,"RepositoryDir")=path
	d ##class(utl.ensemble).EnsAction("stop",nspace)
	d $system.OBJ.ImportDir(path,"*.xml","ck",,1)
	d ##class(utl.ensemble).EnsAction("start",nspace)
	$$$NspReturn(curN)
 quit $$$OK
}

/// Запуск автоматического восстановления с остановкой продукции
/// 
/// в терминале (проблема будет, если сеть неустойчива)
/// do ##class(utl.restore).AUTOREST("EIS2","/opt/isc/ensemble/mgr/EIS/","/opt/isc/ensemble/mgr/EIS2/",.gnLog) write !,"Протокол "_$g(gnLog)
/// 
/// в студио или вебтерминале
/// job ##class(utl.restore).AUTOREST("EIS2","/opt/isc/ensemble/mgr/EIS/","/opt/isc/ensemble/mgr/EIS2/")::1 if { write !,"Запустили, ожидаем завершения"} else { write !,"Ошибка запуска"}
/// Автоматическое восстановление бд на тестовом сервере
ClassMethod AUTOREST(namespace = "", soursedb = "", targetdb = "", gnts)
{
	//Протоколирование восстановления
	set gnts="^%Mvk.Log(""AUTOREST"")"
	set $zt="ErrAUTOREST"
	if namespace'="" s curns=namespace
	else  s curns=$zu(5)
	zn curns
	set stat=##class(Ens.Director).StopProduction()
	do AddLog(gnts,"stopProd_"_curns,stat)
	if 'stat {
		set stat2=##class(Ens.Director).StopProduction(,1) ;форсированная остановка
		do AddLog(gnts,"stopProdForce_"_curns,stat2)
		if 'stat2 g stopAUTOREST
	}
 	do ##class(Ens.Director).GetProductionSummary(.info)
	set curProdName=$o(info(""))
	if curProdName="" do AddLog(gnts,"ProdName_"_curns,"Not found") GOTO stopAUTOREST
	h 5
	set sc=$$EXTSELCT(gnts,curns,soursedb,targetdb)
	if sc'=3 g stopAUTOREST
	;TODO изменение настроек служб для работы в тестовом сервере
	;EnsLib.JavaGateway.Service, Port заменить на 55556
	;Данные из OEBS. * , DSN заменить на OEBS-Daily
	;
 set ^Settings("WF","WebAppName")="/eis2/rest"
	;set ^mvk.settings("fileDir")="/backup/eis2-documents/eis/"   
	;set ^mvk.settings("tempDir")="/backup/EIS2/temp/" ##;24
	set ^mvk.settings("fileDir")="/opt/isc/ensemble/mgr/EIS/"   
	set ^mvk.settings("tempDir")="/opt/isc/ensemble/mgr/Temp/" ##;24
	set sc=##class(Ens.Director).StartProduction(curProdName)
	do AddLog(gnts,"startProd_"_curns,sc_" "_curProdName)
stopAUTOREST	write !,$zr,$g(@$zr)
	quit $$$OK
ErrAUTOREST
	do AddLog(gnts,"error",$ze)
	GOTO stopAUTOREST


AddLog(gnts,Lev2,Val) ;Добавить логирование восстанвления
	set @gnts@($zd($h,3)_" "_$zt($p($h,",",2),3)_" "_$p($zts,".",2),Lev2)=Val
	quit
EXTSELCT(gnts,curns,soursedb="",targetdb="")
 ///	new (curns,gnts,soursedb,targetdb)
	;;set soursedb="/opt/isc/ensemble/mgr/EIS/"
	;;set targetdb="/backup/EIS2/"
	;set soursedb="/opt/isc/ensemble/mgr/INFOSERVICE/"
	;set targetdb="/backup/TEST/"
	i targetdb=""||(soursedb="") d AddLog(gnts,"startRest","soursedb,targetdb is empty") q "0,,"
	
	set line=soursedb_","_targetdb_",Y"
	Set InFile="/backup/temp/backup.list"
	set curday=$tr($zd($h,3),"-")
	;восстанавливаем из последней копии
	set filecbk="/backup/cip/cip_Full_All_"_curday_"001.cbk"
	;создаем файл
	Set File2 = ##class(%File).%New(InFile)
	Do File2.Open("WNK\UTF8\")
	do File2.WriteLine(soursedb_","_targetdb_",Y")
	Do File2.Close()
	;начинаем восстановление
	zn "%SYS"
	do AddLog(gnts,"startRest",line)
 	set sc=$$EXTSELCT^DBREST(1,0,filecbk,InFile,4,"","")
 	;s sc=3 h 30 ;;;;$$EXTSELCT^DBREST(1,0,filecbk,InFile,4,"","")
	do AddLog(gnts,"stopRest",sc)
 	if $g(curns)'="" zn curns
 	quit sc
}

}

