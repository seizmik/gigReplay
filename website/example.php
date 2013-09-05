<?php

require 'php-sdk/facebook.php';

// Create our Application instance (replace this with your appId and secret).
$facebook = new Facebook(array(
  'appId'  => '	425449864216352',
  'secret' => 'e0a33ee97563372f964df382b350af30',
));

// Get User ID
$user = $facebook->getUser();

if ($user) {
  try {
    // Proceed knowing you have a logged in user who's authenticated.
    $user_profile = $facebook->api('/me');
  } catch (FacebookApiException $e) {
    error_log($e);
    $user = null;
  }
}

// Login or logout url will be needed depending on current user state.
if ($user) {
  $logoutUrl = $facebook->getLogoutUrl();
} else {
  $loginUrl = $facebook->getLoginUrl();
}


?>
<?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
	 $fb_user_id=$user_profile['id'];
        $query = "SELECT * FROM user WHERE fb_user_id=$fb_user_id";
        $result = mysqli_query($con, $query);
        $num = mysqli_num_rows($result);
        echo $num;
	
    }
    
    while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
	$user_id=$row['id'];
    	$user_name = $row['user_name'];
    	$email = $row['email'];
    	$fb_token = $row['fb_authorization_token'];
    	$pass= $row['password'];
    	$login = $row['last_login'];
    	    
    }



   mysqli_close($con);
    ?>
   <?php  echo $user_name;?>
<?php echo $email;?>
<?php echo $fb_authorization_token;?>
<?php echo $pass ;?>
<?php echo $login ;?>
</br>

<?php echo $user_id;?>
<?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
	
        $query =" SELECT * FROM gigreplay.media_master JOIN thesmos.user on media_master.user_id=thesmos.user.id WHERE media_master.user_id=19";
        $result = mysqli_query($con, $query);
        
	
    }
    
   
while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
        $session_name = $row['title'];
        $append_url = $row['media_url'];
	?><?php echo "<a href= $append_url > $session_name</a>";?></br> <?php
	

}


   mysqli_close($con);
    ?>



<!doctype html>
<html xmlns:fb="http://www.facebook.com/2008/fbml">
  <head>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="/bootstrap/dist/js/bootstrap.min.js"></script>
<script src="/bootstrap/dist/js/respond.js"></script>
    <title>php-sdk</title>
    <style>
      body {
        font-family: 'Lucida Grande', Verdana, Arial, sans-serif;
      }
      h1 a {
        text-decoration: none;
        color: #3b5998;
      }
      h1 a:hover {
        text-decoration: underline;
      }
    </style>
  </head>
  <body>
  

    <h1>php-sdk</h1>

    <?php if ($user): ?>
      <a href="<?php echo $logoutUrl; ?>">Logout</a>
    <?php else: ?>
      <div>
       
        <a href="<?php echo $loginUrl; ?>">Login with Facebook</a>
      </div>
    <?php endif ?>

    <?php if ($user): ?>
     
      <img src="https://graph.facebook.com/<?php echo $user; ?>/picture">

    <?php else: ?>
    
    <?php endif ?>

    <h3>Leon's variables</h3>
    

    <?php  echo $user_profile['name']?>
    
	
    
  </body>
</html>
