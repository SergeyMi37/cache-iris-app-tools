Include %occKeyword

/// Backup task class
Class App.Task.CustomListBackup Extends %SYS.Task.Definition [ LegacyInstanceContext ]
{

/// If ..AllDatabases=1, include all databases into the backup copy ..PrefixIncludeDB and ..IncludeDatabases are ignored
Property AllDatabases As %Integer [ InitialExpression = 0 ];

/// If ..AllDatabases=1, include all databases into the backup copy, excluding from ..IgnoreForAllDatabases (comma-delimited)
Property IgnoreForAllDatabases As %String(MAXLEN = 32000) [ InitialExpression = "Not applied if AllDatabases=0 " ];

/// If ..IgnoreTempDatabases=1, exclude temporary databases
Property IgnoreTempDatabases As %Integer [ InitialExpression = 1 ];

/// If ..IgnorePreparedDatabases=1, exclude pre-installed databases
Property IgnorePreparedDatabases As %Integer [ InitialExpression = 1 ];

/// If ..AllDatabases=0 and PrefixIncludeDB is not empty, we will be backing up all databases starting with ..PrefixIncludeDB
Property PrefixIncludeDB As %String [ SqlComputeCode = {S {*}=..ListNS()}, SqlComputed ];

/// If ..AllDatabases=0, back up all databases from ..IncludeDatabases (comma-delimited)
Property IncludeDatabases As %String(MAXLEN = 32000) [ InitialExpression = {"Not applied if AllDatabases=1"_..ListDB()} ];

/// Name of the task on the general list
Parameter TaskName = "CustomListBackup";

/// Path for the backup file
Property DirBackup As %String(MAXLEN = 1024) [ InitialExpression = {##class(%File).NormalizeDirectory("Backup")} ];

/// Path for the log
Property DirBackupLog As %String(MAXLEN = 1024) [ InitialExpression = {##class(%File).NormalizeDirectory("Backup")} ];

/// Backup type (Full, Incremental, Cumulative)
Property TypeBackup As %String(DISPLAYLIST = ",Full,Incremental,Cumulative", VALUELIST = ",Full,Inc,Cum") [ InitialExpression = "Full", SqlColumnNumber = 4 ];

/// Backup file name prefix
Property PrefixBackUpFile As %String [ InitialExpression = "back" ];

/// The maximum number of backup files, delete the oldest ones
Property MaxBackUpFiles As %Integer [ InitialExpression = 3 ];

ClassMethod DeviceIsValid(Directory As %String) As %Status
{
	If '##class(%Library.File).DirectoryExists(Directory) quit $$$ERROR($$$GeneralError,"Directory does not exist")
	quit $$$OK
}

ClassMethod CheckBackup(Device, MaxBackUpFiles, del = 0) As %Status
{
	set path=##class(%File).NormalizeFilename(Device)
	quit:'##class(%File).DirectoryExists(path) $$$ERROR($$$GeneralError,"Folder "_path_" does not exist")
	set max=MaxBackUpFiles
	set result=##class(%ResultSet).%New("%File:FileSet")
	set st=result.Execute(path,"*.cbk",,1)
	while result.Next()
	{	If result.GetData(2)="F"	{
			continue:result.GetData(3)=0
			set ts=$tr(result.GetData(4),"-: ")
			set ts(ts)=$lb(result.GetData(1),result.GetData(3))			
		}
	}
	#; Let’s traverse all the files starting from the newest one
	set i="" for count=1:1 { set i=$order(ts(i),-1) quit:i=""
		#; Get the increase in bytes as a size difference with the previous backup
		if $data(size),'$data(delta) set delta=size-$lg(ts(i),2)
		#; Get the size of the most recent backup file in bytes
		if '$data(size) set size=$lg(ts(i),2)
		#; If the number of backup files is larger or equals to the upper limit, delete the oldest ones along with logs
		if count'<max {
			set cbk=$lg(ts(i),1)
			set log=$replace($lg(ts(i),1),".cbk",".log")
			if del { if ##CLASS(%File).Delete(cbk)
					if ##CLASS(%File).Delete(log)
			}
		}
	}
	do result.%Close()
	If $$$isUNIX quit $$$OK ##; Skip for Linux	
	#; Calculate the available disk space in bytes
	set drive=$e(path,1)
	do ##CLASS(%File).GetDirectorySpace(drive_":/",.free,.total,0)
	#; Return an error if the size of the new backup file is larger than the available disk space
	quit:($g(size)+$g(delta))>$g(free) $$$ERROR($$$GeneralError,"Estimated size of the new backup file is larger than the available disk space:("_$g(size)_"+"_$g(delta)_")>"_$g(free))
	quit $$$OK
}

Method OnTask() As %Status
{
	do $zu(5,"%SYS")
	set list=""
	merge oldDBList=^SYS("BACKUPDB")
	kill ^SYS("BACKUPDB")
	#; Adding new properties for the backup task
	set status=$$$OK
	try {
		##; Check the number of database copies, delete the oldest one, if necessary
		##; Check the remaining disk space and estimate the size of the new file
		set status=..CheckBackup(..DirBackup,..MaxBackUpFiles,1)
		quit:$$$ISERR(status)
		#; All databases
		if ..AllDatabases {
			set vals=""
			set disp=""
			set rss=##class(%ResultSet).%New("Config.Databases:List")
			do rss.Execute()
			while rss.Next(.sc) {
				if ..IgnoreForAllDatabases'="",(","_..IgnoreForAllDatabases_",")[(","_$zconvert(rss.Data("Name"),"U")_",") continue
				if ..IgnoreTempDatabases continue:..IsTempDB(rss.Data("Name"))
				if ..IgnorePreparedDatabases continue:..IsPreparedDB(rss.Data("Name"))
				set ^SYS("BACKUPDB",rss.Data("Name"))=""
			}
		}
		else {
			#; if the PrefixIncludeDB property is not empty, we’ll back up all DB’s with names starting from ..PrefixIncludeDB
			if ..PrefixIncludeDB'="" {
					set rss=##class(%ResultSet).%New("Config.Databases:List")
					do rss.Execute(..PrefixIncludeDB_"*")
					while rss.Next(.sc) {
						if ..IgnoreTempDatabases continue:..IsTempDB(rss.Data("Name"))
						set ^SYS("BACKUPDB",rss.Data("Name"))=""
					}
			}
			#; Include particular databases into the list
			if ..IncludeDatabases'="" {
				set rss=##class(%ResultSet).%New("Config.Databases:List")
				do rss.Execute("*")
				while rss.Next(.sc) {
					if ..IgnoreTempDatabases continue:..IsTempDB(rss.Data("Name"))
					if (","_..IncludeDatabases_",")'[(","_$zconvert(rss.Data("Name"),"U")_",") continue
					set ^SYS("BACKUPDB",rss.Data("Name"))=""
				}
			}
		}
		do ..GetFileName(.backFile,.logFile)
		set typeB=$zconvert($e(..TypeBackup,1),"U")
		set:"FIC"'[typeB typeB="F"
		set res=$$BACKUP^DBACK("",typeB,"",backFile,"Y",logFile,"NOINPUT","Y","Y","","","")
		if 'res set status=$$$ERROR($$$GeneralError,"Error: "_res)
	} catch {	set status=$$$ERROR($$$GeneralError,"Error: "_$ze)
				set $ze=""
	 }
	kill ^SYS("BACKUPDB")
	merge ^SYS("BACKUPDB")=oldDBList
	quit status
}

/// Get file names
Method GetFileName(aBackupFile, ByRef aLogFile) As %Status
{
	set tmpName=..PrefixBackUpFile_"_"_..TypeBackup_"_"_$s(..AllDatabases:"All",1:"List")_"_"_$zd($h,8)_$tr($j($i(cnt),3)," ",0)
	do {
		s aBackupFile=##class(%File).NormalizeFilename(..DirBackup_"/"_tmpName_".cbk")
	} while ##class(%File).Exists(aBackupFile)
	set aLogFile=##class(%File).NormalizeFilename(..DirBackupLog_"/"_tmpName_".log")
	quit 1
}

/// Check if the database is pre-installed
ClassMethod IsPreparedDB(name)
{
	if (",ENSDEMO,ENSEMBLE,ENSEMBLEENSTEMP,ENSEMBLESECONDARY,ENSLIB,CACHESYS,CACHELIB,CACHETEMP,CACHE,CACHEAUDIT,DOCBOOK,USER,SAMPLES,")[(","_$zconvert(name,"U")_",") quit 1
	quit 0
}

/// Check if the database is temporary
ClassMethod IsTempDB(name)
{
	quit:$zconvert(name,"U")["TEMP" 1
	quit:$zconvert(name,"U")["SECONDARY" 1
	quit 0
}

/// Get a comma-delimited list of databases
ClassMethod ListDB()
{
	set list=""
	set rss=##class(%ResultSet).%New("Config.Databases:List")
	do rss.Execute()
	while rss.Next(.sc) {
		set list=list_","_rss.Data("Name")
	}
	quit list
}

ClassMethod ListNS() [ Private ]
{
	set disp=""
	set tRS = ##class(%ResultSet).%New("Config.Namespaces:List")
	set tSC = tRS.Execute()
	While tRS.Next() {	
				set disp=disp_","_tRS.GetData(1)
	}
	set %class=..%ClassName(1)
	$$$comSubMemberSet(%class,$$$cCLASSproperty,"PrefixIncludeDB",$$$cPROPparameter,"VALUELIST",disp)
	quit ""
}

ClassMethod oncompile() [ CodeMode = generator ]
{
	$$$defMemberKeySet(%class,$$$cCLASSproperty,"PrefixIncludeDB",$$$cPROPtype,"%String")
	set updateClass=##class("%Dictionary.ClassDefinition").%OpenId(%class)
	set updateClass.Modified=0
	do updateClass.%Save()
	do updateClass.%Close()
}

}

