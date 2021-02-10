public with sharing class DateFormatter {
    public DateFormatter() {

    }
    // Method to test    
    public String getFormattedDate(DateHelper helper) {
        return 'Today\'s date is ' + helper.getTodaysDate();
    }
}
