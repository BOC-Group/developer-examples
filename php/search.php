<?php
function sendRequest ()
{
	# Replace %IDENTIFIER% with your identifier
	$IDENTIFIER = "%IDENTIFIER%";
	
	# Replace %SECRET% with your secret
	$SECRET = "%SECRET%";
	
	# Replace %REPO_ID% with your repository ID (without curly brackets)
	$REPO_ID = "%REPO_ID%";
	
	# Replace %REST_BASE_URL% with the path to your web client (e.g. http://server/ADO)
    $REST_BASE_URL = "%REST_BASE_URL%";
	$REST_URL = $REST_BASE_URL."rest/1.0/repos/".$REPO_ID."/search";
	
	
	# Add your parameters and replace %CLASS_NAME% with the name of the class you want to search for
	$params = array(
		"range-start"=>array("0"),
		"range-end"=>array("5"),
		"attribute"=>array("NAME"),
		"query"=>array
			(
				"{".
				"\"filters\":".
				"[".
				"{".
				"\"className\":\"%CLASS_NAME%\"".
				"}".
				"]".
				"}"
			)
		);
	
	$headers = array(
		"x-axw-rest-identifier"	=> $IDENTIFIER,
		"x-axw-rest-guid"		=> getGUID(),
		"x-axw-rest-timestamp"	=> round(microtime(true) * 1000)
    );
    
	$headers_calc=array();
	$headers_final=array();
	foreach($headers as $key => $value){
		$headers_calc[]=$value;
		$headers_calc[]=$key;
		$headers_final[]=$key.": ".$value;
	}

	$url = $REST_URL;
	
	$i = 0;
	foreach ($params as $paramName => $paramValues)
	{
		$headers_calc[]=$paramName;
		for ($j = 0; $j < count($paramValues);++$j)
		{
			$paramValue = $paramValues[$j];
			$headers_calc[]=$paramValue;
			if ($i == 0 && $j == 0)
			{
				$url=$url."?";
			}
			else
			{
				$url=$url."&";
			}
			$url=$url.$paramName."=".encodeURIComponent($paramValue);
		}
		++$i;
	}
	
	$headers_calc[]=$SECRET;
	
	$coll = collator_create('en_US');
	$coll->sort($headers_calc, Collator::SORT_STRING);

	$tokenConcat = '';
	for($i = 0; $i<count($headers_calc);++$i)
	{
		$tokenConcat=$tokenConcat.$headers_calc[$i];
	}
	
	$curl = curl_init($url);
	$token = base64_encode(hash_hmac("sha512", implode($headers_calc), $SECRET, true));
	
	$headers_final[]="x-axw-rest-token: ".$token;
	$headers_final[]="Accept: "."application/json";
	$headers_final[]="Accept-Language: "."en";
            
	curl_setopt($curl, CURLOPT_HTTPHEADER, $headers_final);
	
    $response = json_decode(curl_exec($curl),true);
	curl_close($curl);
}

function getGUID(){
	mt_srand((double)microtime()*10000);
	$charid = strtoupper(md5(uniqid(rand(), true)));
	$hyphen = chr(45);
	$uuid = strtolower(substr($charid, 0, 8).$hyphen.substr($charid, 8, 4).$hyphen.substr($charid,12, 4).$hyphen.substr($charid,16, 4).$hyphen.substr($charid,20,12));
	return $uuid;
}

function encodeURIComponent($str) {
    $revert = array('%21'=>'!', '%2A'=>'*', '%27'=>"'", '%28'=>'(', '%29'=>')');
    return strtr(rawurlencode($str), $revert);
}
?>

<html>
 <head>
  <title>PHP ADO REST Search</title>
 </head>
 <body>
 <p><?php echo sendRequest()?></p>
 </body>
</html>