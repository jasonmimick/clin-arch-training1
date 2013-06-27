/// ztoolbox - common utilities
/// net - network utilities
/// version: 1
/// jason.mimick@intersystems.com
class ztoolbox.net {

    /// Return the contents of a url as a string
    classmethod gets(url as %String,output headers) as %String {
        set s=..get(url,.headers),data=""
        while ( 's.AtEnd ) { set data=data_s.Read() }
        return data
    }
    /// Return the contents of a url as a stream
    classmethod get(url as %String,output headers) as %Stream.Object {
        set req=##class(%Net.HttpRequest).%New()
        do ##class(%Net.URLParser).Parse(url,.u)
        set req.Server = u("host")
        set:$data(u("port")) req.Port=u("port")
        //set:$zconvert(u("scheme"),"l")="https" req.
        set q=$listfromstring(u("query"),"&")
        for i=1:1:$listlength(q) {
            set r=$listfromstring($listget(q,i),"=")
            do req.SetParam($listget(r,1),$listget(r,2))
        }
        set:$data(u("username")) req.Username=u("username")
        set:$data(u("password")) req.Password=u("password")
        do req.Get(u("path"))
        merge headers=req.HttpResponse.Headers
        return req.HttpResponse.Data
    }
}

