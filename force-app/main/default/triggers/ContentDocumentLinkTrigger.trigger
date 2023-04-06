trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    system.debug('@@@ContentDocumentLinkTrigger called');
    for(ContentDocumentLink l:Trigger.new) {
        system.debug('@@@ContentDocumentLink'+l);
        l.Visibility='AllUsers';
    }
}