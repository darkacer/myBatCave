import LightningDatatable from 'lightning/datatable';
import imageController from './imageController.html'

export default class AdvancedDataTable extends LightningDatatable {
    static customTypes = {
        image: {
            template: imageController
        }
    };
}