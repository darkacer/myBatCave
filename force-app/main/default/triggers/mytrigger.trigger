trigger mytrigger on Account (before insert) {
	
    for (Account accdata : trigger.new ) {
        if (accdata.Name == 'mydata') {
            accdata.Type = 'prospect';
            accdata.get('Name');
        }
    }
    system.debug(trigger.new[0].type);
}