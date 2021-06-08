import { LightningElement, api, track } from "lwc";
import retrieveRecords from "@salesforce/apex/MultiSelectLookupController.retrieveRecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

let i = 0;
export default class LwcMultiSelectLookup extends LightningElement {
  @track globalSelectedItems = []; //holds all the selected checkbox items
  //start: following parameters to be passed from calling component
  @api labelName;
  @api objectApiName; // = 'Contact';
  @api fieldApiNames; // = 'Id,Name';
  @api filterFieldApiName; // = 'Name';
  @api iconName; // = 'standard:contact';
  @api placeholder = "Search...";
  @api maxSelection = 10;
  //end---->
  @track items = []; //holds all records retrieving from database
  @track selectedItems = []; //holds only selected checkbox items that is being displayed based on search

  //since values on checkbox deselection is difficult to track, so workaround to store previous values.
  //clicking on Done button, first previousSelectedItems items to be deleted and then selectedItems to be added into globalSelectedItems
  @track previousSelectedItems = [];
  @track value = []; //this holds checkbox values (Ids) which will be shown as selected
  searchInput = ""; //captures the text to be searched from user input
  isDialogDisplay = false; //based on this flag dialog box will be displayed with checkbox items
  isDisplayMessage = false; //to show 'No records found' message

  //This method is called when user enters search input. It displays the data from database.
  onchangeSearchInput(event) {
    this.searchInput = event.target.value;
    if (this.searchInput.trim().length > 0) {
      //retrieve records based on search input
      retrieveRecords({
        objectName: this.objectApiName,
        fieldAPINames: this.fieldApiNames,
        filterFieldAPIName: this.filterFieldApiName,
        strInput: this.searchInput,
      })
        .then((result) => {
          this.items = []; //initialize the array before assigning values coming from apex
          this.value = [];
          this.previousSelectedItems = [];

          if (result.length > 0) {
            result.map((resElement) => {
              //prepare items array using spread operator which will be used as checkbox options
              this.items = [
                ...this.items,
                { value: resElement.recordId, label: resElement.recordName },
              ];

              /*since previously choosen items to be retained, so create value array for checkbox group.
                            This value will be directly assigned as checkbox value & will be displayed as checked.
                        */
              this.globalSelectedItems.map((element) => {
                if (element.value == resElement.recordId) {
                  this.value.push(element.value);
                  this.previousSelectedItems.push(element);
                }
              });
            });
            this.isDialogDisplay = true; //display dialog
            this.isDisplayMessage = false;
          } else {
            //display No records found message
            this.isDialogDisplay = false;
            this.isDisplayMessage = true;
          }
        })
        .catch((error) => {
          this.error = error;
          this.items = undefined;
          this.isDialogDisplay = false;
        });
    } else {
      this.isDialogDisplay = false;
    }
  }

  //This method is called during checkbox value change
  handleCheckboxChange(event) {
    let selectItemTemp = event.detail.value;

    //all the chosen checkbox items will come as follows: selectItemTemp=0032v00002x7UE9AAM,0032v00002x7UEHAA2
    console.log(" handleCheckboxChange  value=", event.detail.value);
    this.selectedItems = []; //it will hold only newly selected checkbox items.

    /* find the value in items array which has been prepared during database call
           and push the key/value inside selectedItems array           
        */
    selectItemTemp.map((p) => {
      let arr = this.items.find((element) => element.value == p);
      //arr = value: "0032v00002x7UEHAA2", label: "Arthur Song
      if (arr != undefined) {
        this.selectedItems.push(arr);
      }
    });
  }

  //this method removes the pill item
  handleRemoveRecord(event) {
    const removeItem = event.target.dataset.item; //"0032v00002x7UEHAA2"

    //this will prepare globalSelectedItems array excluding the item to be removed.
    this.globalSelectedItems = this.globalSelectedItems.filter(
      (item) => item.value != removeItem
    );
    const arrItems = this.globalSelectedItems;

    //initialize values again
    this.initializeValues();
    this.value = [];

    this.placeholder =
      "Selected " + this.globalSelectedItems.length + " records";

    //propagate event to parent component
    const evtCustomEvent = new CustomEvent("remove", {
      detail: { removeItem, arrItems },
    });
    this.dispatchEvent(evtCustomEvent);
  }

  handleClearClick(event) {
    this.globalSelectedItems = [];
    this.selectedItems = [];
    this.value = [];
    const arrItems = this.globalSelectedItems;
    this.placeholder =
      "Selected " + this.globalSelectedItems.length + " records";

    this.initializeValues();
    //propagate event to parent component
    const evtCustomEvent = new CustomEvent("retrieve", {
      detail: { arrItems },
    });
    this.dispatchEvent(evtCustomEvent);
  }

  //Done dialog button click event prepares globalSelectedItems which is used to display pills
  handleDoneClick(event) {
    //remove previous selected items first as there could be changes in checkbox selection
    this.previousSelectedItems.map((p) => {
      this.globalSelectedItems = this.globalSelectedItems.filter(
        (item) => item.value != p.value
      );
    });

    //now add newly selected items to the globalSelectedItems
    this.globalSelectedItems.push(...this.selectedItems);
    const arrItems = this.globalSelectedItems;

    if (arrItems.length > this.maxSelection) {
      this.globalSelectedItems = this.previousSelectedItems;
      const event = new ShowToastEvent({
        title: "Maximum selections reached!",
        message: "Only  " + this.maxSelection + " selections are allowed",
        variant: "error",
        mode: "pester",
      });
      this.dispatchEvent(event);
    } else {
      //store current selection as previousSelectionItems
      this.previousSelectedItems = this.selectedItems;
      this.initializeValues();

      //propagate event to parent component
      const evtCustomEvent = new CustomEvent("retrieve", {
        detail: { arrItems },
      });
      this.dispatchEvent(evtCustomEvent);

      this.placeholder = "Selected " + arrItems.length + " records";
    }
  }

  //Cancel button click hides the dialog
  handleCancelClick(event) {
    this.initializeValues();
  }

  //this method initializes values after performing operations
  initializeValues() {
    this.searchInput = "";
    this.isDialogDisplay = false;
  }
}