package devportal.adogrc;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.bind.DatatypeConverter;

import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class GetSearchForRisks
{
  public static void main (final String [] args) throws ClientProtocolException, IOException
  {
    final CloseableHttpClient aClient = HttpClients.createDefault ();
    
    final String sUser = "<USER>";
    final String sPass = "<PASSWORD>";
    final String sRepoID = "<REPO_ID>";
    String sPath = "http://<HOST>:<PORT>/ADOGRC/rest/2.0/repos/" + sRepoID + "/search?";
    
    final List <Entry <String, String>> aSearchParameters = new ArrayList <Map.Entry <String, String>> ();
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("query",
                                                           "{filters:[{\"className\":\"C_RISK\"}]}"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("range-start", "0"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("range-end", "20"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("attribute", "NAME"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("attribute", "A_DESCRIPTION"));
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("attribute",
                                                           "A_GRC_MASTER_DATA_RISK_ASSESSMENT_FREQUENCY"));
    
    // Iterate through the search parameters and construct the URL
    for (final Entry <String, String> aParam : aSearchParameters)
    {
      final String sParamName = aParam.getKey ();
      final String sParamValue = aParam.getValue ();
      sPath += sParamName + "=" + URLEncoder.encode (sParamValue, "UTF-8") + "&";
    }
    final HttpGet aMethod = new HttpGet (sPath);
    
    // The headers controlling the return type and the language do not have to be considered for
    // token generation
    aMethod.addHeader ("Accept", "application/json");
    aMethod.addHeader ("Accept-Language", "en");
    
    // Construction of the header to pass the basic authentication information
    aMethod.addHeader ("Authorization",
                       "Basic " +
                           DatatypeConverter.printBase64Binary ((sUser + ":" + sPass).getBytes ()));
    
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
