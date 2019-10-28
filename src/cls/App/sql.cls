/// Query and SQL statements
Class App.sql [ Abstract ]
{

/// s sql=##class(App.sql).getSQL("mvk.ext.SQLext:ContObjHouseLsErrors",1,.desc)
ClassMethod getSQL(name As %String, removeNL = {$$$NO}, ByRef Description) As %String
{
	#dim sc As %Status = $$$OK
	
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set query = ##class(%Dictionary.QueryDefinition).IDKEYOpen(class, queryName,,.sc)
	throw:$$$ISERR(sc) ##class(%Exception.StatusException).CreateFromStatus(sc)
	;zw query
	set sql = query.SqlQuery
	s Description=query.Description
	set:(removeNL = $$$YES) sql = $replace(sql, $$$NL, " ")
	return sql_" -- Today "_$zd($h,3)_" "_$g(ssm)
}

}

