public class AccountHelper {

    public void updateOwnershipTransition(
        List<Account> newAccounts,
        Map<Id, Account> oldMap
    ) {

        Set<Id> userIds = new Set<Id>();

        // Collect changed owner Ids
        for (Account acc : newAccounts) {

            Account oldAcc = oldMap.get(acc.Id);

            if (acc.OwnerId != oldAcc.OwnerId) {
                userIds.add(acc.OwnerId);
                userIds.add(oldAcc.OwnerId);
            }
        }

        if (userIds.isEmpty()) {
            return;
        }

        // Query Users and Roles
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id,
                   UserRoleId,
                   UserRole.ParentRoleId
            FROM User
            WHERE Id IN :userIds
        ]);

        // Update Account fields directly
        for (Account acc : newAccounts) {

            Account oldAcc = oldMap.get(acc.Id);

            if (acc.OwnerId == oldAcc.OwnerId) {
                continue;
            }

            User oldOwner = userMap.get(oldAcc.OwnerId);
            User newOwner = userMap.get(acc.OwnerId);

            String transition = 'None';

            if (oldOwner != null &&
                newOwner != null &&
                oldOwner.UserRoleId != null &&
                newOwner.UserRoleId != null) {

                // Same Role
                if (oldOwner.UserRoleId == newOwner.UserRoleId) {
                    transition = 'None';
                }

                // Pass Up
                else if (oldOwner.UserRole.ParentRoleId ==
                         newOwner.UserRoleId) {
                    transition = 'Pass Up';
                }

                // Pass Down
                else if (newOwner.UserRole.ParentRoleId ==
                         oldOwner.UserRoleId) {
                    transition = 'Pass Down';
                }

                else {
                    transition = 'None';
                }
            }

            // Update fields directly on Account
            //acc.SW_Sales_Rep__c = acc.OwnerId;
            acc.SW_Previous_Sales_Rep__c = oldAcc.OwnerId;
            acc.SW_Transition__c = transition;
            acc.Effective_Transfer_Date__c = System.today();
            acc.SW_Is_Owner_Transferred__c = true;
        }
    }
}