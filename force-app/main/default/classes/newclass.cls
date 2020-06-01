public class newclass {
    public boolean isLightning (){  
        if(Apexpages.currentPage().getUrl().contains('lightning')) {
            return true;
        }
        else 
            return false;
    }
}