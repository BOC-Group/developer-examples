package devportal.ado;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.bind.DatatypeConverter;

import org.apache.commons.io.IOUtils;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

public class GetModelImage
{
  public static void main (final String [] args) throws ClientProtocolException, IOException
  {
    final CloseableHttpClient aClient = HttpClients.createDefault ();
    
    final String sUser = "<USER>";
    final String sPass = "<PASSWORD>";
    final String sRepoID = "<REPO_ID>";
    final String sModelID = "<MODEL_ID>";
    final String sFilePath = "<FILE_PATH>"; // E.g. D:\\model.png
    String sPath = "http://<HOST>:<PORT>/ADONIS/rest/2.0/repos/" +
                   sRepoID +
                   "/models/" +
                   sModelID +
                   "?";
    
    final List <Entry <String, String>> aSearchParameters = new ArrayList <Map.Entry <String, String>> ();
    aSearchParameters.add (new AbstractMap.SimpleEntry <> ("dpi", "150"));
    
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
    aMethod.addHeader ("Accept", "image/png");
    aMethod.addHeader ("Accept-Language", "en");
    
    // Construction of the header to pass the basic authentication information
    aMethod.addHeader ("Authorization",
                       "Basic " +
                           DatatypeConverter.printBase64Binary ((sUser + ":" + sPass).getBytes ()));
    
    final CloseableHttpResponse aResponse = aClient.execute (aMethod);
    
    
    final InputStream aInput = aResponse.getEntity ().getContent ();
    try
    {
      final StatusLine aStatusLine = aResponse.getStatusLine ();
      System.out.println ("Status Code: " + aStatusLine.getStatusCode ());

      final byte [] aBytes = IOUtils.toByteArray (aInput);
      final FileOutputStream aFos = new FileOutputStream (new File(sFilePath));
      try
      {
        aFos.write (aBytes);

        System.out.println ("Image written to '"+sFilePath+"'.");
      }
      finally
      {
        aFos.flush ();
        aFos.close ();
      }
    }
    
    finally
    {
      aInput.close ();
    }
  }
}
