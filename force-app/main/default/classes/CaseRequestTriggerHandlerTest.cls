@isTest
public class CaseRequestTriggerHandlerTest {
    @isTest
    static void testSlaMetTrue() {
        Case_Request__c caseRequest = new Case_Request__c(
            Subject__c = 'Teste SLA true',
            Description__c = 'Descrição de teste',
            Priority__c = 'High',
            Status__c = 'In Progress',
            SLA_Deadline__c = Datetime.now().addHours(1),
            Business_Function_Affected__c = 'TI',
            Resolution_Notes__c = 'Resolvido'
        );
        insert caseRequest;
        
        caseRequest.Status__c = 'Closed';
        update caseRequest;

        List<Case_History__c> historyList = [
            SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case__c = :caseRequest.Id
        ];
        System.assertEquals(1, historyList.size());
        System.assertEquals(true, historyList[0].SLA_Met__c);
    }

    @isTest
    static void testSlaMetFalse() {
        
        Case_Request__c caseRequest = new Case_Request__c(
            Subject__c = 'Teste SLA false',
            Description__c = 'Descrição de teste',
            Priority__c = 'Low',
            Status__c = 'New',
            SLA_Deadline__c = Datetime.now().addMinutes(-1),
            Resolution_Notes__c = 'Resolvido',
            Business_Function_Affected__c = 'TI'
            
        );
        insert caseRequest;
        
        caseRequest.Status__c = 'Closed';
        update caseRequest;

        List<Case_History__c> historyList = [
            SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case__c = :caseRequest.Id
        ];
        System.assertEquals(1, historyList.size());
        System.assertEquals(false, historyList[0].SLA_Met__c);
    }
}