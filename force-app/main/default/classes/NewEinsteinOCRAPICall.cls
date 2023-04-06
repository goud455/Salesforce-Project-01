public class NewEinsteinOCRAPICall {
    public static FINAL String  OCR_API         = 'https://api.einstein.ai/v2/vision/ocr';
    public static FINAL String  OCR_MODEL       = 'OCRModel';
    public static FINAL String  OCR_MODEL_TABEL = 'tabulatev2';
  // public static final string ObjectName = 'Contact';
    public static boolean  duplicateContact = false;
    public static integer duplicateCount = 0;
    public static list<Id> newDupContactIds = new list<Id>();
    public static list<Id> dupContactIds = new list<Id>();
    public static list<Id> dupContentIds = new list<Id>();
    public static list<Id> newContentIds = new list<Id>();
    public static list<SObject> listsobjectRecords = new list<SObject>();
    public static Map<Id,String> contactStatusMap = new Map<Id,String>();
    public static Map<Id,String> sObjectMap = new Map<Id,String>();
    public static Map<String,String> emailValidationMap = new Map<String,String>();
    public static String emailValidaationResult = '';
    //@future(callout=true)
    public static Map<Id,String> einsteinAPICall(list<id> Ids, String objectName,String mode){
        system.debug('ContentdocumentIds'+Ids);
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :Ids AND IsLatest = true AND fileType IN('JPG','PNG','PDF','JPEG')];
      List<ContentDistribution> cdts=[select ContentDocumentId,DistributionPublicUrl,ContentDownloadURL from ContentDistribution where ContentDocumentId =:ids];
       system.debug('contentdistributionrec'+cdts);
       Map<String, String> contentList= new Map <String, String>();  
        if(!cdts.isEmpty())  {
              for(ContentDistribution cdt:cdts) {
            contentList.put(cdt.ContentDocumentId, cdt.ContentDownloadURL);     
                     }
        }
       
      if(!versions.isEmpty()){  // If condition Started
		for(ContentVersion attach:versions) //For Loop Started
        { 
         String ContentDocuId = attach.ContentDocumentId;
         String ContentDocuTitle = attach.Title;   
		 String imageUrl=contentList.get(attach.ContentDocumentId);
                system.debug('imageUrl'+imageUrl);
                 /*************************************/
            if(imageUrl!=null){
                String result = EinsteinAPIService.imageOCR(OCR_API, imageUrl, OCR_MODEL, false, true);
            
                  
		EinsteinOCRResponse response = (EinsteinOCRResponse)System.JSON.deserialize(result, EinsteinOCRResponse.class);
       // EinsteinOCRResponse response = parseResponse(result);
       
        SObject sobjectRecord = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        for(EinsteinOCRResponse.Probabilities prob : response.probabilities){
            switch on prob.attributes.tag {
                when 'PERSON' {
                    sobjectRecord.put('LastName',prob.label);
                }
                when 'PHONE' {
                    sobjectRecord.put('Phone',prob.label);
                }
                when 'MOBILE_PHONE'{
                    sobjectRecord.put('MobilePhone',prob.label);
                }
                when 'EMAIL'{
                    sobjectRecord.put('EMAIL',prob.label);
                   if(mode=='Interface'){
                      // String emailValidityStatus='N/A';
                      String emailValidityStatus = emailVerifyApiClass.emailApiAuthenticate(prob.label);
                       emailValidationMap.put(prob.label,emailValidityStatus);  
                    } 
                    
                }
                when 'WEBSITE' {
                    if(objectName.equals('Lead')){
                        sobjectRecord.put('Website',prob.label);
                    }
                }
                when 'ADDRESS' {
                    if(objectName.equals('Contact')){
                        sobjectRecord.put('MailingStreet',prob.label);
                    }else{
                        sobjectRecord.put('Street',prob.label);
                    }
                }
                when 'ORG' {
                    if(objectName.equals('Lead')){
                        sobjectRecord.put('Company',prob.label);
                    }
                }
            }
        }
            
          /************Link contact to Case Start************/
           list<Id> linkedEntityIds = new List<Id>(); 
                       for(ContentDocumentLink cdl :  [SELECT LinkedEntityId,contentdocumentid  FROM ContentDocumentLink where contentdocumentid=:ContentDocuId]){
                                  linkedEntityIds.add(cdl.LinkedEntityId);
                          }
                
                    system.debug('@@'+linkedEntityIds);
                 if(!linkedEntityIds.isEmpty()){
                    list<emailMessage> emsList = [select id,parentid from emailMessage where id in :linkedEntityIds];
                     if(!emsList.isEmpty()){  
                            sobjectRecord.put('Case__c',emsList[0].parentId);
                       }
                   
                 }
          /************Link Contact to Case End*******/
            
           list<sObject> dupcontactRecs = new list<sObject>();
            
       if(sobjectRecord.get('LastName')!= null) {  
           if(objectName == 'Contact'){
               dupcontactRecs = [select id,name,email from Contact where name = :String.valueOf(sobjectRecord.get('LastName')) and email=:String.valueOf(sobjectRecord.get('EMAIL'))];
               system.debug('DupContactrecord'+dupcontactRecs);
           }
           else{
               dupcontactRecs = [select id,name,email from Lead where name = :String.valueOf(sobjectRecord.get('LastName')) and email=:String.valueOf(sobjectRecord.get('EMAIL'))];
               system.debug('Dupleadrecord'+dupcontactRecs);
           }
            
           if(!dupcontactRecs.isEmpty()){ 
                         dupContentIds.add(ContentDocuId);
                         dupContactIds.add(dupcontactRecs[0].Id); 
                          contactStatusMap.put(dupcontactRecs[0].Id,'Duplicate');
                           system.debug('@@@******Dup'+contactStatusMap);
                        duplicateCount = duplicateCount + 1;
                        system.debug('duplicateCount'+duplicateCount);
                        system.debug('@@@@dupsize'+dupcontactRecs.size());
                        system.debug('@@@deletingContentDocuId'+ContentDocuId);

           }
            system.debug('dupcontactRecs'+dupcontactRecs);
       }
      
        system.debug('sobjectRecord'+sobjectRecord);
            system.debug('sobjectlastname'+sobjectRecord.get('LastName'));
            system.debug('sobjectemail'+sobjectRecord.get('EMAIL'));
          if(sobjectRecord.get('LastName')!= null & dupcontactRecs.isEmpty()){
                newContentIds.add(ContentDocuId);
                system.debug('Add to List');
                listsobjectRecords.add(sobjectRecord); 
            }   
            }//If Condition for imageurl check end
		} //For Loop Ended
      }    // If condition Ended
				
				
		/*******End of For loop */	
         	
        if(!listsobjectRecords.isEmpty()){
            system.debug('listhasRecords');
		Database.insert(listsobjectRecords);
        }
             if(!newContentIds.isEmpty() && !listsobjectRecords.isEmpty() && (mode=='Email-To-Case' || mode=='Manual Case')){
                 system.debug('@@@@Email oneeee'+mode);
                 Id contentDocId = newContentIds[0];
                   list<Id> linkedEntityIds = new List<Id>(); 
                       for(ContentDocumentLink cdl :  [SELECT LinkedEntityId,contentdocumentid  FROM ContentDocumentLink where contentdocumentid=:contentDocId]){
                                  linkedEntityIds.add(cdl.LinkedEntityId);
                          }
                
                    system.debug('Casee@@'+linkedEntityIds);
                 string x = '';
                 if(!linkedEntityIds.isEmpty()){
                    list<emailMessage> emsList = [select id,parentid from emailMessage where id in :linkedEntityIds];
                     system.debug('@@@Case:emailMessage'+emsList);
                     if(!emsList.isEmpty()){  
                          system.debug('@@@caseId'+emsList[0].parentId);
                          Case caseRec = [select id, ContactId from Case where id = :emsList[0].parentId Limit 1];
                            system.debug('@@@caseRec Email-To-Case'+caseRec);
                            if(caseRec.Id != NULL)    {
                                caseRec.ContactId = listsobjectRecords[0].Id;
                                Database.update(caseRec);
                                return sObjectMap;
                                 }
                     }else{
                         system.debug('I think Manual case');
                         Case caseRec = [select id, ContactId from Case where id in :linkedEntityIds Limit 1];
                         system.debug('@@@caseRec Manual case'+caseRec);
                            if(caseRec.Id != NULL)    {
                                system.debug('Case is updating with contact Id'+listsobjectRecords[0].Id);
                                caseRec.ContactId = listsobjectRecords[0].Id;
                                Database.update(caseRec);
                                contact con = [select id,Case__c from contact where id = :listsobjectRecords[0].Id];
                                con.Case__c=caseRec.Id;
                                Database.update(con);
                                return sObjectMap;
                                 }
                         
                     }
                   
                 }
              } 
            
          
        
        
        
        system.debug('afterinsertcontactcards'+listsobjectRecords);
       if(!listsobjectRecords.isEmpty()){  
            for(sObject contactRec: listsobjectRecords){
                system.debug('afterinsertrecordIDDDDD'+contactRec.Id);
                contactStatusMap.put(contactRec.Id,'New');
                system.debug('@@@******New'+contactStatusMap);
                newDupContactIds.add(contactRec.Id);
            }
       }
        if(duplicateCount>0){
            newDupContactIds.addAll(dupContactIds);
            system.debug('dupContentIds'+dupContentIds);
            delete [SELECT Id FROM ContentDocument WHERE Id=:dupContentIds];
        }
        if(objectName.equals('Contact') && !contactStatusMap.keyset().isEmpty()){
                for(Contact conRec:[SELECT  Id, Name, Phone, Email FROM Contact WHERE id in :contactStatusMap.keyset()]){
                    String concatString = contactStatusMap.get(conRec.Id)+' '+emailValidationMap.get(conRec.Email);
                    sObjectMap.put(conRec.Id,concatString);
                }
        }else if(!contactStatusMap.keyset().isEmpty()){
               for(Lead leadRec:[SELECT  Id, Name, Phone, Email FROM Lead WHERE id in :contactStatusMap.keyset()]){
                  String concatString = contactStatusMap.get(leadRec.Id)+' '+emailValidationMap.get(leadRec.Email);
                  sObjectMap.put(leadRec.Id,concatString);
                } 
        }
        
        system.debug('newDupContactIds'+newDupContactIds);
        system.debug('sObjectMap@@@******'+sObjectMap);
        return sObjectMap;
    }

}