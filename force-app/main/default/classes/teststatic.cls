public class teststatic {
    public static String mystr = '';
    public teststatic () {
       mystr = mystr +'me \n';
    }
    // this is new 
    
    
    public String myfuction (String str ) {
        mystr = mystr + str;
        System.debug(mystr);
        return mystr;
    }
}