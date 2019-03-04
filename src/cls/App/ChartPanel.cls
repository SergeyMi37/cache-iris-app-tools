Include App.LogMacro

Class App.ChartPanel Extends App.LogInfoPane
{

/// Отрисовка графиков
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	do ##class(App.LogInfoPane).AddJsScripts("chart")
	set $ZT="errors"
	set nsp=%request.Get("NSP")
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)

	s arg("header")="Ошибка вывода графика"
	s arg("labels")="[""Тест""]"
	s arg("type")="bar" ;line
	s arg("datasets")="{   label: ""Ошибка вывода графика"", borderColor: 'rgb(255, 199, 132)',  data: [30],  }"

	s days=1000
	i %request.Get("days") S days=%request.Get("days")
	
	// 
	if %request.Get("panel")'="" {
		s class=$p($p(%request.Get("panel"),"(",2),")"),method=$p($p(%request.Get("panel"),")",2),".",2)
		s st=$classmethod(class,method,.arg,days)
	}
	&html< <canvas id="Chart"></canvas>
	>
	$$$jsstart
 	w "var ctx = document.getElementById('Chart').getContext('2d');"
 	w "var chart = new Chart(ctx, {   type: '"_$g(arg("type"),"bar")_"',"
    // The data for our dataset
    w "data: {  labels: "_$g(arg("labels"))_","   // ["January", "February", "March", "April", "May", "June", "July"],
    w "   datasets: ["_$g(arg("datasets"))
      /*  {
            label: "Ретроспектива размеров баз данных",
            //backgroundColor: 'rgb(255, 99, 132)',
            borderColor: 'rgb(255, 99, 132)',
            data: [0, 10, 5, 2, 20, 30, 45],
        },
        {
            label: "Ретроспектива размеров баз данных2222",
            //backgroundColor: 'rgb(255, 9, 132)',
            borderColor: 'rgb(255, 9, 132)',
            data: [10, 110, 5, 2, 20, 30, 55],
        }*/

    w " ] },  options: {    hover: { mode: 'index' }, tooltips: { mode: 'index' }	, title: { display: true, text: '"_$tr($g(arg("header")),"'""")_"'  }    } });"
	$$$jsstop
	quit $$$OK
errors
 	write !,$ze
 	quit $$$OK
}

/// d ##class(App.ChartPanel).ColorRGBa(32,0.2)
ClassMethod ColorRGBa(num, alfa = 1)
{
 
	s c=$e(+num,*)
	;i +num>9 
	;тот же свет alfa=1 потому как непрозрачность: 100% *
	i c=0 q "rgba(255, 0, 0, "_alfa_")" ;чистый красный
	i c=1 q "rgba(255, 99, 132, "_alfa_")" ;красный
    i c=2 q "rgba(255, 159, 64, "_alfa_")" ;оранжевый
    i c=3 q "rgba(255, 206, 86, "_alfa_")" ;желтый
    i c=4 q "rgba(0, 255, 0, "_alfa_")" ;чистый зеленый
    i c=5 q "rgba(75, 192, 192, "_alfa_")" ;зеленый
    i c=6 q "rgba(12, 164, 240, "_alfa_");" ;голубой
    i c=7 q "rgba(0, 0, 255, "_alfa_")" ;чистый синий
    i c=8 q "rgba(54, 162, 235, "_alfa_")" ;синий
    i c=9 q "rgba(153, 102, 255, "_alfa_")" ;фиолетовый
}

/// Завершить объекты графика
ClassMethod FinishArg(res, data, labels, arg)
{
	s datasets=""
	s a="" f num=1:1 { s a=$o(res(a)) q:a=""
		s data(a)=$e(data(a),1,*-1)_"], }"
		s datasets=datasets_data(a)_","
	}
	s datasets=$e(datasets,1,*-1)
	s labels=$e(labels,1,*-1)_"]"
	s arg("datasets")=datasets
	s arg("labels")=labels
	q 1
}

