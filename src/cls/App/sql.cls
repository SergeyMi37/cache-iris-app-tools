Include App.LogMacro

/// Query and SQL statements
Class App.sql [ Abstract ]
{

/// s sql=##class(App.sql).getSQL("App.sql:TestXData",0,.desc) w !,sql,!!,desc
/// s sql=##class(App.sql).getSQL("TestQuery",0,.desc) w !,sql,!!,desc
ClassMethod getSQL(name As %String, removeNL = {$$$NO}, ByRef Description) As %String
{
	#dim sc As %Status = $$$OK
	
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set Description=""
		
	if ##class(%Dictionary.QueryDefinition).IDKEYExists(class, queryName) {
		set query = ##class(%Dictionary.QueryDefinition).IDKEYOpen(class, queryName,,.sc)
		throw:$$$ISERR(sc) ##class(%Exception.StatusException).CreateFromStatus(sc)
		set sql = query.SqlQuery
		set Description=query.Description
	} elseif ##class(%Dictionary.XDataDefinition).IDKEYExists(class, queryName) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata,i))
		}
		set sql = stream.Read($$$MaxLocalLength)
		set Description=$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdescription)
		
	} else {
		throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, $$$FormatText($$$aText("Class %1 does not have a Query or XData element named %2",""), class, queryName)))
	}
	
	set:(removeNL = $$$YES) sql = $replace(sql, $$$NL, " ")
	return sql_" -- Today "_$zd($h,3)_" "_$g(ssm)
}

/// test query
/// stored in query
Query TestQuery() As %Query
{
SELECT top 10 * from
  App.Log
}

/// test query
/// stored in xdata
XData TestXData [ MimeType = application/yaml ]
{
SELECT
  c.contractNumber,
  TO_DATE(d."date", 'YYYY-MM-DD'),
  d.year,
  d.month,
  d.amount,
FROM mvk_model_payment.PayDoc d
  JOIN mvk_model_payment.PayDocSession s ON s.ID = d.session
  JOIN mvk_model_contract.Contract c ON d.contract = c.ID
WHERE s.ID = ?
ORDER BY c.contractNumber
}

ClassMethod getViewOrQuerySQL(viewOrQueryName As %String, Output sql As %String) As %Status
{
	#dim sc As %Status = $$$OK
	set sql = ""
	
	if (viewOrQueryName [ ".")
	{
		set sql = "select * from " _ viewOrQueryName _ " where 1=1 "
	}
	else
	{
		try
		{
			set sql = ..getSQL(viewOrQueryName)
		}
		catch ex
		{
			set sql = ""
			set sc = $$$ADDSC($$$ERROR($$$GeneralError, "Error " _ viewOrQueryName), ex.AsStatus())
		}
	}
	
	quit sc
}

}

