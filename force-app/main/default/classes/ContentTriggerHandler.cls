public class ContentTriggerHandler {
    public static void createPublicLinkForFile(List<ContentVersion> contentVersions){
   
        system.debug('@@@contentVersions'+contentVersions);
        system.debug('@@@ContentVersionTrigger Handler called');
        ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
      /* Set<Id> contentDocId = new Set<Id>();
        for(ContentVersion objContentVersion : contentVersions){
            contentDocId.add(objContentVersion.ContentDocumentId);
        } */
          list<Id> contentDocIds = new list<Id>();
        for(ContentVersion objContentVersion : contentVersions){
            contentDocIds.add(objContentVersion.ContentDocumentId);
        } 
       for(ContentVersion objContentVersion : contentVersions){
           distributionsToInsert.add(createContentDistribution(objContentVersion.Id));
        } 
         
        system.debug('@@@distributionsToInsert'+distributionsToInsert);
        insert distributionsToInsert;
        system.debug('distributionsToInsert'+distributionsToInsert);
     //   EinsteinOCRAPICall.einsteinAPICall(contentDocId);
        ContentTriggerHelper.getContentDocIds(contentDocIds);
    }
    
    public static ContentDistribution createContentDistribution(Id contentVersionId){
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        return newDist;
    }
}