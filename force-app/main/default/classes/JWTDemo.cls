public class JWTDemo {
    //public static FINAL STRING END_POINT = 'https://api.einstein.ai/v2/oauth2/token';
    public static void getNewJWT() {
        
        // Get a new token
        JWT jwt = new JWT('RS256');
        jwt.cert = 'test_new'; 
        jwt.iss = 'developer.force.com';
        jwt.sub = 'youremail@gmail.com';
        jwt.aud =  'END_POINT';
        jwt.exp = '3600';
        
        String jwtString = jwt.assertion();
        
        system.debug('jwtString ' + jwtString);
    }
    
    private static String getTempJWT() {
        // this demo key is generated from jwt io using certificates located at 
        // E:\Omkar\Tryout\openSSL
        // 
        /* 
         * 	{
              "alg": "RS256",
              "typ": "JWT"
            }
             {
          "sub": "1234567890",
          "name": "John Doe",
          "admin": true,
          "iat": 1516239022
        }

*/
        return 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.nPo74YJqxbciiFkcKtXG-u-u4AzlQeDIl_fZcyqtAta3nWt2ewMqDHNCTBM2FCpocE1GAT6d34gltHazWQR8OA488jEeJoaVBwXafuoP9SD6aAu6MOxv9Jhr3iZIqIEcfx0QaHdkKFd6yg8V2UyvmaESbciQHN8gRzIoD4qnsd9XuxvLI1ga69XU2OUvI-KrTQzg7XJgcbTfODeZsU4lFsRRX7b8Suiewd9zqv0D0LDX3ll7wkoQXYUrm41ZHmjJ2NFwNKnprJ9if-nrlMz1mDB_-Vke2FhnlaNNCSBjNhQE2Z7JSTzcqdkXlupbW2wp9scycTaj_vh1aA52rLXB6g';
    }
    
    private static Map<String,String> prepareheaders() {
        String jwt = getTempJWT();
        return new Map<String, String>{
            'Authorization' => 'Bearer {!$Credential.OAuthToken}', 
            'x-signature' => jwt
        };
    }
    
    public static void testCall() {
        HttpResponse resp1 = callApi('callout:ibm_org/services/data/v51.0', prepareheaders(), null, 'GET', 'test_new', 'Blob');
        system.debug('response ' + resp1.getBody());
    }
    
    public static HttpResponse callApi(String endpoint, Map<String, String> headers, String reqObj, string reqType, String certName, string reqFormat) {
        Http h = new http();
        HttpRequest req = new HttpRequest();
        
        if(reqObj != null) { 
            if(reqFormat.equalsIgnoreCase('Blob')) {
                req.setBodyAsBlob(Blob.valueOf(reqObj));
            } else {
                req.setBody(reqObj);
            }
        }
        system.debug('header keyset' + headers.keyset());
        for(String head : headers.keySet()) {
            req.setHeader(head, headers.get(head));
            system.debug(head +'key value' + headers.get(head));
        }
        if(certName != null) {
            req.setClientCertificateName(certName);
        }
        req.setTimeout(120000);
        req.setMethod(reqType);
        req.setEndpoint(endpoint);
        system.debug('request = ' + JSON.serialize(headers));
        
        HttpResponse resp = h.send(req);
        system.debug('###response ' + resp);
        return resp;
        
    }
    
    public static void tryOutNamedCredWithoutJWT() {
        Http h = new http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:ibm_org/services/data/v51.0';
        String reqType = 'GET';
        
        req.setMethod(reqType);
        req.setEndpoint(endpoint);
        //system.debug('request = ' + JSON.serialize(headers));
        
        HttpResponse resp = h.send(req);
        system.debug('###response ' + resp);
        system.debug('###response ' + resp.getBody());
    }
    
    @future(callout=true)
    private static void deleteMe() {
        Auth.JWt jws = new Auth.Jwt();
    }
    
    public static void callFreeApi() {
        
        
        
        Http h = new http();
        HttpRequest req = new HttpRequest();
        String endPoint = 'callout:darkacer_free_beeceptor/my/api/path';
        String reqType = 'GET';
        
        req.setMethod(reqType);
        req.setEndpoint(endpoint);
        //system.debug('request = ' + JSON.serialize(headers));
        deleteMe();
        HttpResponse resp = h.send(req);
        
        system.debug('###response ' + resp);
        system.debug('###response ' + resp.getBody());
    }
}


// https://barclays.webex.com/barclays-en/j.php?MTID=m25235820e28e132a0a9c34279fcd2ded
// 
// https://eur01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fbarclays.webex.com%2Fbarclays%2Fj.php%3FMTID%3Dm008b288d6c9629d437f8137edf2dca2b&data=04%7C01%7Ctejas.deshpande%40barclays.com%7C34718c2e02be4a9d795408d9a9097239%7Cc4b62f1d01e04107a0cc5ac886858b23%7C0%7C0%7C637726680293563322%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&sdata=mu%2Fn%2BMng4%2Ft2qxR4szCXt83p05JHbqQeseqYA%2FgT7%2B4%3D&reserved=0