class myblog.comment extends (%SerialObject,relax.JSONAdapter) {

    property comment as %Library.String;
    property when as %Library.TimeStamp;
    property who as %Library.String;
}
