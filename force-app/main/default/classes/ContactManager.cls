/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@RestResource(urlMapping='/Contact/*')
global with sharing class ContactManager {
    @HttpGet
    global static Contact getContactById() {
        RestRequest request = RestContext.request;
        // grab the contactId from the end of the URL
        String contactId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        Contact result =  [SELECT FirstName,LastName,Email_uniq__c,Title
                        FROM Contact
                        WHERE Id = :contactId];
        return result;
    }
    @HttpPost
    global static ID createContact(String firstname, String lastname,
        String email, String title) { 
            // Si un contact avec adresse email existe, pas de création, uniquement retour id
            List<Contact> contacts = [SELECT Id FROM CONTACT where email_uniq__c = :email ];
            if ( contacts.size() != 0 ) {
                return contacts[0].Id;
            }
        Contact thisContact = new Contact(
            FirstName=firstname,
            LastName=lastname,
            Email_uniq__c=email,
            Email=email,
            Title=title,
            Activated__c=true);
        insert thisContact;
        return thisContact.Id;
    }   
    @HttpDelete
    global static void deleteContact() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        System.debug(contactId);
		Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        System.debug('Id à désactiver '+ contactId);
        thisContact.Activated__c = False;
        update thisContact;
        // delete thisContact;
    } 
    @HttpPatch
    global static ID updateContactFields() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Contact sObject
            if ( fieldName == 'Email' ) {
                thisContact.put('Email_uniq__c',params.get(fieldName));
                thisContact.put('Email', params.get(fieldName));
            }else{
            thisContact.put(fieldName, params.get(fieldName));
            }
        }
        update thisContact;
        return thisContact.Id;
    }    
}