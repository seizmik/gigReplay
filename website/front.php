<!DOCTYPE html>
<html lang="en">
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

// Login or logout url will be needed depending on current user state.
if ($user) {
  $logoutUrl = $facebook->getLogoutUrl();
} else {
  $loginUrl = $facebook->getLoginUrl();
}

?>

 <head>
<meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
  <title>GigReplay Video List</title>



    <?php if ($user): ?>
      <?php $fb_user_id=$user_profile['id'];?>
  	
    <?php else: ?>
  <? php //place some controls here to login user?>
    <?php endif ?>


<?php include 'header.php'; ?>
 
  <meta property="og:image" content="/resources/g_logo.png"/>
  <style type="text/css">
  
/** {
border: 1px black solid;
}*/
  </style>
 </head>

 <body>
<div id="fb-root"></div>
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

  // Load the SDK asynchronously
  (function(d){
   var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement('script'); js.id = id; js.async = true;
   js.src = "//connect.facebook.net/en_US/all.js";
   ref.parentNode.insertBefore(js, ref);
  }(document));

  // Here we run a very simple test of the Graph API after login is successful. 
  // This testAPI() function is only called in those cases. 
  function testAPI() {
    console.log('Welcome!  Fetching your information.... ');
    FB.api('/me', function(response) {
	var fb_id=response.id;
      console.log('Good to see you, ' + response.name + '.');
	console.log('fb.id is , '+response.id+'.');
	console.log(fb_id);

    });
  }
</script>


<?php include 'top_toolbar.php'; ?>
<!-- Create the webpage here -->
  <div class="row"><br><br>
  <div class="col-md-8"><p>gigReplay is still under construction, some links/objects may be broken</p></div>
</div>
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
    
<div class="fb-facepile" data-href="http://facebook.com/gigreplay" data-action="Comma separated list of action of action types" data-width="200" data-max-rows="1"></div>
     <ul class="nav nav-pills nav-stacked hidden-sm">
      <li class="active"><a href="#">Featured</a></li>
      <li><a href="#">My Videos</a></li>
      <li><a href="#">My Profile</a></li>
      <!--<li><a href="#">Inbox</a></li>-->
     </ul>
    </div>
    
    
    
    <div class="col-10 col-lg-9">
     <h3>Featured Video</h3>
     <div class="row">
      <div class="col-12 col-lg-12" style="max-width:960px;">
       <video width="100%" controls>
        <source src="http://www.lipsync.sg/uploads/master/318-Sunday_Morning_IV/19-Leon_Ng/output_hi.mp4" type="video/mp4">
       Your browser does not support the video tag.
       </video>
      </div>
     </div>
     <h3>More Videos</h3>
     <div class="row">

<?php
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
        $query = "SELECT * FROM media_master WHERE feature=1 ORDER BY master_id DESC LIMIT 0,50";
        $result = mysqli_query($con, $query);
        $num = mysqli_num_rows($result);
        //echo $num;
    }
    
    while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
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
        $append_url = "http://www.gigreplay.com/watch.php?vid=".$media_id;
        
        //Set user name
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
        
        //Set video title
        if (!$title) {
            $title = $session_name;
        }
        
        //Set default thumbnail. Append the default_thumbnail number to the string.
        $thumbnail_url = dirname($media_url)."/thumb_".$default_thumb.".png";
    
?>

      <div class="col-12 col-lg-4" style="max-width:320px;">
       <a href="<?=$append_url ?>" class="thumbnail">
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$default_thumb ?>" style="display:block;">
       </a>
        <div class="fb-like" data-href="http://www.gigreplay.com/watch.php?vid=<?php echo "$media_id";?>" data-width="200" data-show-faces="false" data-send="false"></div>
       <div class="caption">
        <a href="<?=$append_url ?>"><h3><?=$title ?></h3></a>
        <p>Created by <?=$user_name ?><br>
        <small><?=$views ?> views</small><br>
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