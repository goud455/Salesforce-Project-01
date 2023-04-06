public class EmailVerifyApiClass {
    
    public Static String emailApiAuthenticate(String emailId){ 
        String emailValidateResult='';
        system.debug('@@@emailtoValidate'+emailId);
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
        request.setEndpoint('https://emailvalidation.abstractapi.com/v1/?api_key=096ba7a935c14f8a810a6e4c56213f8d&email='+emailId);
       // request.setEndpoint('https://emailvalidation.abstractapi.com/v1/?api_key=f1cd0f6a441f4ebaa6cfda38b7419482&email='+emailId);
    HttpResponse response = http.send(request);
    system.debug('response Body@@@::'+response.getBody());
        system.debug('response.getStatusCode'+response.getStatusCode());
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
             ValidateEmailJSON EmailResponse = new ValidateEmailJSON();
             EmailResponse = (ValidateEmailJSON) System.JSON.deserialize(response.getBody(), ValidateEmailJSON.class);
            system.debug('EmailResponse::'+EmailResponse.deliverability);
            //  system.debug('Valid Email?'+EmailResponse.result.capitalize()); 
               emailValidateResult = EmailResponse.deliverability=='DELIVERABLE'?'Valid':'Invalid'; 
               } else{
                emailValidateResult='Issue with Email Validation API';
              }
       return emailValidateResult;
    } 
    
    public class Is_valid_format {
		public Boolean value;
		public String text;
	}
    
    public class ValidateEmailJSON {
	

	public String email;
	public String autocorrect;
	public String deliverability;
	public String quality_score;
	public Is_valid_format is_valid_format;
	public Is_valid_format is_free_email;
	public Is_valid_format is_disposable_email;
	public Is_valid_format is_role_email;
	public Is_valid_format is_catchall_email;
	public Is_valid_format is_mx_found;
	public Is_valid_format is_smtp_valid;
	
}
    
}