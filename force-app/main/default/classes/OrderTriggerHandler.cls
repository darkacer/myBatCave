public class OrderTriggerHandler {
    
    private static Map<String, String> userNameToTelegramId = new Map<String, String>();
    // private static String API_Key = 'bot1238384727:AAHzgCtmK3IayqI6rbHrM5pzXqpMwnrZwnA';
    
    static {
        userNameToTelegramId.put('Omkar Deokar', '662468461');
    }
    public static void beforeInsertTrigger(List<Order> newOrders) {
        updatePriceBook(newOrders);
	}
    
    public static void afterUpdateTrigger(List<Order> newOrders, Map<Id, Order> oldMap) {
        makeCallout(newOrders, oldMap);
    }
    
    
    private static void updatePriceBook(List<Order> newOrders) {
        Pricebook2 pbe = [Select Id From Pricebook2 Where IsActive = true and IsStandard = false limit 1];
        if (pbe == null) return;
        for(Order order : newORders) {
            order.Pricebook2Id = pbe.Id;
        }
    }
    
    
    private static void makeCallout(List<Order> newOrder, Map<Id, Order> oldMap) {
        User usr = [Select Id, Name From User Where Id = : userinfo.getUserId() limit 1];
        for(Order order : newOrder) {
            if(order.Status != oldMap.get(order.Id).Status && order.Status == 'Shipped') {
                autoLaunchFlow(order.OrderNumber, usr.Name);
                sendTelegramMessage(order.OrderNumber, usr.Name);
            }
        }
    }
    
    @future(callout=true)
    public static void sendTelegramMessage(String orderId, String userName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telegram_Api/sendMessage');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"chat_id": '+ userNameToTelegramId.get(userName) +',"text": " Your Order is Shipped, OrderId - '+orderId+'"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    }
    
    @future
    private static void autoLaunchFlow(String orderId, String userName) {
        Map<String, Object> inputs = new Map<String, Object>();
        String flowName = 'test_deleteme';
        inputs.put('orderId', orderId);
        inputs.put('UserName', userName);
        Flow.Interview myFlow = Flow.Interview.createInterview(flowName, inputs);
        myFlow.start();
    }
}