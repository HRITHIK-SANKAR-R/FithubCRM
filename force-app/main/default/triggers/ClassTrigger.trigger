trigger ClassTrigger on Class__c (before insert, before update) {
    if (Trigger.isUpdate) {
        // Identify relevant field changes
        Set<Id> relevantClassIds = new Set<Id>();

        for (Class__c newClass : Trigger.new) {
            Class__c oldClass = Trigger.oldMap.get(newClass.Id);

            // Check if meaningful fields (not roll-up summary fields) have changed
            if (newClass.Class_Type__c != oldClass.Class_Type__c ||
                newClass.Schedule__c != oldClass.Schedule__c) {
                relevantClassIds.add(newClass.Id);
            }
        }

        // Proceed only if relevant fields have changed
        if (!relevantClassIds.isEmpty()) {
            List<Class__c> relevantClasses = [SELECT Id, Class_Type__c, Schedule__c 
                                              FROM Class__c 
                                              WHERE Id IN :relevantClassIds];
            AssignTrainerToClassHandler.assignTrainer(relevantClasses);
        }
    } else if (Trigger.isInsert) {
        // Handle insert logic
        AssignTrainerToClassHandler.assignTrainer(Trigger.new);
    }
}