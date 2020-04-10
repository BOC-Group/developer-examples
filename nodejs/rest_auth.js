var request = require('request');
var uuidV1 = require('uuid/v1');

// Replace %SECRET% with your secret
const REST_SECRET = "%SECRET%";
// Replace %IDENTIFIER% with your identifier
const REST_IDENTIFIER = "%IDENTIFIER%";

// Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
const REST_BASE_URL = "%REST_BASE_URL%";

const REST_URL = REST_BASE_URL+"/rest/connection/auth";

function generateHeaders () 
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

var aHeaders = generateHeaders ();

request
(
  {
    url: REST_URL,
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
    console.log ("REST_URL: " + REST_URL);
    console.log ("Headers:");
    console.log (aHeaders);
    console.log ("Body: " + aBody);
  }
);