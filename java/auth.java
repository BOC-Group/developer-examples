import java.io.IOException;
import java.io.UnsupportedEncodingException;
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

public class AuthRESTClient {
	private static final String CONNECTION_PATH = "http://localhost:8080/ADOxxWeb/rest/connection/auth";

	public static void main(final String[] args) throws ClientProtocolException,
		IOException,
		InvalidKeyException,
		NoSuchAlgorithmException,
		NoSuchProviderException {
			final CloseableHttpClient aClient = HttpClients.createDefault();
			final HttpGet aMethod = new HttpGet(CONNECTION_PATH);
			final long nDate = new Date().getTime();
			final String sDate = String.valueOf(nDate);
			final String sGUID = UUID.randomUUID().toString();
			final String sIdentifier = "boc.rest.key.mfb.StandardRESTfulServices";
			final String sSecret = "2edb376a-88d7-4564-a4cb-9fcdd005c8179427ccbd-89eb-45ea-a3ed-69f0d7c38e94f723beea-f2bc-4007-a238-8d9a0c88f8ed22365ab7-ff76-440b-99f8-1dc862e1607d3b2c7138-cba5-4a1e-9a66-00595b2524206ffa0893-4d41-4ba5-a43a-e15b5c9292713b3f066f-2875-4bd0-a49b-a093085c15db1224fc34-6d4d-4c62-a0b1-4aae1dffff6ddb1255c1-ca9a-4d58-9bfd-235c9c9f879869ed9de3-d641-4425-85d2-6f0c7a5d162407be6866-cd04-4fb9-b132-116321cec844ac27c950-ba19-4018-bd93- 38ce70f3ea1c60aae62c-e620-4762-a7a0-39d7f0b6c677176cc895-04c6-4d44-8767-4277ee315cfcbed1341f";

			aMethod.addHeader("x-axw-rest-identifier", sIdentifier);
			aMethod.addHeader("x-axw-rest-timestamp", sDate);
			aMethod.addHeader("x-axw-rest-guid", sGUID);

			final Map < String, String[] > aRequestParameters = new HashMap < String, String[] >
				();
			aRequestParameters.put("x-axw-rest-timestamp", new String[] {
				sDate
			});
			aRequestParameters.put("x-axw-rest-guid", new String[] {
				sGUID
			});
			aRequestParameters.put("x-axw-rest-identifier", new String[] {
				sIdentifier
			});

			final String sSecurityToken = getSecurityToken(sSecret, aRequestParameters);

			aMethod.addHeader("x-axw-rest-token", sSecurityToken);

			final CloseableHttpResponse aResponse = aClient.execute(aMethod);

			try {
				System.out.println("Response From RESTful service: \n" +
					EntityUtils.toString(aResponse.getEntity(), “UTF - 8”));
			} finally {
				aResponse.close();
			}
		}

	private static String getSecurityToken(final String sSecret,
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
					nCount++;
				}
			}
			final byte[] aResult = aHmac.doFinal(aAllParamsArray);
			return new String(Base64.encodeBase64(aResult), "UTF-8");
		}
}