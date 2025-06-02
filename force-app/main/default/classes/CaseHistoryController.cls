public with sharing class CaseHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<Case_History__c> getHistory(Id caseId) {
        return [
            SELECT Id, CreatedDate, Time_Closed__c, SLA_Met__c
            FROM Case_History__c
            WHERE Case__c = :caseId
            ORDER BY CreatedDate DESC
        ];
    }
}