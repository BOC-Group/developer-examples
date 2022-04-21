package devportal.util;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

public class JWTUtil
{  
  public static String createJWTWithClaims (String sSecret, String sUserName, String sForename, String sSurname, String sIssuer, long nTTL)
  {
    //The JWT signature algorithm we will be using to sign the token
    SignatureAlgorithm aSignatureAlgorithm = SignatureAlgorithm.HS256;

    long nNow = System.currentTimeMillis();

    // Sign our JWT with the secret
    byte[] aAPIKeySecretBytes = DatatypeConverter.parseBase64Binary (sSecret);
    Key aSigningKey = new SecretKeySpec (aAPIKeySecretBytes, aSignatureAlgorithm.getJcaName());

    long nExp = nNow + nTTL;

    Map<String, Object> aClaims = new HashMap<String, Object>();
    aClaims.put ("name", sForename+ " " + sSurname);
    JwtBuilder aBuilder = Jwts.builder ()
        .setClaims (aClaims)
        .setIssuedAt (new Date (nNow))
        .setSubject (sUserName)
        .setIssuer (sIssuer)
        .setExpiration(new Date (nExp))
        .signWith (aSigningKey, aSignatureAlgorithm);


    //Builds the JWT and serializes it to a compact, URL-safe string
    return aBuilder.compact();
  }
  
  public static String createJWTWithPayload (String sSecret, String sUserName, String sForename, String sSurname, String sIssuer, long nTTL)
  {
    //The JWT signature algorithm we will be using to sign the token
    SignatureAlgorithm aSignatureAlgorithm = SignatureAlgorithm.HS256;

    long nNow = System.currentTimeMillis();
    
    //We will sign our JWT with our ApiKey secret
    byte[] aAPIKeySecretBytes = DatatypeConverter.parseBase64Binary (sSecret);
    Key aSigningKey = new SecretKeySpec (aAPIKeySecretBytes, aSignatureAlgorithm.getJcaName());

    long nExp = nNow + nTTL;

    ObjectNode aPayload = new ObjectMapper().createObjectNode();
    aPayload.put ("sub", sUserName);
    aPayload.put ("name", sForename+" " + sSurname);
    // iat (Issued At Time) and exp has to be passed as seconds in the payload
    aPayload.put ("iat", nNow/1000);
    aPayload.put ("exp", nExp/1000);
    aPayload.put ("iss", sIssuer);

    //Let's set the JWT Claims
    JwtBuilder aBuilder = Jwts.builder()
            .setPayload(aPayload.toString())
            .signWith (aSigningKey, aSignatureAlgorithm);


    //Builds the JWT and serializes it to a compact, URL-safe string
    return aBuilder.compact();
  }
}
