Include App.LogMacro

/// Утилиты работы с типами
Class App.type [ Abstract ]
{

/// Вернуть дату в формате 3 
/// App.type_Date3(DateFrom)
ClassMethod Date3(h As %String) As %String [ SqlProc ]
{
	return $zd(h,3)
}

/// Посчитать количество секунд в ГГГГ-ММ-ДД ЧЧ:ММ:СС или в $HOROLOG
/// w ##class(App.type).GetCountSec("2018-07-06 08:14:47")
/// w ##class(App.type).GetCountSec($h)
ClassMethod GetCountSec(h) As %String
{
	i h["-" s h=..GetHorYYYYMMDD(h)
	i h'["," q ""
	q $p(h,",",1)*86400+$p(h,",",2)
}

/// w ##class(App.type).GetTextMonth("05")
ClassMethod GetTextMonth(mm) As %String
{
	q $s(+mm="1":"январь",+mm="2":"февраль",+mm="3":"март",+mm="4":"апрель",+mm="5":"май",+mm="6":"июнь",+mm="7":"июль",+mm="8":"август",+mm="9":"сентябрь",+mm="10":"октябрь",+mm="11":"ноябрь",1:"декабрь")
}

/// Получить месяц
/// w ##class(App.type).GetMonth($h)
ClassMethod GetMonth(h) As %String
{
	q $p($zd(h,3),"-",2)
}

/// Перевести ГГГГ-ММ-ДД ЧЧ:ММ:СС в $HOROLOG
/// w ##class(App.type).GetHorYYYYMMDD("2018-07-06 08:14:47")
ClassMethod GetHorYYYYMMDD(dt) As %String
{
	try{ 
		s d=$zdh($p(dt," "),3)
		s c=$zth($p(dt," ",2),1)
		s res=d_","_c
	}
	catch e { s res="" }
	q $g(res)
}

/// Проверить на валидность и вывести дату
/// w ##class(App.type).GetValidZD(+$h)
ClassMethod GetValidZD(hr) As %String
{
	try{ s res=$tr($zd(hr,4),"/",".") }
	catch e { s res="" }
	;$$$LogError("Дополнительное сообщение1")
	q res
}

/// Получить год в формате 2018
/// w ##class(App.type).GetYear($h)
ClassMethod GetYear(h) As %String
{
	q $p($zd(h,3),"-",1)
}

/// Получить дату в формате 2018-04-03T16:40:30
/// w ##class(App.type).GetDateTime($h)
ClassMethod GetDateTime(h) As %String
{
	q $zd(h,3)_"T"_##class(App.type).GetValidZT(h)
}

/// Проверить на валидность и вывести время
/// w ##class(App.type).GetValidZT($h)
ClassMethod GetValidZT(hr) As %String
{
	try{ s res=$zt(+$p(hr,",",2),1) }
	catch e { s res="" }
	;$$$LogError("Дополнительное сообщение "_hr)
	q res
}

/// Переведем дату к формату DD.MM.YY
/// w ##class(App.type).getDDMMYY("2016-05-05")
ClassMethod getDDMMYY(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s pStringDate=$zd(pStringDate,3)
		i pStringDate["." s date=pStringDate s:$p(date,".",3)?4n date=$p(date,".",1,2)_"."_$e($p(date,".",3),3,4)
		i pStringDate["-" s date=$p(pStringDate,"-",3)_"."_$p(pStringDate,"-",2)_"."_$e($p(pStringDate,"-",1),3,4)
		i pStringDate["/" s date=$p(pStringDate,"/",2)_"."_$p(pStringDate,"/",1)_"."_$e($p(pStringDate,"/",3),3,4)
	} catch e {}
	q $g(date)
}

/// Переведем дату к формату DD.MM.YYYY
/// w ##class(App.type).getDDMMYYYY("2016-05-05")
ClassMethod getDDMMYYYY(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s pStringDate=$zd(pStringDate,3)
		i pStringDate["." s date=pStringDate
		i pStringDate["-" s date=$p(pStringDate,"-",3)_"."_$p(pStringDate,"-",2)_"."_$p(pStringDate,"-",1)
		i pStringDate["/" s date=$p(pStringDate,"/",2)_"."_$p(pStringDate,"/",1)_"."_$p(pStringDate,"/",3)
	} catch e {}
	q $g(date)
}

/// Переведем дату к формату YYYY-MM-DD  FORMAT=3 передав формулу типа "CurrentDay+1"
/// w ##class(App.type).GetInpretDate("CurrentDay+1","12:00")
ClassMethod GetInpretDate(pStringDate As %String, time = "") As %String
{
	try {
		i pStringDate["CurrentDay" s pStringDate=$replace(pStringDate,"CurrentDay","$h")
		i pStringDate["$h"||(pStringDate["$H") {
			s %Date=""
			x "s %Date="_pStringDate
			s pStringDate=%Date
		}
		i pStringDate?1n.n s date=$zd(pStringDate,3) q
		i pStringDate["." s date=$p(pStringDate,".",3)_"-"_$p(pStringDate,".",2)_"-"_$p(pStringDate,".",1)
		i pStringDate["-" s date=pStringDate q
		i pStringDate["/" s date=$p(pStringDate,"/",3)_"-"_$p(pStringDate,"/",1)_"-"_$p(pStringDate,"/",2)
	} catch e {}
	q $g(date)_$s($g(date)'=""&&(time'=""):" "_time,1:"")
}

/// Переведем дату к формату YYYY-MM-DD  FORMAT=3
/// w ##class(App.type).getYYYYMMDD(+$h)
ClassMethod getYYYYMMDD(pStringDate As %String) As %String
{
	try {
		i pStringDate?1n.n s date=$zd(pStringDate,3) q
		i pStringDate["." s date=$p(pStringDate,".",3)_"-"_$p(pStringDate,".",2)_"-"_$p(pStringDate,".",1)
		i pStringDate["-" s date=pStringDate q
		i pStringDate["/" s date=$p(pStringDate,"/",3)_"-"_$p(pStringDate,"/",1)_"-"_$p(pStringDate,"/",2)
	} catch e {}
	q $g(date)
}

/// Интерпретирует строку с текущей датой типа
/// Str= DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)
/// Результат вычисленное значение выражения  "added?DateFrom=06.06.2018&DateTo=07.06.2018"
/// w ##class(App.type).InterpretCurrentDay("added?DateFrom=(CurrentDay-2)&DateTo=(CurrentDay-1)",.res)
ClassMethod InterpretCurrentDay(Str As %String, Result As %String) As %Status
{
	#dim tSC As %Status = $$$OK
	#dim e As %Exception.AbstractException
	
	s exp=$p(Str,"?",2)
	q:exp="" "0"
	s exp="s "_$replace(exp,"CurrentDay",+$h)
	s exp=$replace(exp,"&DateTo",",%tempTo")
	s exp=$replace(exp,"DateFrom","%tempFrom")
	try {
		x exp
		s Result=$p(Str,"?",1)_"?DateFrom="_$tr($zd(%tempFrom,4),"/",".")_"&DateTo="_$tr($zd(%tempTo,4),"/",".")
		k %tempFrom,%tempTo
	} Catch e {
		Set tSC=e.AsStatus()
	}
	q tSC
}

/// w ##class(App.type).Transliteration("sfdsdsdfываыавапв")
ClassMethod Transliteration(Str As %String) As %Status
{
	q $tr(Str,"ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ","eicukengsszxyfyvaproldzezccmitybyEICUKEHGSSZXYFYBAPROLDZEYCCMITYBY")
}

/// Разобрать строку по CGI переменным 
/// w ##class(App.type).ParseURL("aaa=sfdsds&bbb=dfываыавапв")
ClassMethod ParseURL(str As %String, ByRef out, del = "&") As %Status
{
	f i=1:1:$l(str,del) {
		continue:$p(str,del,i)=""
		continue:$p($p(str,del,i),"=")=""
		s out($p($p(str,del,i),"="))=$p($p(str,del,i),"=",2)
	}
}

/// Вывести js код для выбора файла в новом окне и загрузки его на сервер
/// ##class(App.type).UploadFilesJS(%id)
ClassMethod UploadFilesJS(id, %id) As %Status
{
	s onclick="win=window.open('App.UploadCSP.cls?idreturn="_id_"&ServerDirPath="_$zconvert($g(%id("filesStore")),"O","URL")_"', 'winupload', 'location=no,left=200,top=300,width=800,height=300,scrollbars=no,status=no,toolbar=no,menubar=no');"
	q $$$appButton("appButtonUpload"_id,"onclick="""_$g(onclick)_"""","Загрузить файл")
}

/// Получить имя таблицы из Класса
/// w ##class(App.type).GetTableName("App.sss.user")
ClassMethod GetTableName(SelectClass) As %String
{
	set (tab,table)=$p(SelectClass,".",*)
	//Если имя таблицы - ключевое слов, обрамим в кавычки
	set:$SYSTEM.SQL.IsReservedWord(table) table = """"_table_""""
	set tab=$tr($p(SelectClass,"."_tab,1),".","_")_"."_table
	q tab
}

/// Вывести сумму прописью
/// w ##class(App.type).SummaProp(1111111.11)
ClassMethod SummaProp(n) As %String
{
 q $$sump(n)
sump(n) ;$$;преобразование
 s n=+$j($tr(n,","),"",2)
 ;w !,$fn(num,",",2),!
 s n=$$tran(n)_"k"
 ;составляем разряды
 s n=$$repl(n,",,,,,,,","eT")
 s n=$$repl(n,",,,,,,","eM")
 s n=$$repl(n,",,,,,","em")
 s n=$$repl(n,",,,,","et")
 s n=$$repl(n,",,,","e")
 s n=$$repl(n,",,","d")
 s n=$$repl(n,",","c")
 ;убрать пустые значения
 s n=$$repl(n,"0c0d0eT","")
 s n=$$repl(n,"0c0d0et","")
 s n=$$repl(n,"0c0d0em","")
 s n=$$repl(n,"0c0d0eM","")
 ;заменяем соответвующие значения на пропись
 s n=$$repl(n,"0c","")
 s n=$$repl(n,"1c","сто ")
 s n=$$repl(n,"2c","двести ")
 s n=$$repl(n,"3c","триста ")
 s n=$$repl(n,"4c","четыреста ")
 s n=$$repl(n,"5c","пятьсот ")
 s n=$$repl(n,"6c","шестьсот ")
 s n=$$repl(n,"7c","семьсот ")
 s n=$$repl(n,"8c","восемьсот ")
 s n=$$repl(n,"9c","девятьсот ")
 ;
 s n=$$repl(n,"1d0e","десять ")
 s n=$$repl(n,"1d1e","одиннадцать ")
 s n=$$repl(n,"1d2e","двенадцать ")
 s n=$$repl(n,"1d3e","тринадцать ")
 s n=$$repl(n,"1d4e","четырнадцать ")
 s n=$$repl(n,"1d5e","пятнадцать ")
 s n=$$repl(n,"1d6e","шестнадцать ")
 s n=$$repl(n,"1d7e","семьнадцать ")
 s n=$$repl(n,"1d8e","восемнадцать ")
 s n=$$repl(n,"1d9e","девятнадцать ")
 ;
 s n=$$repl(n,"0d","")
 s n=$$repl(n,"2d","двадцать ")
 s n=$$repl(n,"3d","тридцать ")
 s n=$$repl(n,"4d","сорок ")
 s n=$$repl(n,"5d","пятьдесят ")
 s n=$$repl(n,"6d","шестьдесят ")
 s n=$$repl(n,"7d","семьдесят ")
 s n=$$repl(n,"8d","восемьдесят ")
 s n=$$repl(n,"9d","девяносто ")
 ;
 s n=$$repl(n,"0e","")
 s n=$$repl(n,"5e","пять ")
 s n=$$repl(n,"6e","шесть ")
 s n=$$repl(n,"7e","семь ")
 s n=$$repl(n,"8e","восемь ")
 s n=$$repl(n,"9e","девять ")
 ;
 s n=$$repl(n,"1e.","один рубль ")
 s n=$$repl(n,"2e.","два рубля ")
 s n=$$repl(n,"3e.","три рубля ")
 s n=$$repl(n,"4e.","четыре рубля ")
 s n=$$repl(n,"1et","одна тысяча ")
 s n=$$repl(n,"2et","две тысячи ")
 s n=$$repl(n,"3et","три тысячи ")
 s n=$$repl(n,"4et","четыре тысячи ")
 s n=$$repl(n,"1em","один миллион ")
 s n=$$repl(n,"2em","два миллиона ")
 s n=$$repl(n,"3em","три миллиона ")
 s n=$$repl(n,"4em","четыре миллиона ")
 s n=$$repl(n,"1eM","один милиард ")
 s n=$$repl(n,"2eM","два милиарда ")
 s n=$$repl(n,"3eM","три милиарда ")
 s n=$$repl(n,"4eM","четыре милиарда ")
 s n=$$repl(n,"1eT","один триллион ")
 s n=$$repl(n,"2eT","два триллиона ")
 s n=$$repl(n,"3eT","три триллиона ")
 s n=$$repl(n,"4eT","четыре триллиона ")
 ;копейки
 s n=$$repl(n,"11k","11 копеек")
 s n=$$repl(n,"12k","12 копеек")
 s n=$$repl(n,"13k","13 копеек")
 s n=$$repl(n,"14k","14 копеек")
 s n=$$repl(n,"1k","1 копейка")
 s n=$$repl(n,"2k","2 копейки")
 s n=$$repl(n,"3k","3 копейки")
 s n=$$repl(n,"4k","4 копейки")
 ;пустые позиции
 s n=$$repl(n,"et","")
 s n=$$repl(n,"em","")
 s n=$$repl(n,"eM","")
 s n=$$repl(n,"eT","")
 ;если число <1
 s:$p(n,".")="" n="ноль "_n
 ;
 s n=$$repl(n,".","рублей ")
 s n=$$repl(n,"t","тысяч ")
 s n=$$repl(n,"m","миллионов ")
 s n=$$repl(n,"M","милиардов ")
 s n=$$repl(n,"T","триллионов ")
 s n=$$repl(n,"k"," копеек")
 ;НЕРАСПОЗНАННЫЕ ОСТАТКИ ОТ ПРЕОБРАЗОВАНИЯ
 s n=$tr(n,".ecdtmMkT")
 ;w !,n
 q n
 ;
tran(n) ;$$;приводим в форму пригодную для замены
 s n=$tr($j(n,18,2)," ","0")
 s n=$tr("q,w,,e,,,,,,,r,t,,y,,,,,,u,i,,o,,,,,p,a,,s,,,,d,f,,g,,,.hj","qwertyuiopasdfg.hj",n)
 ;w !,n
 q n
 
repl(s,s0,sn)
 q $replace(s,s0,sn)
}

/// Получить временную глобальну ссылку
/// w ##class(App.type).tempGN("GN")
ClassMethod tempGN(GN, NoKill = 0) As %String
{
	s gn=$na(^tmpSPGZ(GN,$j)) 
	if 'NoKill KILL @gn	s @gn=$$$AppDT($h)
	q gn
}

}

