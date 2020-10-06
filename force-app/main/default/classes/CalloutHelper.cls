public with sharing class CalloutHelper {
    public CalloutHelper() {

    }

    @auraEnabled(cacheable=true)
    public static String postData(String url, String body) {
        String methodType = 'POST';
	
        System.debug('inside postdata helper' + url + body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(methodType);
        request.setEndpoint(url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody(body); 
        
        // request.setBody('"data": ' + body);
        System.debug('request is ->' + request);
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