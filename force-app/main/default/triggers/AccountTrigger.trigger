trigger AccountTrigger on Account (
    after insert,
    after update,
    before update
) {
    AccountTriggerDispatcher.run();
}