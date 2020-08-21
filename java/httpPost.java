
final HttpPost aMethod = new HttpPost("http://localhost:8000/ADOXXR25_0/rest/hello");

... // Add headers here 

final List < NameValuePair > aPostForm = new ArrayList < NameValuePair > ();
aPostForm.add(new BasicNameValuePair("hello_param", "RESTClient"));

final Map < String, String[] > aRequestParameters = new HashMap < String, String[] > ();
for (final NameValuePair aEntry: aDataEntries) {
	aRequestParameters.put(aEntry.getName(), new String[] {
		aEntry.getValue()
	});
}

... // Add Request parameters here 

aMethod.setEntity(new UrlEncodedFormEntity(aPostForm));
final String sSecurityToken = getSecurityToken(sSecret, aRequestParameters);
aMethod.addHeader("x-axw-rest-token", sSecurityToken);

... // Execute request and print out response here