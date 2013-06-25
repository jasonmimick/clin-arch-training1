class myblog.blogpage extends %CSP.Page {

    
    classmethod renderPost(postId As %Integer) {
        set post=##class(myblog.post).%OpenId(postId)
        if ( '$isobject(post) ) {
            throw ##class(%Exception.General).%New("NoPost",,,"Unable to find post with id='"_postId_"'")
        }
        &html<
            <div class='post' id='post_#(postId)#'>
            <h3>#(post.title)#</h3>
            <p>
        >
        do post.content.OutputToDevice()
        &html<

            <br/>
            <p>#(post.owner)# #($zdt(post.lastUpdate))#</p>
            </div>
        >
    }

    classmethod renderError(e as %Exception.General) {
        &html< <div class='error'> >
        do e.OutputToDevice()
        &html< </div> >
    }

    classmethod savePost(postId As %Integer) {
        &html< save postId=#(postId)# >
    }
    classmethod OnPage() As %Status {
        do ..renderHead()
        set postId=%request.Get("postId")
        try {
            if ( %request.Method = "GET" ) {
                do ..renderPost(postId)
            }
            if ( %request.Method = "POST" ) {
                do ..savePost(postId)
            }
        } catch (e) {
                do ..renderError(e)
        }
        do ..renderFoot()
        return $$$OK
    }

    classmethod renderHead() {
        &html<
        <!DOCTYPE html>
        <head>
            <title>MyBlog</title>
            <style>
            body { font-family: arial; font-size : 16 }
            .error { font-weight: bold; font-size: 18; color: red }
            </style>
        </head>
        >
    }

    classmethod renderFoot() {
        &html<
            </html>
        >
    }
}
