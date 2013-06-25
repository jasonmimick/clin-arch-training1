class myblog.blog extends %Persistent {

    property title as %String;
    property blog as %String;

    property owner as %String;

    property lastUpdate as %TimeStamp;

    //property comments as list of myblog.comment;
}
