/// Allow persistent classes
/// to get managed over a REST-style
/// interface.
class relax.Restable extends (%CSP.Page,relax.JSONAdapter) {

    Parameter CONTENTTYPE = "application/json";

    classmethod OnPreHTTP() as %Boolean {
        quit 1
    }

    classmethod OnPage() as %Status {
        return $classmethod($classname(),%request.Method)
    }

    classmethod GET() as %Status {
        set id=$order(%request.Data(""))
        set obj=$classmethod($classname(),"%OpenId",id)
        zw obj
        return $$$OK
    }


    classmethod POST() as %Status {
    }

    classmethod PUT() as %Status {
    }

    classmethod DELETE() as %Status {
    }
}
