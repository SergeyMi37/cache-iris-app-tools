Include App.LogMacro

Class App.msg [ Abstract ]
{

/// Add two languages to global translation
/// Samples ##Expression(##class(App.sys).AddLangMsg(%en,%ru))
ClassMethod AddLangMsg(en, other) As %String
{
	s otherLang="ru"
	;s @$$$GNLang@($$$GNLangDOMAIN) = otherLang
	s @$$$GNLang@($$$GNLangDOMAIN,"en",$zcrc(en,7)) = en
	s:other'="" @$$$GNLang@($$$GNLangDOMAIN,otherLang,$zcrc(en,7)) = other
	q "$s("_$zcrc(en,7)_":$g("_$$$GNLang_"("""_$$$GNLangDOMAIN_""",$get("_$$$GNEnsConf_"(""Language""),$mvv(58)),"_$zcrc(en,7)_"),"""_en_"""),1:"""_other_""")"
}

/// Get description of parameters, propertis or methodes
/// write ##class(App.msg).man("App.security).LockDown")
/// do ##class(App.msg).man("App.Log",.doc) zw doc ;# get full class description 
ClassMethod man(ClassNameItem, ByRef d) As %String
{
	set cn=$p(ClassNameItem,")")
	q:cn="" ""
	set item=$p(ClassNameItem,").",2)
	do ##class(App.LogInfoPane).GetClassDef(cn,"",.d,0)
	if item="" q $g(d("ClassName",cn))
	for it="Methods","Properties","Parameters"	if $g(d(it,item,"Description"))'="" s ret=$g(d(it,item,"Description"))
	q $g(ret)
}

}

