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

<!doctype html>
<html xmlns:fb="http://www.facebook.com/2008/fbml">
  <head>
  <meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<?php include 'header.php'; ?>
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
  <div id="fb-root"></div>
<script>
  // Additional JS functions here
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '425449864216352', // App ID
      channelUrl : '//WWW.gigreplay.COM/channel.html', // Channel File
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });

    // Additional init code here

  };

  // Load the SDK asynchronously
  (function(d){
     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement('script'); js.id = id; js.async = true;
     js.src = "//connect.facebook.net/en_US/all.js";
     ref.parentNode.insertBefore(js, ref);
   }(document));

  function logout(){
	  FB.logout(function(response) {
		  window.location.href = 'example.php';
		});
  }

  function login(){
	  FB.getLoginStatus(function(r){
	       if(r.status === 'connected'){
	              window.location.href = 'example.php';
	       }else{
	          FB.login(function(response) {
	                  if(response.authResponse) {
	                //if (response.perms)
	                      window.location.href = 'example.php';
	              } else {
	                // user is not logged in
	              }
	       },{scope:'email'}); // which data to access from user profile
	   }
	  });
	  }
	 
</script>

  <?php include 'top_toolbar.php'; ?>

    <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-1 col-lg-2">
<?php if ($user): ?>
      <a href="<?php echo $logoutUrl; ?>">Logout of Facebook</a>
      
    <?php else: ?>
      <div>
        <a href="<?php echo $loginUrl; ?>">Login with Facebook</a>
      </div>
    <?php endif ?>
    <a href='#' onclick='login();'>Facebook login</a>
   <a href='#' onclick='logout();'>Facebook logout</a>
<fb:login-button show-faces="true" width="200" max-rows="1"></fb:login-button>
    <div class="fb-facepile" data-href="http://facebook.com/gigreplay" data-action="Comma separated list of action of action types" data-width="200" data-max-rows="1"></div>
     <ul class="nav nav-pills nav-stacked hidden-sm">
      <li class="active"><a href="http://www.gigreplay.com/front.php">Featured</a></li>
      <li><a href="http://www.gigreplay.com/example.php">My Videos</a></li>
      <li><a href='http://www.gigreplay.com/example.php' onclick='login();'>testing out</a></li>
      <!--<li><a href="#">Inbox</a></li>-->
     </ul>
    </div>
    
	
    
 
<div class="col-10 col-lg-9">
     <div class="row">
      <div class="col-12 col-lg-12" style="max-width:960px;">
      </div>
     </div>
     <h3>My Generated Videos</h3>
     <div class="row">
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
        $master_id=$row['master_id'];
        $default_thumb=$row['default_thumb'];
        $user_name=$row['user_name'];
        $last_modified=$row['date_modified'];
        $append_url ="http://www.gigreplay.com/myVideos.php?vid=".$master_id;
        
	/*?><?php echo "<a href= $append_url > $session_name</a>";?></br> <?php*/

   mysqli_close($con);
    ?>
    
    <div class="col-12 col-lg-4" style="max-width:320px;">
       <a href="<?=$append_url ?>" class="thumbnail">
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$default_thumb ?>" style="display:block;">
       </a>
       <div class="caption">
        <a href="<?=$append_url ?>"><h3><?=$session_name ?></h3></a>
        <p>Created by <?=$user_name ?><br>
        <small>Created at <?=$last_modified ?></small></p>
       </div>
      </div>
<?php
        $row_count++;
        if($row_count>=3) {
        //Echo out the new row and start a new one
?>

<!-- Creating a new row -->
     </div>
     <div class="row">

<?php
            $row_count=0;
        }
    }
?>

     </div>
    </div>
    <div class="col-1 col-lg-1">
    </div>
   </div>
  </div>
 </body>
</html>