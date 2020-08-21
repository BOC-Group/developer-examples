
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.text.Collator;
import java.util.AbstractMap;
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

public class StandardRESTfulServicesClientGetModelData {
	public static void main(final String[] args) throws ClientProtocolException,
		IOException,
		InvalidKeyException,
		NoSuchAlgorithmException,
		NoSuchProviderException {
			final CloseableHttpClient aClient = HttpClients.createDefault();

			// Replace with the ID of your repository
			final String sRepoID = "e1fd8ab4-8a4d-4c6f-969c-b300127db1e6";
			// Replace with your key
			final String sKey = "boc.rest.key.mfb.StandardRESTfulServices";
			// Replace with your secret
			final String sSecret = "d4514a20-0913-4940-8403-f1f58d9fdba8e25bfb85-6066-4449-8970-d1556f126bfa741e2dec-765e-425f-92c7-2a9aef45ea594e947521-1ed7-4773-a244-f75957b5041ec73e334e-37db-4df0-8554-452b1d72208d0e002d92-1451-4513-ab6a-661952c64b8a69b5bb42-0bea-4905-926b-e1ec04e2912369998e61-a355-4f60-a86f-790af5ac4d4cf3d70a24-be75-4168-808c-94fa42d27be065c0e536-7272-48e0-9091-aea9b54ac34aff28734b-14b8-4ffb-99c5-2f28e1fff8ee2d2e01ca-d7b9-4a21-a5ce-0edd9dca9dc9f9986081-3496-4603-bc78-df27635d4c395761a988-9ca0-497c-920e-8621b393db46c166c5b8";

			// Replace with the ID of the model for which you want to get data
			final String sModelID = "4cdb6947-1b8b-49c2-9a87-ab5326f7c166";

			// Replace the path to your ADO* installation
			String sPath = "http://HOST:8080/ADOXX/rest/2.0/repos/" + sRepoID + "/models/" + sModelID + "?";

			final Map < String, String[] > aTokenParameters = new HashMap < String, String[] > ();

			final List < Entry < String, String >> aRequestParameters = new ArrayList < Map.Entry < String, String >> ();
			aRequestParameters.add(new AbstractMap.SimpleEntry < > ("attribute", "NAME"));
			aRequestParameters.add(new AbstractMap.SimpleEntry < > ("attribute", "A_DESCRIPTION"));

			// Iterate through the search parameters and construct the URL
			for (final Entry < String, String > aParam: aRequestParameters) {
				final String sParamName = aParam.getKey();
				final String sParamValue = aParam.getValue();
				sPath += sParamName + "=" + URLEncoder.encode(sParamValue, "UTF-8") + "&";
				// Add the parameter name and the parameter value to the map containing the parameters for the
				// token generation
				final String[] aValues = aTokenParameters.get(sParamName);
				if (aValues == null) {
					aTokenParameters.put(sParamName, new String[] {
						sParamValue
					});
				} else {
					final String[] aNewValues = new String[aValues.length + 1];
					for (int i = 0; i < aValues.length; ++i) {
						aNewValues[i] = aValues[i];
					}
					aNewValues[aNewValues.length - 1] = sParamValue;
					aTokenParameters.put(sParamName, aNewValues);
				}
			}
			final HttpGet aMethod = new HttpGet(sPath);

			final long nDate = new Date().getTime();
			final String sDate = String.valueOf(nDate);
			final String sGUID = UUID.randomUUID().toString();

			aMethod.addHeader("x-axw-rest-identifier", sKey);
			aMethod.addHeader("x-axw-rest-timestamp", sDate);
			aMethod.addHeader("x-axw-rest-guid", sGUID);

			aTokenParameters.put("x-axw-rest-timestamp", new String[] {
				sDate
			});
			aTokenParameters.put("x-axw-rest-guid", new String[] {
				sGUID
			});
			aTokenParameters.put("x-axw-rest-identifier", new String[] {
				sKey
			});

			// Construct the token
			final String sSecurityToken = createSecurityToken(sSecret, aTokenParameters);
			aMethod.addHeader("x-axw-rest-token", sSecurityToken);

			// The headers controlling the return type and the language do not have to be considered for
			// token generation
			aMethod.addHeader("Accept", "application/json");
			aMethod.addHeader("Accept-Language", "en");

			System.out.println("Sending request to: " + sPath);

			final CloseableHttpResponse aResponse = aClient.execute(aMethod);

			try {
				System.out.println("Request Status Code: " + aResponse.getStatusLine().getStatusCode());
				final String sResult = EntityUtils.toString(aResponse.getEntity(), "UTF-8");
				System.out.println("Response from RESTful service: " + sResult);
			} catch (final Exception aEx) {
				aEx.printStackTrace();
			} finally {
				aResponse.close();
			}
		}

	private static String createSecurityToken(final String sSecret,
			final Map < String, String[] > aDataMap) throws UnsupportedEncodingException,
		NoSuchProviderException,
		NoSuchAlgorithmException,
		InvalidKeyException {
			final List < byte[] > aContent = new ArrayList < byte[] > ();
			final List < String > aAllParams = new ArrayList < String > ();
			for (final Entry < String, String[] > aEntry: aDataMap.entrySet()) {
				aAllParams.add(aEntry.getKey());
				for (final String sValue: aEntry.getValue()) {
					aAllParams.add(sValue);
				}
			}
			aAllParams.add(sSecret);

			final Collator aCollator = Collator.getInstance(Locale.US);
			Collections.sort(aAllParams, aCollator);

			for (final String aEntry: aAllParams) {
				aContent.add(aEntry.getBytes("UTF-8"));
			}

			final String PROVIDER_BOUNCYCASTLE = "BC";
			final String SHA512 = "HMac/SHA512";

			if (Security.getProvider(PROVIDER_BOUNCYCASTLE) == null) {
				Security.addProvider(new BouncyCastleProvider());
			}
			final Mac aHmac = Mac.getInstance(SHA512, PROVIDER_BOUNCYCASTLE);
			final SecretKey aKey = new SecretKeySpec(sSecret.getBytes("UTF-8"), SHA512);
			aHmac.init(aKey);
			aHmac.reset();

			int nSize = 0;
			for (final byte[] aEntry: aContent) {
				nSize += aEntry.length;
			}
			final byte[] aAllParamsArray = new byte[nSize];
			int nCount = 0;
			for (final byte[] aEntry: aContent) {
				for (final byte aByte: aEntry) {
					aAllParamsArray[nCount] = aByte;
					++nCount;
				}
			}
			final byte[] aResult = aHmac.doFinal(aAllParamsArray);
			return new String(Base64.encodeBase64(aResult), "UTF-8");
		}
}