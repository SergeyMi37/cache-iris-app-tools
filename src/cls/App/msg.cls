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

}

