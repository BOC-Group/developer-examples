package devportal.ait;

import java.io.IOException;

import javax.xml.bind.DatatypeConverter;

import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class CreateRelation
{
  public static void main (final String [] args) throws ClientProtocolException, IOException
  {
    final CloseableHttpClient aClient = HttpClients.createDefault ();
    
    final String sUser = "<USER>";
    final String sPass = "<PASSWORD>";
    final String sRepoID = "<REPO_ID>";
    final String sSrcObjectID = "<SRC_OBJECT_ID>";
    final String sTrgObjectID = "<TRG_OBJECT_ID>";
    final String sDirection = "outgoing";
    final String sRelClass = "RC_EAM_COMPOSITION";
    final String sPath = "http://<HOST>:<PORT>/ADOIT/rest/2.0/repos/" + sRepoID + "/objects/"+sSrcObjectID+"/relations/"+sDirection+"/"+sRelClass;
    
    final HttpPost aMethod = new HttpPost (sPath);
    
    final StringBuilder aCreationParams = new StringBuilder ();
    aCreationParams.append ("{");
    aCreationParams.append ("\"toId\":\""+sTrgObjectID+"\"");
    aCreationParams.append ("}");
    
    final StringEntity aJSON = new StringEntity (aCreationParams.toString (),
                                                 ContentType.APPLICATION_JSON);
    aMethod.setEntity (aJSON);
    
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
