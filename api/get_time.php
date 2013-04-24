<?php

function getmicrotime($e = 7) 
{ 
    list($u, $s) = explode(' ',microtime()); 
    return bcadd($u, $s, $e); 
} 
echo getmicrotime();

?>