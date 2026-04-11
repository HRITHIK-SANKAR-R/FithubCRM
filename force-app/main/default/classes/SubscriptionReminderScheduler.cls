global class SubscriptionReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Query members whose subscription ends in 5 days
        List<Member__c> membersToNotify = [
            SELECT Id, Full_Name__c, Email__c, Subscription_End_Date__c 
            FROM Member__c 
            WHERE Subscription_End_Date__c = :Date.today().addDays(5)
        ];

        if (!membersToNotify.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Member__c member : membersToNotify) {
                if (String.isNotBlank(member.Email__c)) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { member.Email__c });
                    email.setSubject('Your Membership is Expiring Soon!');
                    email.setPlainTextBody(
                        'Dear ' + member.Full_Name__c + ',\n\n' +
                        'Your membership is set to expire on ' + member.Subscription_End_Date__c.format() + '.\n' +
                        'Please renew your membership to continue enjoying our services.\n\n' +
                        'Best regards,\n' +
                        'The FitHub Team'
                    );
                    emails.add(email);
                }
            }

            // Send all emails
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
}