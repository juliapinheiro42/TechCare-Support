public class CaseRequestTriggerHandler {
    public static void handleAfterUpdate(List<Case_Request__c> newList, Map<Id, Case_Request__c> oldMap) {
        List<Case_History__c> historiesToInsert = new List<Case_History__c>();

        for (Case_Request__c record : newList) {
            Case_Request__c oldRecord = oldMap.get(record.Id);

            if (
                record.Status__c == 'Closed' &&
                oldRecord.Status__c != 'Closed'
            ) {
                Boolean slaMet = record.SLA_Deadline__c != null && record.SLA_Deadline__c >= Datetime.now();

                Case_History__c history = new Case_History__c(
                    Case__c = record.Id,
                    Time_Closed__c = Datetime.now(),
                    SLA_Met__c = slaMet
                );
                historiesToInsert.add(history);
            }
        }

        if (!historiesToInsert.isEmpty()) {
            insert historiesToInsert;
        }
    }
}