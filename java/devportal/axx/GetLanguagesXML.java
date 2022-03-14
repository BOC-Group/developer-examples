package devportal.axx;

import java.io.IOException;

import javax.xml.bind.DatatypeConverter;

import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class GetLanguagesXML
{
  public static void main (final String [] args) throws ClientProtocolException, IOException
  {
    final CloseableHttpClient aClient = HttpClients.createDefault ();
    
    final String sUser = "<USER>";
    final String sPass = "<PASSWORD>";
    final String sPath = "http://<HOST>:<PORT>/ADOXX/rest/2.0/languages";
    
    final HttpGet aMethod = new HttpGet (sPath);
    
    // The headers controlling the return type and the language do not have to be considered for
    // token generation
    aMethod.addHeader ("Accept", "application/xml");
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
