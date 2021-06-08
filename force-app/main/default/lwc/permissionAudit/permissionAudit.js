import { LightningElement, track } from "lwc";
import getObjectFields from "@salesforce/apex/permissionAuditController.getObjectFields";
import getAllObjects from "@salesforce/apex/permissionAuditController.getAllObjects";
import getAccessDetails from "@salesforce/apex/permissionAuditController.getAccessDetails";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PermissionAudit extends LightningElement {
  @track obtectTypeOptions = [
    { label: "Standard", value: "Standard" },
    { label: "Custom", value: "Custom" },
  ];
  @track sobjectoptions = [{ label: "--Select Object--", value: "" }];
  @track fieldOptions = [{ label: "--Select Field--", value: "" }];

  allData;
  tableData;
  @track showSpinner = false;
  @track allObjects;
  @track fieldvalue;
  @track objectType;
  @track objectFields;
  @track selectedField;
  @track showSpinner = false;
  @track selectedsobject;

  connectedCallback() {
    this.fieldvalue = "";
    this.objectType = "Custom";
    this.showSpinner = true;
    this.getObjectsInfo();
  }

  getObjectsInfo() {
    getAllObjects()
      .then((result) => {
        result.forEach((obj) => {
          this.sobjectoptions = [
            ...this.sobjectoptions,
            {
              label: obj.objectLabel,
              value: obj.objectName,
            },
          ];
        });
        this.allObjects = this.sobjectoptions;
        this.filterObjects();
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        this.showToast(error.message);
      });
  }

  getFieldInfo() {
    getObjectFields({
      objectName: this.selectedsobject,
    })
      .then((result) => {
        result.forEach((obj) => {
          this.fieldOptions = [
            ...this.fieldOptions,
            {
              label: obj.fieldLabel,
              value: obj.fieldName,
            },
          ];
        });
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        this.showToast(error.message);
      });
  }

  filterObjects() {
    this.sobjectoptions = this.allObjects;
    this.sobjectoptions = this.sobjectoptions.filter((obj) =>
      this.objectType == "Custom"
        ? obj.value.indexOf("__") != -1
        : obj.value.indexOf("__") == -1
    );
  }

  handleobjectTypeFilter(event) {
    this.objectType = event.target.value;
    this.selectedsobject = "";
    this.fieldvalue = "";
    this.filterObjects();
  }

  handleFieldSelect(event) {
    this.selectedField = event.target.value;
  }

  handleobjectFilter(event) {
    this.selectedsobject = event.target.value;
    this.showSpinner = true;
    this.fieldOptions = [{ label: "--Select Field--", value: "" }];
    this.getFieldInfo();
  }

  fetchDetails() {
    if (!this.selectedsobject) {
      this.showToast("Please select the Object");
      this.showSpinner = false;
      return;
    }
    this.showSpinner = true;
    getAccessDetails({
      objectName: this.selectedsobject,
      fieldName: this.selectedField,
    })
      .then((data) => {
        this.allData = data;
        this.tableData = data;
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        this.showToast(error.message);
      });
  }

  showToast(msg) {
    const event = new ShowToastEvent({
      title: "Error",
      message: msg,
      variant: "error",
      mode: "dismissable",
    });
    this.dispatchEvent(event);
  }
}