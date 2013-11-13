<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html lang="en">
<?php

// require 'config.php';
// require 'php-sdk/facebook.php';

// // Create our Application instance (replace this with your appId and secret).
// $facebook = new Facebook(array(
//   'appId'  => '425449864216352',
//   'secret' => 'e0a33ee97563372f964df382b350af30',
// ));

// // Get User ID
// $user = $facebook->getUser();



// if($user){

// 	try{
// 		//get the facebook user profile data
// 		$user_profile = $facebook->api('/me');
// 		$params = array('next' => $base_url.'logout.php');
// 		//logout url
// 		$logout =$facebook->getLogoutUrl($params);
// 		$_SESSION['User']=$user_profile;
// 		$_SESSION['logout']=$logout;
// 	}catch(FacebookApiException $e){
// 		error_log($e);
// 		$user = NULL;
// 	}		
// }
	
// if(empty($user)){
// //login url	
// $loginurl = $facebook->getLoginUrl(array(
// 				'scope'			=> 'email,read_stream, publish_stream, user_birthday, user_location, user_work_history, user_hometown, user_photos',
// 				'redirect_uri'	=> $base_url.'/login.php',
// 				'display'=>'popup'
// 				));

// header('Location: '.$loginurl);
// }

// ?>

 <head>
 <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js" type="text/javascript"></script>
<script type="text/javascript" src="js/oauthpopup.js"></script>
<script type="text/javascript">
$(document).ready(function(){
    $('#facebook').click(function(e){
        $.oauthpopup({
            path: 'login.php',
			width:600,
			height:300,
            callback: function(){
                window.location.reload();
            }
        });
		e.preventDefault();
    });
});


</script>
<meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
  <title>GigReplay Video List</title>



    <?php if ($user): ?>
      <?php $fb_user_id=$user_profile['id'];?>
  	
    <?php else: ?>
  <? php //place some controls here to login user?>
    <?php endif ?>


<?php include 'headertest.php'; ?>
 
  <meta property="og:image" content="/resources/g_logo.png"/>
  <style type="text/css">
  
/** {
border: 1px black solid;
}*/
  </style>
  
 </head>

 <body >


<?php include 'top_toolbar.php'; ?>
<!-- Create the webpage here -->
  <div class="row"><br><br>
  <div class="col-md-8"><p>gigReplay is still under construction, some links/objects may be broken</p></div>
</div>
  <div class="col-12 col-lg-12">
   <div class="row">
    <div class="col-1 col-lg-2">
 <?php 
session_start();
if(!isset($_SESSION['User']) && empty($_SESSION['User']))   { ?>
<img src="resources/facebook.png" id="facebook"  style="cursor:pointer;" />
<?php  }  else{
	
 echo '<img src="https://graph.facebook.com/'. $_SESSION['User']['id'] .'/picture" width="30" height="30"/><div>'.$_SESSION['User']['name'].'</div>';	
	echo '<a href="'.$_SESSION['logout'].'">Logout</a>';


}
	?>
    
<div class="fb-facepile" data-href="http://facebook.com/gigreplay" data-action="Comma separated list of action of action types" data-width="200" data-max-rows="1"></div>
     <ul class="nav nav-pills nav-stacked hidden-sm">
      <li class="active"><a href="http://www.gigreplay.com/example.php">Featured</a></li>
      <li><a href="http://www.gigreplay.com/myAccount_Videos.php">myG-Videos</a></li>
      <li><a href="http://www.gigreplay.com/myAccount_Session.php">mySessionVideos</a></li>
      <!--<li><a href="#">Inbox</a></li>-->
     </ul>
    </div>
    
    
    
    <div class="col-10 col-lg-9">
    <div class="whats-hot" style=" width:400px; float:right; margin-right:0px; clear:both;">
      <h3>Whats Hot on Youtube</h3>
     	
<!--      <iframe width="560" height="315" src="//www.youtube.com/embed/cbU-V0nW3Bs" frameborder="0" allowfullscreen></iframe> -->
<!--      <p> Korean k-POP Girl Group Girls Day back to capturing millions of view on youtube with their sexy moves..</p> -->
<!--      <br> -->
     
<!--      <iframe width="560" height="315" src="//www.youtube.com/embed/jXOgYxUf6Ts" frameborder="0" allowfullscreen></iframe> -->
<!--      <p>Awesome live TECHNO</p> -->
<!--      <br> -->
     
     </div>
     <h3>Featured Video</h3>
<!--      <div class="row"> -->
      <div class="col-12 col-lg-12" style="max-width:960px;">
      <div id="carousel-example-generic" class="carousel slide">
  <!-- Indicators -->
  <ol class="carousel-indicators">
    <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
    <li data-target="#carousel-example-generic" data-slide-to="1"></li>
    <li data-target="#carousel-example-generic" data-slide-to="2"></li>
  </ol>

  <!-- Wrapper for slides -->
  <div class="carousel-inner">
    <div class="item active">
    <a href="http://www.gigreplay.com/watch.php?vid=21" > <img src="http://gigreplay.com/resources/trouble.png" width="960px" height="500px" alt="..."></a>
     
      <div class="carousel-caption">
        <h3>Cover of trouble</h3>
    <p>#Maricella,#Travis</p>
      </div>
    </div>
    <div class="item">
    <a href="http://www.gigreplay.com/watch.php?vid=4" > <img src="http://gigreplay.com/resources/froya.png" width="960px" height="500px" alt="..."></a>
    
      <div class="carousel-caption">
        <h3>Froya - Fries With Cream</h3>
    <p>@Esplanade, Singapore!</p>
      </div>
    </div>
   <div class="item">
    <a href="http://www.gigreplay.com/watch.php?vid=6" > <img src="http://gigreplay.com/resources/saveme.png" width="960px" height="500px" alt="..."></a>
    
      <div class="carousel-caption">
        <h3>Save Me Hollywood - Happier This Way</h3>
    <p>@Esplanade, Singapore!</p>
      </div>
    </div>
      
    
  </div>

  <!-- Controls -->
  <a class="left carousel-control" href="#carousel-example-generic" data-slide="prev">
    <span class="icon-prev"></span>
  </a>
  <a class="right carousel-control" href="#carousel-example-generic" data-slide="next">
    <span class="icon-next"></span>
  </a>
</div>
<!--        <video width="100%" controls> -->
<!--         <source src="http://www.lipsync.sg/uploads/master/301-Maricelle_Sunday_Morning_II/0-GigReplay_Admin/output.mp4" type="video/mp4"> -->
<!--        Your browser does not support the video tag. -->
<!--        </video> -->
<!--       </div> -->
<!--      </div> -->
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
    
   </div>
  </div>
 </body>

</html>