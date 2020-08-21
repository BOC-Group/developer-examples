import java.io.IOException;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class BasicAuthExample {

	public static void main(final String[] args) throws IOException {
		final CloseableHttpClient client = HttpClients.createDefault();

		// Replace with the ID of your repository
		final String REPO_ID = "927917d3-c1e8-4cee-9105-6402b3f0883f";

		// Replace with login of your user
		final String LOGIN = "arch";

		// Replace with password of your user
		final String PASSWORD = "Password123";

		final String OBJECT_ID = "3abb1673-aab5-46a8-aadf-05cfbd1c5cef";

		// Replace the path to your ADO* installation
		String path = String.format("http://localhost:8080/ADOxxWeb/rest/2.0/repos/%s/objects/%s", REPO_ID, OBJECT_ID); 
		
		final HttpGet method = new HttpGet(path);

		method.addHeader("Authorization", createBasicAuthHeader(LOGIN, PASSWORD));
		
		method.addHeader("Accept-Language", "en");
		final CloseableHttpResponse response = client.execute(method);
		try {
			System.out.println("Request Status Code: " + response.getStatusLine().getStatusCode());
			final String result = EntityUtils.toString(response.getEntity(), "UTF-8");
			System.out.println("Response from RESTful service: " + result);
		} catch (final Exception ex) {
			ex.printStackTrace();
		} finally {
			response.close();
		}

	}

	private static String createBasicAuthHeader(final String login, final String password) {
		String credentials = String.format("%s:%s", login, password);
		String base64 = Base64.encodeBase64String(credentials.getBytes());
		return String.format("Basic %s", base64);
	}

}