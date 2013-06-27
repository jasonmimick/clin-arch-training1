class wikipedia.page extends (%Persistent,relax.Restable) {
    property title As %String(MAXLEN = 4000 );
    property pageid As %String;
    property extract As %Stream.GlobalCharacter;

    
    /// Crawl wikipedia on a given title,
    /// getting all related pages
    classmethod crawl(title) {
        set page=..load(title)
        write page.title,!
        set ^||visited(page.title)=1
        do ..links(title,.links)
        set link=$order(links(""))
        while ( link'="" ) {
            if ( '$data(^||visited(link))) {
                do ..crawl(link)
            }
            set link=$order(links(link))
        }
    }

    /// given a title - find what links it has 
    /// on wikipedia
    classmethod links(title,output links) {
        set url="http://en.wikipedia.org/w/api.php?action=query&prop=links&titles=%%TITLE%%&format=json"
        set url=$replace(url,"%%TITLE%%",title)
        set json=##class(ztoolbox.net).gets(url)
        set sc=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(json,,.object)
        do object.query.pages.%CopyToArray(.a)
        set id=$order(a(""))
        set pageInfo=$property(object.query.pages,id)
        return:'$isobject(pageInfo.links)
        for i=1:1:pageInfo.links.Count() {
            set link=pageInfo.links.GetAt(i)
            set links(link.title)=""
        }
    }
    /// Fetch a title and return a page object 
    classmethod load(title) {
        /*
        if ( $listvalid(titles) ) {
            for i=1:1:$listlength(titles) {
                do ..load($listget(titles,i))
            }
            return
        }
        */
        set url="http://en.wikipedia.org/w/api.php?action=query&prop=extracts&titles=%%TITLE%%&format=json"
        set url=$replace(url,"%%TITLE%%",title)
        //write url,!
        set json=##class(ztoolbox.net).gets(url)
        set sc=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(json,,.object)
        set q=object.query.pages.page
        do object.query.pages.%CopyToArray(.a)
        set id=$order(a(""))
        set pageInfo=$property(object.query.pages,id)
        set page=##class(wikipedia.page).%New()
        set page.title=pageInfo.title
        set page.extract = ##class(%Stream.GlobalCharacter).%New() 
        do page.extract.Write(pageInfo.extract)
        set page.pageid= pageInfo.pageid
        $$$TOE(sc,page.%Save())
        return page
    }
}
