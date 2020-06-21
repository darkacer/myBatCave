import LightningDatatable from 'lightning/datatable';
import imageController from './imageController.html'
import picklistController from './picklistController.html'
export default class AdvancedDataTable extends LightningDatatable {
    static customTypes = {
        image: {
            template: imageController
        },
        picklist: {
            template: picklistController,
            typeAttributes: ['picklistObjectApiName',
                            'picklistRecordTypeId',
                            'picklistFeildApiName',
                            'picklistSelectedValue']
        }
    };
}