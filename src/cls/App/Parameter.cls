/// Example Parameters
Class App.Parameter Extends %Persistent
{

/// The order of the properties in the output in the form
Parameter AppORDERPROPERTY = "Name,Description,Value,Types,Namespace,DateStart,DateFinish,File,isEnabled,isEnabledCheck,OfficeFile";

/// Namespace $zu(5) use parameter
Property Namespace As %String(MAXLEN = "") [ InitialExpression = {$zu(5)} ];

/// The name of the parameter
Property Name As %String(MAXLEN = "") [ Required ];

/// Parameter value default
Property Value As %String(MAXLEN = "");

/// The description of the parameter
/// {"displayname":"Description of option","title":"parameter Description","inputpattern":"textarea"}
Property Description As %String(MAXLEN = "");

/// Date of sampling Protocol
/// {"displayname":"date of sampling Protocol","title":"enter date","inputtype":"date"}
Property DateStart As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-01-01"} ];

/// Date of sampling Protocol on
/// {"displayname":"date of sampling Protocol","title":"enter the date and time","inputtype":"datetime-local"}
Property DateFinish As %String(MAXLEN = "") [ InitialExpression = {##class(App.type).GetYear($h)_"-12-31"} ];

/// Type Boolean in a checkbox
/// {"displayname":"Enabled","inputtype":"checkbox"}
Property isEnabledCheck As %Boolean [ InitialExpression = 1 ];

/// Type Boolean in a list
/// {"displayname":"Included","title":"enter (1 or 0)"}
Property isEnabled As %Boolean [ InitialExpression = 0 ];

/// Select the file to upload to drive TempDir = ##class(%File).GetDirectory(##class(%File).TempFilename())
/// {"displayname":"Select template file","title":"the Choice sablona","inputpattern":"files","filesMethod":"##class(App.type).UploadFilesJS(%id)","attr":"accept='.xls,.xlsx'","filesStore":"TempDir"}
Property File As %String(MAXLEN = "");

/// The list of parameter types
/// {"displayname":"parameter Types","title":"Select a Type"}
Property Types As %String(DISPLAYLIST = ",Project,Application Parameter,System Parameter", MAXLEN = 1, VALUELIST = ",Projecr,AppOption,SysOption") [ InitialExpression = "AppOption", Required ];

/// Select the file to download to disk TempDir
/// {"displayname":"Select file","title":"Select file","inputpattern":"files"}
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
<Type>%Storage.Persistent</Type>
}

}

