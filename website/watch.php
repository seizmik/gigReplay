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
        $thumb_1 = $row['thumb_1_url'];
        $thumb_2 = $row['thumb_2_url'];
        $thumb_3 = $row['thumb_3_url'];
        $default_thumb = $row['default_thumb'];
        $last_modified = $row['date_modified'];
        
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
        
        //Setting the default thumbnail
        if ($default_thumb==1) {
            $thumbnail_url = $thumb_1;
        } else if ($default_thumb==2) {
            $thumbnail_url = $thumb_2;
        } else if ($default_thumb==3) {
            $thumbnail_url = $thumb_3;
        }
        
	?>

 <head>
  <title><?=$title?></title>
  <link rel="stylesheet" type="text/css" href="/gigreplay.css">
  <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
  <meta property="og:image" content="<?=$thumbnail_url?>"/>
  <meta name="keywords" content="HTML,CSS,XML,JavaScript">
  <meta name="description" content="GigReplay | Videos With A Different Angle">
  <link rel="shortcut icon" href='/resources/favicon.ico'>
 </head>

 <body>
<?php include 'top_toolbar.php'; ?>
  <div class="container-fluid">
   <div class="row-fluid">
    <div class="span1">
    </div>
    <div class="span10">
     <h1><?=$title?></h1>
     <video id="video_with_controls" width="960" controls autobuffer poster="<?=$thumbnail_url?>" autoplay> <source src="<?=$media_url?>" type="video/mp4" />
      	Your browser does not support the video tag
     </video>
     <div>
      <p>Created by <?=$user_name?><br>
      Last modified <?=$last_modified?></p>
     </div>
    </div>
    <div class="span1">
    </div>
   </div>
  </div>
 </body>
</html>