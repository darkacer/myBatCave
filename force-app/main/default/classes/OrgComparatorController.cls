public with sharing class OrgComparatorController {

    private static String authUrl = 'https://login.salesforce.com/services/oauth2/authorize';
    private static String tokenUrl = 'https://login.salesforce.com/services/oauth2/token';
    private static String key = '3MVG9d8..z.hDcPIA4C3lokx_dZrfdgqbEqU2WpjsGLuRb2OdZGae.au091r.qrDnujSsd17jrqXCCtiE07qe';
    private static String secret = '4FEEBC0115AA47D80C2BEE5844EF3F98B157FDA78A7C512C68A44EBEBD9DA9BC';
    private static String redirect_uri = '';

    @AuraEnabled
    public static string createAuthUrl(){
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');

        return authUrl;
    }

    public static void authorizeAnOrg() {
        String username = 'omkarde@resilient-goat-4hopaw.com';
        String password = 'resilientGOAT#123';
        String securityToken = '4aUeSrmzn2klgECToiyJzYjSb';

        String clientId = key;
        String clientSecret = secret;

        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password+securityToken;

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');

        req.setEndpoint(tokenUrl);

        HttpResponse res = h.send(req);
        OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        String tempAccess = '123' + objAuthenticationInfo.access_token + '123';
        String left = objAuthenticationInfo.access_token.left(110);
        String right = objAuthenticationInfo.access_token.right(2);
        
        System.debug('auth token ' + objAuthenticationInfo.access_token.length());
        System.debug('auth token ' + left + right);
        System.debug('auth token ' + objAuthenticationInfo.access_token);
        System.debug('full body ' + res.getbody());
        System.debug('temp access token ' + tempAccess);

        Http h1 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer '+objAuthenticationInfo.access_token);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');

        req1.setBody(reqbody);//Send JSON body
        req1.setMethod('POST');
        req1.setEndpoint(tokenUrl);//URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
        HttpResponse res1 = h1.send(req1);
        system.debug('RESPONSE_BODY'+res1 .getbody());

    }


    /*To get aouthentication detail Wrapper*/
    public class OAuth2{
        public String id{get;set;}
        public String issued_at{get;set;}
        public String instance_url{get;set;}
        public String signature{get;set;}
        public String access_token{get;set;}
    }
}