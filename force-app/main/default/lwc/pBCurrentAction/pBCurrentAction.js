import { LightningElement, api } from 'lwc';
import copyPastePage from './copyPaste.html';
import apiPage from './apiPage.html';
import collabEdit from './collabEdit.html';


export default class PBCurrentAction extends LightningElement {
    @api pageType = ''

    render() {
        console.log('myConstant');
        switch (this.pageType) {
            case 'cp':
                return copyPastePage;
            case 'api':
                return apiPage;
            case 'ce':
                return collabEdit;
            default:
                return '';
        }
    }
}