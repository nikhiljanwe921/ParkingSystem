public class LogisticHandler {
    
    public static void handleAfterInsert(List<Logistic__c> logistics) {
        // Create sets to hold the Time Slots to add and remove and store Id
        Set<String> timeSlotsToAdd = new Set<String>();
        Set<String> timeSlotsToRemove = new Set<String>();
        Set<Id> parkingSlotId = new Set<Id>();
        // Loop through the Logistics records
        for (Logistic__c logistic : logistics) {
            // Check if the Time Slot is not blank
            if (logistic.Time_Slot__c != null) {
                // Add the Time Slot to the set to add
                timeSlotsToAdd.add(logistic.Time_Slot__c);
                parkingSlotId.add(logistic.Parking_Slot__c);
                // Remove the Time Slot from the set to remove
                timeSlotsToRemove.remove(logistic.Time_Slot__c);
            }
        }
        
        // Loop through the Parking Slots
        for (Parking_Slot__c parkingSlot : [SELECT Id, Booking__c, Vacant__c FROM Parking_Slot__c WHERE Id IN:parkingSlotId])  {
            // Create sets to hold the Booking and Vacant values
            Set<String> bookingValues = new Set<String>(parkingSlot.Booking__c != null ? parkingSlot.Booking__c.split(';') : new List<String>());
            Set<String> vacantValues = new Set<String>(parkingSlot.Vacant__c != null ? parkingSlot.Vacant__c.split(';') : new List<String>());
            
            // Loop through the Time Slots to add
            for (String timeSlot : timeSlotsToAdd) {
                // Add the Time Slot to the Booking values
                bookingValues.add(timeSlot);
                
                // Remove the Time Slot from the Vacant values
                vacantValues.remove(timeSlot);
            }
            
            // Loop through the Time Slots to remove
            for (String timeSlot : timeSlotsToRemove) {
                // Remove the Time Slot from the Booking values
                bookingValues.remove(timeSlot);
                
                // Add the Time Slot to the Vacant values
                vacantValues.add(timeSlot);
            }
            
            // Update the Parking Slot with the new Booking and Vacant values
            parkingSlot.Booking__c = String.join(new List<String>(bookingValues), ';');
            parkingSlot.Vacant__c = String.join(new List<String>(vacantValues), ';');
            
            // Add the Parking Slot to a list to update
            update parkingSlot;
        }
    }
    
    public static void handleDeleteTrigger(List<Logistic__c> logistics) {
        Set<String> timeSlots = new Set<String>();
        Set<Id> parkingSlotId = new Set<Id>();
        // Collect all the Time Slot values from the deleted Logistics
        for (Logistic__c logistic : logistics) {
            timeSlots.add(logistic.Time_Slot__c);
            parkingSlotId.add(logistic.Parking_Slot__c);
        }
        
        // Find all Parking Slots that have the Time Slots in their Booking__c field
        List<Parking_Slot__c> parkingSlots = [SELECT Id, Booking__c, Vacant__c FROM Parking_Slot__c WHERE Id IN: parkingSlotId];
        
        // Update the Parking Slots' Booking__c and Vacant__c fields accordingly
        for (Parking_Slot__c parkingSlot : parkingSlots) {
            Set<String> bookingValues = new Set<String>(parkingSlot.Booking__c.split(';'));
            Set<String> vacantValues = new Set<String>(parkingSlot.Vacant__c.split(';'));
            
            for (String timeSlot : timeSlots) {
                if (bookingValues.contains(timeSlot)) {
                    bookingValues.remove(timeSlot);
                    vacantValues.add(timeSlot);
                }
            }
            parkingSlot.Booking__c = String.join(new List<String>(bookingValues), ';');
            parkingSlot.Vacant__c = String.join(new List<String>(vacantValues), ';');
        }
        update parkingSlots;
    }
    
}