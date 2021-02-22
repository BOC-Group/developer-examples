package devportal.axx;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import devportal.Util;

public class GetConnectionAuth
{
  public static void main (final String [] args) throws ClientProtocolException,
                                                IOException,
                                                InvalidKeyException,
                                                NoSuchAlgorithmException,
                                                NoSuchProviderException
  {
    final CloseableHttpClient aClient = HttpClients.createDefault ();
    
    final String sKey = "<KEY>";
    final String sSecret = "<SECRET>";
    final String sPath = "http://<HOST>:<PORT>/ADOXX/rest/connection/auth";
    
    final Map <String, String []> aTokenParameters = new HashMap <String, String []> ();
    
    final HttpGet aMethod = new HttpGet (sPath);
    
    final long nDate = new Date ().getTime ();
    final String sDate = String.valueOf (nDate);
    final String sGUID = UUID.randomUUID ().toString ();
    
    aMethod.addHeader ("x-axw-rest-identifier", sKey);
    aMethod.addHeader ("x-axw-rest-timestamp", sDate);
    aMethod.addHeader ("x-axw-rest-guid", sGUID);
    
    aTokenParameters.put ("x-axw-rest-timestamp", new String [] {sDate});
    aTokenParameters.put ("x-axw-rest-guid", new String [] {sGUID});
    aTokenParameters.put ("x-axw-rest-identifier", new String [] {sKey});
    
    // Construct the token
    final String sSecurityToken = Util.createSecurityToken (sSecret, aTokenParameters);
    aMethod.addHeader ("x-axw-rest-token", sSecurityToken);
    
    final CloseableHttpResponse aResponse = aClient.execute (aMethod);
    
    try
    {
      final String sResult = EntityUtils.toString (aResponse.getEntity (), "UTF-8");
      final StatusLine aStatusLine = aResponse.getStatusLine ();
      System.out.println ("Status Code: " + aStatusLine.getStatusCode ());
      System.out.println ("Result: \n" + sResult);
    }
    catch (final Exception aEx)
    {
      aEx.printStackTrace ();
    }
    finally
    {
      aResponse.close ();
    }
  }
}
