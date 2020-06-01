public class myTryout {
  
    public void myParentMethod() {
        system.debug('hi im inside parent');
    }
    
    public class childClass {
        public void childMethod(myTryout parentObj) {
            parentObj.myParentMethod();
            system.debug('hi im child');
        }
    }
}

/* 
 * 
myTryout.childClass childObj = new myTryout.childClass();
childObj.childMethod(new myTryout());

*/