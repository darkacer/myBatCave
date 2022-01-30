public virtual class parentClass {
    /*
    public Integer count = 0;
    
    public void updateCount(Integer count_new) {
        count = count_new;
    }
*/
    
    public virtual class parentInner {
        public Integer count;
        
        public void updateCount(Integer count_new) {
            count = count_new;
        }
    }
    
}