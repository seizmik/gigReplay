<!DOCTYPE html>
<html lang="en">

 <head>
  <title>GigReplay Video List</title>

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
   // Additional JS functions here
   window.fbAsyncInit = function() {
       FB.init({
               appId      : '425449864216352', // App ID
               channelUrl : '//www.gigreplay.com/channel.html', // Channel File
               status     : true, // check login status
               cookie     : true, // enable cookies to allow the server to access the session
               xfbml      : true  // parse XFBML
               });
    
       // Additional init code here
       FB.Event.subscribe('auth.authResponseChange', function(response) {
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
  </script>

<?php include 'top_toolbar.php'; ?>
<!-- Create the webpage here -->
  <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-1 col-lg-2">
     <ul class="nav nav-pills nav-stacked hidden-sm">
      <li class="active"><a href="#">Home</a></li>
      <li><a href="#">Subscriptions</a></li>
      <li><a href="#">Profile</a></li>
      <li><a href="#">Inbox</a></li>
     </ul>
    </div>
    <div class="col-10 col-lg-9">
    <h3>Featured Videos</h3>
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
        $thumb_1 = $row['thumb_1_url'];
        $thumb_2 = $row['thumb_2_url'];
        $thumb_3 = $row['thumb_3_url'];
        $default_thumb = $row['default_thumb'];
        $last_modified = $row['date_modified'];
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
        
        //Set default thumbnail
        if ($default_thumb==1) {
            $thumbnail_url = $thumb_1;
        } else if ($default_thumb==2) {
            $thumbnail_url = $thumb_2;
        } else if ($default_thumb==3) {
            $thumbnail_url = $thumb_3;
        }
    
?>

      <div class="col-12 col-lg-4">
       <a href="<?=$append_url ?>" class="thumbnail">
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$thumbnail_url ?>" style="display:block;">
       </a>
       <div class="caption">
        <a href="<?=$append_url ?>"><h3><?=$title ?></h3></a>
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