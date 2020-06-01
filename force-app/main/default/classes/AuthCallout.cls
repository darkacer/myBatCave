public class AuthCallout {
 
       public void basicAuthCallout(){
           
            String username = 'omkarde@cybage.com';
             String password = 'atlassian#123';
             HttpRequest req = new HttpRequest();
             //req.setEndpoint('https://iambatman.atlassian.net/rest/api/2/issue/MS-13');
           req.setEndpoint('https://iambatman.atlassian.net/rest/api/2/search');
            
             req.setMethod('GET');

            
          
             Blob headerValue = Blob.valueOf(username + ':' + password);
             String authorizationHeader = 'Basic ' + 'b21rYXJkZUBjeWJhZ2UuY29tOmF0bGFzc2lhbiMxMjM=';
           System.debug(authorizationHeader);
             req.setHeader('Content-Type', 'application/json');
             req.setHeader('Authorization', authorizationHeader);
			// req.setheader('Accept', '*/*');
          
             Http http = new Http();
             HTTPResponse res = http.send(req);
           String status = res.getStatus();
           System.debug(status);
             System.debug(res.getBody());
           
           String JSONContent = res.getBody();
           JSONParser parserJira = JSON.createParser(JSONContent);
       }
}