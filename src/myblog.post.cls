class myblog.post extends (%Persistent,relax.Restable) {
    property title as %String;
    property content as %Stream.GlobalCharacter;
    property owner as %String [ InitialExpression = $USERNAME ];
    property lastUpdate as %TimeStamp;

    property comments as list of myblog.comment;

    index ByOwner on owner [ Type = bitmap ];

    method %OnNew(initvalue as %String) as %Status {
        set ..content = ##class(%Stream.GlobalCharacter).%New()
        quit $$$OK
    }

    method %OnBeforeSave(insert As %Boolean) as %Status {
        set %this.lastUpdate = $ztimestamp
        quit $$$OK
    }

    classmethod loadTestData(numberToLoad As %Integer) {
        do ##class(myblog.post).%DeleteExtent() 
        for i=1:1:numberToLoad {
            set p=##class(myblog.post).%New()
            set p.title="Some post #"_i
            for j=1:1:$random(15)+1 { 
                set lineSize=$random(80),line=""
                for k=1:1:lineSize { 
                    set randomChar = $c( $r(126-32) + 32 )
                    set line=line_randomChar
                }
                write line,!
                do p.content.WriteLine( line )
            }
            set numComments=$r(5)
            set comments=$lb( $lb("ok","Happy Guy"), $lb("sucks"," Grumpy Guy") )
            for j=1:1:numComments {
                set comment=##class(myblog.comment).%New()
                set jj=(j#2)+1
                set comment.comment="This blog is "_$lg($lg(comments,jj),1)_", I guess"
                set comment.who=$lg($lg(comments,jj),2)
                //set comment.when=$ztimestamp
                //zw comment
                set sc=p.comments.Insert(comment)
                if ( $$$ISERR(sc) ) { do $system.OBJ.DisplayError(sc) }
            }
            set sc=p.%Save()
            if ( $$$ISERR(sc) ) {
                do $system.OBJ.DisplayError(sc)
                break
            }
            write "Saved post:",p.title,!
        }
    }
}
