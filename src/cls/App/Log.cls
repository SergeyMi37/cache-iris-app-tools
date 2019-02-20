/// Updated at 12/08/2017 16:09:03
Class App.Log Extends %Persistent
{

/// Replacement for missing values
Parameter Null = "Null";

/// Type of event
Property EventType As %String(MAXLEN = 10, VALUELIST = ",NONE,FATAL,ERROR,WARN,INFO,STAT,DEBUG,RAW") [ InitialExpression = "INFO" ];

/// Name of class, where event happened
Property ClassName As %String(MAXLEN = "");

/// Name of method, where event happened
Property MethodName As %String(MAXLEN = "");

/// Line of int code
Property Source As %String(MAXLEN = "");

/// Cache user
Property UserName As %String(MAXLEN = 128) [ InitialExpression = {$username} ];

/// Arguments' values passed to method
Property Arguments As %String(MAXLEN = "", TRUNCATE = 1);

/// Date and time
Property TimeStamp As %TimeStamp [ InitialExpression = {$zdt($h, 3, 1)} ];

/// Identifies the job from which this event was logged.
Property Job As %String [ InitialExpression = {$job} ];

/// User message
Property Message As %String(MAXLEN = "", TRUNCATE = 1);

/// User IP address
Property ClientIPAddress As %String(MAXLEN = 32) [ InitialExpression = {..GetClientAddress()} ];

Index idxEventType On EventType [ Type = bitmap ];

Index idxUserName On UserName [ Type = bitmap ];

Index idxClassName On ClassName [ Type = bitmap ];

Index idxTimeStamp On TimeStamp [ Type = bitslice ];

Index idxClientIPAddress On ClientIPAddress;

/// Determine user IP address
ClassMethod GetClientAddress()
{
	// %CSP.Session source is preferable
	#dim %request As %CSP.Request
	If ($d(%request)) {
		Return %request.CgiEnvs("REMOTE_ADDR")
	}
	Return $system.Process.ClientIPAddress()
}

/// Add new log event
/// Use via $$$LogEventTYPE().
/// Return ID log
ClassMethod AddRecord(ClassName As %String = "", MethodName As %String = "", Source As %String = "", EventType As %String = "", Arguments As %String = "", Message As %String = "")
{
	try {
		Set record = ..%New()
		Set record.Arguments = Arguments
		Set record.ClassName = ClassName
		Set record.EventType = EventType
		Set record.Message = Message
		Set record.MethodName = MethodName
		Set record.Source = Source
		set sc=record.%Save()
		set:sc id=record.%Id()
	} catch err {
		set id=""
	}
	
	quit $g(id)
}

/// Entry point to get method arguments string 
ClassMethod GetMethodArguments(ClassName As %String, MethodName As %String) As %String
{
	Set list = ..GetMethodArgumentsList(ClassName,MethodName)
	Set string = ..ArgumentsListToString(list)
	Return string
}

/// Get a list of method arguments
ClassMethod GetMethodArgumentsList(ClassName As %String, MethodName As %String) As %List
{
	Set result = ""
	Set def = ##class(%Dictionary.CompiledMethod).%OpenId(ClassName _ "||" _ MethodName)
	If ($IsObject(def)) {
		Set result = def.FormalSpecParsed
	}
	Return result
}

/// Convert list of method arguments to string
ClassMethod ArgumentsListToString(List As %List) As %String
{
	Set result = ""
	For i=1:1:$ll(List) {
		Set result = result _ $$$quote($s(i>1=0:"",1:"; ") _ $lg($lg(List,i))_"=") 
		_ ..GetArgumentValue($lg($lg(List,i)),$lg($lg(List,i),2))
		_$S(i=$ll(List)=0:"",1:$$$quote(";"))
	}
	Return result
}

ClassMethod GetArgumentValue(Name As %String, ClassName As %Dictionary.CacheClassname) As %String
{
	If $ClassMethod(ClassName, "%Extends", "%RegisteredObject") {
		// it's an object
		Return "_##class(App.Log).SerializeObject("_Name _ ")_"
	} Else {
		// it's a datatype
		Return "_$g(" _ Name _ ","_$$$quote(..#Null)_")_"
	}
}

/// Сериализация объекта в json
/// obj - объект
/// gn - глобальная ссылка для сохранения потока
/// mode - режима сохранения объекта см: /csp/log/App.LogInfo.cls?WHAT=?
/// w ##class(App.Log).SerializeObject(obj,"^gn","sveta")
ClassMethod SerializeObject(Object, gn = "", mode = "") As %String
{
	Return:'$IsObject(Object) Object
	if $ClassMethod(Object.%ClassName(1), "%Extends", "%Stream.Object") {
		d Object.Rewind() while '(Object.AtEnd) { 
			set:gn'="" @gn@($i(inc))=$zconvert(Object.Read(32000),"I","UTF8")
		}
		Return Object.%ClassName(1)_" %Extends %Stream.Object"
	} 
	Return ..WriteJSONFromObject(Object)
}

/// w ##class(App.Log).WriteJSONFromObject(b)
ClassMethod WriteJSONFromObject(Object) As %String [ ProcedureBlock = 0 ]
{
    // Create a string that we will redirect to
    Set zsStr = ""

    Use $io::("^"_$ZNAME)

    // Enable redirection
    Do ##class(%Device).ReDirectIO(1)
 
    // Any write statements here will be redirected to the labels defined below
    Do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(Object)
 
    // Disable redirection
    Do ##class(%Device).ReDirectIO(0)
    
    Return zsStr
 
    // Labels that allow for IO redirection
    // Read Character - we don't care about reading
rchr(c)      Quit
    // Read a string - we don't care about reading
rstr(sz,to)  Quit
    // Write a character - call the output label
wchr(s)      Do output($char(s))  Quit
    // Write a form feed - call the output label
wff()        Do output($char(12))  Quit
    // Write a newline - call the output label
wnl()        Do output($char(13,10))  Quit
    // Write a string - call the output label
wstr(s)      Do output(s)  Quit
    // Write a tab - call the output label
wtab(s)      Do output($char(9))  Quit
    // Output label - this is where you would handle what you actually want to do.
    // in our case, we want to write to Str
output(s)    Set zsStr = zsStr_s Quit
}

/// Загрузить контекст из протокольного глобала
/// Пример: d ##class(App.Log).Load("^logMSWstack(3)")
ClassMethod Load(gn) As %Status [ ProcedureBlock = 0 ]
{
	Return:gn'["^"||('$d(@gn)) $$$OK
	set key = ""
	if gn'["varList" {
		set GN=$na(@gn@("varList"))
		For { set key=$order(@GN@(key)) quit:key=""
			continue:key["%%%$$LOG^%ETN"||(key["%AppLogId")
			if key="%zlog" {
				set keyzlog="" 
				for { set keyzlog=$order(@GN@(key,keyzlog)) 
					quit:keyzlog=""
					do LoadNode($na(@GN@(key,keyzlog)),keyzlog)
				}
			} else {
				do LoadNode($na(@GN@(key)),key)
			}
		}
	} else {
		do LoadNode(gn,$qs(gn,$ql(gn)))
	}
	Kill key,gn,GN
	Return $$$OK
LoadNode(GNkey,key)
	try {
		// Если в json есть _class
		if $Get(@GNkey)["_class"":" {
			set @key = ..DeserializeObject($Get(@GNkey),$p($p($Get(@GNkey),"_class"":",2),$c(34),2))
		}
		else {
			set @key=$Get(@GNkey)
		}
	} catch e { set LastErrorLoad=$ze}
	q
}

/// Загрузить контекст из таблицы протокола
ClassMethod LoadContext(Id) As %Status [ ProcedureBlock = 0 ]
{
	Return:'..%ExistsId(Id) $$$OK
	Set Obj = ..%OpenId(Id)
	Set Arguments = Obj.Arguments
	Set List = ..GetMethodArgumentsList(Obj.ClassName,Obj.MethodName)
	For i=1:1:$Length(Arguments,";")-1 {
		Set Argument = $Piece(Arguments,";",i)
		Set @$lg($lg(List,i)) = ..DeserializeObject($Piece(Argument,"=",2,*),$lg($lg(List,i),2))
	}
	Kill Obj,Arguments,Argument,i,Id,List
}

ClassMethod DeserializeObject(String, ClassName) As %String
{
	If $ClassMethod(ClassName, "%Extends", "%RegisteredObject") {
		// it's an object
		Set st = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(String,,.obj)
		Return:$$$ISOK(st) obj
	}
	Return String
}

Storage Default
{
<Data name="LogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventType</Value>
</Value>
<Value name="3">
<Value>ClassName</Value>
</Value>
<Value name="4">
<Value>UserName</Value>
</Value>
<Value name="5">
<Value>MethodName</Value>
</Value>
<Value name="6">
<Value>Arguments</Value>
</Value>
<Value name="7">
<Value>TimeStamp</Value>
</Value>
<Value name="8">
<Value>Message</Value>
</Value>
<Value name="9">
<Value>ClientIPAddress</Value>
</Value>
<Value name="10">
<Value>Source</Value>
</Value>
<Value name="11">
<Value>Job</Value>
</Value>
</Data>
<DataLocation>^App.LogD</DataLocation>
<DefaultData>LogDefaultData</DefaultData>
<IdLocation>^App.LogD</IdLocation>
<IndexLocation>^App.LogI</IndexLocation>
<StreamLocation>^App.LogS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

Query FindLog() As %SQLQuery(CONTAINID = 1)
{
SELECT %ID,ClassName,ClientIPAddress,EventType,Message,MethodName,Source,TimeStamp,UserName FROM Log
}

}
