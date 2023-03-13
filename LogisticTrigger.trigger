trigger LogisticTrigger on Logistic__c (after insert,after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            LogisticHandler.handleAfterInsert(Trigger.new);
        }
        if(Trigger.isDelete){
            LogisticHandler.handleDeleteTrigger(Trigger.old);
        }
    }
}