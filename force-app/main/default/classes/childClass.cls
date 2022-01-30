public virtual class childClass extends parentClass {
	/*
    public void printCount() {
        system.debug('count in chid is ' + count);
    }
	*/
    
    public virtual class childInnerClass extends parentInner {
        public void innerPrintCount() {
            system.debug('count in inner child is ' + count);
        }
    }
}