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
      <?php $fb_user_id=$user_profile['id'];
       $fb_user_name=$user_profile['name'];?>
  	
    <?php else: ?>
    
  <? php //place some controls here to login user?>
    <?php endif ?>
    
    
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
?>
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
			header("Location: success2.php?success=$mediaid");
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
  <title><?=$title?></title>

<?php include 'header.php'; ?>

  <meta property="og:image" content="<?=$thumbnail_url?>"/>
  <link rel="shortcut icon" href='/resources/favicon.ico'>
  <style type="text/css">
/** {
border: 1px black solid;
}*/
  </style>
 </head>

 <body>
 
<?php include 'top_toolbar.php'; ?>
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
   

    
     <div class="row">
      <div class="col-12 col-lg-12">
       <div class="text-center" style="margin-left:auto; margin-right:auto;">
        <video id="video_with_controls"  controls autobuffer poster="<?=$thumbnail_url?>"> <source src="<?=$media_url?>" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
       </div>
      </div>
    
     
       <div class="text-center"">
       <h1><?=$title?></h1>
       <h3><?=$title?></h3>
       <p>Created by <?=$user_name?><br>
       Last modified <?=$last_modified?></p>
       <div class="text-center" style="margin-top:1.5em;">
       <p ><strong><?=$views ?></strong> views</p>
      </div>
      </div>
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
</html>

<?php
    $views++;
    //Time to increment the number of views. This should be done 5 seconds after the video is played. Need to also find some way to prevent botting.
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        //Find out if the video has already been created once before
        $query = "UPDATE media_master SET views=".$views." WHERE master_id=".$getthing;
        $result = mysqli_query($con, $query);
    }
    mysqli_close($con);
    
    
?>