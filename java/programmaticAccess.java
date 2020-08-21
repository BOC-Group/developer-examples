import java.io.IOException;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class RESTClient {
	private static final String CONNECTION_PATH = "http://localhost:8080/ADOxxWeb/rest/connection";

	public static void main(final String[] args) throws ClientProtocolException, IOException {
		final CloseableHttpClient aClient = HttpClients.createDefault();
		final HttpGet aMethod = new HttpGet(CONNECTION_PATH);
		final CloseableHttpResponse aResponse = aClient.execute(aMethod);
		try {
			System.out.println("Response From RESTful service: \n" + EntityUtils.toString(aResponse.getEntity(), “UTF - 8”));
		} finally {
			aResponse.close();
		}
	}
}