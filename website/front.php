<!DOCTYPE html>
<html lang="en">
 <head>

  <title>GigReplay Video List</title>

<?php include 'header.php'; ?>
<?php require_once("php-sdk/facebook.php"); ?>
<?php $config = array();
  $config['appId'] = '425449864216352';
  $config['secret'] = 'e0a33ee97563372f964df382b350af30';
  $config['fileUpload'] = true; // optional

  $facebook = new Facebook($config);
  $uid = $facebook->getUser();
  
  ?>
 
  <meta property="og:image" content="/resources/g_logo.png"/>
  <style type="text/css">
  
/** {
border: 1px black solid;
}*/
  </style>
 </head>

 <body>

<?php include 'top_toolbar.php'; ?>
<!-- Create the webpage here -->
  <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-1 col-lg-2">
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
        <source src="http://www.lipsync.sg/uploads/master/301-Maricelle_Sunday_Morning_II/0-GigReplay_Admin/output.mp4" type="video/mp4">
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
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$thumbnail_url ?>" style="display:block;">
       </a>
       <div class="caption">
        <a href="<?=$append_url ?>"><h3><?=$title ?></h3></a>
        <p>Created by <?=$user_name ?><br>
        <small>"<?=$views ?>" views</small><br>
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