Include App.LogMacro

/// Network Utility %Net.HttpRequest, %Net.SMTP, %Net.FTP
Class App.net [ Abstract, DependsOn = App.msg ]
{

/// Zip files and Send to email
/// w ##class(App.net).SendFilesToEmail("subj send file", "send arhive file", .files, 1, "my_email@gmail.com")
ClassMethod SendFilesToEmail(subj, text, files, zip = 1, email = "") As %Status
{
	;send files to email
	s f="" for { s f=$o(files(f)) q:f=""
		s path=$p(f,$$$slash,1,*-1)
		s file=$p(f,$$$slash,*)
		if zip {
			s sc=##class(App.files).zipFile(path,file,file_".zip",path)
			if sc {s file=file_".zip" 
			}
			i 'sc s $$$AppL("APP","SendFilesToEmail")=$System.Status.GetErrorText(sc) 
		}
		s filez($i(fil),"path")=path_$$$slash
		s filez(fil)=file
	}	
	s sc=##class(App.LogInfo).SendEmail(email, subj, text, .filez)
	i 'sc s $$$AppL("APP","SendFilesToEmail2")=$System.Status.GetErrorText(sc) 
	
	q $$$OK
}

/// To send email
/// subscrible - a comma separated list whom to send the letter
/// subj - subject
/// text - the text of the letter
/// attach - an array of files the link
ClassMethod SendMail(server, port, ssl, UseSTARTTLS, timezone, username, psw, from, subscrible, subj, text, attach) As %Status
{
 #dim smtp As %Net.SMTP
 #; Define SMTP server for sending
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
 set mail.Subject=$s($g(subj)="":$g(Subj),1:$g(subj))     ; Subject - the subject
 set mail.Charset="windows-1251"
 set mail.IsHTML=$s(text["<html":1,1:0)
 set mail.IsMultiPart=1
 set mail.MultiPartType="related" 
 do mail.TextData.Write(text)
 set sc=$$$OK
 ; If a single file is transmitted in text format $lb
 if $g(attach)'="" {
	 set attach(1)=$lg(attach,2)
	 set attach(1,"path")=$lg(attach,1)
	 set:$lg(attach,3)'="" attach(1,"content-type")=$lg(attach,3) ;image/jpeg
 }
 ; A lot of files
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

/// Download the file and put on the server by adding the name of the mark date and time
ClassMethod LoadFileHttp(aURL = "", aDATA, TempDir = "", fileName) As %Status
{
	s st=##class(App.net).GetHttp(aURL,.aDATA)
	i 'st q st
	i $g(aDATA("status"))'=200 q $$$ERROR($$$GeneralError,"Status HTTP "_$g(aDATA("status")))
	s sc=1
	i TempDir'="" s sc=##class(App.files).Stream2Log(aDATA("content"), TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	q sc
}

/// To receive from the data server at the URL
/// If TempDir is specified, then the file will be written there 
/// w ##class(App.net).GetHttp("https://codeload.github.com/SergeyMi37/cache-iris-app-tools/zip/master",.out2,"D:\temp\")
ClassMethod GetHttp(aURL = "", aDATA, TempDir = "", tmpGN = "") As %Status
{
	set part1=$p(aURL,"/",3),part2=$p(aURL,"/",4,$l(aURL,"/")),params=$p(aURL,"?",2)
	#; Server
	set server=$p(part1,":",1) quit:(server="") $$$ERROR($$$GeneralError,"0:"_$$$aText("no server",""))
	#; Port
	set port=$p(part1,":",2)
	#; Address
	set location=$p(part2,"?",1) quit:(location="") $$$ERROR($$$GeneralError,"0:"_$$$aText("missing address","")_" - "_location)
	#; Create HTTP request to download the file
	set HttpRequest=##class(%Net.HttpRequest).%New()
	set HttpRequest.Server=server
	if $f($zcvt(aURL,"L"),"https://") {
		set:(port="") port=443
		set HttpRequest.Https=1
		;set HttpRequest.FollowRedirect = 1
		set HttpRequest.SSLConfiguration=..CheckSSLCertificate("DefaultSSL")
	
	#; Request HTTP
	} else {
		s:(port="") port=80
	}
	;w !,server,!,location,!,port,!,params
	set HttpRequest.Port=port
	
	#; Fill in the parameters
	for i=1:1:$l(params,"&") { s pair=$p(params,"&",i),name=$p(pair,"=",1),value=$p(pair,"=",2)
		continue:(name="")	
		;Conversion, to prevent double conversion
		s value=$zcvt(value,"I","URL") 
		d HttpRequest.SetParam(name,value)
	} ; /for i
	
	#; Execute the query
	Try { d HttpRequest.Get(location) } Catch Error { s err=Error.AsSystemError() }
	quit:($g(err)'="") $$$ERROR($$$GeneralError,err)
	#; The processed response is received
	set HttpResponse=HttpRequest.HttpResponse 
	quit:('$isobject(HttpResponse)) $$$ERROR($$$GeneralError,$$$aText("the server does not return a response",""))
	quit:(HttpResponse.StatusCode'=200) $$$ERROR($$$GeneralError,HttpResponse.ReasonPhrase)
	s aDATA("status")=HttpResponse.StatusCode
	#; Parse the response from the server, keeping the structure of the aDATA
	set aDATA("contentType")=HttpResponse.ContentType
	#; The name of the file received via the "content-disposition" as "attachment;filename="name.ext";"
	s fileName=HttpResponse.GetHeader("content-disposition")
	s aDATA("content-disposition")=fileName
	if ($l(fileName,"*=utf-8''")>1) {
		s fileName=$p(fileName,"*=utf-8''",2)
		s fileName=##CLASS(%CSP.Page).UnescapeURL(fileName)
		s fileName=$zcvt(fileName,"I","UTF8")
	} else { s fileName=$p(fileName,"filename=",2),fileName=$tr($p(fileName,";",1),"""'","") }
	
	#; If the file name is not specified, use as the name of the piece of the link
	s:(fileName="") fileName=$p(location,"/",$l(location,"/"))
	s aDATA("content")=HttpResponse.Data
	s aDATA("fileName")=$zcvt(fileName,"I","URL")
	i tmpGN'="" M @tmpGN=aDATA
	s sc=1
	i TempDir'="" s sc=##class(App.files).Stream2Log(HttpResponse.Data, TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	quit sc
}

/// The method checks for the existence of the configured SSL configuration
/// and creates an empty configuration with that name if this yet
/// to connect to a https server, that's enough
ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

/// To obtain the server's IP address
/// w ##class(App.net).GetIP()
/// $G(%request.CgiEnvs("REMOTE_ADDR")) - agrees client
ClassMethod GetListIP() As %String
{
 set lsIface=##class(%SYSTEM.INetInfo).GetListOfConfiguredInterfaces()
 for iface=1:1:$ll(lsIface) { 
   s IPv4=$lg($lg(lsIface,iface),2)
   if $l(IPv4,":")>2 {set IPv4=$lg($lg(lsIface,iface),3) if $l(IPv4,":")>2 {set IPv4=""}}
   write IPv4,!
 }
}

/// Get IP address
/// w ##class(App.net).GetIP("google.com")
/// w $P($ZU(54,13,$zu(54,0)),",",1)
ClassMethod GetIP(host = "") As %String
{
	if host="" set host=$zu(54,0) ;current host
	q $P($ZU(54,13,host),",",1)
}

/// To response to Http Post request
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
	
	;set ht.Https=1
	;set ht.Port = 443
	;set ht.SSLConfiguration=..CheckSSLCertificate("DefaultSSL")
	
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

/// d ##class(App.net).RunPage()
ClassMethod RunPage(Url As %String = "http://intersystems.ru")
{
    #Include %occOptions
    Set Browser = $s($$$isWINDOWS:"start", $$$isUNIX:"x-www-browser", 1:"x-www-browser")
    Set Command = Browser _ " " _ Url
    Do $ZF(-1, Command)
}

/// Import CSP-file from GitHub repository for 7z utility 
/// s repo="cache-iris-app-tools" d ##class(App.net).ImportCSPFromGitHub("https://codeload.github.com/SergeyMi37/"_repo_"/zip/master",repo,"d:\!\csptest")
ClassMethod ImportCSPFromGitHub(url, repo, target)
{
	s tempdir=$zu(12)_"Temp"_$$$slash_$p(##class(%File).TempFilename("zip"),$$$slash,*)
	w !,tempdir
	s st=##class(%File).CreateDirectory(tempdir)
	i 'st q st
 	s st=##class(App.net).GetHttp(url,.out,tempdir)
	s unzip=$zu(12)_"Temp"_$$$slash_$p(##class(%File).TempFilename("unzip"),$$$slash,*)
	s st=##class(%File).CreateDirectory(unzip)
	i 'st q st
	d ##class(App.files).UnzipToDirectory(tempdir_$$$slash_repo_"-master.zip",unzip)
	s source=unzip_$$$slash_repo_"-master"_$$$slash_"src"_$$$slash_"csp"
	w !,source_" copy to "_target,!
	s st=##class(%File).CopyDir(source,target,1,1,1)
	i 'st w !,st
	s source=unzip_$$$slash_repo_"-master"_$$$slash_"src"_$$$slash_"glb"_$$$slash_"appcachemsg.xml"
	do $system.OBJ.Load(source,"ck")
	d ##class(%File).RemoveDirectoryTree(tempdir)
	d ##class(%File).RemoveDirectoryTree(unzip)
	q $$$OK
}

/// MDEAM - MAIL SERVER NAME OR ITS IP
/// BSmName - USER NAME = "NAME_user@"_MDEAM
/// BSmPass - USER PASSWORD
/// MASS - THE ARRAY FROM WHICH TO CREATE THE PROGRAM, WHICH WILL BE BASED ON A LIST OF EMAILS
/// dir - the PATH TO the DIRECTORY WHERE you DOWNLOADED the attached FILES
///  d ##class(App.net).GetMailPOP3()
ClassMethod GetMailPOP3(MDEAM, BSmName, BSmPass, MASS, dir) As %String
{
 set mailserver=##class(%Net.POP3).%New()
 I $D(dir) set mailserver.AttachDir=dir
 set mailserver.Debug=0
 set mailserver.port=25
 set mailserver.StoreAttachToFile=1
 set status=mailserver.Connect(MDEAM,BSmName,BSmPass)
 if ('status) w !,$System.Status.GetErrorText(status) g clo
 f mssg=1:1 d  if ('status) Q
 .set status=mailserver.FetchMessage(mssg,.from,.to,.date,.subject,.messagesize,.hdrs,.mailMsg,0)
 .if ('status) Q
 .S MASS(mssg,"subject")=subject
 .S MASS(mssg,"date")=date
 .S MASS(mssg,"from")=from
 .S MASS(mssg,"messagesize")=messagesize
 .S MASS(mssg,"to")=to
 .K MAS
 .d Dump(mailMsg,.MAS)
 .M MASS(mssg,"z")=MAS
 .s status=mailMsg.%Close()
clo s status=mailserver.%Close()
	i 'status w !,$System.Status.GetErrorText(status)
 q $G(mssg)-1
 
Dump(msg,MASS) 
 ;new i,index,value
 if msg.IsMultiPart do  quit
 . for i=1:1:msg.Parts.Count() do Dump(msg.Parts.GetAt(i),.MASS)
 s index=""  f  s value=msg.Headers.GetNext(.index) q:index=""  S MASS(msg,"head",index)=value
 if msg.IsBinary do
 . S MASS(msg,"msg")="binary"
 . S MASS(msg,"msgFN")=msg.FileName
 . S MASS(msg,"msgGA")=msg.GetAttribute("content-disposition","filename")
 else  do
 . ;w !,"Dumping text msg Filename="_msg.FileName_" filename="_msg.GetAttribute("content-disposition","filename"),!
 . S MASS(msg,"msg")="text"
 . S MASS(msg,"msgFN")=msg.FileName
 . S MASS(msg,"msgGA")=msg.GetAttribute("content-disposition","filename")
 . set stream=msg.TextData
 . do stream.Rewind()
 . k len,line
 . for l=1:1 set len=32763,line=stream.Read(.len) do  quit:stream.AtEnd
 ..S MASS(msg,"msg",l)=line         ;write line
 quit
}

ClassMethod KILLMAIL(MDEAM, BSmName, BSmPass, MSGK, Kill) As %String
{
 S OK=1,Kill=0
 set mailserver=##class(%Net.POP3).%New()
 set mailserver.port=$G(^%BScSMTP(MDEAM,"POP"),"110")
 set mailserver.Debug=0
 set mailserver.StoreAttachToFile=1
 set status=mailserver.Connect(MDEAM,BSmName,BSmPass)
 if ('status) S OK=status g Kclo
 S I="" F  S I=$O(MSGK(I)) Q:I=""  set OK=mailserver.DeleteMessage(I) S:OK Kill=Kill+1 I 'OK Q
 s status=mailserver.QuitAndCommit()
Kclo s status=mailserver.%Close()
 q $G(OK)
}

}

