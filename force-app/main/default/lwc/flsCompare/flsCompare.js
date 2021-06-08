import { LightningElement, track } from "lwc";
import getFieldLevelPermissions from "@salesforce/apex/permissionSetController.getPermissionInfo";
import getAllObjects from "@salesforce/apex/permissionSetController.getAllObjects";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PermissionSet extends LightningElement {
  @track accessOptions = [
    { label: "All", value: "" },
    { label: "Read Only", value: "readonly" },
    { label: "Read/Edit", value: "edit" },
    { label: "No Access", value: "noaccess" },
  ];

  @track obtectTypeOptions = [
    { label: "Standard", value: "Standard" },
    { label: "Custom", value: "Custom" },
  ];

  allFields;
  tableData;
  permissionSets;
  @track values = [];
  @track selectedsobject;
  @track filterText = "";
  @track isItemExists = false;
  @track showSpinner = false;
  @track permissionType = false;
  @track permissionTypeFilter = false;
  @track allObjects;
  @track sobjectoptions = [{ label: "--Select Object--", value: "" }];
  @track selectedItemsToDisplay = "";
  @track psHeaderColSpan;
  @track objectType;

  connectedCallback() {
    this.acessvalue = "";
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

  handleobjectTypeFilter(event) {
    this.objectType = event.target.value;
    this.selectedsobject = "";
    this.filterObjects();
  }

  filterObjects() {
    this.sobjectoptions = this.allObjects;
    this.sobjectoptions = this.sobjectoptions.filter((obj) =>
      this.objectType == "Custom"
        ? obj.value.indexOf("__") != -1
        : obj.value.indexOf("__") == -1
    );
  }

  handleFLSFilter(event) {
    let selectedAccessFilter = event.target.value;
    this.tableData = this.allFields;
    if (selectedAccessFilter === "noaccess") {
      this.tableData = this.tableData.filter((el) =>
        el.fieldPermissionsInfo.every((key) => key.PermissionsRead === false)
      );
    } else {
      this.tableData = this.tableData.filter((el) =>
        el.fieldPermissionsInfo.some((key) =>
          selectedAccessFilter === "readonly"
            ? key.PermissionsEdit === false && key.PermissionsRead === true
            : selectedAccessFilter === "edit"
            ? key.PermissionsEdit === true
            : true
        )
      );
    }
  }

  handleFieldSearch(event) {
    this.tableData = this.allFields;
    let filterText = event.target.value.toLowerCase();
    this.tableData = this.tableData.filter((el) =>
      Object.keys(el).some((key) =>
        key === "fieldInfo"
          ? Object.entries(el[key])
              .toString()
              .toLowerCase()
              .indexOf(filterText) != -1
          : ""
      )
    );
  }

  handleCheckType(event) {
    this.permissionTypeFilter = event.target.checked;
  }

  handleobjectFilter(event) {
    this.selectedsobject = event.target.value;
  }

  searchFLS() {
    this.showSpinner = true;
    if (!this.selectedsobject && !this.permissionTypeFilter) {
      this.showToast("Please select the Object");
      this.showSpinner = false;
      return;
    } else if (!this.values.length > 0) {
      this.showToast("Please select at least one Permission Set");
      this.showSpinner = false;
      return;
    }
    getFieldLevelPermissions({
      permissionSetIds: JSON.stringify(this.values),
      isSystemPermission: this.permissionTypeFilter,
      objectName: this.selectedsobject,
    })
      .then((data) => {
        this.allFields = data;
        this.tableData = data;
        let psSet = [];
        data.forEach((result) => {
          if (result.fieldPermissionsInfo) {
            result.fieldPermissionsInfo.forEach((inneresult) => {
              psSet.push(inneresult.ParentName);
            });
          }
        });
        this.permissionSets = [...new Set(psSet)];
        this.permissionType = this.permissionTypeFilter;
        this.psHeaderColSpan = this.permissionSets.length;
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        this.showToast(error.message);
      });
  }

  selectItemEventHandler(event) {
    let args = JSON.parse(JSON.stringify(event.detail.arrItems));
    this.displayItem(args);
  }

  deleteItemEventHandler(event) {
    let args = JSON.parse(JSON.stringify(event.detail.arrItems));
    this.displayItem(args);
  }

  displayItem(args) {
    this.values = [];
    args.map((element) => {
      this.values.push(element);
    });

    this.isItemExists = args.length > 0;
    this.selectedItemsToDisplay = this.values.join(", ");
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

  exportToCSV() {
    let columnHeader = ["Field Name", "Field API Name", "Field Type"];
    columnHeader = [...columnHeader, this.permissionSets];
    var jsonRecordsData = this.allFields;
    let csvIterativeData;
    let csvSeperator;
    let newLineCharacter;
    csvSeperator = ",";
    newLineCharacter = "\n";
    csvIterativeData = "";
    csvIterativeData += columnHeader.join(csvSeperator);
    csvIterativeData += newLineCharacter;

    this.allFields.forEach(
      (element) =>
        (csvIterativeData +=
          '"' +
          element.fieldInfo.fieldLabel +
          '"' +
          csvSeperator +
          '"' +
          element.fieldInfo.fieldAPIName +
          '"' +
          csvSeperator +
          '"' +
          element.fieldInfo.fieldType +
          '"' +
          csvSeperator +
          '"' +
          this.flsInfo(element) +
          newLineCharacter)
    );

    // Creating anchor element to download
    let downloadElement = document.createElement("a");
    downloadElement.href =
      "data:text/csv;charset=utf-8,%EF%BB%BF" +
      encodeURIComponent(csvIterativeData);
    downloadElement.target = "_self";
    downloadElement.download = "FLS Compare.csv";
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  flsInfo(elem) {
    let val = '"';
    elem.fieldPermissionsInfo.forEach(
      (el) =>
        (val +=
          (el.PermissionsEdit
            ? this.permissionType
              ? "True"
              : "Edit"
            : el.PermissionsRead
            ? "Read"
            : "X") + ",")
    );
    return val.substring(0, val.length - 1);
  }
}