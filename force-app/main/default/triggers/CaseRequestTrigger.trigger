trigger CaseRequestTrigger on Case_Request__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseRequestTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}