public class EmailMessageTriggerHandler {
    @future(callout=true)
    public static void emailToCaseAttachments(List<Id> emailMessIds){
                 String objectName = 'Contact';
                 system.debug('EmailmessageTrigerrrrrrr');
			
				List<Id> contentDocumentids = new List<Id>();
	
				 List<ContentDocumentLink> links= [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN :emailMessIds];
				 system.debug('*******links'+links);
				  if(!links.isEmpty()){
				       for(ContentDocumentLink link:links)
						{
							contentDocumentids.add(link.ContentDocumentId);
						}
						  system.debug('@@@caseContentDocumentId'+ContentDocumentIds);
                      if(!contentDocumentids.isEmpty()){
                          NewEinsteinOCRAPICall.einsteinAPICall(contentDocumentids,objectName,'Email-To-Case'); 
                      }
						  
				  }	 
			 
    }
}