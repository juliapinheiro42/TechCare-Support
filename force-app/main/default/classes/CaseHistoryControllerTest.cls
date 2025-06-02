@isTest
private class CaseHistoryControllerTest {

    @isTest
    static void testGetHistory_WithRecords() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Standard' AND SObjectType = 'Case_Request__c' LIMIT 1];
        Case_Request__c caseReq = new Case_Request__c(
            Subject__c = 'Test Case',
            Description__c = 'Testing getHistory',
            Product_Serial_Number__c = '000555',
            Priority__c = 'Low',
            Status__c = 'Closed',
            SLA_Deadline__c = System.now(),
            Resolution_Notes__c = 'Resolução feita',
            RecordTypeId = rt.Id
        );
        insert caseReq;

        // Cria 2 registros de Case_History__c relacionados
        List<Case_History__c> histories = new List<Case_History__c>();
        histories.add(new Case_History__c(
            Case__c = caseReq.Id,
            Time_Closed__c = System.now(),
            SLA_Met__c = true
        ));
        histories.add(new Case_History__c(
            Case__c = caseReq.Id,
            Time_Closed__c = System.now().addHours(-1),
            SLA_Met__c = false
        ));
        insert histories;

        // Act
        Test.startTest();
        List<Case_History__c> result = CaseHistoryController.getHistory(caseReq.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(2, result.size(), 'Should return 2 history records');
        System.assert(result[0].CreatedDate >= result[1].CreatedDate, 'Should be ordered by CreatedDate DESC');
    }

    @isTest
    static void testGetHistory_NoRecords() {
        // cria Case_Request__c sem histórico
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Standard' AND SObjectType = 'Case_Request__c' LIMIT 1];
        Case_Request__c caseReq = new Case_Request__c(
            Subject__c = 'Test Case No History',
            Description__c = 'No history for this one',
            Product_Serial_Number__c = '000555',
            Priority__c = 'Low',
            Status__c = 'Closed',
            SLA_Deadline__c = System.now(),
            Resolution_Notes__c = 'Resolução feita',
            RecordTypeId = rt.Id
        );
        insert caseReq;

        // Act
        Test.startTest();
        List<Case_History__c> result = CaseHistoryController.getHistory(caseReq.Id);
        Test.stopTest();

        // Assert
        System.assertEquals(0, result.size(), 'Should return no records');
    }
}