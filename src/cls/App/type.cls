Include App.LogMacro

/// Утилиты работы с типами
Class App.type [ Abstract ]
{

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

}

