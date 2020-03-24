ROUTINE App.LogMacro [Type=INC]
#Include %occMessages
#Include App.JsonUtils
#;Include %msql $$$MaxStringLength
#;		;2016.2<= set title={}.%FromJSON(json).title 
#;		;2016.1 set title={}.$fromJSON(json).title
#;		set title={}.$$$jsonFromJSON(json).title
#define R(%property) %request.Content.##Expression(%property)
#define RG(%property) %request.Get(%property)
#define StackPlace 		$st($st(-1),"PLACE")
#define CurrentClass 	##Expression($$$quote(%classname))
#define CurrentMethod 	##Expression($$$quote(%methodname))
#define slash $s($zversion(1)=3:"/",1:"\")

#define MethodArguments ##Expression(##class(App.Log).GetMethodArguments(%classname,%methodname))

#define LogEvent(%type, %message) Do ##class(App.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,%type,$$$MethodArguments,%message)
#define LogNone(%message) 		$$$LogEvent("NONE", %message)
#define LogError(%message) 		$$$LogEvent("ERROR", %message)
#define LogFatal(%message) 		$$$LogEvent("FATAL", %message)
#define LogWarn(%message) 		$$$LogEvent("WARN", %message)
#define LogInfo(%message) 		$$$LogEvent("INFO", %message)
#define LogStat(%message) 		$$$LogEvent("STAT", %message)
#define LogDebug(%message) 		$$$LogEvent("DEBUG", %message)
#define LogRaw(%message) 		$$$LogEvent("RAW", %message)

#; To obtain the date and time in $h
#define LoggedDT(%h) $s(%h[",":$tr($zd(%h,4),"/",".")_" "_$zt(+$p(%h,",",2),1),1:"")

#; the macro saves the node in the global call stack and all local variables 
#; Example of usage: /apptools/App.LogInfo.cls?WHAT=?
#; If you need a trap for a particular process, to assign s ^logFIO(0)=Number of process
#define LogEventAddGN(%debubGN, %message) s %AppLogId=##class(App.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,"DEBUG",%debubGN,%message)
#define logdevGN 	"^log"
#define MgtPortalSettings 	"^CacheTemp.MgtPortalSettings"
#define AppLogTab(%type,%message,%desc) Do ##class(App.Log).AddRecord($$$CurrentClass,$$$CurrentMethod,$$$StackPlace,%type,%desc,%message)
#define AppLog(%dev,%node,%list,%mode) s zsr=$zr,zsG=$$$logdevGN_%dev  if $g(@zsG@(0))=$j||($g(@zsG@(0))="") { s @zsG@(1,$i(@zsG),%node)=%list,zsGzr=$zr if %mode["t" { $$$LogEventAddGN(zsGzr,%list) } if %mode["s" {s zsG=$na(@($qs(zsGzr,0)_"stack")@($qs(zsGzr,2))),@zsG=$lb($ze,$h,$tl,$io,$j,$zu(110),##class(App.LogInfoPane).GetPathStack(),##class(App.Log).GetClientAddress()) S zs1="",zsG=$na(@zsG@("varList")),zsii=0 k @zsG s:%mode["e" @zsG@("%%%$$LOG^%ETN")=$$LOG^%ETN  if %mode["v" { f { s zs1=$O(@zs1) q:zs1=""  continue:$e(zs1,1,2)="zs"&&(zs1'="zs")  if $d(@zs1)'["0",$isobject(@zs1) { s @zsG@(zs1)=##class(App.Log).SerializeObject(@zs1,$na(@zsG@(zs1))),zsii=zsii+1 } elseif $d(@zs1)>9 {s:$d(@zs1)=11 @zsG@(zs1)=@zs1,zsii=zsii+1 MERGE @zsG@(zs1)=@zs1 if zs1="%zlog" {s zs2="" for {s zs2=$o(@zs1@(zs2)) q:zs2=""   s @zsG@(zs1,zs2)=##class(App.Log).SerializeObject($G(@zs1@(zs2)),$na(@zsG@(zs1,zs2)),%mode)   }}}	 elseif $d(@zs1)=1 {s @zsG@(zs1)=@zs1,zsii=zsii+1}} s @zsG=zsii KILL zsii,zsG,zs1,zs2}else{KILL zsii,zsG,zs1,zs2,zsGzr}} try{ if $d(@zsr) KILL zsr} catch e { KILL zsr}}
#; To add an active link to the panel
#define addAppLog(%text,%title,%input,%target) "<a title='"_%title_"' "_$g(%target)_" href=""App.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert(%input,"O","URL")_""">"_%text_"</a>"
#define addAppL(%text) "<a target="""_$ZCRC(%text,7)_""" href=""App.LogInfo.cls?NSP="_$zu(5)_"&WHAT="_$zconvert(%text,"O","URL")_""">"_%text_"</a>"

