import { LightningElement, wire, api, track } from "lwc";
import getParkingSlots from "@salesforce/apex/ParkingBookingSystemController.getParkingSlots";
import createLogisticObject from "@salesforce/apex/ParkingBookingSystemController.createLogisticObject";
import deleteLogistic from "@salesforce/apex/ParkingBookingSystemController.deleteLogistic";

export default class ParkingBookingSystem extends LightningElement {
  @api parkingSlots;
  @track customFormModal = false;
  @track showBookingPopup = false;

  @track parkingTime = [];
  @track parkingSpot = [];
  @track bookingSlots = [];
  @track deleteTimeArray = [];
  @track deleteSpotArray = [];

  @track name;
  @track slot;
  @track vehicleNumber;
  @track time;

  @track deleteTime;
  @track deleteSlot;

  @wire(getParkingSlots)
  parkingSlots;

  @wire(getParkingSlots)
  wiredParkingSlots({ error, data }) {
    if (data) {
      this.parkingSlots = data;
      this.parkingSpot = [...new Set(data.map((slot) => slot.Name))];
      this.bookingSlots = [...new Set(data.map((slot) => slot.Booking__c))];
      this.parkingTime = [...new Set(data.map((slot) => slot.Vacant__c))];
    } else if (error) {
      console.error(error);
    }
  }

  customShowBooking(event) {
    // get the value of the selected parking spot
    let deleteSpot = event.target.dataset.parkingspot;
    let deleteSpotId = event.target.dataset.parkingspotid;
    let deleteTime = event.target.dataset.parkingtime;

    this.deleteSpotArray = [
      {
        label: deleteSpot,
        value: deleteSpotId
      }
    ];

    let bookingTimeValues = deleteTime.split(";"); //seperate the value

    let bookingTimeOptions = bookingTimeValues.map((value) => {
      //map the values seperately
      return {
        label: value,
        value: value
      };
    });
    this.deleteTimeArray = bookingTimeOptions;

    this.showBookingPopup = true;
  }
  customHideBooking() {
    this.showBookingPopup = false;
  }

  customShowModalPopup(event) {
    // get the value of the selected parking spot
    let selectedSpot = event.target.dataset.parkingspot;
    let selectedSpotId = event.target.dataset.parkingspotid;
    let selectedTime = event.target.dataset.parkingtime;
    // set the value of parking spot in the component property
    this.parkingSpot = [
      {
        label: selectedSpot,
        value: selectedSpotId
      }
    ];

    let parkingTimeValues = selectedTime.split(";"); //seperate the value

    let parkingTimeOptions = parkingTimeValues.map((value) => {
      //map the values seperately
      return {
        label: value,
        value: value
      };
    });
    this.parkingTime = parkingTimeOptions; //store the values to be used in the picklist format
    // set the customFormModal property to true to show the modal popup
    this.customFormModal = true;
  }

  customHideModalPopup() {
    //method to hide Logistic object
    this.customFormModal = false;
  }

  saveName(event) {
    //saving data from the UI
    this.name = event.target.value;
  }

  saveSlot(event) {
    //saving data from the UI
    this.slot = event.target.value;
  }

  saveVehicleNumber(event) {
    //saving data from the UI
    this.vehicleNumber = event.target.value;
  }

  saveTime(event) {
    //saving data from the UI
    this.time = event.target.value;
  }

  createObject() {
    //to create logistic object
    createLogisticObject({
      name: this.name,
      slot: this.slot,
      vehicleNumber: this.vehicleNumber,
      timeSlot: this.time
    })
      .then((response) => {
        if (response == "success") {
          //toast code here
        } else {
          //toast code here
        }
        this.customHideModalPopup();
      })
      .catch((error) => {
        console.log("error: logistic not inserted ", error);
        //this.customHideModalPopup();
      });
  }

  deleteTime(event) {
    this.deleteTime = event.target.value;
  }
  // console.log(this.deleteTime);
  deleteSlot(event) {
    this.deleteSlot = event.target.value;
  }
  // console.log(deleteSlot);

  deleteLogisticObject() {
    deleteLogistic({
      timeSlot: this.deleteTime,
      slot: this.deleteSlot
    })
      .then((response) => {
        if (response == "success") {
          //toast code here
        } else {
          //toast code here
        }
        this.customHideBooking();
      })
      .catch((error) => {
        console.log("error: logistic not deleted ", error);
      });
  }
}
