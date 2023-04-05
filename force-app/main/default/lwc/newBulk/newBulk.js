import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import invokeContentDocumentIds from '@salesforce/apex/ContentDocumentIdsProcessing.invokeContentDocumentIds';


export default class NewBulk extends LightningElement {
    ContactHeader;
    isLoading = false;
    tableData;
    title = 'Contacts for Uploaded Cards';
    iconName = 'standard:contact';
    value = 'Contact';
    @track columns=[];
    @api recordId;
    @track error;
    @track contactList ;
    @track leadList ;
    @track contactListWrapper ;

    /*To show in pick list field */
    get options() {
        return [
            { label: 'Contact', value: 'Contact' },
            { label: 'Lead', value: 'Lead' }
        ];
    }


  /*Columns to show on table for contact records */
    @track contactColumns = [{
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'name' }, 
        target: '_blank'},
        sortable: true
    }, 
    {
        label: 'Phone',
        fieldName: 'phone',
        type: 'phone',
        sortable: true
    },
    {
        label: 'Email',
        fieldName: 'email',
        type: 'email',
        sortable: true
    },
    {
        label: 'Valid/Invalid Email',
        fieldName: 'emailValidationResult',
        type: 'text',
        sortable: true,
        cellAttributes:{
            class:{fieldName:'emailValidColor'}
    }},
    {
        label: 'New/Duplicate',
        fieldName: 'Status',
        type: 'text',
        sortable: true,
        cellAttributes:{
            class:{fieldName:'statusColor'}
    }}
   
    
];

/*Columns to show on table for Lead records */
@track leadColumns = [{
    label: 'Name',
    fieldName: 'nameUrl',
    type: 'url',
    typeAttributes: {label: { fieldName: 'name' }, 
    target: '_blank'},
    sortable: true
}, 
{
    label: 'Phone',
    fieldName: 'phone',
    type: 'phone',
    sortable: true
},
{
    label: 'Email',
    fieldName: 'email',
    type: 'text',
    sortable: true
},
{
    label: 'Valid/Invalid Email',
    fieldName: 'emailValidationResult',
    type: 'text',
    sortable: true,
    cellAttributes:{
        class:{fieldName:'emailValidColor'}
}},
{
    label: 'New/Duplicate',
    fieldName: 'Status',
    type: 'text',
    sortable: true,
    cellAttributes:{
        class:{fieldName:'statusColor'}
}}


];

    Message = false;
    /*List of file formats to accepts while uploading the files */
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }

    /*To capture the selected pick list value */ 
    handleChangePick(event){
        this.value = event.target.value;
     /*   if(this.value==='Contact'){
            this.title = 'Contacts for Uploaded Cards';
           /this.iconName = 'standard:contact';
        }
        else{
            this.title = 'Leads for Uploaded Cards';
            this.iconName = 'standard:lead';
        } */
    }

  /* To capture the uploaded files IDs*/  
      handleUploadFinished(event) {
          console.log('Upload',event);
                // Get the list of uploaded files
                this.Message = false;
            const uploadedFiles = event.detail.files;
                let uploadedFileNames = '';
                let uploadedFileIds = [];
                for(let i = 0; i < uploadedFiles.length; i++) {
                    uploadedFileNames += uploadedFiles[i].name + ', ';
                    uploadedFileIds.push(uploadedFiles[i].documentId);
                }
                this.isLoading = true;
                console.log('uploadedFileIds',uploadedFileIds);
                   /*Calling the Apex class by passing the selected pick list value & the uploaded files Ids */      
                    invokeContentDocumentIds({
                        ContentDocumentIds : uploadedFileIds,
                        objectName : this.value
                    })
                    /* Handle if the callback from apex is Success */
                    .then(result => {
                        this.isLoading = false;
                        console.log('Success');
                        console.log('resultlength',result.length);
                        /* Verifying whether the records recevied from apex class or not*/ 
                        if(result.length>0){
                                
                                this.Message = true;
                                console.log('result',result);
                                /*To Verify whether the received records are of Contact object type */
                                if(this.value==='Contact'){
                                    this.title = 'Contacts for Uploaded Cards';
                                    this.iconName = 'standard:contact';
                                    this.columns=this.contactColumns;
                                    this.contactList = result.reverse();
                                    console.log('contactlist',this.contactList);
                                    /*To add CSS to the Status column to differentiate New and Duplicate Status */
                                    this.tableData = this.contactList.map(item=>{
                                        let statusColor = item.Status === 'Duplicate' ? "slds-text-color_error":"slds-text-color_success"
                                        let emailValidColor = item.emailValidationResult === 'Invalid' ? "slds-text-color_error":"slds-text-color_success"
                                        return {...item, 
                                            "statusColor":statusColor,
                                            "emailValidColor":emailValidColor
                                            
                                        }
                                    })

                                    console.log('Message',this.Message);
                                    /*To show success Toast Message for Contact Records */
                                    this.errors = undefined;
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Success',
                                            message: 'Contacts are created sucessfully for the uploaded cards',
                                                variant: 'success',
                                            }),
                                        ); 
                                 /* Handle if the received record types from apex are of Lead Object Type */
                                }else{
                                    this.title = 'Leads for Uploaded Cards';
                                    this.iconName = 'standard:lead';
                                    this.columns = this.leadColumns;
                                    this.leadList = result.reverse();
                                    /*To add CSS to the Status column to differentiate New and Duplicate Status */
                                    this.tableData = this.leadList.map(item=>{
                                        let statusColor = item.Status === 'Duplicate' ? "slds-text-color_error":"slds-text-color_success"
                                        let emailValidColor = item.emailValidationResult === 'Invalid' ? "slds-text-color_error":"slds-text-color_success"
                                        return {...item, 
                                            "statusColor":statusColor,
                                            "emailValidColor":emailValidColor
                                            
                                        }
                                    })
                                    /*To show success Toast Message for Lead Records */
                                    console.log('Message',this.Message);
                                    this.errors = undefined;
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Success',
                                            message: 'Leads are created sucessfully for the uploaded cards',
                                                variant: 'success',
                                            }),
                                        ); 
                                }
                               
                    
                               
                        } 
                        /*Show error toast message if there are no  records received from Apex */
                        else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Something went wrong',
                                message: 'Please contact your admin',
                                    variant: 'error',
                                }),
                            ); 

                        }
                        
                    
                    }) /* To handle error scenario */
                        .catch(error => {
                            this.isLoading = false;
                            console.log('Error');
                            this.errors = error;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Something went wrong',
                                message: 'Please contact your admin',
                                    variant: 'error',
                                }),
                            ); 
                            
                        })
            
        }
    }