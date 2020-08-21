import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.text.Collator;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.bouncycastle.jce.provider.BouncyCastleProvider;


public class SearchExample 

{

	public static void main(final String[] args) throws ClientProtocolException, IOException, InvalidKeyException,
			NoSuchAlgorithmException, NoSuchProviderException {
		final CloseableHttpClient client = HttpClients.createDefault();

		// Replace with the ID of your repository
		final String REPO_ID = "927917d3-c1e8-4cee-9105-6402b3f0883f";

		// Replace with your key
		final String KEY = "boc.rest.key.mfb.StandardRESTfulServices";

		// Replace with your secret
		final String SECRET = "d4514a20-0913-4940-8403-f1f58d9fdba8e25bfb85-6066-4449-8970-d1556f126bfa741e2dec-765e-425f-92c7-2a9aef45ea594e947521-1ed7-4773-a244-f75957b5041ec73e334e-37db-4df0-8554-452b1d72208d0e002d92-1451-4513-ab6a-661952c64b8a69b5bb42-0bea-4905-926b-e1ec04e2912369998e61-a355-4f60-a86f-790af5ac4d4cf3d70a24-be75-4168-808c-94fa42d27be065c0e536-7272-48e0-9091-aea9b54ac34aff28734b-14b8-4ffb-99c5-2f28e1fff8ee2d2e01ca-d7b9-4a21-a5ce-0edd9dca9dc9f9986081-3496-4603-bc78-df27635d4c395761a988-9ca0-497c-920e-8621b393db46c166c5b8";

		// Replace the path to your ADO* installation
		String path = String.format("http://localhost:8080/ADOxxWeb/rest/2.0/repos/%s/search?query=", REPO_ID); 
		
		// Token parameters which will be needed to authenticate		
		Map< String, String[] > tokenParameters = new HashMap < String, String[] >();

		// Filter parameter as JSON objects in form of String which will be passed as to query
		String classNameObject = "{className: \"C_APPLICATION\"}";
		String attributeObject = "{attrName: \"A_DESCRIPTION\", value: \"Example\", op: \"OP_EQ\"}";
		String nextAttributeObject = "{attrName: \"A_EXPLANATION\", op: \"OP_EMPTY\"}";
		
		//Add them to array
		String params = String.format("{\"filters\":[%s,%s,%s]}", classNameObject, attributeObject, nextAttributeObject);

		tokenParameters.put("query", new String[]{params});
		path += URLEncoder.encode(params, "UTF-8");
		
		//Add attributes in query params
		String queryParams = String.format("&attribute=%s&attribute=%s", "A_TYPE_APPLICATION", "A_NEED_FOR_ACTION");
		tokenParameters.put("attribute", new String[] {"A_TYPE_APPLICATION", "A_NEED_FOR_ACTION"});
		path += queryParams;

		final HttpGet method = new HttpGet(path);
		final String date = String.valueOf(new Date().getTime());
		final String GUID = UUID.randomUUID().toString();


		method.addHeader("x-axw-rest-identifier", KEY);
		method.addHeader("x-axw-rest-timestamp", date);
		method.addHeader("x-axw-rest-guid", GUID);
		

		tokenParameters.put("x-axw-rest-timestamp", new String[] { date });
		tokenParameters.put("x-axw-rest-guid", new String[] { GUID });
		tokenParameters.put("x-axw-rest-identifier", new String[] { KEY });

//		// Construct the token
		final String securityToken = createSecurityToken(SECRET, tokenParameters);
		method.addHeader("x-axw-rest-token", securityToken);
//
//		// The headers controlling the return type and the language do not have to be
//		// considered for
//		// token generation
		method.addHeader("Accept", "application/json");
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

	private static String createSecurityToken(final String secret, final Map< String, String[] > dataMap)
			throws UnsupportedEncodingException, NoSuchProviderException, NoSuchAlgorithmException,
			InvalidKeyException {

		final List< byte[] > content = new ArrayList<>();
		final List< String > allParams = new ArrayList<>();
		for (final Entry< String, String[] > entry : dataMap.entrySet()) {
			allParams.add(entry.getKey());
			for (final String value : entry.getValue()) {
				allParams.add(value);
			}
		}

		allParams.add(secret);

		final Collator aCollator = Collator.getInstance(Locale.US);

		Collections.sort(allParams, aCollator);

		for (final String aEntry : allParams) {
			content.add(aEntry.getBytes("UTF-8"));
		}

		final String PROVIDER_BOUNCYCASTLE = "BC";
		final String SHA512 = "HMac/SHA512";

		if (Security.getProvider(PROVIDER_BOUNCYCASTLE) == null) {
			Security.addProvider(new BouncyCastleProvider());
		}

		final Mac hmac = Mac.getInstance(SHA512, PROVIDER_BOUNCYCASTLE);
		final SecretKey key = new SecretKeySpec(secret.getBytes("UTF-8"), SHA512);
		hmac.init(key);
		hmac.reset();

		int size = 0;
		for (final byte[] aEntry : content) {
			size += aEntry.length;
		}

		final byte[] allParamsArray = new byte[size];

		int count = 0;

		for (final byte[] entry : content) {
			for (final byte entryByte : entry) {
				allParamsArray[count] = entryByte;
				++count;
			}
		}

		final byte[] result = hmac.doFinal(allParamsArray);
		return new String(Base64.encodeBase64(result), "UTF-8");
	}

}