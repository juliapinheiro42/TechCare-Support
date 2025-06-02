@isTest
private class CaseRequestControllerTest {

    private static RecordType getRecordType(String devName) {
        return [SELECT Id FROM RecordType WHERE DeveloperName = :devName AND SObjectType = 'Case_Request__c' LIMIT 1];
    }

    private static Case_Request__c createCase(String status, String recordTypeName) {
        RecordType rt = getRecordType(recordTypeName);
        Case_Request__c cr = new Case_Request__c(
            Subject__c = 'Test ' + status,
            Description__c =  'Testando',
            Business_Function_Affected__c = 'TI',
            Product_Serial_Number__c = '000555',
            Priority__c = 'Low',
            Status__c = status,
            SLA_Deadline__c = System.now().addHours(1),
            Resolution_Notes__c = 'Resolução feita',
            RecordTypeId = rt.Id
        );
        insert cr;
        return cr;
    }

    @isTest
    static void testGetCaseDetails_Valid() {
        Case_Request__c cr = createCase('New', 'Standard');

        Test.startTest();
        Case_Request__c result = CaseRequestController.getCaseDetails(cr.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(cr.Id, result.Id);
    }

    @isTest
static void testGetCaseDetails_Invalid() {
    Boolean exceptionThrown = false;

    Test.startTest();
    try {
        CaseRequestController.getCaseDetails('a00INVALID');
    } catch (Exception e) {
        exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(exceptionThrown, 'Expected exception to be thrown for invalid ID');
}

    @isTest
    static void testReopenCase_Premium() {
        Case_Request__c cr = createCase('Closed', 'Premium');
        
        update cr;
        
        Test.startTest();
        CaseRequestController.reopenCase(cr.Id);
        Test.stopTest();

        Case_Request__c updated = [SELECT Status__c, SLA_Deadline__c FROM Case_Request__c WHERE Id = :cr.Id];
        System.assertEquals('In Progress', updated.Status__c);
        System.assert(updated.SLA_Deadline__c >= System.now().addHours(7), 'SLA should be extended to ~8h');
    }

    @isTest
    static void testReopenCase_Standard() {
        Case_Request__c cr = createCase('Closed', 'Standard');
        
        cr.Status__c = 'Closed';
        cr.Resolution_Notes__c = 'Resolução feita';
        
        Test.startTest();
        CaseRequestController.reopenCase(cr.Id);
        Test.stopTest();

        Case_Request__c updated = [SELECT Status__c, SLA_Deadline__c FROM Case_Request__c WHERE Id = :cr.Id];
        System.assertEquals('In Progress', updated.Status__c);
        System.assert(updated.SLA_Deadline__c >= System.now().addHours(23), 'SLA should be extended to ~24h');
    }

    @isTest
    static void testReopenCase_NotClosed() {
        Case_Request__c cr = createCase('New', 'Standard', true);

        update cr;
        Test.startTest();
        CaseRequestController.reopenCase(cr.Id);
        Test.stopTest();

        Case_Request__c updated = [SELECT Status__c FROM Case_Request__c WHERE Id = :cr.Id];
        System.assertEquals('New', updated.Status__c, 'Status should remain unchanged');
    }

    @isTest
    static void testReopenCase_Invalid() {
            Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CaseRequestController.reopenCase('a00INVALID');
            System.assert(false, 'Expected exception for invalid ID');
        } catch (Exception e) {
        exceptionThrown = true;
        }
        Test.stopTest();
            System.assert(exceptionThrown, 'Expected exception to be thrown for invalid ID');

    }

    @isTest
    static void testContactSupport_Valid() {
        Case_Request__c cr = createCase('New', 'Premium', true);

        Test.startTest();
        CaseRequestController.contactSupport(cr.Id);
        Test.stopTest();

        System.assert(true, 'contactSupport executed successfully');
    }

    

    @isTest
static void testContactSupport_Invalid() {
    Boolean exceptionThrown = false;

    Test.startTest();
    try {
        CaseRequestController.contactSupport('a00INVALID');
    } catch (Exception e) {
        exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(exceptionThrown, 'Expected exception to be thrown for invalid ID');
}
}