public class OpportunityTriggerDispatcher {

    public static void run() {

        if (Trigger.isBefore && Trigger.isUpdate) {

            OpportunityTriggerHandler.beforeUpdate(
                (List<Opportunity>) Trigger.new,
                (Map<Id, Opportunity>) Trigger.oldMap
            );
        }
        
        if (Trigger.isAfter && Trigger.isUpdate){
            
            OpportunityTriggerHandler.afterUpdate((List<Opportunity>) Trigger.new);
        }
    }
}