#; To obtain the date and time YYYY-MM-DD HH:MM:SS
#define AppDT(%h) $zd(+%h,3)_" "_##class(App.type).GetValidZT(%h)
#define AppObJs(%ob)  $s($isobject(%ob):##class(App.Log).WriteJSONFromObject(%ob),1:%ob)
#define ApplogGN(%fio) ("^log"_$zconvert($e(%fio,1,3),"U"))
#;define AppL(%fio,%node) @$$$ApplogGN(%fio)@($i(@$$$ApplogGN(%fio)),$$$AppDT($h)_" "_%node)
#define AppL(%fio,%node) @$$$ApplogGN(%fio)@($i(@$$$ApplogGN(%fio)),$$$AppDT($h)_" ("_$classname()_")."_%node)

#define forAll(%in,%gn) s gn%in=$na(%gn) s %in="" f { s %in=$o(@gn%in@(%in)) q:%in=""
#define forAllk(%in,%kn,%gn) s gn%in=$na(%gn) s %in="" f %kn=1:1 { s %in=$o(@gn%in@(%in)) q:%in=""
#define forEnd  }

#; keep the name of the current region
#define NspGoto(%cur,%ns)  s %cur=$zu(5) try {zn %ns} catch e {} 
#; to return to the current region
#define NspReturn(%cur)  zn %cur
#;---------- layout
#;
#define appStyleInput " style='border: none;	background: none;	color: inherit;	padding: .222em 0;	margin: .2em 0;	vertical-align: middle;	margin-left: .4em;	margin-right: .4em;' "
#define appInputHidden(%id,%attr,%val) "<input type=hidden "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'>"
#define appText(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" type=text "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appAutocomplete(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input id='"_%id_"' name='"_%id_"' "_%attr_" "_$$$appStyleInput_" autocomplete='off' value='"_%val_"'>"
#define appAutocomplete2(%id,%attr,%val) "<input id='"_%id_"' name='"_%id_"' "_%attr_" class='ui-autocomplete-input' autocomplete='off' value='"_%val_"'>"
#define appInput(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appButton(%id,%attr,%val) $s($g(%ui):"<button class='uk-button uk-button-default uk-margin-small-right' type='button' "_%attr_" id='"_%id_"' name='"_%id_"' >"_%val_"</button>",1:"<input class='ui-button ui-corner-all ui-widget' type=button id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>")
#define appTextarea(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><textarea autocomplete='off' "_$$$appStyleInput_" "_%attr_" id='"_%id_"' name='"_%id_"' >"_%val_"</textarea></span>"
#define appDate(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" type=date "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#define appDateTime(%id,%attr,%val) "<span class='ui-spinner ui-corner-all ui-widget ui-widget-content'><input autocomplete='off' "_$$$appStyleInput_" type=datetime-local "_%attr_" id='"_%id_"' name='"_%id_"' value='"_%val_"'></span>"
#;define appCheck(%id,%attr,%val) "<input class='ui-button ui-corner-all ui-widget' type=checkbox id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>"
#define appCheck(%id,%attr,%val) "<input class='bigbox' type=checkbox id='"_%id_"' name='"_%id_"' "_%attr_" value='"_%val_"'>"
#define appSelect(%id,%attr,%val) ""
#define appError(%val) "<div class='ui-widget'><div class='ui-state-error ui-corner-all' style='margin-top: 20px; padding: 1em;'><p><span class='ui-icon ui-icon-alert' style='float: left; margin-right: 3em;'></span>"_%val_"</p></div></div>"
#define appMsg(%val) "<div class='ui-widget'><div class='ui-state-highlight ui-corner-all' style='margin-top: 20px; padding: 1em;'><p><span class='ui-icon ui-icon-info' style='float: left; margin-right: 3em;'></span>"_%val_"</p></div></div>"

