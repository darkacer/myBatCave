public class basictoken {
    
    
   // public basictoken() {
        
        final String oauthconsumerkey = '3MVG9d8..z.hDcPIA4C3lokx_da.kqhUy.7WbL4.GebY7UQpI6hT_pDhUakdXJYHDQq6rgUsrOOD98SRwMzd4';
        final String oauthConsumerSecret = '1138742335137717267';
        final String baseUrl = 'https://iambatman.atlassian.net/';
        final String oauthSignatureMethod = 'RSA-SHA1';
        final String oauth_callback = 'http://localhost:8080/';
        String oauthTimestamp;
        String oauthNonce;
        String oauthToken;
        String oauthTokenSecret;
        String accessToken;
        String accessTokenSecret;
        String oauth_signature_method;
   // }
    public void basicAuthCallout() {
        HttpRequest req = new HttpRequest();
        
        String requestMethod = 'POST';
        String oauth_callback = 'https://localhost/';
        //String oauth_consumer_key = '3MVG9d8..z.hDcPIA4C3lokx_da.kqhUy.7WbL4.GebY7UQpI6hT_pDhUakdXJYHDQq6rgUsrOOD98SRwMzd4';
        String oauth_signature_method = 'RSA-SHA1';
        String oauth_timestamp = String.valueOf(DateTime.now().getTime() / 1000);
        String oauth_nonce = String.valueOf(crypto.getRandomLong()) + String.valueOf(Crypto.getRandomLong()) + String.valueOf(Crypto.getRandomLong());
        String url = 'https://iambatman.atlassian.net/plugins/servlet/oauth/request-token';
        Map<String, String> params = new Map<String, String>();
        params.put('oauth_callback', oauth_callback);
        params.put('oauth_timestamp', oauth_timestamp);
        //----------------------------------------------------------
        /*
        String callbackParam = '&oauth_callback=' + EncodingUtil.urlEncode(oauth_callback, 'UTF-8');
        String consumerKeyParam = '&oauth_consumer_key=' + EncodingUtil.urlEncode(oauthconsumerkey, 'UTF-8');
        String signatureMethodParam = '&oauth_signature_method=RSA-SHA1';
        String timestampParam = '&oauth_timestamp=' + EncodingUtil.urlEncode(oauth_timestamp, 'UTF-8');
        String nonceParam = '&oauth_nonce=' + oauth_nonce;
        String versionParam = '&oauth_version=1.0';
        String paramString = consumerKeyParam + nonceParam + signatureMethodParam + timestampParam + versionParam + callbackParam;
		*/
        String callbackParam = EncodingUtil.urlEncode('oauth_callback', 'UTF-8') +'=' + EncodingUtil.urlEncode(oauth_callback, 'UTF-8');
        String consumerKeyParam = '&' + EncodingUtil.urlEncode('oauth_consumer_key', 'UTF-8') + '=' + EncodingUtil.urlEncode(oauthconsumerkey, 'UTF-8');
        String signatureMethodParam = '&'+EncodingUtil.urlEncode('oauth_signature_method', 'UTF-8')+'='+EncodingUtil.urlEncode('RSA-SHA1', 'UTF-8');
        String timestampParam = '&'+EncodingUtil.urlEncode('oauth_timestamp', 'UTF-8')+'=' + EncodingUtil.urlEncode(oauth_timestamp, 'UTF-8');
        String nonceParam = '&'+EncodingUtil.urlEncode('oauth_nonce', 'UTF-8')+'=' + EncodingUtil.urlEncode(oauth_nonce, 'UTF-8');
        String versionParam = '&' + EncodingUtil.urlEncode('oauth_version', 'UTF-8') + '=' +EncodingUtil.urlEncode('1.0', 'UTF-8');
        String paramString = callbackParam + consumerKeyParam + nonceParam + signatureMethodParam + timestampParam + versionParam;
        
     
        
        
        String baseString = requestMethod + '&' + EncodingUtil.urlEncode(baseUrl,'UTF-8') + '&' + EncodingUtil.urlEncode(paramString,'UTF-8');
        System.debug(baseString);   
        String signingKey = EncodingUtil.urlEncode(this.oauthConsumerSecret,'UTF-8') + '&';
           if(params.containsKey('oauth_token') && String.isNotBlank(this.oauthTokenSecret)){
               signingKey += EncodingUtil.urlEncode(this.oauthTokenSecret,'UTF-8');
           }   
           
           Blob data = Crypto.generateMac('hmacSHA1', Blob.valueOf(baseString), Blob.valueOf(signingKey));
           //String oauth_signature =  EncodingUtil.base64Encode(data);
        String oauth_signature =  EncodingUtil.urlEncode(EncodingUtil.base64Encode(data), 'UTF-8');
        System.debug(oauth_signature);
        
        url = url + '?&oauth_consumer_key=' + oauthconsumerkey + 
            		'&oauth_signature_method=' + oauth_signature_method + 
            		'&oauth_timestamp=' + oauth_timestamp +
            		'&oauth_nonce=' + oauth_nonce 
            		+ '&oauth_signature=' + oauth_signature
            		;
             req.setEndpoint(url);
             req.setMethod('POST');
        	 Http http = new Http();
             HTTPResponse res = http.send(req);
           String status = res.getStatus();
           System.debug(status);
             System.debug(res.getBody());
    }
    
      
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
}
}