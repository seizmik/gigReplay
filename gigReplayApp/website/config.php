<?php

session_start();
//Facebook App Id and Secret
$appID='425449864216352';
$appSecret='e0a33ee97563372f964df382b350af30';

//URL to your website root
if($_SERVER['HTTP_HOST']=='localhost'){
$base_url='http://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
}else{
$base_url='http://'.$_SERVER['HTTP_HOST'];	
}
?>