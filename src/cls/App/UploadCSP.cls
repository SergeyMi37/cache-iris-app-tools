Include App.LogMacro

Class App.UploadCSP Extends %CSP.Page
{

/// Путь к директории на сервере для хранения файлов
Parameter pathfiles = {##class(%File).GetDirectory(##class(%File).TempFilename())};

ClassMethod OnPage() As %Status
{
    #; был передан файл, поэтому ответим браузеру, о том что приняли файл и как
    s FieldName="loadFile"
    if $g(%loadFileSuccess)'="" {
	    if $lv(%loadFileSuccess) {
	        if $lg(%loadFileSuccess,1) {
		        if $lg(%loadFileSuccess,5)'=1 w "<H3>Произошла ошибка</h3>"_$System.Status.DisplayError($lg(%loadFileSuccess,5))_"<p><p>Попробуйте еще раз, в противном случае обратитесь к администратору через HelpDesk" q 1
	    		s orig=$lg(%loadFileSuccess,6)
	    		s orig=$s(orig["\":$p(orig,"\",*),1:$p(orig,"/",*))
	    		s orig=$tr(orig," №`()\/*;'"":","_N---")
	    		w "<script>"
	    		w "window.opener.document.getElementById('"_$g(%request.Data("FieldName",1))_"').value='"_$lg(%loadFileSuccess,2)_"*"_orig_"';"
	    		;w "alert('"_$g(%request.Data("FieldName",1))_"OriginalFileName'+'='+'"_orig_"');"
	    		;w "try{ window.opener.document.getElementById('"_$g(%request.Data("FieldName",1))_idOrigNameReturn_"').value='"_orig_"';} catch(e){ };"
	    		w "window.close();"
	    		w "</script>"
	    		q 1
	            #; файл принят удачно, ответим об удачном приеме и отправим имя файла и его размер
	            w "{""success"":true,",
	                """fileName"":"""_$lg(%loadFileSuccess,2)_""",",
	                """fileSize"":"""_$lg(%loadFileSuccess,3)_"""}"
	        } else {
	            #; произошла ошибка при приеме файла
	            w "<H3>Произошла ошибка при приеме файла</h3> Попробуйте еще раз, в противном случае обратитесь к администратору через HelpDesk"
	            q 1
	            w "{""error"":""Error load file""}"
	        }
	        q $$$OK
	    }
    }
    #; HTML форма для отправки файлов
     ;m a=%request.Data     zw a
    &html<<!DOCTYPE HTML>
<html>
<head>
<title>Загрузка файлов</title>
>
 write ##class(App.LogInfoPane).GetLink()
 &html<
    <script>
        $(document).ready(function(){
            $(this).keydown(function(eventObject){
                if (eventObject.which == 27)
                    window.close();
            });
        });
    </script>  
</head>
<body bgcolor="#f0f8ff" >
<form action="#(..%ClassName(1)_".cls")#" enctype="multipart/form-data" method="post">
    <br><center>
     Выберите файл: <input class='ui-button ui-corner-all ui-widget' name='loadFile' id='loadFile' size=30 type='file' accept=".doc,.docx,.odt,.pdf,.xls,.xlsx" >
    <br><br>
    <input class='ui-button ui-corner-all ui-widget' type="submit" value="Загрузить файл"> <input class='ui-button ui-corner-all ui-widget' type="button" value="Отмена" onclick='window.close();'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=FieldName id=FieldName value='#($g(%request.Data("idreturn",1)))#'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=idOrigNameReturn id=idOrigNameReturn value='#($g(%request.Data("idOrigNameReturn",1)))#'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=ServerDirPath id=ServerDirPath value='#($g(%request.Data("ServerDirPath",1)))#'>
    </center>
</form></body>
</html>
>
    Quit $$$OK
}

///  [ ServerOnly = 1 ]
ClassMethod OnPreHTTP() As %Boolean
{
	set ServerDirPath=$zconvert($g(%request.Data("ServerDirPath",1)),"I","URL")
	if ServerDirPath="" set ServerDirPath=..#pathfiles

    #; Передан файл
    ;if $d(%request.Data("loadFile")) {
        s %loadFileSuccess=0
        #; поле с файлом
        s FieldName="loadFile"
        #; получим содержимое файла
        i %request.IsDefinedMimeData(FieldName,1) {
            s ContentType=%request.MimeData(FieldName,1).ContentType
            s Content=%request.MimeData(FieldName,1)
        } else {
            s ContentType=%request.ContentType
            s Content=%request.Content
        }
        #; если файл получен, и он не нулевого размера, соберем информацию по нему
        i $isobject(Content),Content.Size>0 {
	        s fileName=Content.FileName
	        ;s name=$tr(##class(App.type).GetDateTime($h),"T: ","_--")_"_"_$p(fileName,"\",*)
	        s name=$tr(##class(App.type).GetDateTime($h),"T: ","_")_"_"_$tr(##class(App.type).Transliteration($p(fileName,"\",*))," №`()","_N---")
	        s %loadFileSuccess=$lb(1,$g(name),Content.Size)
	        s sc=##class(App.files).Stream2Log(Content, ServerDirPath,$zconvert( name,"O","UTF8"),.path) 
	        if sc s %loadFileSuccess=%loadFileSuccess_$lb($g(path),1,fileName)
	        else  s %loadFileSuccess=%loadFileSuccess_$lb($g(path),sc)
	        
        }
    	;s ^logMSW2(1,$i(^logMSW2),"0 %request-%loadFileSuccess")=%loadFileSuccess
        q 1
    ;}
    q 1
}

}

