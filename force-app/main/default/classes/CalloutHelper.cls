public with sharing class CalloutHelper {
    public CalloutHelper() {

    }

    public static String postData(String url) {
        String methodType = 'POST';
	
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(methodType);
        request.setEndpoint(url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody('{"cart":["hi", "bye"]"}');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return '';
    }
}