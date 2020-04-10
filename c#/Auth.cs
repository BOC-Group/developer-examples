using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using System.Security.Cryptography;
using System.Web;
using System.Net;

namespace REST_Client
{
    class Auth
    {
        // Replace %SECRET% with your secret
        static string REST_SECRET = "%SECRET%";
        // Replace %IDENTIFIER% with your identifier
        static string REST_IDENTIFIER = "%IDENTIFIER%";

        // Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
        static string REST_BASE_URL = "%REST_BASE_URL%";

        static string REST_URL = REST_BASE_URL+"/rest/connection/auth";
        static void Main(string[] args)
        {            
            Dictionary <string, string[]> aHeaders = new Dictionary<string, string[]>();            
            aHeaders.Add("x-axw-rest-identifier", new string[]{REST_IDENTIFIER});            
            aHeaders.Add("x-axw-rest-guid", new string[]{Guid.NewGuid().ToString()});
            aHeaders.Add("x-axw-rest-timestamp", new string[]{((long)(DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds).ToString()});

            ArrayList aRESTTokenCollection = new ArrayList();

            HttpWebRequest aReq = (HttpWebRequest)WebRequest.Create(REST_URL);

            foreach (string sHeaderName in aHeaders.Keys)
            {
                string[] aHeaderValues = aHeaders.GetValueOrDefault(sHeaderName);
                aRESTTokenCollection.Add(sHeaderName);
                foreach (String sHeaderValue in aHeaderValues)
                {
                    aReq.Headers.Add(sHeaderName, sHeaderValue);
                    aRESTTokenCollection.Add(sHeaderValue);
                }
            }

            aRESTTokenCollection.Add(REST_SECRET);
            aRESTTokenCollection.Sort(StringComparer.Create(new System.Globalization.CultureInfo("en-US"), true));

            ArrayList aBytes = new ArrayList();
            for (int i = 0; i < aRESTTokenCollection.Count; ++i)
            {
                byte[] aHeaderBytes = Encoding.UTF8.GetBytes((String)aRESTTokenCollection[i]);
                aBytes.AddRange(aHeaderBytes);
            }

            byte[] aByteArr = (byte[])aBytes.ToArray(typeof(byte));
            byte[] aKeyArr = Encoding.UTF8.GetBytes(REST_SECRET);

            HMACSHA512 aKeyHMAC = new HMACSHA512(aKeyArr);
            byte[] aHash = aKeyHMAC.ComputeHash(aByteArr);

            String sToken = Convert.ToBase64String(aHash);

            aReq.Headers.Add("x-axw-rest-token", sToken);

            aReq.KeepAlive = false;
            aReq.ProtocolVersion = HttpVersion.Version10;
            aReq.Method = "GET";
            HttpWebResponse aResponse = (HttpWebResponse)aReq.GetResponse();
            Console.WriteLine("Status: " + aResponse.StatusCode + ", Description: " + aResponse.StatusDescription);
            
            System.IO.Stream aResponseStream = aResponse.GetResponseStream();
            try
            {
                System.IO.StreamReader aStreamReader = new System.IO.StreamReader(aResponseStream);
                Console.WriteLine("Response: " + aStreamReader.ReadToEnd());
            }
            finally
            {
                aResponseStream.Close();
            }
        }
    }
}
