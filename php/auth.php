<?php
function sendRequest ()
{
	# Replace %IDENTIFIER% with your identifier
	$IDENTIFIER = "%IDENTIFIER%";
	# Replace %SECRET% with your secret
    $SECRET = "%SECRET%";

	# Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
    $REST_BASE_URL = "%REST_BASE_URL%";
	$REST_URL = $REST_BASE_URL."rest/connection/auth";
	
	$headers = array(
		'x-axw-rest-identifier'	=> $IDENTIFIER,
		'x-axw-rest-guid'		=> getGUID(),
		'x-axw-rest-timestamp'	=> round(microtime(true) * 1000)
    );
    
	$headers_calc=array();
	$headers_final=array();
	foreach($headers as $key => $value){
		$headers_calc[]=$value;
		$headers_calc[]=$key;
		$headers_final[]=$key.": ".$value;
    }
    
	$headers_calc[]=$SECRET;
	$coll = collator_create('en_US');
	$coll->sort($headers_calc, Collator::SORT_STRING);
    $curl = curl_init($REST_URL);
	$headers_final[]='x-axw-rest-token: '.base64_encode(hash_hmac('sha512', implode($headers_calc), $SECRET, true));
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers_final);
	
    $response = json_decode(curl_exec($curl),true);
	curl_close($curl); 
	print_r($response);
}

function getGUID(){
	mt_srand((double)microtime()*10000);
	$charid = strtoupper(md5(uniqid(rand(), true)));
	$hyphen = chr(45);
	$uuid = strtolower(substr($charid, 0, 8).$hyphen.substr($charid, 8, 4).$hyphen.substr($charid,12, 4).$hyphen.substr($charid,16, 4).$hyphen.substr($charid,20,12));
	return $uuid;
}
?>

<html>
 <head>
  <title>PHP ADO REST Authentication</title>
 </head>
 <body>
 <p><?php echo sendRequest()?></p>
 </body>
</html>