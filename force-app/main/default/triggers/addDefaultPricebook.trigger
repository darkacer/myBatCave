trigger addDefaultPricebook on Opportunity (before insert) {
        List<Pricebook2> stdPBL =  [select id from Pricebook2 where Name = 'test'];
        if(!stdPBL.isEmpty()){
            for(Opportunity o: Trigger.new)
                 o.PriceBook2Id = stdPBL[0].id;
  }
}