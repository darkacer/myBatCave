import { LightningElement, track } from "lwc";
import getPermissionSets from "@salesforce/apex/auditTrailController.getPermissionSets";
import getAdutiDetails from "@salesforce/apex/auditTrailController.getAdutiDetails";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
  { label: "Object", fieldName: "objectName", sortable: true },
  { label: "Component Name", fieldName: "fieldName", sortable: true },
  { label: "Description", fieldName: "access", sortable: true },
  {
    label: "Access Indicator",
    cellAttributes: { iconName: { fieldName: "indicator" } },
  },
  { label: "User", fieldName: "user", sortable: true },
  { label: "Date", fieldName: "date", sortable: true },
];

export default class AuditTrail extends LightningElement {
  @track psOptions = [{ label: "--Select Permission Set--", value: "" }];
  @track accessOptions = [
    { label: "All", value: "All" },
    { label: "Increased", value: "increased" },
    { label: "Decreased", value: "decreased" },
    { label: "Removed", value: "removed" },
  ];
  @track typeOptions = [
    { label: "Field Level Access", value: "FLS" },
    { label: "Field Creation", value: "fieldCreate" },
    { label: "Field Deletion", value: "fieldDelete" },
    { label: "Workflow Rules", value: "workFlow" },
    { label: "Validation Rules", value: "validation" },
    { label: "Flows", value: "flows" },
    { label: "Email Alerts", value: "emailAlerts" },
    { label: "Picklists", value: "picklist" },
    { label: "All (Except FLS)", value: "All" },
  ];
  @track error;
  @track auditDetails;
  @track selectedDateRange;
  @track selectedPermissionSet;
  @track selectedAccessFilter;
  @track disableOption = false;
  @track displaySearch = false;
  @track showSpinner = false;
  @track filterText = "";
  @track tableHeight;
  @track actionValue;

  /* Pagination attributes */
  @track page = 1;
  @track startingRecord = 1;
  @track endingRecord = 0;
  @track pageSize = 15;
  @track totalRecountCount = 0;
  @track totalPage = 0;
  @track disableNext;
  @track disablePrevious;

  data;
  tempData;
  columns = columns;
  rowOffset = 0;
  actionValue = "FLS";
  accessLevelValue = "All";
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;

  connectedCallback() {
    this.actionValue = "FLS";
    getPermissionSets()
      .then((result) => {
        for (let key in result) {
          if (result.hasOwnProperty(key)) {
            this.psOptions = [...this.psOptions, { label: key, value: key }];
          }
        }
      })
      .catch((error) => {
        this.showToast(JSON.stringify(error));
      });
  }

  handleDateChange(event) {
    this.selectedDateRange = event.target.value;
  }

  handleAccessChange(event) {
    this.selectedAccessFilter = event.target.value;
    if (typeof this.data !== "undefined") {
      let filterCon =
        this.selectedAccessFilter == "increased"
          ? "utility:jump_to_top"
          : this.selectedAccessFilter == "decreased"
          ? "utility:jump_to_bottom"
          : this.selectedAccessFilter == "removed"
          ? "utility:close"
          : "";

      this.tempData = this.data;
      this.tempData = this.tempData.filter((obj) =>
        Object.keys(obj).some((key) =>
          key === "indicator" ? obj[key].indexOf(filterCon) != -1 : ""
        )
      );
      this.resetPagination();
      this.paginationSet(this.tempData);
    }
  }

  handlePSChange(event) {
    this.selectedPermissionSet = event.target.value;
    this.selectedPermissionSet
      ? (this.displaySearch = true)
      : (this.displaySearch = false);
  }

  handleTypeChange(event) {
    this.actionValue = event.target.value;
    this.template.querySelector('[data-id="accessLevelId"]').value = "All";
    this.actionValue !== "FLS"
      ? (this.disableOption = this.displaySearch = true)
      : this.selectedPermissionSet
      ? ((this.displaySearch = true), (this.disableOption = false))
      : (this.disableOption = this.displaySearch = false);
  }

