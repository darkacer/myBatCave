public without sharing class PushBulletController {
    public PushBulletController() {

    }
    private static Map<String, String> userNameToTelegramId = new Map<String, String>();
    // private static String API_Key = 'bot1238384727:AAHzgCtmK3IayqI6rbHrM5pzXqpMwnrZwnA';
    
    static {
        userNameToTelegramId.put('Omkar Deokar', '662468461');
    }
    @auraEnabled
    public static String sendToTelegram(String text) {
        sendTelegramMessage(text, 'Omkar Deokar');
        return text;
    }

    @future(callout=true)
    public static void sendTelegramMessage(String text, String userName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://api.telegram.org/' + API_Key + '/sendMessage')
        request.setEndpoint('callout:Telegram_Api/sendMessage');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"chat_id": '+ userNameToTelegramId.get(userName) +',"text": "'+ text +'"}');
        system.debug('request: ' + request.getBody());
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
            system.debug('hi more!');
        }
    }
}