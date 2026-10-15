trigger OpportunityTrigger on Opportunity (before update, after update) {
    OpportunityTriggerDispatcher.run();
}