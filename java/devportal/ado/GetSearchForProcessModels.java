package devportal.ado;

import java.io.IOException;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.UUID;

import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import devportal.Util;

public class GetSearchForProcessModels
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
    final String sRepoID = "<REPO_ID>";
    String sPath = "http://<HOST>:<PORT>/ADONIS/rest/2.0/repos/" + sRepoID + "/search?";
    
    final Map <String, String []> aTokenParameters = new HashMap <String, String []> ();
    
    final List <Entry <String, String>> aSearchParameters = new ArrayList <Map.Entry <String, String>> ();
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("query",
                                                           "{filters:[{\"className\":\"MT_CROSS_LAYER\"}]}"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("range-start", "0"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("range-end", "20"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("attribute", "NAME"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("attribute", "A_DESCRIPTION"));
    
    // Iterate through the search parameters and construct the URL
    for (final Entry <String, String> aParam : aSearchParameters)
    {
      final String sParamName = aParam.getKey ();
      final String sParamValue = aParam.getValue ();
      sPath += sParamName + "=" + URLEncoder.encode (sParamValue, "UTF-8") + "&";
      // Add the parameter name and the parameter value to the map containing the parameters for the
      // token generation
      final String [] aValues = aTokenParameters.get (sParamName);
      if (aValues == null)
      {
        aTokenParameters.put (sParamName, new String [] {sParamValue});
      }
      else
      {
        final String [] aNewValues = new String [aValues.length + 1];
        for (int i = 0; i < aValues.length; ++i)
        {
          aNewValues[i] = aValues[i];
        }
        aNewValues[aNewValues.length - 1] = sParamValue;
        aTokenParameters.put (sParamName, aNewValues);
      }
    }
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
    
    // The headers controlling the return type and the language do not have to be considered for
    // token generation
    aMethod.addHeader ("Accept", "application/json");
    aMethod.addHeader ("Accept-Language", "en");
    
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