/// Динамика расходования лицензий на основе регулярного задания  
/// с legacy методом: s st=##class(App.sys).SaveQuery("%SYSTEM.License:Counts")
/// d ##class(App.ChartPanel).ChartLicUsed(.arg,1200,.res)
ClassMethod ChartLicUsed(arg, days, res, gn = "^%App.Task")
{
 s par=$p(days,",",2,999)
 s days=+days
 s ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 s arg("header")="Динамика расходования лицензий на основе регулярного задания в диапазоне дат с "_FromDay_" по "_ToDay
 s arg("type")="line"
 s GN=$na(@gn@("%SYSTEM.License:Counts"))
 s dt=""
 f i=1:1:10 { s dt=$o(@GN@(dt),1) q:dt=""
 	w !,dt," ",$g(@GN@(dt,4,2))
 }
}

/// Поиск в протоколе cconsole.log важных событий
/// d ##class(App.ChartPanel).ChartAlert(.arg,1200,.res)
ClassMethod ChartAlert(arg, days, res, list, mm)
{
 	s method="class(App.files).Alert" 
	d ##class(App.files).FindContextInLog(days,method,.res) ;разобрать протокол посчитать важные события
	s df=$p(res," ",1)
	s dt=$p(res," ",2)
	s arg("header")="Важные события системы в диапазоне дат с "_df_" по "_dt
	s arg("type")="line"
	s labels="["
	f yyyy=$p(df,".",3):1:$p(dt,".",3) {
		for m=1:1:12 {
			i yyyy=$p(df,".",3),m<$p(df,".",2)  continue
			i yyyy=$p(dt,".",3),m>$p(dt,".",2)  continue
			i m?1n s mm="0"_m
			e  s mm=m
			s labels=labels_""""_##class(App.type).GetTextMonth(mm)_"."_yyyy_""","
			s a="" f num=1:1 { s a=$o(res(a)) q:a=""
				i '$d(color(a)) s color(a)=num
				i '$d(data(a)) s data(a)="{  label: """_a_""", borderColor: '"_..ColorRGBa(color(a),1)_"',  data: ["
				s data(a)=data(a)_+$g(res(a,yyyy,mm))_","
			}

		}
	}
 d ..FinishArg(.res, .data, .labels, .arg)
 q 1
}

/// Ретроспектива размеров баз данных
/// d ##class(App.ChartPanel).ChartDbSize(.arg,1200,.res,.list,.mm)
ClassMethod ChartDbSize(arg, days, res, list, mm)
{
	s method="class(App.files).ExpansionDB" 
	d ##class(App.files).FindContextInLog(days,method,.res) ;разобрать протокол посчитать месячный прирост баз в мегабайтах
	d ##class(App.RestMetrics).getDBsize("dbsize",.list) ;посчитать актуальный размер бд в гигабайтах
	;пройдем назад по времени отнимая месяный прирост
	s df=$p(res," ",1)
	s dt=$p(res," ",2)
	s arg("header")="Динамика роста баз данных в диапазоне дат с "_df_" по "_dt_" в Мегабайтах"
	s arg("type")="line"
	s labels="["
	s datasets="{  label: ""Ошибка вывода графика"", borderColor: '"_..ColorRGBa(0,1)_"',  data: [30],  }"
	s bd="",max=0	f num=1:1 { s bd=$o(list(bd)) q:bd=""  
		s list(bd)=list(bd)*1024
		i list(bd)>max s max=list(bd),free=list(bd,"free")*1024,maxbd=list(bd,"name")
		s order(list(bd))=bd ;ранжируем по размеру
		s color(bd)=num
	}
	s list("free","name")="Disk Free Size + "_maxbd
	s list("free")=max+free
	s order(max+free)="free"
	s color("free")=0
	;zw order	zw list
	//переведем в мегабайты
	s mm=$p(dt,".",2)
	f yyyy=$p(dt,".",3):-1:$p(df,".",3) {
		for {
			i mm?1n s mm="0"_mm
			;w !,yyyy,"-",mm
			s bd=""	f { s bd=$o(list(bd)) q:bd=""   continue:bd="total"
				s mm(yyyy,mm,bd)=list(bd) ;,1,2) ;текущий размер гиг
				i $d(res(bd,yyyy,mm)) {
					s list(bd)=list(bd)-($g(res(bd,yyyy,mm))) ;вычитаем месячный прирост переведя в гиги
					i list(bd)<0 s list(bd)=0
				}
			}
			s mm=mm-1
			i mm<1 s mm=12 q
			i yyyy=$p(df,".",3),mm<$p(df,".",2) q

		}
	}
	s yyyy="" f { s yyyy=$o(mm(yyyy)) q:yyyy=""
		f mon=1:1:12 { 
			s mm=mon i mm?1n s mm="0"_mm
			continue:'$d(mm(yyyy,mm))
			s labels=labels_""""_##class(App.type).GetTextMonth(mm)_"."_yyyy_""","
			s bd2="" f { s bd2=$o(order(bd2),-1,bd) q:bd2=""
				i '$d(data(bd)) s data(bd)="{  label: """_list(bd,"name")_""", borderColor: '"_..ColorRGBa(color(bd),1)_"',  data: ["
				s data(bd)=data(bd)_$g(mm(yyyy,mm,bd))_","
			}
		}
	}
	s datasets=""
	s bd2="" f { s bd2=$o(order(bd2),-1,bd) q:bd2=""
		s data(bd)=$e(data(bd),1,*-1)_"], }"
		s datasets=datasets_data(bd)_","
	}
	s datasets=$e(datasets,1,*-1)
	s labels=$e(labels,1,*-1)_"]"
	s arg("datasets")=datasets
	s arg("labels")=labels
	q 1
}

