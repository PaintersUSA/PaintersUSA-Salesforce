public class AccountTriggerDispatcher {

    public static void run() {

        SW_Trigger_Setting__mdt setting =
            SW_Trigger_Setting__mdt.getInstance('Account_Trigger');

        if (setting != null && !setting.SW_Is_Active__c) {
            return;
        }

        AccountTriggerHandler handler = new AccountTriggerHandler();

        if (Trigger.isBefore) {

            if (Trigger.isUpdate) {
                handler.handleBeforeUpdate(
                    (List<Account>)Trigger.new,
                    (Map<Id, Account>)Trigger.oldMap
                );
            }
        }

        if (Trigger.isAfter) {

            if (Trigger.isInsert) {
                // Existing after insert logic
            }

            if (Trigger.isUpdate) {
                // Existing after update logic (if any)
            }
        }
    }
}