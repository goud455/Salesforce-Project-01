import { LightningElement,track,api } from 'lwc';
import getQueryData from '@salesforce/apex/ChatGptHandler.getQueryData';
import IMAGE from '@salesforce/resourceUrl/ChatBot';


export default class ChatGPT extends LightningElement {
  searchTerm = '';
  imageUrl = IMAGE;
  showSpinner = false;
  showSpace=true;
  @track responseData ;
  handleKeyDown(event) {
    
      if (event.keyCode === 13) {
        // Perform search when the Enter key is pressed
        this.searchTerm = event.target.value;
        this.showSpinner = true

        getQueryData({searchString:this.searchTerm})
         .then(result=>{
           this.showSpinner = false
           let response = JSON.parse(JSON.stringify(JSON.parse(result)));
           if (response.error) {
                    this.responseData = response.error.message;
            } else if (response.choices[0].text) {
                    this.responseData = response.choices[0].text;
                    this.responseData = this.responseData.replace(/\n/g, "<br />");
                    let tempScriptData = ''
                    tempScriptData = (response.choices[0].text.includes('<script>')) ? 'JS File: ' + response.choices[0].text.split('<script>')[1] : '';
                    tempScriptData = this.responseTextLWCJS.replace(/\n/g, "<br />");
                    this.responseData = this.responseData + this.responseTextLWCJS;
                    this.responseData = (this.responseData.includes('XML File:')) ? this.responseData.split('XML File:')[0] : this.responseData;
                    this.responseData.trim();
            }
           console.log('ss',JSON.stringify(responseData))
         })
         .catch(error=>{
           this.showSpinner = false
           console.log('error is '+error)
         })
   
    
  }
}
}