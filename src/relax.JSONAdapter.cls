class relax.JSONAdapter {

    classmethod isSubclassOf(parent,child) as %Boolean {
        return:parent=child 1
        set rs=##class(%Library.ResultSet).%New("%Dictionary.ClassDefinitionQuery:SubclassOf")
        do rs.Execute(parent)
        while ( rs.Next() ) {
            if ( rs.Get("Name")=child ) {
                return 1
            }
        }
        return 0
    }

    method toJSON() As %String [ CodeMode = objectgenerator, ProcedureBlock = 1 ] {
        do %code.WriteLine(" set json=""{""")
        for i=1:1:%class.Properties.Count() {
            set p=%class.Properties.GetAt(i)
            do %code.WriteLine(" set value=$property($this,"""_p.Name_""")")
            if ( ""=p.Collection ) {
                //do %code.WriteLine(" if ( $isobject(value) ) {")
                // we know about the properties type at compile time -
                //do %code.WriteLine(" "_p.Type) 
                if ( ($length(p.Type,".")=1) && ($extract(p.Type,1)="%") ) {
                    set ptype="%Library."_$e(p.Type,2,*)
                } else {
                    set ptype=p.Type
                }
                //do %code.WriteLine(" "_ptype)
                set typeDef=##class(%Dictionary.ClassDefinition).%OpenId(ptype)
                //do %code.WriteLine(" "_typeDef.Name_" "_typeDef.Super)
                /**/
                if ( ..isSubclassOf("relax.JSONAdapter",typeDef.Name) ) {
                    do %code.WriteLine("  set value=value.toJSON()")
                }
                if ( ..isSubclassOf("%Stream.Object",typeDef.Name) ) {
                    do %code.WriteLine("  set temp=""""")
                    do %code.WriteLine("  while ( 'value.AtEnd ) {")
                    do %code.WriteLine("     set temp=temp_##class(%CSP.Page).QuoteJS(value.ReadLine())")
                    do %code.WriteLine("  }")
                    do %code.WriteLine(" set value=temp")
                }
                if ( ..isSubclassOf("%Library.TimeStamp",typeDef.Name) ) {
                    do %code.WriteLine(" set value=$zdt(value,-2)")
                }
                /**/
                //do %code.WriteLine(" }")
                do %code.WriteLine(" set value=##class(%CSP.Page).QuoteJS(value)")
                do %code.WriteLine(" set name=##class(%CSP.Page).QuoteJS("""_p.Name_""")")
                do %code.WriteLine(" set json=json_name_"":""_value")
                //do %code.WriteLine(" set json=json_"""""""_p.Name_""""":""""""_value_"""""""")
            } else {        // got a collection
                if ( p.Collection="list" ) {
                    //
                    do %code.WriteLine(" // list -- todo")
                    set var="i"_$r(100)

                    do %code.WriteLine(" set name=##class(%CSP.Page).QuoteJS("""_p.Name_""")")
                    do %code.WriteLine(" set json=json_name_"":"" ")
                    do %code.WriteLine(" set json=json_""[""")
                    do %code.WriteLine(" for "_var_"=1:1:value.Count() {")
                    do %code.WriteLine("  set lv=value.GetAt("_var_")")
                    do %code.WriteLine("  //set jlv=..coaxValue(lv)")
                    do %code.WriteLine("  set jlv=lv.toJSON()")
                    do %code.WriteLine("  set json=json_jlv")
                    do %code.WriteLine("  set:"_var_"<value.Count() json=json_"", """)
                    do %code.WriteLine(" }")
                    do %code.WriteLine(" set json=json_""]""")
                }
                elseif ( p.Collection="array" ) {
                } else {
                    // TO-DO throw an error here
                    do %code.WriteLine(" // Unsupported collection!"_p.Name_" "_p.Collection)
                }
            }
            if ( i<%class.Properties.Count() ) {
                do %code.WriteLine(" set json=json_"", """)
            }
        }
        do %code.WriteLine(" set json=json_""}""")
        do %code.WriteLine(" return json") 
    }

    method fromJSON(json as %String) {
    }
}
