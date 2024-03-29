<?php


require 'php-sdk/facebook.php';

// Create our Application instance (replace this with your appId and secret).
$facebook = new Facebook(array(
  'appId'  => '425449864216352',
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

//Login or logout url will be needed depending on current user state.
if ($user) {
  $logoutUrl = $facebook->getLogoutUrl();
} else {
  $loginUrl = $facebook->getLoginUrl();
}

?>
<html>
<head>
 <head>
  <meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<?php include 'headertest.php'; ?>
</head>

<body style="padding-bottom:100px;">

 <?php if ($user): ?>
      <?php $fb_user_id=$user_profile['id'];?>
  	
    <?php else: ?>
    
  <? php //place some controls here to login user?>
    <?php endif ?>

<div id="fb-root"></div>
<script>
  // Additional JS functions here
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '425449864216352', // App ID
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
	  FB.getLoginStatus(function(r){ //check if user already authorized the app
	       if(r.status === 'connected'){
	             
	       }else{
	          FB.login(function(response) { // opens the login dialog
	                  if(response.authResponse) { // check if user authorized the app
	                //if (response.perms) {
	                     FB.login();
	              } else {
	            	  	FB.login();
	                // user is not logged in
	              }
	       },{scope:'email'}); //permission required by the app
	   }
	  });
	  }

</script>

<?php include 'top_toolbar.php'; ?>

<div class="videos" style="margin-left:auto; margin-right:auto; width:960px;">

     <h3>My Generated Videos</h3>
 <?php     if (!$user){
	echo "You have to log in to view your G-Videos!";
	
}?>
<?php if ($user): ?>
      <a href="<?php echo $logoutUrl; ?>" onclick='login();'>Logout of Facebook</a>
    <?php else: ?>
      <div>
        <a href="<?php echo $loginUrl; ?>" onclick='login();'>Login with Facebook</a>
      </div>
    <?php endif ?>
     <div class="row">
<?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else { 
        $query =" SELECT * FROM gigreplay.media_master JOIN thesmos.user on media_master.user_id=thesmos.user.id WHERE thesmos.user.fb_user_id=".$fb_user_id;
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
    <h1><?php echo $result2;?></h1>
       <a href="<?=$append_url ?>" onclick='login();' class="thumbnail">
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$default_thumb ?>" style="display:block;">
       </a>
       <div class="caption">
        <a href="<?=$append_url ?>"  onclick="login();"> <h3><?=$session_name ?></h3></a>
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
  </body>
  <?php include 'bottom_toolbar.php'; ?>
  </html>