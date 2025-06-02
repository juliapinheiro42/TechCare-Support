public with sharing class CaseRequestController {
    @AuraEnabled(cacheable=true)
public static Case_Request__c getCaseDetails(Id caseId) {
    return [
        SELECT Id, SLA_Deadline__c, Status__c, RecordType.DeveloperName, Subject__c, Description__c
        FROM Case_Request__c
        WHERE Id = :caseId
        LIMIT 1
    ];
}

   @AuraEnabled
public static void reopenCase(Id caseId) {
    Case_Request__c cr = [
        SELECT Id, Status__c, RecordType.DeveloperName
        FROM Case_Request__c
        WHERE Id = :caseId
        LIMIT 1
    ];

    if (cr.Status__c == 'Closed') {
        cr.Status__c = 'In Progress';

        if (cr.RecordType.DeveloperName == 'Premium') {
            cr.SLA_Deadline__c = System.now().addHours(8);
        } else {
            cr.SLA_Deadline__c = System.now().addHours(24);
        }

        update cr;
    }
}
    @AuraEnabled
public static void contactSupport(Id caseId) {
    Case_Request__c cr = [
        SELECT Id, Subject__c, Description__c
        FROM Case_Request__c
        WHERE Id = :caseId
        LIMIT 1
    ];

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] { 'jupfarias42@gmail.com' });
    mail.setSubject('Novo chamado de suporte - Case Request: ' + cr.Subject__c);
    mail.setPlainTextBody(
        'Descrição: ' + cr.Description__c + '\n' +
        'Case ID: ' + cr.Id
    );

    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}