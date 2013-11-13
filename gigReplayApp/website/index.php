<!DOCTYPE html>
    
<html>
<head>
<!--  meta data of html -->
<meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="keywords" content="HTML,CSS,XML,JavaScript">
<meta name="description" content="GigReplay">

<!-- Jquery cdn links -->
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js" type="text/javascript"></script>

<!-- Bootstrap js/css files from cdn -->
<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
<script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>

<!-- ColorBox js/css files -->
<link rel="stylesheet" href="js/colorbox.css" />
<script src="js/jquery.colorbox.js"></script>




<!-- This script for facebook pop up log in -->
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

	$(document).ready(function() {
		$(".youtube").colorbox({iframe:true, innerWidth:640, innerHeight:350});
	});
</script>

<style type="text/css">
body{
position:relative;
margin-top: 0px; 
margin-bottom: 0px;
 margin-left: 0px;
  margin-right: 0px;
    padding: 0;
    background:#222;
    
   
    }
.company-logo{
background:#fff;
float:left;
width:800px;
height:540px;
}
.slideshow{
margin-left:800px;
width:960px;
height:540px;
}
.other-videos{
clear:both;
margin-left:auto;
margin-right:auto;
height:auto;
width:1760px;
margin-bottom:100px;


}
.wrapper{
margin-left:auto;
margin-right:auto;
width:1760px;

}
.individual-video{
position: relative;
float:left;
width:25%;
height:280px;
margin-top: 0px; 
margin-bottom: 0px;
 margin-left: 0px;
  margin-right: 0px;
padding: 2px;
background:#fff;



}
.individual-video:hover .imgDescription  {
  visibility: visible;
  opacity: 1;


      } 
.individual-video:hover .playbutton{

  visibility: visible;
  opacity: 1;

}
      
.playbutton{
position: absolute;
top:10px;
left:10px;
width:50px;
height:50px;
visibility: hidden;
}

.imgDescription {
  position: absolute;
  text-align:center;
  bottom: 0;
  left: 0;
  right: 0;
  background: clear;
  color: #fff;
  visibility: hidden;
  font-family: HelveticaNeue-Light, "Helvetica Neue Light";
   font-size:20px;

}
.footer{
float:left;
width:100%;
height:60px;
position:relative;
background:#585858;
}
.side-floater{
position:fixed;
background:clear;
right:0;
top:300px;
width:70px;
height:400px;
}
</style>
</head>
<body>
<div class="wrapper">
<div class="company-logo">
<img src="resources/g_logo_title_large.png" >
<h1>Delivering Multi-angled videos! your videos will never be the same again</h1>
<hr>

<h3> Join us in creating dynamic and exciting production-style videos and share your videos with the world</h3><br>
<p>
  <button type="button" class="btn btn-primary btn-lg">Join|GigReplay</button>
  <button type="button" class="btn btn-default btn-lg">Sign|In</button>
 <?php 
session_start();
if(!isset($_SESSION['User']) && empty($_SESSION['User']))   { ?>
 <button type="button" class="btn btn-primary btn-lg " id="facebook" >Facebook Login</button>
<!-- <img src="resources/facebook.png"  id="facebook"  style="cursor:pointer;" />-->
<?php  }  else{
	
 echo '<img src="https://graph.facebook.com/'. $_SESSION['User']['id'] .'/picture" width="50" height="50"/>'.$_SESSION['User']['name'].'';	
	echo '<a href="'.$_SESSION['logout'].'">Logout</a>';


}
	?>
</p>
	

</div>
<div class="slideshow">
<div id="carousel-example-generic" class="carousel slide">
  <!-- Indicators -->
  <ol class="carousel-indicators">
    <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
    <li data-target="#carousel-example-generic" data-slide-to="1"></li>
    <li data-target="#carousel-example-generic" data-slide-to="2"></li>
    <li data-target="#carousel-example-generic" data-slide-to="2"></li>
  </ol>

  <!-- Wrapper for slides -->
  <div class="carousel-inner">
    <div class="item active">
