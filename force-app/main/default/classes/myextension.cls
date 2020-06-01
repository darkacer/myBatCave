public with sharing class myextension {
    public myextension(ApexPages.StandardController std) {
        System.debug('@@@@@@hello ' + UserInfo.getUiThemeDisplayed());
    }
}