@RestResource(urlMapping='/caseinfo/*')
global with sharing class CaseInfoResource {

    @HttpGet
    global static void getCaseInfo() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String caseId = req.requestURI.substringAfter('/caseinfo/');
            if (String.isBlank(caseId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new Map<String, Object>{ 'error' => 'Missing Case ID' })
                );
                return;
            }

            List<Case_Request__c> results = [
                SELECT Id, Status__c, SLA_Deadline__c
                FROM Case_Request__c
                WHERE Id = :caseId
                LIMIT 1
            ];

            if (results.isEmpty()) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new Map<String, Object>{ 'error' => 'Case not found' })
                );
                return;
            }

            Case_Request__c caseRecord = results[0];

            Boolean slaMet = (caseRecord.SLA_Deadline__c != null)
                ? caseRecord.SLA_Deadline__c >= Datetime.now()
                : false;

            Map<String, Object> response = new Map<String, Object>{
                'caseId' => caseRecord.Id,
                'status' => caseRecord.Status__c,
                'slaMet' => slaMet
            };

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String, Object>{ 'error' => e.getMessage() })
            );
        }
    }
}