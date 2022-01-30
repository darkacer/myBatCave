@istest
public class testingClass extends childClass {
    @istest
    public static void testParentChild() {
        
        childInnerClass ch = new childInnerClass();
        ch.updateCount(5);
        // ch.innerPrintCount();
        
        
    }
}

// childClass = f2fBEMIntegration
// parentClass = f2fIntegrationVrtCls
// childInnerClass = bemService
// parentInnerClass = httpService
// updateCount = callout_istest