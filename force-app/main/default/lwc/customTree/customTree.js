import { LightningElement, track } from 'lwc';

export default class CustomTree extends LightningElement {
    @track
    inputData = {
        "title" : "paremt title",
        "description" : "   this is a description",
        "children" : [
            {
                "title" : " child title",
                "description" : "   this is a description2",
                "children" : [
                    {
                        "title" : " child title2",
                        "description" : "  this is a description3",
                    }
                ]
            },
            {
                "title" : " child title3",
                "description" : "  this is a description4",
            }
        ]
    };

    
}