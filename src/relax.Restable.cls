/// Allow persistent classes
/// to get managed over a REST-style
/// interface.
class relax.Restable extends (%CSP.Page) {

    Parameter CONTENTTYPE = "application/json";

    classmethod OnPreHTTP() as %Boolean {
        quit 1
    }

    classmethod OnPage() as %Status {
        set sc=$classmethod($classname(),%request.Method)
        if ( $$$ISERR(sc) ) {
            write $system.Status.GetErrorText(sc)
        }
        return $$$OK
    }

    classmethod GET() as %Status {
        set id=$order(%request.Data(""))
        set obj=$classmethod($classname(),"%OpenId",id)
        do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(obj)
        return $$$OK
    }


    classmethod POST() as %Status {
	    set source=%request.Content
        set data=""
	    set source.LineTerminator=$C(10)
	    while ( 'source.AtEnd ) {
		    set line=source.ReadLine()
            set data=data_line   
        }

        set sc=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(data,$classname(),.object)
        return:$$$ISERR(sc) sc
        set sc=object.%Save()
        return:$$$ISERR(sc) sc
        // Return a small json string with the new object's id
        write "{ ""id"":"_object.%Id()_"}"
        return $$$OK
    }

    classmethod PUT() as %Status {
        return ..POST()
    }


    classmethod DELETE() as %Status {
        set id=$order(%request.Data(""))
        set object=$classmethod($classname(1),"%OpenId",id)
        if ( $isobject(object) ) {
            set sc=object.%Delete()
            return sc
        }
        return $$$ERROR("Can't find "_$classname(1)_" with id="_id)
    }
}
