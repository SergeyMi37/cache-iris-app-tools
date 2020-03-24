Include App.LogMacro

/// Utilities working with files
Class App.files [ Abstract, DependsOn = App.msg ]
{

ClassMethod getSlash() As %String
{
	q $$$slash
}

/// Stream convert to string
/// w ##class(App.files).Stream2String(resp,.str)
ClassMethod Stream2String(resp As %Stream, StringValue As %String) As %Status
{
	set st=$$$OK
	set StringValue=""
	i '$isobject(resp) q $$$ERROR($$$GeneralError,"An empty stream")
	d resp.Rewind() 
	set StringValue=resp.Read($$$MaxStringLength) 
	while '(resp.AtEnd) { 
		s StringValue($i(i))=resp.Read($$$MaxStringLength) 
	}
	q st
}

/// Unpack the archive to a directory
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
		if (result '= 0) { $$$ThrowStatus($$$ERROR($$$GeneralError, $$$aText("Return code error","")_":" _ result_" cmd="_cmd)) }
	} catch ex {
		set st = ex.AsStatus()
		;$$$TRACE($system.Status.GetErrorText(st))
	}
	quit st
}

/// Packaging file in the archive
/// Directory tempdir need to assign write cacheusr >sudo chmod ugo+w .
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
		if (result '= 0) { $$$ThrowStatus($$$ERROR($$$GeneralError, $$$aText("Return code error","")_":" _ result_" cmd="_cmd)) }
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
	// TODO: make error handling removal of
	i pDir'="" do ##class(%File).RemoveDirectoryTree(pDir)
	do ##class(%File).Delete(pFile)
	quit $$$OK
}

ClassMethod GetUzipCommand(file, dir) As %String
{
	if $zversion(1)=3 quit "unzip -o " _ file _ " -d " _ dir
	quit "7z x " _ file _ " -o" _ dir
}

/// Method unloads the stream aStream into a file folder aLogFolder. 
/// aLogFolder - directory of discharge /back/temp/
/// aFileName - name of the unloaded file
/// File - the full path to the file
/// w ##class(App.files).Stream2Log(HttpResponse.Data, TempDir, fileName,.File) s aDATA("pathfileName")=$g(path)
ClassMethod Stream2Log(aStream, aLogFolder, aFileName, ByRef filename) As %Status
{
	#dim sc As %Status = $$$OK
	quit:(aLogFolder="") sc
	
	s aLogFolder=##class(%File).NormalizeDirectory(aLogFolder)
	if '##class(%File).DirectoryExists(aLogFolder) {
		quit:'##class(%File).CreateDirectoryChain(aLogFolder) $$$ERROR($$$GeneralError,"Cann't create directory chain: "_aLogFolder)
	}
	// Define a prefix for the file name and the file name
	i (aFileName="") s filename = aLogFolder_"t"_$tr($zts,",.","")_".xml"
	e  s filename = aLogFolder_aFileName
	
	// Execute copy file to stream
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

	// Return result
	d aStream.Rewind() quit sc
}

/// To open a file and write to the array 
/// w ##class(App.files).ReadFile2Arr("/backup/temp/snmp/ruRunCmd2018-10-03_14:31:00.txt","RSK",,"%tmp")
/// w ##class(App.files).ReadFile2Arr(fn,"RSK","CP1251",gn)
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

/// To open a file for writing 
/// set fn="/backup/temp/log.txt" if ##class(App.files).OpenFile(fn) use fn write "test",! close fn
ClassMethod OpenFile(file, time = 1, mode = "WNSK", code = "UTF8") As %Status
{
	Open file:(mode_"\"_code_"\"):time
	quit $test
}

/// To read a file and write to global 
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

/// Loading XML into the feature class 
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

/// To the system path Protocol
/// w ##class(App.files).getPathcconsole()
ClassMethod getPathcconsole(ByRef dir, ByRef logname)
{
	s slash=$$$slash
	Set path=$p($zu(86),"*",1)
	s dir=$p(path,slash,1,$l(path,slash)-1)_slash_"mgr"_slash
	s logname=$s($zv["IRIS":"messages",1:"cconsole")
 quit dir_logname_".log"
}

/// Search of time of the extension of the database
ClassMethod getDate(Line, yyyy, mm, dd)
{
	Set mm=$p(Line,"/",1)
	;Set dd=$p(Line,"/",2)
	Set yyyy="20"_$p($p(Line,"/",3),"-")
	q mm'=""&&(yyyy'="")
}

/// Search important events
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

/// Search of time of the extension of the database
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

/// To date range in number of days from the current
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
 /// Interpreterpath string with the current date type
 /// Str= DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)
 /// The result the computed value of the expression 
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

/// To execute the method on each line of Protocol
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
		// Search context 
		d $classmethod(class,method,Line,.bd)
	}
	quit $$$OK


