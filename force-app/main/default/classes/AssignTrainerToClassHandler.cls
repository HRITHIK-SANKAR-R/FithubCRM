public class AssignTrainerToClassHandler {
    public static void assignTrainer(List<Class__c> classes) {
        // Get the class types and their corresponding trainer specializations
        Map<String, String> specializationMap = new Map<String, String>{
            'Yoga' => 'Yoga',
            'Cardio' => 'Cardio',
            'Weight Loss' => 'Weight Loss',
            'Strength Training' => 'Strength Training',
            'Nutrition Coaching' => 'Nutrition Coaching',
            'Rehabilitation Training' => 'Rehabilitation Training',
            'Personal Training' => 'Personal Training',
            'Zumba' => 'Zumba'
        };

        for (Class__c classRecord : classes) {
            // Get the required specialization for the class type
            String requiredSpecialization = specializationMap.get(classRecord.Class_Type__c);

            // Find available trainers with matching specialization
            List<Trainer__c> availableTrainers = [SELECT Id, Name, Availability__c 
                                                  FROM Trainer__c 
                                                  WHERE Specialization__c = :requiredSpecialization 
                                                  AND Availability__c = TRUE];

            Boolean trainerAssigned = false;

            // Extract time from Schedule__c of the current class
            Time classTime = classRecord.Schedule__c.time();

            for (Trainer__c trainer : availableTrainers) {
                // Query for classes assigned to this trainer
                List<Class__c> trainerClasses = [SELECT Schedule__c 
                                                 FROM Class__c 
                                                 WHERE Trainer__c = :trainer.Id];

                Boolean conflictFound = false;

                // Check for time conflicts
                for (Class__c trainerClass : trainerClasses) {
                    if (trainerClass.Schedule__c.time() == classTime) {
                        conflictFound = true;
                        break;
                    }
                }

                if (!conflictFound) {
                    classRecord.Trainer__c = trainer.Id;
                    trainerAssigned = true;
                    break;
                }
            }

            // If no trainer is available, add an error
            if (!trainerAssigned) {
                classRecord.addError('No available trainer found for this class type or the trainer is already scheduled at the same time.');
            }
        }
    }
}