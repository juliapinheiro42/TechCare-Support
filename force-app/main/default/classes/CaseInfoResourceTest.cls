@isTest
public class CaseInfoResourceTest {

    @isTest
    static void testGetCaseInfoSuccess() {
        Case_Request__c cr = new Case_Request__c(
            Subject__c = 'REST Test',
            Description__c = 'REST test case',
            Priority__c = 'Low',
            Status__c = 'Closed',
            SLA_Deadline__c = Datetime.now().addHours(1),
            Business_Function_Affected__c = 'TI',
            Resolution_Notes__c = 'Fechado corretamente'
        );
        insert cr;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caseinfo/' + cr.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        CaseInfoResource.getCaseInfo();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains(cr.Id));
    }

    @isTest
    static void testGetCaseInfoMissingId() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caseinfo/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        CaseInfoResource.getCaseInfo();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Missing Case ID'));
    }

    //testando se aparece error 404 por boas práticas
@isTest
static void testGetCaseInfoInvalidId() {
    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/caseinfo/a00INVALID';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    CaseInfoResource.getCaseInfo();
    Test.stopTest();

    String responseStr = RestContext.response.responseBody.toString();
    System.debug('Response: ' + responseStr);

    System.assertEquals(404, RestContext.response.statusCode, 'Expected 404 Not Found');
    System.assert(responseStr.contains('"error"'), 'Expected error key in JSON response');
}

    //Testando quando o deadline vai nulo
@isTest
static void testSlaDeadlineNull() {

    Case_Request__c cr = new Case_Request__c(
        Subject__c = 'Sem SLA',
        Description__c = 'Caso sem deadline',
        Priority__c = 'Medium',
        Status__c = 'Closed',
        Business_Function_Affected__c = 'TI',
        Resolution_Notes__c = 'Resolução feita'
    );
    insert cr;

    cr.SLA_Deadline__c = null;
update cr;

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/caseinfo/' + cr.Id;
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    CaseInfoResource.getCaseInfo();
    Test.stopTest();

    String result = RestContext.response.responseBody.toString();
    System.debug('Response: ' + result);

    System.assertEquals(200, RestContext.response.statusCode);
    System.assert(result.contains('"slaMet":false'), 'Expected slaMet to be false when SLA_Deadline__c is null');
}
}