/// Построить графики ошибок ансамбля по протоколу Ens_Util.Log where Type='2' 
ClassMethod ChartEnsUtilLog(arg, days, res, list)
{
 s ns=$p(days,",",2,999)
 s days=+days
 s ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 s sql="select Convert(VarChar,TimeLogged, 103) as days,count(*) as erro from Ens_Util.Log where Type='2' and TimeLogged>'"_FromDay_"' and TimeLogged<'"_ToDay_"' and (Text not like '%ErrFTP%' and Text not like '%Не реализовано%' and text not like '%Ключ не определен однозначно%' and text not like '%Could not get%') group by Convert(VarChar,TimeLogged, 103)"
 f i=1:1:$l(ns,",") {
	 s nspace=$p(ns,",",i)
	 continue:nspace=""
	 $$$NspGoto(curNs,nspace)
	 i nspace=$zu(5) {
		s gn="^||tmpCount" ;_$tr(nspace,"-")
		;w "<br>"_gn
		s res(nspace)=""
		d ##class(App.sys).SaveSQL(sql,gn)
		f ii=1:1 {  q:'$d(@gn@(ii))
			s count=+$lg($g(@gn@(ii)),2)
			s dat=$lg($g(@gn@(ii)),1)
			s dd=$p(dat,"/",1),mm=$p(dat,"/",2)
			s res(nspace,$p(dat,"/",3)_"-"_mm_"-"_dd)=count
		}
	 }
	 $$$NspReturn(curNs)
 }
 ;set st=##class(App.LogInfoPane).DrawArray(GN,1000,$zu(5),"Вывод массива "_GN) ;посмотреть массив
 s arg("header")="Количество ошибок Ens_Util.Log в диапазоне дат с "_FromDay_" по "_ToDay
 s arg("type")="line"
 s labels="["
 for day=$h-days:1:+$h {
	s labels=labels_""""_$zd(day,3)_""","
	s a="" f num=1:1 { s a=$o(res(a)) q:a=""
		i '$d(color(a)) s color(a)=num
		i '$d(data(a)) s data(a)="{  label: """_a_""", borderColor: '"_..ColorRGBa(color(a),1)_"',  data: ["
		s data(a)=data(a)_+$g(res(a,$zd(day,3)))_","
	}
 }
 d ..FinishArg(.res, .data, .labels, .arg)
 q 1
}

}

