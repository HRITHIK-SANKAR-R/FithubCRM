trigger BookingTrigger on Booking__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        BookingTriggerHandler.updateAmount(Trigger.new);
    } else if (Trigger.isafter && (Trigger.isInsert || Trigger.isUpdate)) {
        BookingTriggerHandler.updateSubscriptionDates(Trigger.new);
    }
}