public class UsefullCode {
    public static void main() {
        String searchKey = '// Constructor 2';
        List<List<SObject>> searchList =[FIND :searchKey IN ALL FIELDS RETURNING ApexClass(id, name, namespaceprefix, body), ApexTrigger(id, name, namespaceprefix, body), ApexPage(id, name, namespaceprefix, markup), ApexComponent(id, name, namespaceprefix, markup)];
        system.debug('result ' + searchList);
    }
    
}