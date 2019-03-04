Include App.LogMacro

/// Утилита работ с %Net.HttpRequest и %Net.SMTP
Class App.net [ Abstract ]
{

/// Zip files and Send to email
/// w ##class(App.net).SendFilesToEmail()
ClassMethod SendFilesToEmail(subj, text, files, zip = 1) As %Status
{
	;send files to email
	s slash=##class(App.files).getSlash()
	zw files
	;s path=$p(exportXLSfile,slash,1,*-1)
	;s sc=##class(App.files).zipFile(path,$p(exportXLSfile,slash,*),$p(exportXLSfile,slash,*)_".zip",path)
	;if sc s exportXLSfile=exportXLSfile_".zip"
	;i 'sc s $$$AppL("APP","CloseXLSfile-zipFile")=$System.Status.GetErrorText(sc) 
	//TODO prepare file to send e-mail
	q 1
	;i exportXLSfileEmail'="" {
	;	s sc=##class(App.LogInfo).SendEmail(exportXLSfileEmail, $$$aText("Send file","Отправление файла")_" "_exportXLSfile, $g(msg)_"<br> "_$$$aText("Namespace","Область")_" :"_$zu(5)_"<br> "_$$$aText("Query","Запрос")_": "_SQL, exportXLSfile)
	;	i 'sc s $$$AppL("APP","CloseXLSfile-SendEmail")=$System.Status.GetErrorText(sc) 
	;	}
	q $$$OK
}

/// Послать электронное письмо
/// subscrible - список через запятую, кому направлять письмо
/// subj - тема
/// text - текст письма
/// attach - массив файлов по ссылке
ClassMethod SendMail(server, port, ssl, UseSTARTTLS, timezone, username, psw, from, subscrible, subj, text, attach) As %Status
{
 #dim smtp As %Net.SMTP
 #; Определяем SMTP-сервер для отправки
 set smtp=##class(%Net.SMTP).%New()
 set smtp.smtpserver=server
 set:port smtp.port=port
 set:ssl||(port=465) smtp.SSLConfiguration=..CheckSSLCertificate("SSL4SMTP")
 set:UseSTARTTLS smtp.UseSTARTTLS=1
 set smtp.timezone=timezone
 if username'="" {
	set auth=##class(%Net.Authenticator).%New()
	set auth.UserName=username
	set auth.Password=psw
	set smtp.authenticator=auth
 }
 set smtp.timezone=$g(timezone,"0300")  ;Timezone by Grinwitch  +3 russia
 set mail=##class(%Net.MailMessage).%New() 
 set mail.From=$G(from)        ##; From 
 ##; List of emails to send this mail
 for i=1:1 {
	 q:$p(subscrible,",",i,i+1)=""  
	 set to=$p(subscrible,",",i) 
	 if to'="" do mail.To.Insert(to)
 }
 set mail.Subject=$s($g(subj)="":$g(Subj),1:$g(subj))     ; Subject - тема
 set mail.Charset="windows-1251"
 set mail.IsHTML=$s(text["<html":1,1:0)
 set mail.IsMultiPart=1
 set mail.MultiPartType="related" 
 do mail.TextData.Write(text)
 set sc=$$$OK
 ; Если файл один и передается по тексту в формате $lb
 if $g(attach)'="" {
	 set attach(1)=$lg(attach,2)
	 set attach(1,"path")=$lg(attach,1)
	 set:$lg(attach,3)'="" attach(1,"content-type")=$lg(attach,3) ;image/jpeg
 }
 ; Файлов много
 if $d(attach)>1 {
	set rec="" 
	for { s rec=$o(attach(rec),1,file) quit:rec=""
	 set sc=mail.AttachFile($g(attach(rec,"path")),file) ;  C:\!\","utl.zip")
	 if $$$ISERR(sc) q
	 set part=mail.Parts.GetAt(rec)
	 do part.Headers.SetAt(file,"Content-ID")
	 do part.Headers.SetAt($g(attach(rec,"content-type")),"Content-Type")
	}
 }
 if $$$ISERR(sc) quit sc ;##class(%Library.Status).LogicalToOdbc(sc)
 set sc=smtp.Send(mail) 
 if $$$ISERR(sc) quit sc ;##class(%Library.Status).LogicalToOdbc(sc)
 quit $$$OK
}

