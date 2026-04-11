public class BookingTriggerHandler {
    public static void updateAmount(List<Booking__c> bookingList) {
        // Collect related Member and Class IDs
        Set<Id> memberIds = new Set<Id>();
        Set<Id> classIds = new Set<Id>();
        
        for (Booking__c booking : bookingList) {
            if (booking.Member__c != null) {
                memberIds.add(booking.Member__c);
            }
            if (booking.Class__c != null) {
                classIds.add(booking.Class__c);
            }
        }

        // Query Member and Class data
        Map<Id, Member__c> memberMap = new Map<Id, Member__c>(
            [SELECT Id, Membership_Type__c FROM Member__c WHERE Id IN :memberIds]
        );
        Map<Id, Class__c> classMap = new Map<Id, Class__c>(
            [SELECT Id, Class_Type__c FROM Class__c WHERE Id IN :classIds]
        );

        // Define pricing logic
        Map<String, Map<String, Decimal>> pricingMatrix = new Map<String, Map<String, Decimal>> {
            'Basic' => new Map<String, Decimal> {
                'Yoga' => 1000,
                'Cardio' => 3000,
                'Strength Training' => 3500,
                'Weight Loss' => 4000,
                'Nutrition Coaching' => 4500,
                'Rehabilitation Training' => 6000,
                'Personal Training' => 85000,
                'Zumba' => 2000
            },
            'Standard' => new Map<String, Decimal> {
                'Yoga' => 2000,
                'Cardio' => 5000,
                'Strength Training' => 4500,
                'Weight Loss' => 5000,
                'Nutrition Coaching' => 6000,
                'Rehabilitation Training' => 8000,
                'Personal Training' => 10000,
                'Zumba' => 2500
            },
            'Premium' => new Map<String, Decimal> {
                'Yoga' => 2500,
                'Cardio' => 6000,
                'Strength Training' => 5500,
                'Weight Loss' => 6000,
                'Nutrition Coaching' => 7000,
                'Rehabilitation Training' => 9000,
                'Personal Training' => 15000,
                'Zumba' => 3000
            }
        };

        // Update Amount field for each Booking record
        for (Booking__c booking : bookingList) {
            if (booking.Member__c != null && booking.Class__c != null) {
                Member__c member = memberMap.get(booking.Member__c);
                Class__c classRecord = classMap.get(booking.Class__c);

                if (member != null && classRecord != null) {
                    String membershipType = member.Membership_Type__c;
                    String classType = classRecord.Class_Type__c;

                    if (pricingMatrix.containsKey(membershipType) &&
                        pricingMatrix.get(membershipType).containsKey(classType)) {
                        booking.Amount__c = pricingMatrix.get(membershipType).get(classType);
                    } else {
                        booking.Amount__c = 0; // Default if no match in pricing
                    }
                }
            }
        }
    }
    
    // Updating Member object fields
    public static void updateSubscriptionDates(List<Booking__c> bookings) {
        Map<Id, Member__c> memberUpdates = new Map<Id, Member__c>();

        for (Booking__c booking : bookings) {
            if (booking.Member__c != null ) {
                Member__c member = memberUpdates.get(booking.Member__c);
                if (member == null) {
                    member = new Member__c(Id = booking.Member__c);
                }
                if(booking.Booking_Type__c == 'New Booking'){
                    member.Subscription_Start_Date__c = booking.Booking_Date__c;
                    member.Subscription_End_Date__c = booking.Booking_Date__c.addDays(30);
                } else {
                    member.Subscription_End_Date__c = booking.Booking_Date__c.addDays(30);
                }
        
                memberUpdates.put(member.Id, member);
            }
        }

        if (!memberUpdates.isEmpty()) {
            update memberUpdates.values();
        }
    }
}