/// Function parse Protocol of the file on the date required depth
/// To skanirovat cconsole.log the result to put 
ParseFile(gnTemp,InFile)
	if $g(@gnTemp)[InFile,InFile'["cconsole.log" q 1 ;already archive dismantled
	;w !,InFile
	Set File2 = ##class(%File).%New(InFile)
	Do File2.Open("RSK\UTF8\")
	Do {
		Set Line = File2.ReadLine()
		s H=$$DataTimeCConsole2H($p(Line,":",1,3))
		i H="",$g(zts)'="" {
			i $l($g(@gnTemp@(zts)))>32000 continue
			;i $i(@gnTemp@(0))
			s @gnTemp@(zts)=$g(@gnTemp@(zts))_" "_Line ;glue from the previous
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
	s:$g(@gnTemp)'[InFile @gnTemp=$g(@gnTemp)_"*"_InFile ;add the name of zagolovok for exceptions in the following analysis
 quit $g(@gnTemp)

/// Transform the date 09/01/17-10:31:15 in $Horolog.
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


/// Check entry Date1=MM/DD/YY, Time1=HH:MM:SS in the range df,dt
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

/// Count one journal as what globals modifierade
/// k ^tmpJRN d ##class(App.files).OneJournalCount("/sdb/journals/20181225.003","^tmpJRN")
ClassMethod OneJournalCount(journal = "", tempGlob = {$$$TEMPJRNL})
{
	s TmpGN="^||log" k @TmpGN
	i '$isobject(journal) s journal=##class(%SYS.Journal.File).%OpenId(journal)	q:'$isobject(journal)
	w !,$$$FormatText($$$aText("Processed %1% 2 written in %3",""),journal.Name,$zdt($h,4),tempGlob),! 
	d JournalCount(journal)
	m @tempGlob@($P($zu(86),"*",2))=@TmpGN
    q
JournalCount(journal)
	  #dim record As %SYS.Journal.Record
	  set quit=0
	  i $isobject(journal) {
	    #; the first and last address, to calculate the progress in percent
	    set firstPos=journal.FirstRecord.Address
	    set lastPos=journal.LastRecord.Address
	    set opr=""
	    #; start with the end of the file
	    set record=journal.LastRecord
	    for {
	      if '(record.Address#500000) {
	      	#; the progress display processing
	      	set proc=$j((lastPos-record.Address)/(lastPos-firstPos)*100,5,1)
	      	if proc'=opr set opr=proc write $c(13),?10,proc,"%  "
	      }
	      s TimeStamp=$tr(record.TimeStampGet(),"-")
	      s date=$p(TimeStamp," ")
	      s hour=$p($p(TimeStamp," ",2),":",1)
	      #; Change record data
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
	      #; move to the previous record in the log file
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
	elseif $e($qs(gref,0),*)="D"||($e($qs(gref,0),*)="I")||($e($qs(gref,0),*)="S") { //record objects
		s gref=$na(@$qs(gref,0))
	}
	elseif $qs(gref,0)["log"||($qs(gref,0)["tmp") { //protocols
		s gref=$na(@$qs(gref,0))
	}
	else {
		s gref=$na(@$qs(gref,0)) ;the name of the array
	}
	;s Log($lb(base,gref))=$g(Log($lb(base,gref)))+1
	i $i(@TmpGN@(date,hour,base,TypeOp,gref,"Counts"))
	;we assume the number of new would
	s @TmpGN@(date,hour,base,TypeOp,gref,"OldValue")=$g(@TmpGN@(date,hour,base,TypeOp,gref,"OldValue"))+OV
	s @TmpGN@(date,hour,base,TypeOp,gref,"NewValue")=$g(@TmpGN@(date,hour,base,TypeOp,gref,"NewValue"))+NV
 q
}

/// To count in journal which globals as modifierade for a specific date
///  d ##class(App.files).OneDayJournalCount("/opt/isc/ensemble/mgr/journal/20181225","^tmpJRN")
///  d ##class(App.files).OneDayJournalCount("/sdb/journals/20181225","^tmpJRN")
ClassMethod OneDayJournalCount(fileYYYYMMDD = "", tempGlob = {$$$TEMPJRNL})
{
 i $g(@tempGlob)'="" w !,$$$aText("About is already underway","")_" "_$g(@tempGlob) q
 s @tempGlob=$zts ;the beginning of the formation

 s slash=$$$slash
 if fileYYYYMMDD="" { 
	w !,$$$aText("We assume for the previous day","")
	s file=##class(%SYS.Journal.System).GetCurrentFile()
	s fileYYYYMMDD=$p(file.Name,slash,1,*-1)_slash_$tr($zd($h-1,3),"-")
 }
 ;date for which we believe
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
 s @tempGlob="" ;flag the end of nascet
 q
}

/// Export to CSV file
/// d ##class(App.files).Export2CSV("/backup/temp/JrnCount*.csv","^tmpJRN2")
ClassMethod Export2CSV(aFileName = {$$$EMAILXLSPATH_"JrnCount*.csv"}, tmpGN = {$$$TEMPJRNL}, aCharset = "CP1251")
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
	WRITE !,$$$aText("Written to the file","")_" "_aFileName,!
	KILL FileStream quit sc
	q
}

/// Get all files in a directory and subdirectories
/// d ##class(App.files).GetAllDir("d:\dev\app1\src\",,.a)
/// ext = "*.jpg;*.jpeg;*.3gp" 
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

/// Convert XSL file to CSV format and upload to GD
/// d ##class(App.files).TransXLS2CSV
ClassMethod TransXLS2CSV(fileXSL, FieldNameHead = "QUANTITY", ByRef out, ByRef error, tempDir = {##class(%File).GetDirectory(##class(%File).TempFilename())})
{
		s path=$p(fileXSL,$$$slash,1,*-1)
		if path="" s error="Empty "_path q $$$ERROR($$$GeneralError,error)
		s gn2=..tempGN("Xls2") k @gn2

		;Convert xls to csv in UTF8 format delimited by commas and field values enclosed in double quotes
		s cmd="cd "_path_"; export HOME=$(eval echo ~$(id -u -n)) && unset LD_LIBRARY_PATH && soffice --convert-to csv --infilter=CSV:44,34,76,1 --headless "_fileXSL
		w "<br> "_cmd
		d ##class(App.sys).RunCmd(cmd,gn2,0,tempDir) h 1
		k @gn2

		s fileCSV=$p(fileXSL,".",1,*-1)_".csv"
		;Load and parse the received CSV
		;w "<br> csv "_fileCSV
		s gn3=..tempGN("Xls3") k @gn3
		s st=##class(App.files).ReadFile2Arr(fileCSV,"RSK","UTF8",gn3)
		i 'st s error=$System.Status.GetErrorText(st) q st
		i '$d(@gn3) s error="Not file "_fileCSV q $$$ERROR($$$GeneralError,error)
		;zw @gn3
		if FieldNameHead="" m out=@gn3 k @gn3 q $$$OK
		s gn=..tempGN("CsvTable") kill @gn
		s i=""
		f { s i=$o(@gn3@(i),1,s) q:i=""
			s ss=""
			;First go through by double quotes and each even-numbered commas in Char broadcast=1
			f ii=1:1 { q:$p(s,$c(34),ii,ii+1)=""
				s ss=ss_$s('(ii#2):$tr($p(s,$c(34),ii),",",$c(1)),1:$p(s,$c(34),ii))
			}
			i s[FieldNameHead { ;make a hat once
				f ii=1:1 { q:$p(ss,",",ii,ii+1)=""
					s name=$tr($ZStrip($p(ss,",",ii),"<>WP"),$c(1),",") ;reverse stream
					continue:name=""
					s @gn@(0,ii)=$lb(name)
					s @gn@(-1,name)=ii
				}
			} elseif 1 { ;pass on all other rows
				;w "<br>"_ss
				s listval=""
				;We'll use the comma Char=1 return back to commas
				f ii=1:1 { q:$p(ss,",",ii,ii+1)=""
					s val=$tr($ZStrip($p(ss,",",ii),"<>W"),$c(1),",") ;reverse stream
					s listval=listval_$lb(val)
				}
				s row=$g(row)+1
				s @gn@(row)=listval
			}
		}
		if $g(out)="gn" { s out=$na(@gn)}
		elseif $g(out)["^" { m @out=@gn k @gn }
		else {	m out=@gn k @gn
		}
		q $$$OK
}

/// To globalnu a reference to a temporary global
/// w ##class(App.files).tempGN("GN")
ClassMethod tempGN(GN, NoKill = 0) As %String
{
	;not to do ^|| and ^mtemp
	s gn=$na(^tmpAppFile(GN,$j)) 
	if 'NoKill KILL @gn	s @gn=$$$AppDT($h)
	q gn
}

/// To a temporary directory
/// w ##class(App.files).tempDir()
ClassMethod tempDir() As %String
{
 q ##class(%File).GetDirectory(##class(%File).TempFilename())
}

/// Generate the XLSX document template transforming field
/// f - the array of fields to replace
/// ParamData - the name Value of the parameter
/// node - the subnode of a temporary global
/// ParamClass - "Spgz.model.Param"
/// ParamField - field name ;"OfficeFile"
ClassMethod XlsxTransChoiceLotResult(f, node, ParamData, ParamClass, ParamField, debug = 0, newfile = "", msg = "")
{
	///Forming Applications WG
	s st=##class(App.Form).GetValueByName(ParamClass,ParamData,ParamField,.Val,1)
	i 'st {
		w $System.Status.GetErrorText(st) q $$$OK
	} else {
		s desc=Val("obj").Description
		s file=$p($g(Val("fileName")),"*",1)
	}
	if $g(file)="" w $$$appError("Empty file "_file) q 1
	
	s gn=..tempGN(node) k @gn
	;d ##class(App.files).File2Arr(file,gn)
	i debug s msg=msg_"<br>"_gn_" "_file
	;Unzip
	s tempDir=..tempDir()_$j
	d ##class(App.files).UnzipToDirectory(file,tempDir)
	
	;Read the global source template
	s fileSource=tempDir_"/xl/sharedStrings.xml"
	s st=##class(App.files).ReadFile2Arr(fileSource,"RSK",,gn) ;read the file into an array

	i 'st s msg=msg_$$$appError($System.Status.GetErrorText(st)) w msg q 1
	i '$d(@gn) w $$$appError($$$aText("No file","")) q 1

	set fn=fileSource ;    $replace(file,"-doc","-order-"_$username_"-") ;_$tr($zts,",.")) 
	if '##class(App.files).OpenFile(fn) s msg=msg_$$$appError($$$aText("No access rights to write the file","")_" "_fn) w msg q 1
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
	;Archived again under a new name
	;i ##class(App.files).zipFile(tempDir,tempDir,newfilename,"/backup/temp/spgz-zip")
	s newfile=..tempDir()_node_"-"_$username_"-"_$zd($h,3)_"-"_$tr($zt($p($h,",",2),1),":")_".xlsx"
	set cmd="cd "_tempDir_"; zip -r "_newfile_" * ; rm -R "_tempDir
	s gn=..tempGN(node_"Xlsx3") k @gn
	i debug s msg=msg_"<br>"_cmd
	d ##class(App.sys).RunCmd(cmd,gn) h 3
	i debug zw @gn
	;The link is temporary
	if ##class(App.DownloadCSP).GetFileId(newfile,.url) { 
		s msg=msg_"<li><a title="""_$$$aText("Save this file on your disk","")_""" href='"_url_"'>"_$$$aText("To the formed document file","")_" "_$g(desc)_"</a>"
		w msg
	}
}

/// %request.Application_"get-files/"_id
ClassMethod GetFileIdView(FileName, gn = "", ContentType = "") As %String
{
	set st=$$$OK
	if gn="" { //store referals is temporary
		s gn = ##class(App.DownloadCSP).GetGN()
		set id=$r(+$h)_$zcrc(7,FileName)_$r(+$h)_"."_$p(FileName,".",*)
		set @gn@(id)=FileName
		if ContentType'="" set @gn@(id,"ContentType")=ContentType ;="application/force-download"
	} else {
		set id=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.MD5Hash(FileName))_"."_$p(FileName,".",*)
		if $g(@gn@(id))=""	{
			s @gn@(id)=FileName
			if ContentType'="" set @gn@(id,"ContentType")=ContentType
		}
	}
 		;set @gn@(id,"origname")=origname
 		;set URL=..%ClassName(1)_".cls?"_cgivar_"="_id
 	quit id
}

}

