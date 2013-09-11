<!DOCTYPE html>
<html prefix="og: http://ogp.me/ns#">
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
  <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-lg-1 hidden-sm">
    </div>
    <div class="col-12 col-lg-10" style="max-width:960px">
     <div class="row">
      <div class="col-12 col-lg-12">
       <div class="text-center" style="margin-left:auto; margin-right:auto;">
        <video id="video_with_controls" width="640px" controls autobuffer poster="<?=$thumbnail_url?>" autoplay> <source src="<?=$media_url?>" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
       </div>
      </div>
     </div>
     <div class="fb-like" data-href="http://www.gigreplay.com/myVideos.php?vid=<?php echo "$getthing";?>" data-width="200" data-show-faces="true" data-send="false"></div>
     <div class="row">
      <div class="col-9 col-lg-9">
       <span class="hidden-sm"><h1><?=$title?></h1></span>
       <span class="visible-sm"><h3><?=$title?></h3></span>
       <p>Created by <?=$user_name?><br>
       Last modified <?=$last_modified?></p>
      </div>
     </div>
    </div>
    <div class="col-lg-1 hidden-sm">
    </div>
   </div>
  </div>
 </body>
</html>

