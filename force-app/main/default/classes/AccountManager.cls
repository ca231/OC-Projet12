/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@RestResource(urlMapping='/Account/*')
global with sharing class AccountManager {
    @HttpGet
    global static account getaccountById() {
        RestRequest request = RestContext.request;
        // grab the accountId from the end of the URL
        String accountId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        account result =  [SELECT Id,Name
                        FROM account
                        WHERE Id = :accountId];
        return result;
    }
    @HttpPost
    global static ID createaccount(String accountId, String name) {
        account thisaccount = new account(
            Id=accountId,
            Name=name);
        insert thisaccount;
        return thisaccount.Id;
    }   
    @HttpPatch
    global static ID updateAccountFields() {
        RestRequest request = RestContext.request;
        String accountId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Account thisAccount = [SELECT Id FROM account WHERE Id = :accountId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Account sObject
            thisAccount.put(fieldName, params.get(fieldName));
        }
        update thisAccount;
        return thisAccount.Id;
    }    
}