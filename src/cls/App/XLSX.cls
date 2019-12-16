Include (App.LogMacro, %occODBC)

/// Report generation in a given directory upon request with a given field format
Class App.XLSX
{

/// Report generation in a given directory upon request with a given field format
/// set sc = ##class(App.XLSX).Report2xlsx("/backup/temp/","select top 10 id,ClassName  FROM App.Log order by id desc","AppLogReport",",N")
ClassMethod Report2xlsx(directory As %String, sql = "", filename = "", format = "", args...) As %Status
{
	q:sql="" $$$OK
	set directory = ##class(%File).NormalizeDirectory(directory)
	#dim sc As %Status = $$$OK

	if ('##class(%File).DirectoryExists(directory)) {
		do ##class(%File).CreateDirectoryChain(directory)
	}
	if ##class(%Dictionary.CompiledClass).%ExistsId("isc.SetEnv") {
		set env = "EXCELMEMSIZE"
		set sc = ##class(isc.SetEnv).Setup()
		quit:$$$ISERR(sc) sc
		set sc = ##class(isc.SetEnv).SetEnvVar(env, "4096m")
		quit:$$$ISERR(sc) sc
		set val = $system.Util.GetEnviron(env)
	}
	
	i filename="" s filename=query_"-"_$system.Util.CreateGUID()
	set file = filename_".xlsx"
	set $$$AppL("MSW",$username_" Generated in")=directory_file
	w !,"Generated in "_directory_file
	set sc = ..generateFileFromSQL(directory_file, sql,format,args...)
	if $$$ISERR(sc) w !,$System.Status.GetErrorText(sc) quit sc
	set $$$AppL("MSW",$username_" Compliet in")=directory_file
	w !,"Compliet "_directory_file
	;set ..reportStream.Filename = directory _ file 
	;set sc = ..%Save()
	quit sc
}

/// Outputs Excel-compliant table from sql into file. args are sql arguments
/// Does not support
/// w ##class(mvk.util.XLSX).generateFileFromSQL(,"SELECT * FROM Sample.Person")
ClassMethod generateFileFromSQL(file As %String = {##class(%File).TempFilename("xlsx")}, sql As %String, format = "", args...) As %Status
{
	#dim sc As %Status = $$$OK
	
	set xmlfile = ##class(%File).TempFilename("xml")
	set sc = ..generateXMLFromSQL(xmlfile, sql,format, args...)
	quit:$$$ISERR(sc) sc
	
	set sc = ..generateXLSXfromXML(xmlfile, file)
	
	do:$$$ISOK(sc) ##class(%File).Delete(xmlfile)

	
	quit sc
}

/// Outputs XML to be fed into %SYS.ZENReportExcelExporter Excel-compliant stream from sql into file. args are sql arguments
ClassMethod generateXMLFromSQL(xmlfile As %String, sql As %String, format = "", args...) As %Status
{
	#dim sc As %Status = $$$OK
	set st = ##class(%SQL.Statement).%New()
	set sc = st.%Prepare(sql)
	quit:$$$ISERR(sc) sc
	#dim result As %SQL.StatementResult
	set result = st.%Execute(args...)
	set stream = ##class(%Stream.FileCharacter).%New()
	set sc=stream.LinkToFile(xmlfile)
	quit:$$$ISERR(sc) sc
	set header = ##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(), "header").Data.Read(10000)
	do stream.Write(header)
	set $$$AppL("MSW",$username_"header")=header
	#dim metadata As SQL.StatementMetadata
	set metadata = result.%GetMetadata()
	set columnCount = metadata.columns.Count()
	for i=1:1:columnCount {
		#dim column As %SQL.StatementColumn
		set column = metadata.columns.GetAt(i)
		
		set class(i) = "<item excelName="""_ column.colName _ """"
		if $p(format,",",i)'="" {
			s type=$e($zconvert($p(format,",",i),"L"),1)
			set type="isExcel"_$s(type="n":"Number",type="d":"Date",type="t":"Time",1:"")_"=""1"" "
			set class(i) = class(i) _ " "_type
		}
		elseif column.IsNumeric() {
			set class(i) = class(i) _ " isExcelNumber=""1"""
		} elseif ..isDate(column.ODBCType) {
			set class(i) = class(i) _ " isExcelDate=""1"""
		} elseif ..isTime(column.ODBCType)  {
			set class(i) = class(i) _ " isExcelTime=""1"""	
		}
		set class(i) = class(i) _ ">"
	}
	while result.%Next() {
		do stream.WriteLine("<Row>")
		for i=1:1:columnCount {
			set data = result.%GetData(i)
			set:$lv(data) data = $lts(data)
			set data=$zstrip(data,"*C")
			do stream.WriteLine(class(i) _ $zcvt(data, "O", "XML") _ "</item>")
			if $i(row)
		}
		do stream.WriteLine("</Row>")
	}
	do stream.WriteLine("</sheet></MyReport>")
	set sc=stream.%Save()
	return sc
}

ClassMethod generateXLSXfromXML(xmlfile As %String, file As %String) As %Status
{
	set exportType = "xlsx"
	set outputdir = ##class(%File).GetDirectory(file)
	set outputfile = file
	set isMultiSheet = $$$YES
	set aggregateTag = ""
	set reportName = "Report"
	set logfile = ##class(%File).TempFilename("log")
	set suppresExcelHeaders = $$$NO
	set ExcelMode = "element"
	set DisplayLog= $$$NO
	
	set sc = ##class(%SYS.ZENReportExcelExporter).CommonExport(exportType, xmlfile, outputdir, outputfile, isMultiSheet, aggregateTag, reportName, logfile, suppresExcelHeaders, ExcelMode, DisplayLog)
	
	do:$$$ISOK(sc) ##class(%File).Delete(logfile)	
	
	return sc
}

ClassMethod isDate(odbcType As %Integer) As %Boolean
{
	return:odbcType=$$$ODBCTYPEtimestamp $$$YES
	return:odbcType=$$$ODBCTYPEdate $$$YES
	return $$$NO
}

ClassMethod isTime(odbcType As %Integer) As %Boolean
{
	return:odbcType=$$$ODBCTYPEtime $$$YES
	return $$$NO
}

XData header [ MimeType = application/yaml ]
{
<?xml version="1.0" encoding="UTF-8"?>
 <MyReport xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:zr="http://www.intersystems.com/zenreports" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg">
 <sheet excelSheetName="Report">
}

}

