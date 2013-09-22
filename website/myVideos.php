<!DOCTYPE html>
<html prefix="og: http://ogp.me/ns#">
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
<?php if ($user): ?>
      <?php $fb_user_id=$user_profile['id'];?>
      <?php  $fb_user_name=$user_profile['name'];?>
  	
    <?php else: ?>
    
  <? php //place some controls here to login user?>
    <?php endif ?>
<!-- Select media details of vid -->
<?php
    
    $getthing = $_GET['vid'];
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        //Find out if the video has already been created once before
        $query = "SELECT * FROM media_master WHERE master_id=".$getthing;
        $result = mysqli_query($con, $query);
        $row = mysqli_fetch_array($result);
    }
    mysqli_close($con);
    
    $media_id = $row['master_id'];
    $user_id = $row['user_id'];
    $session_id = $row['session_id'];
    $title = $row['title'];
    $media_url = $row['media_url'];
    $media_url_lo = $row['media_url_lo'];
    $views = $row['views'];
    $likes = $row['likes'];
    $default_thumb = $row['default_thumb'];
    $last_modified = $row['date_modified'];
    $start_time = $row['start_time'];
    
    //Setting the session name
    if ($user_id == 0) {
        //Query the thesmos database for the session name
        $con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
        if (mysqli_connect_errno($con)) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        } else {
            //Find out if the video has already been created once before
            $query = "SELECT * FROM session WHERE id=".$session_id;
            $result = mysqli_query($con, $query);
            $row = mysqli_fetch_array($result);
        }
        mysqli_close($con);
        
        $session_name = $row['session_name'];
        $user_name = "GigReplay";
        
    } else {
        $con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
        if (mysqli_connect_errno($con)) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        } else {
            //Find out if the video has already been created once before
            $query = "SELECT U.user_name, S.session_name FROM user_session US INNER JOIN user U on U.id = US.user_id INNER JOIN session S on S.id = US.session_id WHERE US.session_id = ".$session_id." AND US.user_id = ".$user_id;
            $result = mysqli_query($con, $query);
            $row = mysqli_fetch_array($result);
        }
        mysqli_close($con);
        
        $user_name = $row['user_name'];
        $session_name = $row['session_name'];
    }
    
    //Setting the title
    if (!$title) {
        $title = $session_name;
    }
    
    //Set default thumbnail. Append the default_thumbnail number to the string.

   // $thumbnail_url = dirname($media_url)."/thumb_".$default_thumb.".png";
    $thumbnail_url= $default_thumb;

// $thumbnail_url = dirname($media_url)."/thumb_".$default_thumb.".png";
    $thumbnail_url= $default_thumb;
    

?>
<!-- Select media details of vid -->

<!-- Edit Title of video -->
<?php 
$mediaid=$_POST['mediaid'];
$form_title=$_POST['title'];
$submit_title=$_POST['submit'];
if($submit_title){
	if($form_title)
	{
		$con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
		if (mysqli_connect_errno($con)) {
			echo "Failed to onnect to MySQL: " . mysqli_connect_error();
		} else {
			$query_title="UPDATE media_master SET title='$form_title' WHERE master_id= '$mediaid'" ;
			$result = mysqli_query($con, $query_title);
			header("Location: success.php?success=$mediaid");
		}
		
	}
	else
	{
		echo "Please Enter Valid Text.";
	}


}
mysqli_close($con);
?>
<!-- Edit Title of video -->

<!-- Grab Post data from form and process -->
<?php 
$username=$_POST['username'];
$mediaid=$_POST['mediaid'];
$userid=$_POST['userid'];
$comment=$_POST['comments'];
$submit=$_POST['submit'];
if($submit){
	if($username && $comment)
	{
		$con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
		if (mysqli_connect_errno($con)) {
			echo "Failed to onnect to MySQL: " . mysqli_connect_error();
		} else {
			$query="INSERT INTO user_comment (user_name,media_id,user_id,comment) VALUES ('$username','$mediaid','$userid','$comment')";
			$result = mysqli_query($con, $query);
			header("Location: success.php?success=$mediaid");
		}
		
	}
	else
	{
		echo "Please fill out all the fields.";
	}


}
mysqli_close($con);
?>
<!--Grab Post data from form and process  -->


<head>
<link rel="stylesheet" type="text/css" href="gigreplay.css" />
<link href="/bootstrap/dist/css/bootstrap.css" rel="stylesheet" media="screen">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="keywords" content="HTML,CSS,XML,JavaScript">
<meta name="description" content="GigReplay"
<meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<title><?=$title?></title>
<?php include 'headertest.php'; ?>


 <!-- Required for facebook post image -->
  <meta property="og:image" content="<?=$thumbnail_url?>"/>

 </head>

 <body style="padding-bottom: 100px;">
 
 <script>
  window.fbAsyncInit = function() {
  FB.init({
    appId      : '425449864216352', // App ID
    channelUrl : '//www.gigreplay.com/channel.html', // Channel File
    status     : true, // check login status
    cookie     : true, // enable cookies to allow the server to access the session
    xfbml      : true  // parse XFBML
  });

  // Here we subscribe to the auth.authResponseChange JavaScript event. This event is fired
  // for any authentication related change, such as login, logout or session refresh. This means that
  // whenever someone who was previously logged out tries to log in again, the correct case below 
  // will be handled. 
   FB.Event.subscribe('auth.authResponseChange', function(response) {
    // Here we specify what we do with the response anytime this event occurs. 
    if (response.status === 'connected') {
     
      testAPI();
    } else if (response.status === 'not_authorized') {
     
      FB.login();
    } else {
      
      FB.login();
    }
  });
  }; 
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
	 
	  

  // Load the SDK asynchronously
  (function(d){
   var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement('script'); js.id = id; js.async = true;
   js.src = "//connect.facebook.net/en_US/all.js";
   ref.parentNode.insertBefore(js, ref);
  }(document));

