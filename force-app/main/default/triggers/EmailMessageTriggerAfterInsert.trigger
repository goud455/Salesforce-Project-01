trigger EmailMessageTriggerAfterInsert on EmailMessage (after insert) {
    
  system.debug('****afteremailMessageInsert');
    list<id> emailMessageIds = new list<id>();
    list<id> emailMessageIds1 = new list<id>();
    for(EmailMessage emailMessageRec: trigger.new){
        if(emailMessageRec.HasAttachment){
            system.debug('@@@attach');
           emailMessageIds.add(emailMessageRec.Id);  
        }else{
            system.debug('No Attach');
           emailMessageIds1.add(emailMessageRec.Id); 
        }
        
    }
    system.debug('***emailMessageIds'+emailMessageIds);
    system.debug('***NewemailMessageIds'+emailMessageIds1);
    if(!emailMessageIds.isEmpty()){
        system.debug('@@@withtattachement'+emailMessageIds);
       EmailMessageTriggerHandler.emailToCaseAttachments(emailMessageIds);  
    }
    if(!emailMessageIds1.isEmpty() ){
        system.debug('@@@withoutattachement'+emailMessageIds1);
      // fetchSentiments.getCaseStatus(emailMessageIds1);  
    }
   
}