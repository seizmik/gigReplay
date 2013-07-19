<!DOCTYPE html>
<html lang="en">

 <head>
  <title>GigReplay Video List</title>
  <link rel="stylesheet" type="text/css" href="/gigreplay.css">
  <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
  <link rel="shortcut icon" href="/resources/favicon.ico">
  <meta property="og:image" content="/resources/g_logo.png"/>
  <meta name="keywords" content="HTML,CSS,XML,JavaScript">
  <meta name="description" content="GigReplay">
  <style type="text/css">
/** {
border: 1px black solid;
}*/
  </style>
 </head>

 <body>
<?php include 'top_toolbar.php'; ?>
  <div class="container-fluid">
   <div class="row-fluid">
    <div class="span2">
     <p>There should be a left panel here</p>
    </div>
    <div class="span9">
     <h2>Featured Videos</h2>
     <div class="row-fluid">
      <ul class="thumbnails">

<?php
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
        $query = "SELECT * FROM media_master ORDER BY master_id DESC LIMIT 0,50";
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

       <li class="span4">

         <a href="<?=$append_url ?>" class="thumbnail span12">
         <img src="<?=$thumbnail_url ?>" /></a>
         <a href="<?=$append_url ?>"><h3><?=$title ?></h3></a>
         Created by <?=$user_name ?><br>
         <small>Created at <?=$last_modified ?></small>
       </li>

<?php
        $row_count++;
        if($row_count>=3) {
        //Echo out the new row and start a new one
?>

      </ul>
     </div>
     <div class="row-fluid">
      <ul class="thumbnails">

<?php
            $row_count=0;
        }
    }
?>

      </ul>
     </div>
    </div>
    <div class="span1">
     <p>There should be a right panel here.</p>
    </div>
   </div>
  </div>
 </body>

</html>