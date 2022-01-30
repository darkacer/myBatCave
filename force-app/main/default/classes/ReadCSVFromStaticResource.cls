public class ReadCSVFromStaticResource {
    private final static Integer slotLength = 10000;
    private final static Integer numberOfSlots = 50;
    private final static String pattern = '\n';
    public static void main() {
        StaticResource defaultResource = [Select s.Body From StaticResource s where s.Name LIKE 'newAuditTRail%'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
        

        String[] filelines = convertStringToArray(contentFile);
        List<String> defaults = new List<String>();
        for(Integer i = 0; i < filelines.size(); i++) {
            String temp = '';
            String[] inputvalues = filelines[i].split(',');
            temp = inputValues[0];
            defaults.add(temp);	
        }
        
        system.debug('defaults ' + defaults.size());
    }
    
    private static List<String> convertStringToArray(String str) {
        List<String> resultArr = new List<String>();
        if(str.length() <= slotLength) {
            return str.split(pattern);
        } else {
            system.debug('string length');
            String p1 = str.substring(0, slotLength);
            String p2 = str.substring(slotLength + 1, str.length() - 1);
            List<String> tempList = p1.split(pattern);
            p2 = tempList[tempList.size() - 1] + p2;
            // String newStr = tempList.remove(tempList.size() - 1);
            tempList.addAll(convertStringToArray(p2));
            return tempList;
        }
    }
}

// https://barclays.webex.com/barclays/j.php?MTID=m74215a6088aa321ab1fbeca6d6eff1b7
// https://barclays.webex.com/barclays/j.php?MTID=mcba560eae59c9c1de36167b752e91920