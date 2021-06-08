import { LightningElement, track } from 'lwc';
import readFileFromRecord from '@salesforce/apex/ReadFileData.readFileFromRecord';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import sheetjs from '@salesforce/resourceUrl/sheetjs';

let XLS = {};

export default class DataLoader extends LightningElement {
    @track acceptedFormats = ['.xls', '.xlsx'];
    uploadedFile; 
    fileName;
    

    connectedCallback() {
        console.log('hi file updaload component loaded ');
        // this.readFromFile();

        Promise.all([
            // loadScript(this, sheetjs + '/sheetjs/sheetjs.js'),
            loadScript(this, sheetjs + '/sheetjs/sheetmin.js')
          ]).then(() => {
            console.log("loaded sheetminjs ");
            XLS = XLSX
            console.log('xls ', XLS);
            this.readFromFile()
          })
        

    }


    async readFromFile() {
        let returnVal = await readFileFromRecord({recordId:'test'})
        console.log(returnVal);
        let wb = XLS.read(returnVal, {type:'base64', WTF:false});
        console.log(wb);
        console.log(this.to_json(wb));
    }

    to_json(workbook) {
        var result = {};
		workbook.SheetNames.forEach(function(sheetName) {
			var roa = XLS.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
			if(roa.length) result[sheetName] = roa;
		});
		return JSON.stringify(result, 2, 2);
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        console.log(JSON.stringify(uploadedFiles));
        if(uploadedFiles.length > 0) {   
            console.log("File lenght is ", uploadedFiles.length);
        }


    }


}