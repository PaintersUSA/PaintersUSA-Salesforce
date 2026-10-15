public with sharing class AccountTriggerHandler {

    private AccountHelper helper = new AccountHelper();

    public void handleBeforeUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldMap
    ) {
        helper.updateOwnershipTransition(newAccounts, oldMap);
    }

    public void handleAfterUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldMap
    ) {
        // Keep existing after update logic here if required.
    }
}