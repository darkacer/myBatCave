public with sharing class DateHelper {
    public DateHelper() {

    }

    public String getTodaysDate() {
        return Date.today().format();
    }
}
