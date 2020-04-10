var request = require('request');
var uuidV1 = require('uuid/v1');

// Replace %SECRET% with your secret
const REST_SECRET = "%SECRET%";
// Replace %IDENTIFIER% with your identifier
const REST_IDENTIFIER = "%IDENTIFIER%";

// Replace %REPO_ID% with your repository ID (without curly brackets)
const REPO_ID = "%REPO_ID%";

// Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
const REST_BASE_URL = "%REST_BASE_URL%";

const REST_URL = REST_BASE_URL+"/rest/1.0/repos/"+REPO_ID+"/search";

// Add your parameters and replace %CLASS_NAME% below with the name of the class you want to search for
var aParameters =
[
  {
    name: "range-start",
    values: ["0"]
  },
  {
    name: "range-end",
    values: ["5"]
  },
  {
    name: "query",
    values: 
    [
      JSON.stringify
      (
        {
          filters:
          [
            {
              className:"%CLASS_NAME%"
            }
          ]
        }
      )
    ]
  },
  {
    name: "attribute",
    values: ["NAME"]
  }
];

function generateHeaders (aQueryParameters) 
{
  var aHeaders = 
  {
    'x-axw-rest-identifier': REST_IDENTIFIER,
    'x-axw-rest-guid': uuidV1(),
    'x-axw-rest-timestamp': Date.now().toString()
  };
  var aRESTTokenCollection = [];
  for (var sKey in aHeaders) 
  {
    aRESTTokenCollection.push (aHeaders[sKey]);
    aRESTTokenCollection.push (sKey);
  }
  for (var i = 0; i < aQueryParameters.length;++i)
  {
    var aCurQueryParam = aQueryParameters[i];
    
    aRESTTokenCollection.push (aCurQueryParam.name);
    for (var j = 0; j < aCurQueryParam.values.length;++j)
    {
      aRESTTokenCollection.push (aCurQueryParam.values[j]);
    }
  }
  
  aRESTTokenCollection.push (REST_SECRET);
  aRESTTokenCollection = aRESTTokenCollection.sort (sortRestTokenCollection);
  
  var aRESTToken = require('crypto').createHmac('sha512', Buffer.from(REST_SECRET, 'utf8'));
  
  aRESTToken.update (Buffer.from (aRESTTokenCollection.join(''), 'utf8'));
  aHeaders ["x-axw-rest-token"] = Buffer.from (aRESTToken.digest (), "utf8").toString ('base64');
  
  return aHeaders;
}

function sortRestTokenCollection (a, b) 
{
  return a.localeCompare (b, "en-US");
}

var aHeaders = generateHeaders (aParameters);

aHeaders ["Accept"] = "application/json";
aHeaders ["Accept-Language"] = "en";


var sURL = REST_URL;
for (var i = 0; i < aParameters.length;++i)
{
  var aCurParam = aParameters [i];
  for (var j = 0; j < aCurParam.values.length;++j)
  {
    if (i === 0 && j === 0)
    {
      sURL+="?";
    }
    else
    {
      sURL+="&";
    }
  
    sURL+=aCurParam.name+"="+encodeURIComponent (aCurParam.values [j])+"&";
  }
}

request
(
  {
    url: sURL,
    headers: aHeaders,
    method: 'GET',
  }, 
  function (aErr, aRes, aBody) 
  {
    if (aErr) 
    {
      console.log ("Error: " + aErr);
    }
    console.log ("Status: " + aRes.statusCode);
    console.log ("REST_URL: " + sURL);
    console.log ("Headers:");
    console.log (aHeaders);
    console.log ("Body: " + aBody);
  }
);