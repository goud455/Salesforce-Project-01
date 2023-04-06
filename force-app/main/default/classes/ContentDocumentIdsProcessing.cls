public class ContentDocumentIdsProcessing {

    @AuraEnabled
      public static list<Sobjectwrap> invokeContentDocumentIds(list<Id> ContentDocumentIds,String objectName){
          Map<Id,String> contactStatusMap = new Map<Id,String>();
          list<Id> dupContactIds = new list<Id>();
          list<Sobjectwrap> listSobjectwrap = new list<Sobjectwrap>();
       //   list<Leadwrap> listLeadwrap = new list<Leadwrap>();
        system.debug('@@@ContentDocumentIds'+ContentDocumentIds);
         contactStatusMap= NewEinsteinOCRAPICall.einsteinAPICall(ContentDocumentIds,objectName,'Interface');
        //  NewEinsteinOCRAPICall.einsteinAPICall(ContentDocumentIds);
          system.debug('@@keyset'+contactStatusMap.keyset());
          system.debug('@@values'+contactStatusMap.values());
         // return 'sucess from apex';
       if(objectName=='Contact'){
          list<contact> allContactList =  [ SELECT  Id, Name, Phone, Email FROM Contact WHERE id in :contactStatusMap.keyset()];
          system.debug('@@allContactList'+allContactList);
          for(Contact conRec:allContactList){
              Sobjectwrap ContactwrapRec = new Sobjectwrap();
              ContactwrapRec.sObjectId = conRec.Id;
              ContactwrapRec.name = conRec.Name;
              ContactwrapRec.nameUrl = '/'+conRec.Id;
              ContactwrapRec.phone = conRec.phone;
              ContactwrapRec.email = conRec.Email;
              system.debug('@ConcatinateString'+contactStatusMap.get(conRec.Id));
              List<String> stringList = contactStatusMap.get(conRec.Id).split(' ');
              system.debug('@@@stringList'+stringList);
              ContactwrapRec.Status = stringList[0];
              ContactwrapRec.emailValidationResult  = stringList[1];
              listSobjectwrap.add(ContactwrapRec);
          }
           system.debug('****listContactwrap'+listSobjectwrap);
          return listSobjectwrap;
       }else{
            list<lead> allLeadList =  [ SELECT  Id, Name, Phone, Email FROM Lead WHERE id in :contactStatusMap.keyset()];
          system.debug('@@allLeadList'+allLeadList);
          for(Lead leadRec:allLeadList){
              Sobjectwrap LeadwrapRec = new Sobjectwrap();
              LeadwrapRec.sObjectId = leadRec.Id;
              LeadwrapRec.name = leadRec.Name;
              LeadwrapRec.nameUrl = '/'+leadRec.Id;
              LeadwrapRec.phone = leadRec.phone;
              LeadwrapRec.email = leadRec.Email;
              system.debug('@concatinateLeadString'+contactStatusMap.get(leadRec.Id));
              List<String> stringList = contactStatusMap.get(leadRec.Id).split(' ');
              LeadwrapRec.Status = stringList[0];
              LeadwrapRec.emailValidationResult  = stringList[1];
              listSobjectwrap.add(LeadwrapRec);
          }
           system.debug('****listLeadwrap'+listSobjectwrap);
            return listSobjectwrap;
       }
         
          
      }
    
     public class Sobjectwrap {
        @AuraEnabled
        public Id sObjectId ;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String nameUrl;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public string email;
      //   @AuraEnabled
      //  public string company;
        @AuraEnabled public String Status;
        @AuraEnabled public String emailValidationResult; 
    }
    
  /*    public class Leadwrap {
        @AuraEnabled
        public Id leadId ;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String nameUrl;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public string company;
        @AuraEnabled public String Status;
    } */
}