</script>
 
<?php include 'top_toolbar.php'; ?>


     <div class="row">
      <div class="col-12 col-lg-12">
       <div class="text-center" >
        <video id="video_with_controls" width="960px"  controls autobuffer poster="<?=$thumbnail_url?>" > <source src="<?=$media_url?>" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
       </div>
      <div class="text-center" style="margin-left:-500px;" >
       <div class="fb-like" data-href="http://www.gigreplay.com/myVideos.php?vid=<?php echo "$getthing";?>" data-width="200" data-show-faces="false" data-send="false"></div>
     <a href="https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fwww.gigreplay.com/myVideos.php?vid=<?php echo "$getthing";?>" target="_blank"><img src="resources/share.png" width=40px; height=40px;>
 	 <a href="https://twitter.com/share?url=http%3A%2F%2Fwww.gigreplay.com/myVideos.php?vid=<?php echo "$getthing";?>" target="_blank"><img src="resources/Twitter.png" width=40px; height=40px;></a>
 	 <img src="resources/youtube.png" width=40px; height=40px;>
 	 <img src="resources/pinterest.png" width=40px; height=40px;>
 	 <img src="resources/wordpress.png" width=40px; height=40px;>
</a>
</div>
      </div>
     </div>
    
     <div class="row"  >
     
      <div class="text-center" >
       <h1><?=$title?></h1>
       <p>Created by <?=$user_name?><br>
       Last modified <?=$last_modified?></p>
     
     </div>
     </div>
     <div >
     <!-- Form for editing title -->
      <div class="title-form" style="margin-left:auto; margin-right:auto; width:960px;">
     <form action="myVideos.php?vid=<?php echo $getthing ?>"  method="POST">
Title:<br />
<textarea class="form-control" rows="1" name="title" placeholder="Set title here" method="POST"></textarea><br />
<input type="hidden" name="mediaid" value="<?php echo "$media_id" ?>"/>
<input type="submit" class="btn btn-default pull-right" name="submit" value="Set" />
</form>
</div>
<br><br>
     <!--  Form for comments -->
     
     <div class="comments-form" style="margin-left:auto; margin-right:auto; width:960px;">
     <?php if(!$user){?>
     <?php }else {?>
     <form action="myVideos.php?vid=<?php echo $getthing ?>"  method="POST">   
Comments:<br />
<textarea class="form-control" rows="3" name="comments" placeholder="Type comment here" method="POST"></textarea><br />
<input type="hidden" name="username" value="<?php echo "$fb_user_name"?>"/>
<input type="hidden" name="mediaid" value="<?php echo"$media_id"?>"/>
<input type="hidden" name="userid" value="<?php echo"$fb_user_id"?>"/>
<input type="submit" class="btn btn-default pull-right" name="submit"  value="Comment" />
<br><br>
</form>
</div>
<?php }?>
<?php if(!$user){?>
	<div class="notloggedin-comments" style="margin-left:auto; margin-right:auto; width:960px;">
	<div class="list-group">
	<h4 class="list-group-item-heading">Please log in to view or comment</h4>
	<?php if ($user): ?>
      <a href="<?php echo $logoutUrl; ?>" onclick='login();'>Logout of Facebook</a>
    <?php else: ?>
      <div>
        <a href="<?php echo $loginUrl; ?>" onclick='login();'>Login with Facebook</a>
      </div>
    <?php endif ?>
	</div>
	</div>
	
<?php }else{ ?>
<?php 
$con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
if (mysqli_connect_errno($con)) {
	echo "Failed to onnect to MySQL: " . mysqli_connect_error();
} else {
	$query2="SELECT * FROM user_comment WHERE media_id=".$getthing." ORDER BY last_post DESC limit 10 ";
	$result2 = mysqli_query($con, $query2);
}


while($rows=mysqli_fetch_array($result2))
{
    $dfacebookid=$rows['user_id'];
     $dname=$rows['user_name'];
     $dcomment=$rows['comment'];?>
      <div class="comments" style="margin-left:auto; margin-right:auto; width:960px;">
    <div class="list-group">
    <h4 class="list-group-item-heading"><img src="http://graph.facebook.com/<?php echo $dfacebookid?>/picture?type=small&width=40&height=40"><?php echo $dname?></h4>
    <p class="list-group-item-text"><?php echo $dcomment?></p></br><hr>
  </a>
</div> 
</div>
<?php 
}

if(mysqli_num_rows($result2) == 0){?>
	<div class="zero-comments" style="margin-left:auto; margin-right:auto; width:960px;">
    <div class="list-group">
    <h4 class="list-group-item-heading">No Comments for this Video</h4>
</div> 
</div>
<?php 
}
mysqli_close($con);
}?>
     </div>

 </body>
 <?php include 'bottom_toolbar.php'; ?>



</html>

