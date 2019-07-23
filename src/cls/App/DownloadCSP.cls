Include App.LogMacro

/// // Класс на основе %CSP Page для создания ссылок
Class App.DownloadCSP Extends %CSP.Page
{

/// Event handler for <b>PreHTTP</b> event: this is invoked before
/// the HTTP headers for a CSP page have been sent.  All changes to the
/// <class>%CSP.Response</class> class, such as adding cookies, HTTP headers,
/// setting the content type etc. must be made from within the OnPreHTTP() method.
/// Also changes to the state of the CSP application such as changing
/// %session.EndSession or %session.AppTimeout must be made within the OnPreHTTP() method.
/// It is prefered that changes to %session.Preserve are also made in the OnPreHTTP() method
/// as this is more efficient, although it is supported in any section of the page.
/// Return <b>0</b> to prevent <method>OnPage</method> from being called.
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	if %request.Get("fileName")'="" {
		s file=%request.Get("fileName")
	}
	elseif %request.Get("fileId")'="" {
		s file=..GetfileName(%request.Get("fileId"),,.origname)
	}
	elseif %request.Get("Id")'="" {
		s file=..GetfileName(%request.Get("Id"),,.origname)
	}
	if file="" {set fileName=$$$aText("Link already invalid","Ссылка уже недействительна")}
	else {set fileName = $p(file,$$$slash,*)}
	s %response.ContentType="application/force-download"
	;s %response.CharSet="windows-1251"
	d %response.SetHeader("Expires", "0")
	;d %response.SetHeader("Accept-Ranges","bytes")
	set f=##class(%File).%New()
 	s size=f.GetFileSize(file)
	d %response.SetHeader("Content-Length",size)
	set name=fileName
	if origname'="" set name=origname
	set name=$ZCVT($ZCVT(name,"O","UTF8"),"O","URL")
	d %response.SetHeader("Content-Disposition","attachment;filename="_name)
	Quit $$$OK
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
/// w "<a title=""Сохранить этот файл у себя на диске"" href=""App.DownloadCSP.cls?fileId=221212"">"
ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	if %request.Get("fileName")'="" {
		s file=%request.Get("fileName")
	}
	elseif %request.Get("fileId")'="" {
		set fileId=%request.Get("fileId")
		s file=..GetfileName(fileId)
		d ..DeleteFileId(fileId)
	}
	elseif %request.Get("Id")'="" {
		set fileId=%request.Get("Id")
		s file=..GetfileName(fileId)
	}
	
	set stream=##class(%FileBinaryStream).%New()
	set stream.Filename=file
	while 'stream.AtEnd {
		set line=stream.Read()
		write line
	}
	
	/*
	#dim f As %File
	set f=##class(%File).%New(file)
 	set ok=f.Open("RS")     
 	if 'ok do f.%Close() Q ok
 	;set len=$zu(140,1,file)
 	d f.Rewind()
 	while 'f.AtEnd {
    	Write f.Read($$$MaxLocalLength)
	}
 	do f.%Close()
 	*/
 	if %request.Get("log")'="" {
 		try {
 			Do $classmethod(%request.Get("log"),"AddRecord","App.DownloadCSP","OnPage",$st($st(-1),"PLACE"),"INFO",file,"DownLoad")
 		} catch e {}
 	}
     Quit $$$OK
}

/// Получить глобальную ссылку
ClassMethod GetGN() As %String
{
	quit $na(^tmpDownloadCSP(+$h))
}

/// Удалить идентификатор для скачивания
ClassMethod DeleteFileId(FileId, gn = {..GetGN()}) As %Status
{
	KILL @gn@(FileId)
	quit $$$OK
}

/// Получить полное имя файла по идентификатору для скачивания
ClassMethod GetfileName(FileId, gn = {..GetGN()}, origname = "") As %String
{
	if '$d(@gn@(FileId)) quit ""
	set origname=$g(@gn@(FileId,"origname"))
	if $g(@gn@(FileId))'=""	quit $g(@gn@(FileId))
	quit ""
}

/// Получить идентификатор для скачивания файла
/// if ##class(App.DownloadCSP).GetFileId(fileName,.url) { set fn="<a href='"_url_"'>DownLoad</a>"	}
/// cgivar="Id" отдавать файл в течении дня
/// cgivar="fileId" отдавать файл только один раз
/// cgivar="fileName" отдавать файл по полному пути (небезопасно)
ClassMethod GetFileId(FileName, ByRef URL, ByRef id, cgivar = "Id", gn = {..GetGN()}) As %Status
{
	set URL=""
	set st=$$$OK
	set origname=$p(FileName,"*",2)
	set FileName=$p(FileName,"*",1)
	TRY {
		set f=##class(%File).%New(FileName)
 		set st=f.Open("RS")     
 		if 'st do f.%Close() Q
 		if cgivar="fileName" {
	 		s id=FileName
	 	} else {
 			set id=$r(+$h)_$zcrc(7,FileName)_$r(+$h)
 			set @gn@(id)=FileName
 			set @gn@(id,"origname")=origname
	 	}
 		set URL=..%ClassName(1)_".cls?"_cgivar_"="_id
	} catch (e) {  
		s st=$System.Status.GetErrorText(e) 
	}
 	quit st
}

}