#define appTableAttr "style=""border-radius: 10px; border: 1px solid #72a7cf"" cellpadding=2 cellspacing=0 class=""DetailTable"" bgcolor=""#c4d6d6"" width=""90%"""
#define appTable1(%n1) "<table "_$$$appTableAttr_"><tbody><tr><th>"_%n1_"</th></tr>"
#define appTableTrTd1(%n1) "<tr class=""trs"" ><td align=""center"" >"_%n1_"</td></tr>"
#define appTableEnd1 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTable2(%n1,%n2) "<table "_$$$appTableAttr_"><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th></tr>"
#define appTableTrTd2(%n1,%n2) "<tr class=""trs"" ><td align=""left"" >"_%n1_"</td><td>"_%n2_"</td></tr>"
#define appTableEnd2 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTable3(%n1,%n2,%n3) "<table "_$$$appTableAttr_"><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th><th align=""left"" width=""50px"">"_%n3_"</th></tr>"
#define appTableTrTd3(%n1,%n2,%n3) "<tr class=""trs"" ><td style=""text-align:left"" >"_%n1_"</td><td style=""text-align:left"" >"_%n2_"</td><td style=""text-align:left"" >"_%n3_"</td></tr>"
#define appTableEnd3 "</tbody></table>"_$s('$d(%DrawArray):"<script language='javascript'>$('.trs').hover(function(){ $(this).toggleClass( 'ui-widget-content' ) });</script>",1:"")

#define appTab3(%n1,%n2,%n3) "<table cellpadding=2 cellspacing=0 border=1 class=""DetailTable"" width=""90%""><tbody><tr><th align=""left"" width=""5px"">"_%n1_"</th><th align=""left"" width=""50px"">"_%n2_"</th><th align=""left"" width=""50px"">"_%n3_"</th></tr>"

#define jsstart w "<script language='javascript'>"
#define jsstop w "</script>"
#define styleurl "text-decoration:underline; color:blue; cursor:hand;"
#define blockui(%msg)  "$.blockUI( { message: '"_%msg_"' , css: { border: 'none', padding: '15px', backgroundColor: '#000', '-webkit-border-radius': '10px','-moz-border-radius': '10px', opacity: .5, color: '#fff' }} );"

#;	Localization
#define GNLangDOMAIN "AppTools"

#define GNEnsConf "^%App.Setting"
/// Global history of command
#define HISTORYGN "^%App.History"
/// Global tempory data
#define TEMPORYGN "^mtempAppData"
/// Global projects in the system
#define PROJGN "^%App.Proj"
/// Global tempory data for Journals
#define TEMPJRNL "^%App.JRNL"
/// Limiting the number of nodes in a global or query result for output
#define MAXSHOW 10000

#;;; Parameters dependent on the installation server
#define GNLang "^%AppCacheMsg"
#; Path to CSP apps "/apptools/"
#define  PATHCSP $GET(@$$$GNEnsConf@("PATHCSP")) 
#; Mail Server Settings
#define  EMAILSERVERIP $GET(@$$$GNEnsConf@("EMAILSERVERIP"))
#define  EMAILSERVERPORT $GET(@$$$GNEnsConf@("EMAILSERVERPORT"))
#; Authorization in the mail server
#define  EMAILAUTH $GET(@$$$GNEnsConf@("EMAILAUTH")) 
#define  EMAILAUTHPASS $GET(@$$$GNEnsConf@("EMAILAUTHPASS"))
#; Technical support admin address
#define  EMAILSUPPORT $G(@$$$GNEnsConf@("EMAILSUPPORT")) 
#; Path for temporary xls file before sending to mail
#define  EMAILXLSPATH $G(@$$$GNEnsConf@("EMAILXLSPATH"))
#; Path to storing project sources
#define  EXPORTPROJPATH $G(@$$$GNEnsConf@("EXPORTPROJPATH")) 
#; List of databases to monitor free space in App..Chart.cls?panel=class(App.ChartPanel).ChartDbSize
#define DBCACHESizeMon $G(@$$$GNEnsConf@("DBCACHESizeMon"))


#; --------------- Application section
#define GNmessages "^%App.cconsolelog"
#define DubledQuote(%s)	$replace(%s,"'","''")


#If $DATA(^%App.Proj("INFOBANKS"))
#define  TESTSERVER "-test"
#define DEVELOPER "mihaylenko_sv"
#; The module display links to the administrative application panel
#define  DRAWAllApp ##class(App.MVK.docbook).GetAllApp(0)
#define SDNum if $g(SDNum)'="" write:##class(App.sys).ClassExist("App.MVK.docbook") "<br>"_##class(App.MVK.docbook).FindSDRef(SDNum)
#define aText(%en,%ru) ##Expression(##class(App.msg).AddLangMsg(%en,%ru))
#define  MultiLang 1
#define  JSLibLocal 1

#Else 
#define  TESTSERVER " "
#define DEVELOPER "admin"
#; The module display links to the administrative application panel
#define  DRAWAllApp " "
#define SDNum  
#define aText(%en,%ru) %en
#define  MultiLang 0
#define  JSLibLocal 0

#EndIf



