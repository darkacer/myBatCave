import { LightningElement, track } from 'lwc';
import findRecords from '@salesforce/apex/LWCController.getRecordList';

const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'name',
        label: 'Account Name'
    },
    {
        type: 'text',
        fieldName: 'identifier',
        label: 'identifier',
    },
    {
        type: 'text',
        fieldName: 'parent',
        label: 'parent',
    },
    {
        type: 'text',
        fieldName: 'value',
        label: 'value',
    },
];
export default class DisplayTreeGrid extends LightningElement {
    searchKey = '';
    parentName = 'custom_parent__c';
    label = 'Name';
    @track gridData = [];
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
    @track gridExpandedRows = [];
    get itemsLength() {
        return this.gridData.length;
    }

    connectedCallback() {
        this.searchKey = 'abcs';
        findRecords({ queryString: this.searchKey })
        .then(result => {
            console.log('result', result);
            this.processData(result);
        }).catch(error => {
            console.log('error', error);
        });
    }

    processData(data) {
        let childToParentMap = {};
        let idToRecordMap = {};
        data.forEach(record => {
            console.log('record', record);
            if (record[this.parentName]) {
                childToParentMap[record.Id] = record[this.parentName];
                this.gridExpandedRows.push(record['Name']);
            }
            idToRecordMap[record.Id] = record;
        });

        // create parent to child Map
        let parentToChildMap = {};
        data.forEach(record => {
            if(!parentToChildMap.hasOwnProperty(record[this.parentName])) {
                parentToChildMap[record[this.parentName]] = [];
            }
            parentToChildMap[record[this.parentName]].push(record);
        });
        // this.items.push(this.generateTree(parentToChildMap, idToRecordMap, parentToChildMap['undefined'][0].Id));
        this.gridData.push(this.generateTableTree(parentToChildMap, idToRecordMap, parentToChildMap['undefined'][0].Id));
    }

    generateTableTree(parentToChildMap, idToRecordMap, elementId) {
        let record = idToRecordMap[elementId];
        let temp = {
           name: record['Name'],
           identifier: record['Identifier__c'],
           value: record['Value__c'],
           parent: (record['custom_parent__r'] && record['custom_parent__r']['Name'] ? record['custom_parent__r']['Name'] : 'undefined'),
           _children:[]
        }
        if(parentToChildMap.hasOwnProperty(elementId) && parentToChildMap[elementId] && parentToChildMap[elementId].length > 0) {
            parentToChildMap[elementId].forEach(child => {
                temp._children.push(this.generateTableTree(parentToChildMap, idToRecordMap, child.Id));
            });
        }
        return temp;
    }
}