<!--     <a href="http://www.gigreplay.com/watch.php?vid=21" > <img src="http://www.gigreplay.com/resources/trouble.png" width="960px" height="500px" alt="..."></a> -->
     <video id="video_with_controls" width="960px" height="540px"  autobuffer autoplay loop > <source src="http://www.gigreplay.com/resources/Movie.mp4" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
<!--       <div class="carousel-caption"> -->
<!--         <h3>Cover of trouble</h3> -->
<!--     <p>#Maricella,#Travis</p> -->
<!--       </div> -->
    </div>
    <div class="item">
     <a href="http://www.gigreplay.com/watch.php?vid=21" > <img src="http://www.gigreplay.com/resources/trouble.png" width="960px" height="500px" alt="..."></a>
     
      <div class="carousel-caption">
        <h3>Cover of trouble</h3>
    <p>#Maricella,#Travis</p>
      </div>
    </div>
    <div class="item">
    <a href="http://www.gigreplay.com/watch.php?vid=4" > <img src="http://www.gigreplay.com/resources/froya.png" width="960px" height="500px" alt="..."></a>
    
      <div class="carousel-caption">
        <h3>Froya - Fries With Cream</h3>
    <p>@Esplanade, Singapore!</p>
      </div>
    </div>
   <div class="item">
    <a href="http://www.gigreplay.com/watch.php?vid=6" > <img src="http://www.gigreplay.com/resources/saveme.png" width="960px" height="500px" alt="..."></a>
    
      <div class="carousel-caption">
        <h3>Save Me Hollywood - Happier This Way</h3>
    <p>@Esplanade, Singapore!</p>
      </div>
    </div>
      
    
  </div>

  <!-- Controls -->
  <a class="left carousel-control" href="#carousel-example-generic" data-slide="prev" data-interval="false" >
    <span class="icon-prev"></span>
  </a>
  <a class="right carousel-control" href="#carousel-example-generic" data-slide="next" data-interval="false" >
    <span class="icon-next"></span>
  </a>
</div>
</div>
</div>

<div class="other-videos">
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
	
	
      <div class="individual-video" >
       
     <a href=<?php echo $append_url?>><img src="<?=$default_thumb ?>" style="width:436px; height:276px;"></a>
        
      <!--  <a class='youtube'  href="<?=$append_url ?>"  > -->
       <a class='youtube'  href="<?=$media_url_lo ?>"  >
       <div class="playbutton" ><img src="resources/g_logo.png" style="width:40px;height:40px;"></div> 
       </a>
        
       <p class="imgDescription" ><?=$title ?></p>
   
    


		</div>
		
     
     

<?php 
        }
    
?>
     </div>
     
 <div class="footer">
 <a class="navbar-brand" href="http://www.gigreplay.com">
 <div class="row">
  <div class="col-2 col-lg-2"><img src='/resources/g_logo_title_invert.png' />
  
  </div>
  </div>
 </a>
 
 </div>
  <div class="side-floater">
    <a href="http://www.gigreplay.com" data-toggle="tooltip" title="Home"><img src="/resources/home.png" style="width:50px; height:50px;" > </a>
 	<a href="http://www.gigreplay.com/profile.php" data-toggle="tooltip" title="My Profile"><img src="/resources/profile.png" style="width:50px; height:50px;" > </a>
 	<a href="" data-toggle="tooltip" title="My Sessions"><img src="/resources/session.png" style="width:50px; height:50px;" > </a>
 	<a href="" data-toggle="tooltip" title="G Videos"><img src="/resources/g.png" style="width:50px; height:50px;" > </a>
 	<a href="" data-toggle="tooltip" title="Store"><img src="/resources/store.png" style="width:50px; height:50px;" > </a>
 </div>

    
</body>

 
</html>