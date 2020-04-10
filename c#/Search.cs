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
    class Search
    {
        // Replace %SECRET% with your secret
        static string REST_SECRET = "%SECRET%";
        // Replace %IDENTIFIER% with your identifier
        static string REST_IDENTIFIER = "%IDENTIFIER%";

        // Replace %REPO_ID% with your repository ID (without curly brackets)
        static string REPO_ID = "%REPO_ID%";

        // Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
        static string REST_BASE_URL = "%REST_BASE_URL%";

        static string REST_URL = REST_BASE_URL+"/rest/1.0/repos/"+REPO_ID+"/search";
        static void Main(string[] args)
        {
            // Add your parameters and replace %CLASS_NAME% with the name of the class you want to search for
            Dictionary<string, string[]> aParameters = new Dictionary<string, string[]>();
            aParameters.Add("range-start", new string[]{"0"});
            aParameters.Add("range-end", new string[]{"5"});
            aParameters.Add("query", new string[]{
                "{"+
                    "filters:"+
                    "["+
                    "{"+
                    "className:\"%CLASS_NAME%\""+
                    "}"+
                    "]"+
                "}"});

            aParameters.Add("attribute", new string[]{"NAME"});
            
            Dictionary <string, string[]> aHeaders = new Dictionary<string, string[]>();            
            aHeaders.Add("x-axw-rest-identifier", new string[]{REST_IDENTIFIER});            
            aHeaders.Add("x-axw-rest-guid", new string[]{Guid.NewGuid().ToString()});
            aHeaders.Add("x-axw-rest-timestamp", new string[]{((long)(DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds).ToString()});

            ArrayList aRESTTokenCollection = new ArrayList();

            string sURL = REST_URL;

            for (int i = 0; i < aParameters.Keys.Count;++i)
            {
                string sParamName = aParameters.Keys.ElementAt(i);
                aRESTTokenCollection.Add(sParamName);
                string[] aParamValues = aParameters[sParamName];
                for (int j = 0; j < aParamValues.Length;++j)
                {
                    string sParamValue = aParamValues[j];
                    if (i == 0 && j == 0)
                    {
                        sURL+="?";
                    }
                    else
                    {
                        sURL+="&";
                    }
                    sURL+=sParamName+"="+HttpUtility.UrlEncode(aParamValues[j]);
                    aRESTTokenCollection.Add(aParamValues[j]);
                }
            }

            HttpWebRequest aReq = (HttpWebRequest)WebRequest.Create(sURL);

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
            
            aReq.Headers.Add("Accept", "application/json");

            aReq.Headers.Add("Accept-Language", "en");

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
