public with sharing class ParkingBookingSystemController {
    @AuraEnabled(cacheable=true)
    public static List<Parking_Slot__c> getParkingSlots() {
        return [SELECT Id, Name, Booking__c, Vacant__c FROM Parking_Slot__c ORDER BY Name ASC];
    }

    @AuraEnabled
    public static void deleteLogistic(String timeSlot,String slot){
        System.debug('Time: '+timeSlot+' slot: '+ slot);
        List<Logistic__c> logList = [SELECT Id,Name from Logistic__c WHERE Time_Slot__C =: timeSlot AND Parking_Slot__c =: slot];
        System.debug('Fetched driver: '+logList);
        try{
            delete logList;
            system.debug('Deleted succesfully!!!');
        }catch(DMLException e){
            system.debug('While delete error: '+e.getMessage());
        }
    }

    @AuraEnabled
    public static void createLogisticObject(String name, Id slot, String vehicleNumber, String timeSlot){

        createLogisticObjectFuture(name,slot,vehicleNumber,timeSlot);
      /* if (logistic.Id != NULL) {
            return 'Success';
        }
        else{
            return 'error';
        }*/
    }
    
    @future
    public static void createLogisticObjectFuture(String dname, Id slot, String vehicleNumber, String timeSlot){
         Logistic__c logistic = new Logistic__c( Name=dname, Parking_Slot__c=slot, Vehicle_Number__c=vehicleNumber, Time_Slot__c=timeSlot);

        try {
            insert logistic;
            system.debug('Logistic object inserted succesfully');
        } catch (Exception e) {
            system.debug('While Insert error: '+e.getMessage());
        }
    }
                    
    
}