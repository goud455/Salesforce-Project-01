public class ContentTriggerHelper {
 @future(callout=true)
    public static void getContentDocIds(list<id> contentDocIds){
        system.debug('ContentTriggerHelper');
        system.debug('ContentTriggerHelper+++contentDocIds'+contentDocIds);
        
         Id contentDocId = contentDocIds[0];
                   list<Id> linkedEntityIds = new List<Id>(); 
                       for(ContentDocumentLink cdl :  [SELECT LinkedEntityId,contentdocumentid  FROM ContentDocumentLink where contentdocumentid=:contentDocId]){
                                  linkedEntityIds.add(cdl.LinkedEntityId);
                          }
                
                    system.debug('ContentTriggerHelper+++linkedEntityIdsr@@'+linkedEntityIds);
                 string x = '';
                 if(!linkedEntityIds.isEmpty()){
                    list<emailMessage> emsList = [select id,parentid from emailMessage where id in :linkedEntityIds];
                     list<Case> caseREcList = [Select id from Case where Id =:linkedEntityIds];
                     system.debug('ContentTriggerHelper+++emsList@@'+emsList);
                     if(emsList.isEmpty() && !caseREcList.isEmpty()){
                         // NewEinsteinOCRAPICall.einsteinAPICall(contentDocIds,'Contact','Manual Case');
                     }        
        
                 }
                 
    }
}