import LightningDatatable from 'lightning/datatable';
import normalPicklist from './normalPicklist.html'

const generateObjValPair = (_dataArray) => {
    return _dataArray.map(el => Object.assign({ value: el, label: el }))
}

const addDependentValues = (_dataArray, data_picklist, dependee) => {
    let count = 0
    return _dataArray.map( item => 
        Object.assign(item, {index: count++}, {dependentValues: generateObjValPair(data_picklist[item[dependee]])})
    )
}
export { generateObjValPair, addDependentValues }

export default class CustomDataTable extends LightningDatatable {

    static customTypes = {
        normalpicklist: {
            template: normalPicklist,
            typeAttributes: [
                'picklistOptions',
                'value',
                'label',
                'index',
                'fieldApiName'
            ]
        }
    };
}