public class OpportunityTriggerHandler {

    public static void beforeUpdate(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap
    ) {
        OpportunityTriggerHelper.preserveOpportunityOwner(newList, oldMap);
    }
    
    public static void afterUpdate(List<Opportunity> newList){
        
        OpportunityTriggerHelper.storeAccountIds(newList);
    }
}