  handleFilterChange(event) {
    this.tempData = this.data;
    this.filterText = event.target.value.toLowerCase();
    this.tempData = this.tempData.filter((obj) =>
      Object.keys(obj).some((key) =>
        key !== "indicator"
          ? obj[key].toString().toLowerCase().indexOf(this.filterText) != -1
          : ""
      )
    );
    this.resetPagination();
    this.paginationSet(this.tempData);
  }

  searchAudit(event) {
    this.showSpinner = true;
    getAdutiDetails({
      permissionSetName: this.selectedPermissionSet,
      dateFilter: this.selectedDateRange,
      actionType: this.actionValue,
    })
      .then((result) => {
        this.auditDetails = result;
        let currentData = [];
        let options = {
          year: "numeric",
          month: "short",
          day: "numeric",
        };

        result.forEach((data) => {
          let rowData = {};
          rowData.objectName = data.objectName;
          rowData.fieldName = data.fieldName;
          rowData.access = data.access;
          //rowData.indicator = tableIcons + "/images/" + data.indicator + ".png";
          rowData.indicator = data.indicator;
          if (data.auditInstance) {
            rowData.user = data.auditInstance.CreatedBy.Name;
            rowData.date = new Date(
              data.auditInstance.CreatedDate
            ).toLocaleDateString("en-US", options);
          }
          currentData.push(rowData);
        });

        this.data = currentData;
        this.tempData = this.data;
        this.resetPagination();
        this.paginationSet(this.data);
        this.sortedBy = this.sortedBy !== "" ? "" : this.sortedBy;
        this.sortDirection = this.sortDirection !== "" ? "" : this.sortedBy;
        this.filterText = this.filterText !== "" ? "" : this.filterText;
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showToast("1" + JSON.stringify(error));
        this.showSpinner = false;
      });
  }

  paginationSet(tableData) {
    this.totalRecountCount = tableData.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
    this.tempData = tableData.slice(0, this.pageSize);
    this.endingRecord =
      this.totalRecountCount < this.pageSize
        ? this.totalRecountCount
        : this.pageSize;
    this.disablePrevious = true;
    this.disableNext = true;
    if (this.totalPage > this.page) {
      this.disableNext = false;
    }
  }

  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  resetPagination() {
    this.page = 1;
    this.startingRecord = 1;
  }

  //this method displays records page by page
  displayRecordPerPage(page) {
    this.tempData = this.data;
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;
    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.tempData = this.tempData.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;

    if (this.totalPage == 1) {
      this.disablePrevious = true;
      this.disableNext = true;
    } else if (this.page == this.totalPage) {
      this.disablePrevious = false;
      this.disableNext = true;
    } else if (this.page < this.totalPage) {
      this.disablePrevious = this.page == 1 ? true : false;
      this.disableNext = false;
    }
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

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    this.resetPagination();
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.data];
    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.data = cloneData;
    this.paginationSet(this.data);
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
    this.filterText = "";
  }

  exportToCSV() {
    let columnHeader = ["Object", "Field", "Access", "User", "Date"];
    var jsonRecordsData = this.auditDetails;
    let csvIterativeData;
    let csvSeperator;
    let newLineCharacter;
    csvSeperator = ",";
    newLineCharacter = "\n";
    csvIterativeData = "";
    csvIterativeData += columnHeader.join(csvSeperator);
    csvIterativeData += newLineCharacter;

    this.data.forEach(
      (element) =>
        (csvIterativeData +=
          '"' +
          element.objectName +
          '"' +
          csvSeperator +
          '"' +
          element.fieldName +
          '"' +
          csvSeperator +
          '"' +
          element.access +
          '"' +
          csvSeperator +
          '"' +
          element.user +
          '"' +
          csvSeperator +
          '"' +
          element.date +
          '"' +
          newLineCharacter)
    );

    // Creating anchor element to download
    let downloadElement = document.createElement("a");
    downloadElement.href =
      "data:text/csv;charset=utf-8," + encodeURIComponent(csvIterativeData);
    downloadElement.target = "_self";
    downloadElement.download = "Audit Trail Data.csv";
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }
}