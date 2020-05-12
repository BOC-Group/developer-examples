# Introduction
The source repository contains coding examples how to access the REST APIs of our BOC Group Products. The code snippets can be used as starting point to retrieve data or to perform a query within our products.
Please note that this documentation does not contain detailed information about the REST API endpoints. This documentation is part of BOC Group product delivery.

BOC Group products ADONIS, ADOIT and GRC provide REST capabilities to call various functionality to create, read, update and delete data. As such, all incoming REST calls need to be authenticated to ensure security.

REST authentication in ADOxx can be done in three ways:

* Token Based authentication
* Basic authentication
* OAuth 2.0 Authentication

These three authentication mechanisms are described below in more detail.
## Basic Authentication
Basic Authentication is done by sending a header with the REST request which contains the username and password of an BOC Group product user.
### Authentication Details
The header's name is **Authorization**, the header's value has to have the format **Basic <encodeBase64(username:password)>.**
Usernames that contain a colon are not supported.

**Example (Java):**

    ...
    String sPath = "https://myserver/ADO/rest/myEndpoint";
    String sUsername = "user";
    String sPassword = "pass";
 
    HttpGet aMethod = new HttpGet (sPath);
    String sUnencodedToken = sUsername + ":" + sPassword;
    aMethod.addHeader ("Authorization", "Basic " + DatatypeConverter.printBase64Binary (sUnencodedToken.getBytes ()));
    ...
The REST request will then be done in the context of the user that is identified by provided username. This user's rights will be applied when accessing or manipulating data.
### Enabling Basic Authentication
To enable Basic Authentication, several steps have to be done:

* Basic Authentication has to be allowed in BOC Group Products
* The endpoint implementation has to support Basic Authentication
#### Configure Basic Authentication in BOC Group Products
To configure Basic Authentication in BOC Group Products, the file **RESTAuthorization.xml** on the web server in the directory **WEB-INF/registry/rest** has to be edited and the entry with key **REST_BASIC_AUTHENTICATION** has to be set to true:

    <properties>
      ... 
      <entry key="REST_BASIC_AUTHENTICATION">true</entry>
    </properties>
#### Configure Basic Authentication in the Standard RESTful Services
For details please refer to the corresponding manuals of our BOC Group Products.
## OAuth 2.0 Authentication
OAuth 2.0 Authentication is done by first retrieving a token from the server which can then be sent in the Authorization header to gain access to the desired resource. For details on how to activate OAuth 2.0, how to register a client for it and how to use OAuth 2.0 authentication in your own APIs, refer to [OAuth 2.0](https://oauth.net/2/).
### Configure OAuth 2.0 Authentication in the Standard RESTful Services
For details please refer to the corresponding manuals of our BOC Group Products.
## Token Based Authentication
Token Based authentication in BOC Group Products is done using a security hash which is constructed from a public identifier of the client, a secret key of the client, a GUID and a timestamp of the request. This prevents that the REST functionality is used by unauthorized clients or that requests could be replayed or abused.
### Authentication Details
Each authenticated request to BOC Group Products using REST needs four headers. While by default headers should be used to communicate this relevant information, it is also possible to send this information also using parameters (e.g. if the third party system that needs to be integrated with BOC Group Products does not provide a means to set headers for requests).

* **x-axw-rest-identifier**
This is the key defined for this client either programmatically or in the file **RESTAuthorization.xml**. As this is transferred by the client it means the client has to know this identifier in advance – preferably by having it configured somewhere.
* **x-axw-rest-guid**
This is a UUID to ensure uniqueness of the request.
* **x-axw-rest-timestamp**
This is the timestamp of when the request was sent by the client. The timestamp has to be a UTC milliseconds value converted to a string.
* **x-axw-rest-token**
This is a hashed security token to ensure validity of the request.

The security token has to be generated in the following way:

**Manually constructing the hash:**

a. Get the secret key matching to the identifier sent via the **x-axw-rest-identifier** header/parameter.

b. Take all request parameter names and put them into a collection. (NOTE: ignore any parameters sent via request body)

c. Take all request parameter values as string and put them into the same collection. (NOTE: ignore any parameters sent via request body)

d. Take the header/parameter names of the identifier, GUID and timestamp and put them into the collection.

e. Take the values of the identifier, GUID, timestamp and secret key and put them into the collection.

f. Sort this collection using **Locale en_US**.

g. Convert each item of the collection into byte array using UTF-8 encoding. (So in the end the whole collection should be converted from **Collection\<String>** to **Collection<byte[]>**)
  
h. Append all items of the byte array collection into a single byte array in the order of their sorting.

i. Convert the secret key into a byte array using UTF-8 encoding.

j. Create a new HMac instance using SHA-512 algorithm.

k. Initialize the HMac instance using the secret key byte array.

l. Finalize the HMac using the byte array containing all parameters and headers/parameters.

m. Get the resulting byte array of the HMac.

n. Convert the byte array into a Base64 encoded string using UTF-8 encoding.
### Reference Implementation - Java
The following file shows a sample implementation of a REST client in Java.

In [**auth.java**](https://github.com/BOC-Group/rest-examples/blob/master/java/auth.java) a simple call to the connection endpoint of the REST API that requires authentication is made.

### Reference Implementation - PHP
The following two files show sample implementations of a REST client in PHP.

In [**auth.php**](https://github.com/BOC-Group/rest-examples/blob/master/php/auth.php) a simple call to the connection endpoint of the REST API that requires authentication is made.

[**search.php**](https://github.com/BOC-Group/rest-examples/blob/master/php/search.php) shows how to call the search API.

In both cases, adapt the necessary parameters within the files (e.g. %SECRET%, %IDENTIFIER%, %REPO_ID%, %REST_BASE_URL%, %CLASS_NAME%, etc.).
### Reference Implementation - C#
The following example contains a sample implementation that shows how to create the necessary token in C# and send a request in a way that it is understandable by the REST API.
To make this example work, run the exe and enter your secret and your identifier. Also provide a URL and select the desired request.
It is possible to send parametrized post requests, the parameters need to be entered as KEY:VALUE pairs in the text box. For each new KEY:VALUE pair, a new line has to be started.

These two examples contain simple C# code that can be executed e.g. in Visual Studio Code.

In [**Auth.cs**](https://github.com/BOC-Group/rest-examples/blob/master/c%23/Auth.cs) a simple call to the connection endpoint of the REST API that requires authentication is made.

[**Search.cs**](https://github.com/BOC-Group/rest-examples/blob/master/c%23/Search.cs) shows how to call the search API.

In both cases, adapt the necessary parameters within the files (e.g. %SECRET%, %IDENTIFIER%, %REPO_ID%, %REST_BASE_URL%, %CLASS_NAME%, etc.).
### Reference Implementation - NodeJS
The following two files show sample implementations of a REST client in NodeJS.

In [**rest_auth.js**](https://github.com/BOC-Group/rest-examples/blob/master/nodejs/rest_auth.js) a simple call to the connection endpoint of the REST API that requires authentication is made.

[**rest_search.js**](https://github.com/BOC-Group/rest-examples/blob/master/nodejs/rest_search.js) shows how to call the search API.

In both cases, adapt the necessary parameters within the files (e.g. %SECRET%, %IDENTIFIER%, %REPO_ID%, %REST_BASE_URL%, %CLASS_NAME%, etc.).
