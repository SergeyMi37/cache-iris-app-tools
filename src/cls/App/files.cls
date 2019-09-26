Include App.LogMacro

/// Утилиты работы с файлами
Class App.files [ Abstract ]
{

/// Поучить слэшь
ClassMethod getSlash() As %String
{
	q $$$slash
}

/// Поток перевести в строку
/// w ##class(App.files).Stream2String(resp,.str)
ClassMethod Stream2String(resp As %Stream, StringValue As %String) As %Status
{
	set st=$$$OK
	set StringValue=""
	i '$isobject(resp) q $$$ERROR($$$GeneralError,"Пустой поток")
	d resp.Rewind() 
	set StringValue=resp.Read($$$MaxStringLength) 
	while '(resp.AtEnd) { 
		s StringValue($i(i))=resp.Read($$$MaxStringLength) 
	}
	q st
}

/// Распаковка архива в директорию
/// w ##class(App.files).UnzipToDirectory("/backup/eaist/imported/3a308a20ff8e271ae3e063231a8df1ad.zip","/backup/eaist/last")
ClassMethod UnzipToDirectory(fileName As %String, Output dirName As %String, cmd) As %Status
{
	set st = $$$OK
	try {
		set:$g(dirName)="" dirName = ##class(%File).NormalizeDirectory(##class(%File).TempFilename())
		$$$TOE(st, ##class(%File).CreateDirectoryChain(dirName))
		
		set cmd = ..GetUzipCommand(fileName, dirName)
		
		;$$$TRACE(cmd)
		set result = $zf(-1, cmd)
		if (result '= 0) { $$$ThrowStatus($$$ERROR($$$GeneralError, $$$aText("Return code error","Ошибка кода возврата")_":" _ result_" cmd="_cmd)) }
	} catch ex {
		set st = ex.AsStatus()
		;$$$TRACE($system.Status.GetErrorText(st))
	}
	quit st
}

/// Упаковка файла в архив
///  Каталогу tempdir нужно присвоить права на запись cacheusr >sudo chmod ugo+w .
ClassMethod zipFile(dir, fileName As %String, newfileName As %String, tempdir As %String = "") As %Status
{
	set st = $$$OK
	if tempdir="" set tempdir=dir
	try {
		if $zversion(1) { ;for Linux
			set cmd = "cd "_dir_"; zip -r "_tempdir_"/"_newfileName_" "_fileName_";"
			if dir'=tempdir s cmd=cmd_" cp -f "_tempdir_"/"_newfileName_" "_newfileName_";" 
		} else {
			;set cmd = "cd "_dir_"; zip -r "_tempdir_"/"_newfileName_" "_fileName_";"
			
		}
		set result = $zf(-1, cmd)
		if (result '= 0) { $$$ThrowStatus($$$ERROR($$$GeneralError, $$$aText("Return code error","Ошибка кода возврата")_":" _ result_" cmd="_cmd)) }
	} catch ex {
		set st = ex.AsStatus()
	}
	quit st
}

/// Get all files in a directory without subdirectories
/// w ##class(App.files).GetList("D:\dev\app1\src\","*.xml",.List)
ClassMethod GetList(directory As %String, ext As %String = "*.*", ByRef list) As %Status
{
	set st = $$$OK
	try {
		set directory = ##class(%File).NormalizeDirectory(directory)
		set rs = ##class(%ResultSet).%New("%File:FileSet")
		s sc=rs.Execute(directory, ext)
		while (rs.Next()) {
			set fName = rs.Get("Name")
			m list(fName)=rs.Data
		}
	} catch ex {
		set st = ex.AsStatus()
	}
	quit st
}

ClassMethod RemoveFiles(pFile As %String, pDir As %String = "") As %Status
{
	// TODO: сделать обработку ошибок удаления
	i pDir'="" do ##class(%File).RemoveDirectoryTree(pDir)
	do ##class(%File).Delete(pFile)
	quit $$$OK
}

ClassMethod GetUzipCommand(file, dir) As %String
{
	if $zversion(1)=3 quit "unzip -o " _ file _ " -d " _ dir
	quit "7z x " _ file _ " -o" _ dir
}

/// Метод выгружает поток aStream в файл в папку aLogFolder. 
/// aLogFolder - директория выгрузки /back/temp/
/// aFileName - Имя выгруженного файла
/// File - полный путь к файлу
/// w ##class(App.files).Stream2Log(HttpResponse.Data, TempDir, fileName,.File) s aDATA("pathfileName")=$g(path)
ClassMethod Stream2Log(aStream, aLogFolder, aFileName, ByRef filename) As %Status
{
	#dim sc As %Status = $$$OK
	quit:(aLogFolder="") sc
	
	s aLogFolder=##class(%File).NormalizeDirectory(aLogFolder)
	if '##class(%File).DirectoryExists(aLogFolder) {
		quit:'##class(%File).CreateDirectoryChain(aLogFolder) $$$ERROR($$$GeneralError,"Cann't create directory chain: "_aLogFolder)
	}
	#; Определяем префикc для имени файла и имя файла
	i (aFileName="") s filename = aLogFolder_"t"_$tr($zts,",.","")_".xml"
	e  s filename = aLogFolder_aFileName
	
	#; Выполняем копирование файла в поток
	s ext=$p(filename,".",$l(filename,"."))
	
	i aStream.%ClassName(1)="%Stream.FileCharacterGzip" {
		s gzfileName=aStream.Filename
		set f2 = ##class(%Stream.FileBinary).%New()
		set f1 = ##class(%Stream.FileBinaryGzip).%New()
		do f1.LinkToFile(gzfileName)
		do f2.LinkToFile(filename)
		s sc=f2.CopyFromAndSave(f1)
		d aStream.Rewind() 
		quit sc
	}
	i "xml,txt,html,aspx,"[ext {
		s File = ##class(%Stream.FileCharacter).%New()
		s File.TranslateTable="UTF8"
	}
	else {
		 s File = ##class(%Stream.FileBinary).%New()
	}
	
	s File.Filename=filename
	s sc=File.CopyFromAndSave(aStream)

	#; Возвращаем результат
	d aStream.Rewind() quit sc
}

/// Открыть файл и записать в массив 
/// w ##class(App.files).ReadFile2Arr("/backup/temp/snmp/ruRunCmd2018-10-03_14:31:00.txt","RSK",,"%tmp")
ClassMethod ReadFile2Arr(file, mode = "RSK", code = "UTF8", gn = "tmp") As %Status
{
	s io=$i
	Open file:(mode_"\"_code_"\"):1
	if $test {
		s $zt="endoffile"
		for i=1:1 use file read r s @gn@(i)=r
	}
	else {
		q $$$ERROR($$$GeneralError,"No open file "_file)
	}
endoffile u io close file
	q $$$OK
}

/// Открыть файл для записи 
/// set fn="/backup/temp/log.txt" if ##class(App.files).OpenFile(fn) use fn write "test",! close fn
ClassMethod OpenFile(file, time = 1, mode = "WNSK", code = "UTF8") As %Status
{
	Open file:(mode_"\"_code_"\"):time
	quit $test
}

/// Прочитать файл и записать в глобал 
/// w ##class(App.files).File2Arr("/backup/eaist/work/SPGZ.xml_2018-05-07_14.56.26.461","^tmpFile")
ClassMethod File2Arr(file, Mas, Param = "RSU") As %Status
{
 set f=##class(%File).%New(file)
 set ok=f.Open(Param)     if 'ok do f.%Close() Q ok
 set len=$zu(140,1,file)
 while 'f.AtEnd {
     set str = f.ReadLine()
     s @Mas@($i(@Mas))=str
  }
 do f.%Close()
 Q len_" byte"
}

/// Загрузка XML в класс объектов  
/// d ##class(App.files).LoadXML("d:\!\InfoObject.xml","infoObject","Model.InfoObject") 
ClassMethod LoadXML(fn, tag, class)
{
	Set tReader = ##class(%XML.Reader).%New()
	s sc=tReader.OpenFile(fn)
	If $$$ISERR(sc) Do $system.OBJ.DisplayError(sc) Quit  
	Do tReader.Correlate(tag,class)
	Set Count=0
	While tReader.Next(.Object, .sc) {
	    Write Object_" imported.",!
	    Set Count=Count+1
	}
	If $$$ISERR(sc) Do $system.OBJ.DisplayError(sc) Quit  
	Write !,Count
	Quit
}

/// Получить путь к системному протоколу
/// w ##class(App.files).getPathcconsole()
ClassMethod getPathcconsole(ByRef dir, ByRef logname)
{
	s slash=$$$slash
	Set path=$p($zu(86),"*",1)
	s dir=$p(path,slash,1,$l(path,slash)-1)_slash_"mgr"_slash
	s logname=$s($zv["IRIS":"messages",1:"cconsole")
 quit dir_logname_".log"
}

/// Поиск момента расширения базы данных
ClassMethod getDate(Line, yyyy, mm, dd)
{
	Set mm=$p(Line,"/",1)
	;Set dd=$p(Line,"/",2)
	Set yyyy="20"_$p($p(Line,"/",3),"-")
	q mm'=""&&(yyyy'="")
}

/// Поиск выжный событий
ClassMethod Alert(Line, ByRef bd)
{
	q:'..getDate(Line,.yyyy,.mm) $$$OK
	if Line["Shutdown complete"	{
		i $i(bd("Reboot",yyyy,mm))
	}
	elseif 0,Line["DELETE:",Line["journals"	{
		i $i(bd("DELETE journals",yyyy,mm))
	}
	elseif 0,Line["Automatic journal file roll"	{
		i $i(bd("Automatic journal file roll",yyyy,mm))
	}
	elseif Line["Paging Alert: Physical Memory is"	{
		i $i(bd("Paging Alert: Physical Memory is used",yyyy,mm))
	}
	elseif Line["Error reading from SNMP port"	{
		i $i(bd("Error reading from SNMP port",yyyy,mm))
	}
	elseif Line["Lock table full"	{
		i $i(bd("Lock table full",yyyy,mm))
	}
	q $$$OK
}

/// Поиск момента расширения базы данных
ClassMethod ExpansionDB(Line, ByRef bd)
{
	s context = "Expansion completed"
	if Line[context	{
		q:'..getDate(Line,.yyyy,.mm) $$$OK
		Set dbn=$p($p(Line,"database ",2),". Expanded",1)
		Set mb=$p($p(Line,"Expanded by ",2)," MB",1)
		;Set bd("total",yyyy,mm)=$g(bd("total",yyyy,mm))+mb
		;Set bd("total",yyyy)=$g(bd("total",yyyy))+mb
		Set bd(dbn,yyyy,mm)=$g(bd(dbn,yyyy,mm))+mb
		Set bd(dbn,yyyy)=$g(bd(dbn,yyyy))+mb
	}
	q $$$OK
}

/// Получить диапазон дат по количеству дней от текущего
/// w ##class(App.files).getPeriod(69,.FromDateTime,.ToDateTime,.df,.dt)
ClassMethod getPeriod(days, FromDateTime, ToDateTime, df, dt) As %String
{
	s FromDateTime="CurrentDay-"_days
	s ToDateTime="CurrentDay"

	if $$InterpretCurrentDay("added?DateFrom="_FromDateTime_"&DateTo="_ToDateTime,.res,.df,.dt) {
		 Set:$g(df)'="" FromDateTime=$p(df,".",2)_"/"_$p(df,".",1)_"/"_$e($p(df,".",3),3,4)_"-00:00:00"
		 Set:$g(dt)'="" ToDateTime=$p(dt,".",2)_"/"_$p(dt,".",1)_"/"_$e($p(dt,".",3),3,4)_"-23:59:59"
	}
	i $g(dt) q df_" "_dt
	q ""
 /// Интерпретирует строку с текущей датой типа
 /// Str= DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)
 /// Результат вычисленное значение выражения 
InterpretCurrentDay(Str, Result,df,dt) 
	#dim tSC As %Status = 1
	#dim e As %Exception.AbstractException
	
	Set exp=$p(Str,"?",2)
	quit:exp="" "0"
	Set exp="s "_$replace(exp,"CurrentDay",+$h)
	Set exp=$replace(exp,"&DateTo",",%tempTo")
	Set exp=$replace(exp,"DateFrom","%tempFrom")
	try {
		x exp
		Set df=$tr($zd(%tempFrom,4),"/",".")
		Set dt=$tr($zd(%tempTo,4),"/",".")
		Set Result=$p(Str,"?",1)_"?DateFrom="_df_"&DateTo="_dt
		kill %tempFrom,%tempTo
	} Catch e {
		Set tSC=e.AsStatus()
	}
  quit tSC
}

/// Выполнить метод на каждой строкой прготокола
ClassMethod FindContextInLog(days, method, bd) [ PublicList = (tProductionName, inf) ]
{
	Set gn=$$$GNmessages
	KILL res
	d ##class(App.files).getPathcconsole(.dir,.logname) ;w !,dir
	d ##class(App.files).GetList(dir,logname_"*",.List) ;zw List
	s i="" f { s i=$o(List(i)) q:i="" 
		do ParseFile(gn,i)
	}
	
	s bd=##class(App.files).getPeriod(days,.FromDateTime,.ToDateTime,.df,.dt) ;df_" "_dt
	
	if FromDateTime="" Set HFromDateTime="1.1"
	else  Set HFromDateTime=$$DataTimeCConsole2H(FromDateTime)
	if ToDateTime="" Set HToDateTime="99999999"
	else  Set HToDateTime=$$DataTimeCConsole2H(ToDateTime)
	
	;w !,HFromDateTime_" "_HToDateTime
	
	s hdt=HFromDateTime
	s class=$p($p(method,"(",2),")"),method=$p($p(method,")",2),".",2)
	f { s hdt=$o(@gn@(hdt),1,Line) q:hdt=""  q:hdt>HToDateTime
		// Контекст поиска		
		d $classmethod(class,method,Line,.bd)
	}
	quit $$$OK


/// Функция разбора протокольного файла на дату требуемой глубины
/// Сканироровать cconsole.log и результат положить 
ParseFile(gnTemp,InFile)
	if $g(@gnTemp)[InFile,InFile'["cconsole.log" q 1 ;уже архив разбирали
	;w !,InFile
	Set File2 = ##class(%File).%New(InFile)
	Do File2.Open("RSK\UTF8\")
	Do {
		Set Line = File2.ReadLine()
		s H=$$DataTimeCConsole2H($p(Line,":",1,3))
		i H="",$g(zts)'="" {
			i $l($g(@gnTemp@(zts)))>32000 continue
			;i $i(@gnTemp@(0))
			s @gnTemp@(zts)=$g(@gnTemp@(zts))_" "_Line ;склеим с предыдущей
			continue
		}
		s zts=H_","_$p($p(Line,":",4)," ")
		i $g(@gnTemp@(zts))'="",$g(@gnTemp@(zts))'=Line {
			 i $l($g(@gnTemp@(zts)))>32000 continue
			 ;i $i(@gnTemp@(0))
			 s @gnTemp@(zts)=$g(@gnTemp@(zts))_" "_Line  
			 continue
		}
		;i $i(@gnTemp@(0)) ;i '(@gnTemp@(0)#1000) w "."
		s @gnTemp@(zts)=Line
		} While 'File2.AtEnd
	Do File2.Close()
	s:$g(@gnTemp)'[InFile @gnTemp=$g(@gnTemp)_"*"_InFile ;добавим имя в заколовок для исключений в следующий разбор
 quit $g(@gnTemp)

/// Трансформировать дату 09/01/17-10:31:15 в $Horolog.
DataTimeCConsole2H(DT) 
		s dc=""
		Set Date1=$p(DT,"-")
		Set Time1=$p(DT,"-",2)
		try {
			Set dh=$zdh($p(Date1,"/",1,2)_"/20"_$p(Date1,"/",3),1)
			Set th=$zth(Time1,1)
			Set dc=dh_"."_th
		} catch {}
 quit $g(dc)


/// Проверка вхождения Date1=MM/DD/YY, Time1=HH:MM:SS в диапазон df,dt
IncludDataTime(DateTime1,df,dt,stop)
	Set z="0"
	try {
		Set dc=$$DataTimeCConsole2H(DateTime1)
		i dc>df,dc<dt s z=1
	} catch {
		Set z=$ze w !,$g(DateTime1)_","_$g(df)_","_$g(dt)_" "_$ze
	}
 quit z
}

/// Посчитать в одном журнале какие глобалы как модифицируются
/// k ^tmpJRN d ##class(App.files).OneJournalCount("/sdb/journals/20181225.003","^tmpJRN")
ClassMethod OneJournalCount(journal = "", tempGlob = {##class(App.LogInfoPane).#TEMPJRNL})
{
	s TmpGN="^||log" k @TmpGN
	i '$isobject(journal) s journal=##class(%SYS.Journal.File).%OpenId(journal)	q:'$isobject(journal)
	w !," Обрабатываем "_journal.Name_" "_$zdt($h,4)_" записываем в "_tempGlob,! 
	d JournalCount(journal)
	m @tempGlob@($P($zu(86),"*",2))=@TmpGN
    q
JournalCount(journal)
	  #dim record As %SYS.Journal.Record
	  set quit=0
	  i $isobject(journal) {
	    #; первый и последний адрес, для расчета прогресса обработки в процентах
	    set firstPos=journal.FirstRecord.Address
	    set lastPos=journal.LastRecord.Address
	    set opr=""
	    #; начнем с конца файла
	    set record=journal.LastRecord
	    for {
	      if '(record.Address#500000) {
	      	#; отображение прогресса обработки
	      	set proc=$j((lastPos-record.Address)/(lastPos-firstPos)*100,5,1)
	      	if proc'=opr set opr=proc write $c(13),?10,proc,"%  "
	      }
	      s TimeStamp=$tr(record.TimeStampGet(),"-")
	      s date=$p(TimeStamp," ")
	      s hour=$p($p(TimeStamp," ",2),":",1)
	      #; Запись об изменении данных
	      if record.%IsA("%SYS.Journal.SetKillRecord") {
	        ;set gref=record.GlobalReference
	    	s (OV,NV)=""
	    	i record.TypeName="SET" {
	    		s OV=record.OldValue
	    		s NV=record.NewValue
	    	}
	    	elseif record.TypeName="BitSET" {
		    	s NV=1
	    	}
	        d Count(record.TypeName,$l(OV),$l(NV),record.DatabaseName,record.GlobalNode)
	      }
	      #; перейдем к предыдущей записи в файле журнала
	      set record=record.Prev
	      quit:'$isobject(record)
	    }
	  }
	q  	
Count(TypeOp,OV,NV,base,gref)
	;q:$qs(gref,0)["CacheAuditD"
	;q:$qs(gref,0)["Ens."
	;s base=$qs(gref,-1)
	if $qs(gref,0)["SYS",$ql(gref)>0 {
		s gref=$na(@$qs(gref,0)@($qs(gref,1))) ;$qs(gref,2)))
	}
	elseif $e($qs(gref,0),*)="D"||($e($qs(gref,0),*)="I")||($e($qs(gref,0),*)="S") { //записи объектов
		s gref=$na(@$qs(gref,0))
	}
	elseif $qs(gref,0)["log"||($qs(gref,0)["tmp") { //протоколы
		s gref=$na(@$qs(gref,0))
	}
	else {
		s gref=$na(@$qs(gref,0)) ;имя массива
	}
	;s Log($lb(base,gref))=$g(Log($lb(base,gref)))+1
	i $i(@TmpGN@(date,hour,base,TypeOp,gref,"Counts"))
	;будем считать количество новых бы
	s @TmpGN@(date,hour,base,TypeOp,gref,"OldValue")=$g(@TmpGN@(date,hour,base,TypeOp,gref,"OldValue"))+OV
	s @TmpGN@(date,hour,base,TypeOp,gref,"NewValue")=$g(@TmpGN@(date,hour,base,TypeOp,gref,"NewValue"))+NV
 q
}

/// Посчитать в журналах какие глобалы как модифицируются за конкретную дату
///  d ##class(App.files).OneDayJournalCount("/opt/isc/ensemble/mgr/journal/20181225","^tmpJRN")
///  d ##class(App.files).OneDayJournalCount("/sdb/journals/20181225","^tmpJRN")
ClassMethod OneDayJournalCount(fileYYYYMMDD = "", tempGlob = {##class(App.LogInfoPane).#TEMPJRNL})
{
 i $g(@tempGlob)'="" w !,"Насчет уже идет "_$g(@tempGlob) q
 s @tempGlob=$zts ;начало формирования

 s slash=$$$slash
 if fileYYYYMMDD="" { 
	w !,"Будем считать за предыдущий день"
	s file=##class(%SYS.Journal.System).GetCurrentFile()
	s fileYYYYMMDD=$p(file.Name,slash,1,*-1)_slash_$tr($zd($h-1,3),"-")
 }
 ;дата за которую считаем
 s date=$p($p(fileYYYYMMDD,slash,$l(fileYYYYMMDD,slash)),".")
 for j=1:1:999 {
	  s suf=$s($l(j)=1:"00",$l(j)=2:"0",1:"")_j
	  s jname=fileYYYYMMDD_"."_suf 
	  w !,jname
	  #dim journ As %SYS.Journal.File = ##class(%SYS.Journal.File).%OpenId(jname)
	  i $isobject(journ) {	  
		 d ..OneJournalCount(journ,tempGlob)
	  }
	  else { QUIT
	  }
 }
 s @tempGlob="" ;флаг окончания насчета
 q
}

/// Экспорт в файл формата CSV
/// d ##class(App.files).Export2CSV("/backup/temp/JrnCount*.csv","^tmpJRN2")
ClassMethod Export2CSV(aFileName = {$$$EMAILXLSPATH_"JrnCount*.csv"}, tmpGN = {##class(App.LogInfoPane).#TEMPJRNL}, aCharset = "CP1251")
{
	s:aFileName["*" aFileName=$replace(aFileName,"*",$tr($zd($h,3)_$zt($p($h,",",2),-1),":- "))
	#dim FileStream As %FileCharacterStream = ##class(%FileCharacterStream).%New()
	s FileStream.Filename=aFileName
	s:(aCharset'="") FileStream.TranslateTable=aCharset
	d FileStream.WriteLine("Instance;Date;Hour;Drive;Base;TypeOperation;GlobalRef;Counts;ByteOldValue;ByteNewValue")
	s (c4,o4,n4)=0
		s s1="" f { s s1=$o(@tmpGN@(s1)) q:s1=""
			s s2="" f { s s2=$o(@tmpGN@(s1,s2)) q:s2=""      ; Date
				s s3="" f { s s3=$o(@tmpGN@(s1,s2,s3)) q:s3=""	; Hour
					s s4="" f { s s4=$o(@tmpGN@(s1,s2,s3,s4)) q:s4="" ; Base
						s (c4,o4,n4)=0
						s s5="" f { s s5=$o(@tmpGN@(s1,s2,s3,s4,s5)) q:s5="" ; TypeOperation
							s s6="" f { s s6=$o(@tmpGN@(s1,s2,s3,s4,s5,s6)) q:s6="" ; Ref
								continue:s6="^"
								s Count=$g(@tmpGN@(s1,s2,s3,s4,s5,s6,"Counts"))
								s Old=$g(@tmpGN@(s1,s2,s3,s4,s5,s6,"OldValue"))
								s New=$g(@tmpGN@(s1,s2,s3,s4,s5,s6,"NewValue"))
								s gref=s6
								#dim line As %String = $lb(s1,s2,s3,$p($p(s4,":"),"^^",2)_":",s4,s5,s6,Count,Old,New)
								d FileStream.WriteLine($lts(line,";"))
							}
						}
					}
				}
			}
		}
	
	s sc=FileStream.SaveStream()
	WRITE !,"Записано в файл "_aFileName,!
	KILL FileStream quit sc
	q
}

/// Get all files in a directory and subdirectories
/// d ##class(App.files).GetAllDir("d:\dev\app1\src\",,.a)
ClassMethod GetAllDir(dir, ext = "", ByRef out)
{
	set dir = ##class(%File).NormalizeDirectory(dir)
	set rs = ##class(%ResultSet).%New("%File:FileSet")
	s sc=rs.Execute(dir, ext)
	while (rs.Next()) {
		;w !,rs.Get("Name")
		set out($i(out)) = $lb(rs.Get("Name"),rs.Get("Type"),rs.Get("Size"),rs.Get("ItemName"),rs.Get("DateCreated"),rs.Get("DateModified"))
		i rs.Get("Type")="D" d ##class(App.files).GetAllDir($lg(out(out),1),ext,.out)
	}
	q $$$OK
}

/// Конвертировать XSL файл в формат CSV и загрузить в глобал
/// d ##class(App.files).TransXLS2CSV
/// 
ClassMethod TransXLS2CSV(fileXSL, FieldNameHead = "QUANTITY", ByRef out, ByRef error, tempDir = {##class(%File).GetDirectory(##class(%File).TempFilename())})
{
		;s path=;"/opt/isc/ensemble/csp/spgz/files/"
		s path=$p(fileXSL,"/",1,*-1)
		if path="" s error="Пустой путь "_path q $$$ERROR($$$GeneralError,error)
		;	s fileXSL=path_NameFileXLS
		;w "<br> "_fileXSL 
		s gn2=..tempGN("Xls2") k @gn2

		;Конвертировать xls в csv в формат UTF8 с разделителем по запятой, а значения полей в двойных кавычках
		s cmd="cd "_path_"; export HOME=$(eval echo ~$(id -u -n)) && unset LD_LIBRARY_PATH && soffice --convert-to csv --infilter=CSV:44,34,76,1 --headless "_fileXSL

		d ##class(App.sys).RunCmd(cmd,gn2,0,tempDir) h 1
		k @gn2

		s fileCSV=$p(fileXSL,".",1,*-1)_".csv"
		;Загружаем и разбираем полученный CSV

		s gn3=..tempGN("Xls3") k @gn3
		s st=##class(App.files).ReadFile2Arr(fileCSV,"RSK","UTF8",gn3)
		i 'st s error=$System.Status.GetErrorText(st) q st
		i '$d(@gn3) s error="Нет файла "_fileCSV q $$$ERROR($$$GeneralError,error)
		;zw @gn3
		if FieldNameHead="" m out=@gn3 k @gn3 q $$$OK
		s gn=..tempGN("CsvTable") kill @gn
		s i=""
		f { s i=$o(@gn3@(i),1,s) q:i=""
			s ss=""
			;Сначало пройдем по двойным кавычкам и на каждой четной запятые транслируем в Чар=1
			f ii=1:1 { q:$p(s,$c(34),ii,ii+1)=""
				s ss=ss_$s('(ii#2):$tr($p(s,$c(34),ii),",",$c(1)),1:$p(s,$c(34),ii))
			}
			i s[FieldNameHead { ;делаем шапку один раз
				f ii=1:1 { q:$p(ss,",",ii,ii+1)=""
					s name=$tr($ZStrip($p(ss,",",ii),"<>WP"),$c(1),",") ;обратная трансляция
					continue:name=""
					s @gn@(0,ii)=$lb(name)
					s @gn@(-1,name)=ii
				}
			} elseif 1 { ;проход по всем остальным строкам
				;w "<br>"_ss
				s listval=""
				;Пройдем по запятым и Чар=1 вернем обратно в запятие
				f ii=1:1 { q:$p(ss,",",ii,ii+1)=""
					s val=$tr($ZStrip($p(ss,",",ii),"<>W"),$c(1),",") ;обратная трансляция
					s listval=listval_$lb(val)
				}
				s row=$g(row)+1
				s @gn@(row)=listval
			}
		}
		m out=@gn k @gn q $$$OK
}

/// Получить глобальну ссылку на временный глобал
/// w ##class(App.files).tempGN("GN")
ClassMethod tempGN(GN, NoKill = 0) As %String
{
	;не делать ^|| и ^mtemp
	s gn=$na(^tmpAppFile(GN,$j)) 
	if 'NoKill KILL @gn	s @gn=$$$AppDT($h)
	q gn
}

/// Получить временную директорию
/// w ##class(App.files).tempDir()
ClassMethod tempDir() As %String
{
 q ##class(%File).GetDirectory(##class(%File).TempFilename())
}

/// Сформировать документ XLSX по шаблону трансформировав поля
/// f - массив полей на замену
/// ParamData - Значение имени парамера
/// node - подузел временного глобала
/// ParamClass - "Spgz.model.Param"
/// ParamField - имя поля ;"OfficeFile"
ClassMethod XlsxTransChoiceLotResult(f, node, ParamData, ParamClass, ParamField, debug = 0, newfile = "", msg = "")
{
	///Формирование Заявки РГ
	s st=##class(App.Form).GetValueByName(ParamClass,ParamData,ParamField,.Val,1)
	i 'st {
		w $System.Status.GetErrorText(st) q $$$OK
	} else {
		s desc=Val("obj").Description
		s file=$p($g(Val("fileName")),"*",1)
	}
	if $g(file)="" w $$$appError("Пустой файл "_file) q 1
	
	s gn=..tempGN(node) k @gn
	;d ##class(App.files).File2Arr(file,gn)
	i debug s msg=msg_"<br>"_gn_" "_file
	;Разархивировать
	s tempDir=..tempDir()_$j
	d ##class(App.files).UnzipToDirectory(file,tempDir)
	
	;Прочитаем в глобал исходник шаблона
	s fileSource=tempDir_"/xl/sharedStrings.xml"
	s st=##class(App.files).ReadFile2Arr(fileSource,"RSK",,gn) ;читаем файл в массив

	i 'st s msg=msg_$$$appError($System.Status.GetErrorText(st)) w msg q 1
	i '$d(@gn) w $$$appError("Нет файла") q 1

	set fn=fileSource ;    $replace(file,"-doc","-order-"_$username_"-") ;_$tr($zts,",.")) 
	if '##class(App.files).OpenFile(fn) s msg=msg_$$$appError("Нет прав доступа записать файл "_fn) w msg q 1
	s curIo=$i
	s i=""
	f { s i=$o(@gn@(i),1,str) q:i=""
		s fkey="" 
		f { s fkey=$o(f(fkey),1,fdata) q:fkey=""
			i str[fkey s str=$replace(str,fkey,fdata)
		}
		s @gn@(i)=str
		use fn 	write @gn@(i),!	use curIo
	}
	close fn
	
	i debug s msg=msg_"<br>fn="_fn_"<br>tempDir="_tempDir
	;Архивируем снова под новым именем
	;i ##class(App.files).zipFile(tempDir,tempDir,newfilename,"/backup/temp/spgz-zip")
	s newfile=..tempDir()_node_"-"_$username_"-"_$zd($h,3)_"-"_$tr($zt($p($h,",",2),1),":")_".xlsx"
	set cmd="cd "_tempDir_"; zip -r "_newfile_" * ; rm -R "_tempDir
	s gn=..tempGN(node_"Xlsx3") k @gn
	i debug s msg=msg_"<br>"_cmd
	d ##class(App.sys).RunCmd(cmd,gn) h 3
	i debug zw @gn
	;Ссылка временная
	if ##class(App.DownloadCSP).GetFileId(newfile,.url) { 
		s msg=msg_"<li><a title=""Сохранить этот файл у себя на диске"" href='"_url_"'>Получить сформированный документ по файлу "_$g(desc)_"</a>"
		w msg
	}
}

}

