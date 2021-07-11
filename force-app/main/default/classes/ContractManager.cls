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
@RestResource(urlMapping='/Contract/*')
global with sharing class ContractManager {
    @HttpGet
    global static contract getcontractById() {
        RestRequest request = RestContext.request;
        // grab the contractId from the end of the URL
        String contractId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        contract result =  [SELECT Id,AccountId,Status,StartDate,ContractTerm
                        FROM contract
                        WHERE Id = :contractId];
        return result;
    }
    @HttpPost
    global static ID createcontract(String accountId, String status,
        Date startDate, Integer contractTerm) {
        contract thiscontract = new contract(
            AccountId=accountId,
            Status=status,
            StartDate=startDate,
            ContractTerm=contractTerm);
        insert thiscontract;
        return thiscontract.Id;
    }   
    @HttpDelete
    global static void deletecontract() {
        RestRequest request = RestContext.request;
        String contractId = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);

        System.debug(contractId);
		Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
        System.debug('Id à deleter '+ contractId);
        delete thisContract;
    }  
    @HttpPut
    global static ID upsertcontract(String accountId, String status,
        Date startDate, Integer contractTerm, String id) {
        contract thiscontract = new contract(
            Id=id,
            AccountId=accountId,
            Status=status,
            StartDate=startDate,
            ContractTerm=contractTerm);
        // Match contract by Mail, if present.
        // Otherwise, create new contract.
        upsert thiscontract;
        // Return the contract ID.
        return Id=thiscontract.Id;
    }
    @HttpPatch
    global static ID updatecontractFields() {
        RestRequest request = RestContext.request;
        String contractId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        contract thiscontract = [SELECT Id FROM contract WHERE Id = :contractId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Contract sObject
            if (fieldName == 'startdate') {
            	thisContract.put(fieldName, Date.valueOf((string) params.get(fieldName)));  
            } else {
                if (fieldName == 'contractterm') {
                 thisContract.put(fieldName, integer.valueOf(params.get(fieldName)));  
                }else{
                    thisContract.put(fieldName, params.get(fieldName));
                }
            }
        }
        update thiscontract;
        return thiscontract.Id;
    }    
}