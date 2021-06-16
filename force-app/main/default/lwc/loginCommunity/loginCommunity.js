import { LightningElement } from 'lwc';

export default class LoginCommunity extends LightningElement {
    connectedCallback() {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const username = urlParams.get('username')
        console.log(username);
    }

}