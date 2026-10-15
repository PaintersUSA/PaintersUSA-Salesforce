public class OpportunityTriggerHelper {
    
    public static void preserveOpportunityOwner(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap
    ) {
        
        User runningUser = [
            SELECT Id, Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        System.debug(runningUser.Name);
        if (runningUser.Name != 'Saas Worx') {
            return;
        }
        
        for (Opportunity opp : newList) {
            
            Opportunity oldOpp = oldMap.get(opp.Id);
            
            if (opp.OwnerId != oldOpp.OwnerId) {
                opp.OwnerId = oldOpp.OwnerId;
            }
        }
    }
    
    
    public static void storeAccountIds(List<Opportunity> newList) {
        
        Set<Id> accIds = new Set<Id>();
        Map<Id, List<Opportunity>> accountToOpportunities =
            new Map<Id, List<Opportunity>>();
        
        for (Opportunity opp : newList) {
            
            if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                
                accIds.add(opp.AccountId);
                
                if (!accountToOpportunities.containsKey(opp.AccountId)) {
                    accountToOpportunities.put(
                        opp.AccountId,
                        new List<Opportunity>()
                    );
                }
                
                accountToOpportunities.get(opp.AccountId).add(opp);
            }
        }
        
        if (!accIds.isEmpty()) {
            
            System.debug('Published Test');
            
            AccountContactEventPublisher.publishAccountContactData(
                accIds,
                accountToOpportunities
            );
        }
    }
}