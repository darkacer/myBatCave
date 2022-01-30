public class JWT {
    
    public String alg {get;set;}
    public String iss {get;set;}
    public String sub {get;set;}
    public String aud {get;set;}
    public String exp {get;set;}
    public String iat {get;set;}
    public Map<String,String> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
    public String privateKey {get;set;}
    
    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';
    
    public JWT(String alg) {
        this.alg = alg;
        this.validFor = 3600;
    }
    
    public String assertion() {
        
        String jwt = '';
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ', 'JWT');
        header.writeStringField('kid', 'paymentsapply_jwks_sit');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('sub', this.sub);
        body.writeStringField('aud', this.aud);
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        if ( this.alg == HS256 ) {
            Blob key = EncodingUtil.base64Decode(privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);  
        } else if ( this.alg == RS256 ) {
            Blob signature = null;
            
            if (cert != null ) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
            }
            jwt += '.' + base64URLencode(signature);  
        } else if ( this.alg == NONE ) {
            jwt += '.';
        }
        return jwt;
    }
    
    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
}


/*

{
  "content-length": "364",
  "authorization": "Bearer eyJraWQiOiJhMTlPSlR5aVlKOXhPM3FoWnhWeE1KZE5ZNXJ4cUhpQzBSTUY0TWRheGtjIiwiYWxnIjoiUlMyNTYifQ.eyJqdGkiOiI5YWJiNzIyMGY4OTE4YjRlOTcwMjYzZDM3NDAzY2JjYzIxOTM2MDBiYTA3ZjBhZjM5OGMyOTJiMDlkNTEwNGNiIiwiaWF0IjoxNjMxNjk1NTMzLCJleHAiOjE2MzE3Mzg3MzMsInN1YiI6IjYwMDA1ZTVhNGRjY2ZhODk1NmE5YzBiZTM4N2QzMGZjZDIzNDhkOTk2OTYwOWIzNjEzMWIwYTA3ZTlhZTg0YzMiLCJjbGllbnRfaWQiOiI2MDAwNWU1YTRkY2NmYTg5NTZhOWMwYmUzODdkMzBmY2QyMzQ4ZDk5Njk2MDliMzYxMzFiMGEwN2U5YWU4NGMzIiwic2NvcGUiOiJjbGllbnQ6YmFyY2xheWNhcmRfb25ib2FyZGluZ19zdGF0dXNfd2ViaG9vazp3cml0ZSIsImF1dGguZnJlc2hib29rcy5jb20vc3ViX3R5cGUiOiJjbGllbnQifQ.vc_oK1Da4rn2Yy_AG5XbDQIQe3Zq7LUJU4Aw6k64SnewpT1C6-yOWf7rJcx4YZZh_Imkxhq2r6n85xAhsjkiWg33Trc7fe58staroEyz3mxEzbY7U6dp5P5XNiVFU2fyI3zHxY5CAFBek28-a4K8Y5yy9Q_vLbNfp5Pr9azs94JGALnNuxosnE-K-dQlSBIhQ3mGjmsAN8wxG0U2dLhaWEBki8yuL32lUfGuYv6xuZLAVLONi1dt6LDaLIT8xssa-uYedsHUz4OlUbyqyQwcRCB_sX1RjXKnqnOH8X6kpc4rw31rn-PhiSqQZImYPefVOZfuPusdjxwjxHhKg7Reag",
  "user-agent": "SFDC-Callout/52.0",
  "x-signature": "eyJraWQiOiJwYXltZW50c2FwcGx5X2p3a3Nfc2l0IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL3d3dy5iYXJjbGF5cy5jb20iLCJzdWIiOiJvbmJvYXJkaW5nX3N0YXR1c193ZWJob29rwqAiLCJhdWQiOiJodHRwczovL2F1dGguc3RhZ2luZy5mcmVzaGVudi5jb20vb2F1dGgvdG9rZW4iLCJuYmYiOjE2MzE2OTU1MzQsImlhdCI6MTYzMTY5NTUzNCwiZXhwIjoxNjMxNjk5MTM0fQ.O-mMp-bOqssqpTWU97FbAcpVbL8p49thcX6VUhicUKhH5H0zuU8wMCisKYTbt8lUof0v6DJdXcM_Gx45CyLfXvmy7pTT9RkQ2h7E8mljmYzjj0YmstwrSq_OKmVOZyPLukNpEqWxWDa1ps1_5EVeRC9gvDd98XJbI7XcdfbjC3q8VqMbGQxGNl3KO2j7aSfC7Ir4V56pF2kEnAHizTp58HpEZJrrLJzLFJYDl5kDvAnaoYpQJ2YwMuI1EZGUMobCgM22ZGyGW00vlPwOUzs-AUNiYJ40lMSGMCRhrstmuTiPG1p-65dj3s9H7Ci7JkpsT_ZLVsk8gvLd3rEYFFfcig",
  "content-type": "application/json",
  "cache-control": "no-cache",
  "pragma": "no-cache",
  "accept": "text/html, image/gif, image/jpeg, *; q=.2, /*; q=.2"
}

*/