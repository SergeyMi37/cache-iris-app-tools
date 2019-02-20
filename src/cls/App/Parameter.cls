/// Параметры для панели администратора
Class App.Parameter Extends (%Persistent, App.Form)
{

/// Порядок свойств при выводе в форме
Parameter AppORDERPROPERTY = "Namespace,ServerName,PATHCSPUI,TESTSERVER,EMAILSERVERIP,EMAILSERVERPORT,EMAILAUTH,EMAILAUTHPASS,EMAILSUPPORT,EMAILXLSPATH,DateStart,DateFinish";

/// Namespace $zu(5)
Property Namespace As %String(MAXLEN = "");

/// ServerName $zu(110) 
Property ServerName As %String(MAXLEN = "");

/// Путь к приложению jQuery-UI 
Property PATHCSPUI As %String(MAXLEN = "") [ InitialExpression = "/csp/log/jqueryui/" ];

/// Имя тестового сервера (Для Админок проектов)
Property TESTSERVER As %String(MAXLEN = "");

/// Настройки почтового сервера IP (Для Админок проектов)
Property EMAILSERVERIP As %String(MAXLEN = "");

/// Порт почтового сервера (Для Админок проектов)
Property EMAILSERVERPORT As %String(MAXLEN = "") [ InitialExpression = 25 ];

/// Авторизация в почтовом сервера User (Для Админок проектов)
Property EMAILAUTH As %String(MAXLEN = "");

/// Авторизация в почтовом сервера Password (Для Админок проектов)
Property EMAILAUTHPASS As %String(MAXLEN = "");

/// Адрес админа техподдержки (Для Админок проектов)
Property EMAILSUPPORT As %String(MAXLEN = "");

/// Путь для временного XLS файла перед посылкой на почту  (Для Админок проектов)
Property EMAILXLSPATH As %String(MAXLEN = "") [ InitialExpression = "/backup/temp/integ/" ];

/// ​​Дата выборки протокола с
/// {"displayname":"Дата выборки протокола с","title":"введите дату","inputtype":"date"}
Property DateStart As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-01-01"} ];

/// ​​Дата выборки протокола по
/// {"displayname":"Дата выборки протокола по","title":"введите дату","inputtype":"date"}
Property DateFinish As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-12-31"} ];

Storage Default
{
<Data name="ParameterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>dob</Value>
</Value>
<Value name="4">
<Value>ts</Value>
</Value>
<Value name="5">
<Value>num</Value>
</Value>
<Value name="6">
<Value>Namespace</Value>
</Value>
<Value name="7">
<Value>TESTSERVER</Value>
</Value>
<Value name="8">
<Value>EMAILSERVERIP</Value>
</Value>
<Value name="9">
<Value>EMAILSERVERPORT</Value>
</Value>
<Value name="10">
<Value>EMAILAUTH</Value>
</Value>
<Value name="11">
<Value>EMAILAUTHPASS</Value>
</Value>
<Value name="12">
<Value>EMAILSUPPORT</Value>
</Value>
<Value name="13">
<Value>EMAILXLSPATH</Value>
</Value>
<Value name="14">
<Value>PATHCSPUI</Value>
</Value>
<Value name="15">
<Value>ServerName</Value>
</Value>
<Value name="16">
<Value>DateStart</Value>
</Value>
<Value name="17">
<Value>DateFinish</Value>
</Value>
</Data>
<DataLocation>^%App.ParameterD</DataLocation>
<DefaultData>ParameterDefaultData</DefaultData>
<IdLocation>^%App.ParameterD</IdLocation>
<IndexLocation>^%App.ParameterI</IndexLocation>
<StreamLocation>^%App.ParameterS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

