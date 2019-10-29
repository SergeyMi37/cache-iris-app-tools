Include App.LogMacro

Class App.ChartPanel Extends App.LogInfoPane
{

/// Drawing graphs
Method DrawBODY(pInstance As PageInstance) As %Status [ PublicList = (nsp, what, field, value, type, typeclass, caption) ]
{
 	write ##class(App.LogInfoPane).AddJsScripts("chart")
	set $ZT="errors"
	set nsp=%request.Get("NSP")
	if nsp'="" try {zn nsp set NSpace=nsp } catch e {}
	set NSpace=$zu(5)

	s arg("header")="Error"
	s arg("labels")="[""Error""]"
	s arg("type")="bar" ;line
	s arg("datasets")="{   label: """_$$$aText("Error display on the graph","")_""", borderColor: 'rgb(255, 199, 132)',  data: [30],  }"

	s days=1000
	i %request.Get("days") S days=%request.Get("days")
	
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
	;the same light alfa=1 because the opacity: 100% *
	i c=0 q "rgba(255, 0, 0, "_alfa_")" ;pure red
	i c=1 q "rgba(255, 99, 132, "_alfa_")" ;red
    i c=2 q "rgba(255, 159, 64, "_alfa_")" ;orange
    i c=3 q "rgba(255, 206, 86, "_alfa_")" ;yellow
    i c=4 q "rgba(0, 255, 0, "_alfa_")" ;pure green
    i c=5 q "rgba(75, 192, 192, "_alfa_")" ;green
    i c=6 q "rgba(12, 164, 240, "_alfa_");" ;blue
    i c=7 q "rgba(0, 0, 255, "_alfa_")" ;clear blue
    i c=8 q "rgba(54, 162, 235, "_alfa_")" ;blue
    i c=9 q "rgba(153, 102, 255, "_alfa_")" ;purple
}

/// Complete the chart objects
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

/// Dynamics of consumption of license on the basis of regular job 
/// with legacy method: s st=##class(App.sys).SaveQuery("%SYSTEM.License:Counts")
/// d ##class(App.ChartPanel).ChartLicUsed(.arg,1200,.res)
ClassMethod ChartLicUsed(arg, days, res, gn = "^%App.Task")
{
 s par=$p(days,",",2,999)
 s days=+days
 s ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 s arg("header")=$$$aText("The dynamics of license spending based on a regular job in a date range ","")_FromDay_" - "_ToDay
 s arg("type")="line"
 s GN=$na(@gn@("%SYSTEM.License:Counts"))
 s dt=""
 f i=1:1:10 { s dt=$o(@GN@(dt),1) q:dt=""
 	w !,dt," ",$g(@GN@(dt,4,2))
 }
}

/// Search in the Protocol cconsole.log important events
/// d ##class(App.ChartPanel).ChartAlert(.arg,1200,.res)
ClassMethod ChartAlert(arg, days, res, list, mm)
{
 	s method="class(App.files).Alert" 
	d ##class(App.files).FindContextInLog(days,method,.res) // to parse a Protocol to calculate important events
	s df=$p(res," ",1)
	s dt=$p(res," ",2)
	s arg("header")=$$$aText("Important system events in the date range ","")_df_" - "_dt
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
 q $$$OK
}

/// Retrospective database sizes
/// d ##class(App.ChartPanel).ChartDbSize(.arg,1200,.res,.list,.mm)
ClassMethod ChartDbSize(arg, days, res, list, mm)
{
	s method="class(App.files).ExpansionDB" 
	d ##class(App.files).FindContextInLog(days,method,.res) //to disassemble the Protocol to calculate the monthly growth of the database in megabytes
	d ##class(App.RestMetrics).getDBsize("dbsize",.list) //to calculate the current database size in gigabytes
	//let's go back in time taking masany growth
	s df=$p(res," ",1)
	s dt=$p(res," ",2)
	s arg("header")=$$$aText("Dynamics of database growth in the date range ","")_df_" - "_dt
	s arg("type")="line"
	s labels="["
	s datasets="{  label: """_$$$aText("Error display on the graph","")_""", borderColor: '"_..ColorRGBa(0,1)_"',  data: [30],  }"
	s bd="",(max,free,maxbd)=0
	f num=1:1 { s bd=$o(list(bd)) q:bd=""  
		s list(bd)=list(bd)*1024
		i list(bd)>max s max=list(bd),free=list(bd,"free")*1024,maxbd=list(bd,"name")
		s order(list(bd))=bd //Rangiroa size
		s color(bd)=num
	}
	s list("free","name")="Disk Free Size + "_$g(maxbd)
	s list("free")=max+free
	s order(max+free)="free"
	s color("free")=0
	;zw order	zw list
	//translate into megabytes
	s mm=$p(dt,".",2)
	f yyyy=$p(dt,".",3):-1:$p(df,".",3) {
		for {
			i mm?1n s mm="0"_mm
			;w !,yyyy,"-",mm
			s bd=""	f { s bd=$o(list(bd)) q:bd=""   continue:bd="total"
				s mm(yyyy,mm,bd)=list(bd) ;,1,2) ;the current size of the gig
				i $d(res(bd,yyyy,mm)) {
					s list(bd)=list(bd)-($g(res(bd,yyyy,mm))) //subtract monthly increase in moving Gigi
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

/// Plot the error of the ensemble Protocol Ens_Util.Log where Type='2' 
ClassMethod ChartEnsUtilLog(arg, days, res, list)
{
 s ns=$p(days,",",2,999)
 s days=+days
 s ToDay=$zd($h,3),FromDay=$zd($h-days,3)
 s sql="select Convert(VarChar,TimeLogged, 103) as days,count(*) as erro from Ens_Util.Log where Type='2' and TimeLogged>'"_FromDay_"' and TimeLogged<'"_ToDay_"' and (Text not like '%ErrFTP%' and Text not like '%"_$$$aText("Not implemented","")_"%' and text not like '%"_$$$aText("The key is not defined uniquely","")_"%' and text not like '%Could not get%') group by Convert(VarChar,TimeLogged, 103)"
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
 s arg("header")=$$$aText("Number of Ens_Util errors.Log in date range","")_FromDay_" - "_ToDay
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

