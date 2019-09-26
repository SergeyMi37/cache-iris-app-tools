/// Пример Параметров
Class App.Parameter Extends %Persistent
{

/// Порядок свойств при выводе в форме
Parameter AppORDERPROPERTY = "Name,Description,Value,Types,Namespace,DateStart,DateFinish,File,isEnabled,isEnabledCheck,OfficeFile";

/// Namespace $zu(5) применения параметра
Property Namespace As %String(MAXLEN = "") [ InitialExpression = {$zu(5)} ];

/// Имя параметра
Property Name As %String(MAXLEN = "") [ Required ];

/// Значение параметра по умолчанию
Property Value As %String(MAXLEN = "");

/// Описание параметра
/// {"displayname":"Описание параметра","title":"Описание параметра","inputpattern":"textarea"}
Property Description As %String(MAXLEN = "");

/// ​​Дата выборки протокола с
/// {"displayname":"Дата выборки протокола с","title":"введите дату","inputtype":"date"}
Property DateStart As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-01-01"} ];

/// ​​Дата выборки протокола по
/// {"displayname":"Дата выборки протокола по","title":"введите дату и время","inputtype":"datetime-local"}
Property DateFinish As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-12-31"} ];

/// ​Тип Boolean в виде checkbox
/// {"displayname":"Включен","inputtype":"checkbox"}
Property isEnabledCheck As %Boolean [ InitialExpression = 1 ];

/// ​Тип Boolean в виде списка
/// {"displayname":"Включен","title":"введите (1 или 0)"}
Property isEnabled As %Boolean [ InitialExpression = 0 ];

/// ​Выбор файла для загрузки на диск TempDir = ##class(%File).GetDirectory(##class(%File).TempFilename())
/// {"displayname":"​Выбор шаблонного файла","title":"​Выбор шаблона","inputpattern":"files","filesMethod":"##class(App.type).UploadFilesJS(%id)","attr":"accept='.xls,.xlsx'","filesStore":"TempDir"}
Property File As %String(MAXLEN = "");

/// Список типов параметра
/// {"displayname":"Типы параметра","title":"Выберите Тип"}
Property Types As %String(DISPLAYLIST = ",Проект,Параметр приложения,Системный параметр", MAXLEN = 1, VALUELIST = ",Projecr,AppOption,SysOption") [ InitialExpression = "AppOption", Required ];

/// ​Выбор файла для загрузки на диск TempDir
/// {"displayname":"​Выбор файла","title":"​Выбор файла","inputpattern":"files"}
Property OfficeFile As %String(MAXLEN = "");

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
<Value name="18">
<Value>Description</Value>
</Value>
<Value name="19">
<Value>Name</Value>
</Value>
<Value name="20">
<Value>isBiddingByOne</Value>
</Value>
<Value name="21">
<Value>FileOther</Value>
</Value>
<Value name="22">
<Value>FileOtherOriginalFileName</Value>
</Value>
<Value name="23">
<Value>contractType</Value>
</Value>
<Value name="24">
<Value>Types</Value>
</Value>
<Value name="25">
<Value>isEnabled</Value>
</Value>
<Value name="26">
<Value>File</Value>
</Value>
<Value name="27">
<Value>FileName</Value>
</Value>
<Value name="28">
<Value>ImageFile</Value>
</Value>
<Value name="29">
<Value>ImageGlobal</Value>
</Value>
<Value name="30">
<Value>isEnabledCheck</Value>
</Value>
<Value name="31">
<Value>OfficeFile</Value>
</Value>
<Value name="32">
<Value>Value</Value>
</Value>
<Value name="33">
<Value>ImageFileName</Value>
</Value>
<Value name="34">
<Value>ImageGlobalName</Value>
</Value>
<Value name="35">
<Value>CustomFile</Value>
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

