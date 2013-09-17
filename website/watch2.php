<!DOCTYPE html>
<html prefix="og: http://ogp.me/ns#">
<?php
    
    function time2str($ts)
    {
        if(!ctype_digit($ts))
            $ts = strtotime($ts);
        
        $diff = time() - $ts;
        if($diff == 0)
            return 'now';
        elseif($diff > 0)
        {
            $day_diff = floor($diff / 86400);
            if($day_diff == 0)
            {
                if($diff < 60) return 'just now';
                if($diff < 120) return '1 minute ago';
                if($diff < 3600) return floor($diff / 60) . ' minutes ago';
                if($diff < 7200) return '1 hour ago';
                if($diff < 86400) return floor($diff / 3600) . ' hours ago';
            }
            if($day_diff == 1) return 'Yesterday';
            if($day_diff < 7) return $day_diff . ' days ago';
            if($day_diff < 31) return ceil($day_diff / 7) . ' weeks ago';
            if($day_diff < 60) return 'last month';
            return date('F Y', $ts);
        }
        else
        {
            $diff = abs($diff);
            $day_diff = floor($diff / 86400);
            if($day_diff == 0)
            {
                if($diff < 120) return 'in a minute';
                if($diff < 3600) return 'in ' . floor($diff / 60) . ' minutes';
                if($diff < 7200) return 'in an hour';
                if($diff < 86400) return 'in ' . floor($diff / 3600) . ' hours';
            }
            if($day_diff == 1) return 'Tomorrow';
            if($day_diff < 4) return date('l', $ts);
            if($day_diff < 7 + (7 - date('w'))) return 'next week';
            if(ceil($day_diff / 7) < 4) return 'in ' . ceil($day_diff / 7) . ' weeks';
            if(date('n', $ts) == date('n') + 1) return 'next month';
            return date('F Y', $ts);
        }
    }
    
    // End of Function list ----------------------------------------
    
    
    if (is_numeric($_GET['vid'])) {
        $getthing = $_GET['vid'];
    } else {
        die("Unable to find video.");
    }
    
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
  <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-lg-1 hidden-sm">
    </div>
    <div class="col-12 col-lg-10" style="max-width:960px">
     <div class="row">
      <div class="col-12 col-lg-12">
       <div class="text-center" style="margin-left:auto; margin-right:auto;">
        <video id="video_with_controls" width="100%" controls autobuffer poster="<?=$thumbnail_url?>" autoplay> <source src="<?=$media_url?>" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
       </div>
      </div>
     </div>
     <div class="row"><div class="col-12 col-lg-12">
      <div class="row">
       <div class="col-9 col-lg-9">
        <span class="hidden-sm"><h1><?=$title?></h1></span>
        <span class="visible-sm"><h3><?=$title?></h3></span>
        <p>Created by <?=$user_name?><br>
        Last modified <?=$last_modified?></p>
       </div>
       <div class="col-3 col-lg-3" style="margin-top:1.5em;">
        <p class="text-right"><strong><?=$views ?></strong> views</p>
       </div>
      </div>

      <!--Comments section-->
      <div class="row">
       <form role="form">
        <div class="form-group">
         <label for="insertComment">Comments:</label>
         <input type="comment" class="form-control" id="insertComment" placeholder="Type comment here">
        </div>
        <button type="button" class="btn btn-default pull-right">Submit</button>
       </form>
      </div>
      <hr/>
      <div class="row">
       <h3>User comments</h3>

<?php
    //Retieve all the comments from media_master
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        //Find out if the video has already been created once before
        
        $query = "SELECT * FROM socialMedia WHERE media_id=".$media_id." ORDER BY date_created DESC";
        
        $comment_results = mysqli_query($con, $query);
    }
    mysqli_close($con);
    
    //If there are no comments, put something different
    if (mysqli_num_rows($comment_results) == 0) {
        
?>
       <p>There are no comments for this video yet.</p>
<?php
    } else {
        while ($comment = mysqli_fetch_array($comment_results)) {
            $comment_array[] = $comment;
        }
        foreach ($comment_array as $row) {
            $comment_user_id = $row['user_id'];
            $comment_user_name = $row['user_name'];
            $comment_text = $row['comment'];
            $comment_up = $row['thumb_up'];
            $comment_down = $row['thumb_down'];
            $comment_flag = $row['flagged'];
            $comment_date = time2str($row['date_created']);

?>

       <!--A comment entry-->
       <div class="row">
        <div class="col-12 col-lg-12"> <!--Decorate this division-->
         <p>
          <b><?=$comment_user_name?></b> writes:<br>
          <?=$comment_text?><br>
          <small><?=$comment_date?></small>
         </p>
         <div class="btn-toolbar pull-right">
          <div class="btn-group">
           <button type="button" class="btn btn-default"><span class="glyphicon glyphicon-thumbs-up"></span></button>
           <button type="button" class="btn btn-default"><span class="glyphicon glyphicon-thumbs-down"></span></button>
          </div>
          <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-warning-sign"></span></button>
         </div>
        </div>
       </div>

<?php
        }
    }
?>

      </div>

      <!--Comments portion end-->

     </div></div>
    </div>
    <div class="col-lg-1 hidden-sm">
    </div>
   </div>
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