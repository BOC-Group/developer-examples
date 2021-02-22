package devportal;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.text.Collator;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

public class Util
{
  public static String createSecurityToken (final String sSecret,
                                            final Map <String, String []> aDataMap) throws UnsupportedEncodingException,
                                                                                   NoSuchProviderException,
                                                                                   NoSuchAlgorithmException,
                                                                                   InvalidKeyException
  {
    final List <byte []> aContent = new ArrayList <byte []> ();
    final List <String> aAllParams = new ArrayList <String> ();
    for (final Entry <String, String []> aEntry : aDataMap.entrySet ())
    {
      aAllParams.add (aEntry.getKey ());
      for (final String sValue : aEntry.getValue ())
      {
        aAllParams.add (sValue);
      }
    }
    aAllParams.add (sSecret);
    
    final Collator aCollator = Collator.getInstance (Locale.US);
    Collections.sort (aAllParams, aCollator);
    
    for (final String aEntry : aAllParams)
    {
      aContent.add (aEntry.getBytes ("UTF-8"));
    }
    
    final String PROVIDER_BOUNCYCASTLE = "BC";
    final String SHA512 = "HMac/SHA512";
    
    if (Security.getProvider (PROVIDER_BOUNCYCASTLE) == null)
    {
      Security.addProvider (new BouncyCastleProvider ());
    }
    final Mac aHmac = Mac.getInstance (SHA512, PROVIDER_BOUNCYCASTLE);
    final SecretKey aKey = new SecretKeySpec (sSecret.getBytes ("UTF-8"), SHA512);
    aHmac.init (aKey);
    aHmac.reset ();
    
    int nSize = 0;
    for (final byte [] aEntry : aContent)
    {
      nSize += aEntry.length;
    }
    final byte [] aAllParamsArray = new byte [nSize];
    int nCount = 0;
    for (final byte [] aEntry : aContent)
    {
      for (final byte aByte : aEntry)
      {
        aAllParamsArray[nCount] = aByte;
        ++nCount;
      }
    }
    final byte [] aResult = aHmac.doFinal (aAllParamsArray);
    return new String (Base64.encodeBase64 (aResult), "UTF-8");
  }
}