/// Загрузить файл и положить на сервер добавив к имени метку даты и времени
/// w ##class(App.net).LoadFileHttp("http://kisu-apps.mvk.ru:8000/OA_HTML/XxkWebServ/download?fileId=5215954",.out,"/backup/temp/",1)
ClassMethod LoadFileHttp(aURL = "", aDATA, TempDir = "", fileName) As %Status
{
	s st=##class(App.net).GetHttp(aURL,.aDATA)
	i 'st q st
	i $g(aDATA("status"))'=200 q $$$ERROR($$$GeneralError,"Status HTTP "_$g(aDATA("status")))
	s sc=1
	i TempDir'="" s sc=##class(App.files).Stream2Log(aDATA("content"), TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	q sc
}

/// Получить от сервер  данные по URL
/// Если TempDir определен, то файл запишется туда 
/// w ##class(App.net).GetHttp("https://opendatabot.com/c/19358827",.out,"c:\!\","^temp")
/// w ##class(App.net).GetHttp("http://www.cbr.ru/mcirabis/PluginInterface/GetBicCatalog.aspx",.out,"/backup/temp/")
/// w ##class(App.net).GetHttp("http://www.cbr.ru/mcirabis/BIK/bik_db_13102017.zip",.out2,"/backup/temp/")
ClassMethod GetHttp(aURL = "", aDATA, TempDir = "", tmpGN = "") As %Status
{
	set part1=$p(aURL,"/",3),part2=$p(aURL,"/",4,$l(aURL,"/")),params=$p(aURL,"?",2)
	#; Сервер
	set server=$p(part1,":",1) quit:(server="") $$$ERROR($$$GeneralError,"0: отсутствует сервер")
	#; Порт
	set port=$p(part1,":",2)
	#; Адрес
	set location=$p(part2,"?",1) quit:(location="") $$$ERROR($$$GeneralError,"0: отсутствует адрес - "_location)
	set location=$zcvt(location,"O","URL")
	;i location="" s location="/"
	
	#; Создание HTTP-запроса для загрузки файла
	set HttpRequest=##class(%Net.HttpRequest).%New()
	set HttpRequest.Server=server
	if $f($zcvt(aURL,"L"),"https://") {
		set:(port="") port=443
		set HttpRequest.Https=1
		;set HttpRequest.FollowRedirect = 1
		set HttpRequest.SSLConfiguration=..CheckSSLCertificate("MvkDefaultSSL")
	
	#; Запрос по HTTP
	} else {
		s:(port="") port=80
	}
	;w !,server,!,location
	set HttpRequest.Port=port
	
	#; Заполняем параметры
	for i=1:1:$l(params,"&") { s pair=$p(params,"&",i),name=$p(pair,"=",1),value=$p(pair,"=",2)
		continue:(name="")	
		;Конвертация, чтобы предотвратить двойной конвертации
		s value=$zcvt(value,"I","URL") 
		d HttpRequest.SetParam(name,value)
	} ; /for i
	
	#; Выполняем запрос
	Try { d HttpRequest.Get(location) } Catch Error { s err=Error.AsSystemError() }
	quit:($g(err)'="") $$$ERROR($$$GeneralError,err)
	#; Обрабатываем полученный ответ
	set HttpResponse=HttpRequest.HttpResponse 
	quit:('$isobject(HttpResponse)) $$$ERROR($$$GeneralError,"сервер не вернул ответ")
	quit:(HttpResponse.StatusCode'=200) $$$ERROR($$$GeneralError,HttpResponse.ReasonPhrase)
	s aDATA("status")=HttpResponse.StatusCode
	#; Разбираем ответ сервера, сохраняя в структуру aDATA
	set aDATA("contentType")=HttpResponse.ContentType
	#; Имя файла получаем через "content-disposition" в виде "attachment;filename="name.ext";"
	s fileName=HttpResponse.GetHeader("content-disposition")
	s aDATA("content-disposition")=fileName
	if ($l(fileName,"*=utf-8''")>1) {
		s fileName=$p(fileName,"*=utf-8''",2)
		s fileName=##CLASS(%CSP.Page).UnescapeURL(fileName)
		s fileName=$zcvt(fileName,"I","UTF8")
	} else { s fileName=$p(fileName,"filename=",2),fileName=$tr($p(fileName,";",1),"""'","") }
	
	#; Если имя файла не задано, то используем в качестве имени кусок адреса ссылки
	s:(fileName="") fileName=$p(location,"/",$l(location,"/"))
	s aDATA("content")=HttpResponse.Data
	s aDATA("fileName")=$zcvt(fileName,"I","URL")
	i tmpGN'="" M @tmpGN=aDATA
	s sc=1
	i TempDir'="" s sc=##class(App.files).Stream2Log(HttpResponse.Data, TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	quit sc
}

/// Метод проверяет существование настроенной SSL конфигурации
/// и создает пустую конфигурацию с таким именем если такого пока нет
/// для подключения к https серверу, этого достаточно
ClassMethod CheckSSLCertificate(name) As %String
{
	set curNS=$zu(5)
	try {
		zn "%SYS"
		quit:(##class(Security.SSLConfigs).Get(name))
		d ##class(Security.SSLConfigs).Create(name)
	} catch {
	}
	zn curNS
	quit name
}

/// fix by Eduard Lebedyuk 
/// w ##class(App.net).CopyFileBinaryGzip()
ClassMethod CopyFileBinaryGzip() As %String
{
	w !,$zv
	set HttpRequest=##class(%Net.HttpRequest).%New()
	set HttpRequest.Server="www.cbr.ru"
	set HttpRequest.Port=80
	Try { d HttpRequest.Get("mcirabis/PluginInterface/GetBicCatalog.aspx") } Catch Error { s err=Error.AsSystemError() }
	if ($g(err)'="") w !,"ERROR1:",$system.Status.GetOneErrorText(err) Quit
	
	set HttpResponse=HttpRequest.HttpResponse 
	if ('$isobject(HttpResponse)) w !,"ERROR2"
	
	s newFilename="/backup/GetBicCatalog4.xml"
	d HttpResponse.Data.Rewind()
	
	w !,HttpResponse.Data.%ClassName(1)
	w !,HttpResponse.Data.Filename
		s gzipfileName=HttpResponse.Data.Filename
		set f2 = ##class(%Stream.FileBinary).%New()
		set f1 = ##class(%Stream.FileBinaryGzip).%New()
		do f1.LinkToFile(gzipfileName)
		do f2.LinkToFile(newFilename)
		s sc=f2.CopyFromAndSave(f1)

	if $$$ISERR(sc) w !,"ERROR3:",$system.Status.GetOneErrorText(sc) Quit
	s sc=f2.%Save()
	if $$$ISERR(sc) w !,"ERROR4:",$system.Status.GetOneErrorText(sc) Quit
	q sc
}

/// Чтение файлов из фтп сервера
/// w ##class(App.net).ListFtp()
ClassMethod ListFtp() As %String
{
	;ftp://fz223free:fz223free@ftp.zakupki.gov.ru/out/
 #dim ftp As %Net.FtpSession
 Set ftp=##class(%Net.FtpSession).%New()
 //ftp.Connect("nameserver","name","pass","port")
 s st=ftp.Connect("ftp.zakupki.gov.ru","fz223free","fz223free",21) 
 i 'st Write "Not connected "_$System.Status.GetErrorText(st),! Quit
 Write "Ftp server messsage: ",ftp.ReturnMessage,!
 
 If 'ftp.System() W "No answer System" G FTPSTOP
 Write "Ftp server messsage: ",ftp.ReturnMessage,!
 
 If 'ftp.Binary() Write "Can not swap to binary mode",! G FTPSTOP
 Write "Mode now: ",ftp.Type,!

 // ПРОЧИТАТЬ ДИРЕКТОРИЮ
 Set stream=##class(%GlobalCharacterStream).%New()
 W ! 
 s st=ftp.List("/out/published/undefined/purchaseNoticeEP/daily",.stream) 
 i 'st W !,"Error List "_$System.Status.GetErrorText(st) G FTPSTOP
 IF stream.Size>0 {
 Write "-------- Length of file received: ",stream.Size," ------",!
 ;for  set len=32763,line=stream.Read(.len) write line  quit:stream.AtEnd
 for  {
	 s line=stream.ReadLine() s ^logFTT(1,$i(^logFTT),"F")=$lb(line) 
	 quit:stream.AtEnd
 }
 Write !," -------- End of stream -----",!
 }
 D stream.%Close() 
 
 /*/ ПРОЧИТАТЬ ДИРЕКТОРИЮ
 Set stream=##class(%GlobalCharacterStream).%New()
 W ! IF 'ftp.List("CLIeNT\*.F*",.stream) W !,"Error List" G FTPSTOP
 IF stream.Size>0 D
 .Write "-------- Length of file received: ",stream.Size," ------",!
 . new len,line
 . for  set len=32763,line=stream.Read(.len) do  quit:stream.AtEnd
 .. write line
 .Write !," -------- End of stream -----",!
 D stream.%Close() ;*/
 
 /*/ДОБАВИТЬ ФАЙЛ
 Set stream=##class(%GlobalCharacterStream).%New()
 for I=1:1:100 D stream.WriteLine(I_" ASASAS")
 If 'ftp.Append("CLIENT\AAA.TXT",stream) Write "Failed to PUT file",! G FTPSTOP
 D stream.%Close() ;*/
 
 /*/ВОЗВРАТИТЬ ФАЙЛ
 Set stream=##class(%GlobalCharacterStream).%New()
 If 'ftp.Retrieve("CLIENT\mAIN.FRM",stream) Write "Failed to get file",! G FTPSTOP
 IF stream.Size>0 D
 .Write "-------- Length of file received: ",stream.Size," ------",!
 . new len,line
 . for  set len=32763,line=stream.Read(.len) do  quit:stream.AtEnd
 .. write line
 .Write !," -------- End of stream -----",!!!!
 D stream.%Close() ;*/
FTPSTOP If 'ftp.Logout() S ER="Failed to logout"
 Do ftp.%Close()
 Q
}

/// Получить IP адрес
/// w ##class(App.net).GetIP()
ClassMethod GetListIP() As %String
{
 set lsIface=##class(%SYSTEM.INetInfo).GetListOfConfiguredInterfaces()
 for iface=1:1:$ll(lsIface) { 
   s IPv4=$lg($lg(lsIface,iface),2)
   if $l(IPv4,":")>2 {set IPv4=$lg($lg(lsIface,iface),3) if $l(IPv4,":")>2 {set IPv4=""}}
   write IPv4,!
 }
}

/// Получить IP адрес
/// w ##class(App.net).GetIP()
ClassMethod GetIP() As %String
{
	q $P($ZU(54,13,$zu(54,0)),",",1)
}

/// Получить ответ на Post Http запрос
/// w ##class(App.net).PostHttp("cip-test.mvk.ru:57772", "/apptoolsrest/jsonrpc","msw" ,"S37@asu3" ,"{""jsonrpc"":""2.0"",""method"":""server.shutdown"",""params"":{""server"":""42""},""id"":1}",.out)
ClassMethod PostHttp(ServerPort, method, user, pass, ByRef body, ByRef out) As %String
{
    set ht = ##class(%Net.HttpRequest).%New()
	set ht.Server = $p(ServerPort,":")
	if user'="" {
		set ht.Username=user
		set ht.Password=pass
	}
	s ht.ContentType="text/html;  charset=UTF-8"
	;s ht.ContentType="application/json; charset=UTF-8"
	i $p(ServerPort,":",2)'="" set ht.Port = $p(ServerPort,":",2)
	Do ht.EntityBody.Write($g(body))
	if $d(body)>1 s i="" f  s i=$o(body(i)) q:i=""  Do ht.EntityBody.Write(body(i))
	
	Do ht.Post(method)
	;Do ht.HttpResponse.OutputToDevice()
	S out=ht.HttpResponse.StatusLine
	;s ^z1=ht.HttpResponse.ContentLength
    set i="" for  S i=ht.HttpResponse.GetNextHeader(i) Q:i=""  S out("Header",i)=ht.HttpResponse.GetHeader(i)
    if ht.HttpResponse.Data.Size>0 {
	    set sc=##class(App.files).Stream2String(ht.HttpResponse.Data,.json)
	    m out("Data")=json
	}
 	do ht.%Close()
 	q $g(out)
}

}

