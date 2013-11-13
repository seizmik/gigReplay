<html>
<head>
<?php require 'php-sdk/facebook.php';
session_start();
if(isset($_SESSION['User'])) {
	$fb_user=$_SESSION['User']['id'];
}

?>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js" type="text/javascript"></script>

<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
<script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>

<style type="text/css">

body{
	
}

.profile_wrapper{
	margin-top:0 px;
	margin-left:auto;
	margin-right:auto;
	width:1000px;
	height:300px;
}
.profile_details{
	width:700px;
	height:300px;
	float:left;
}
.network{
	width:300px;
	height:300px;
	margin-left:700px;
	
}
.profile_items_wrapper{
	margin-left:auto;
	margin-right:auto;
	width:990px;
	height:auto;
	
	
}
.profile_items_videos{
	width:990px;
	margin-left:auto;
	margin-right:auto;
	height:auto;
	
}
.profile_items_friends_videos{
	width:990px;
	margin-left:auto;
	margin-right:auto;
	height:auto;
}
.profile_items_comments{
position:absolute;
	width:990px;
	height:auto;
	
	
}

.footer{
	margin-bottom:0px;
	
}

</style>

</head>
<?php 
session_start();
if(!$_SESSION['User']){?>
<h3> Please Log in to Continue</h3>
<?php }else{?>

	

<body>

<div class="navbar navbar-inverse">
<a class="navbar-brand" href="http://www.gigreplay.com">
<div class="col-2 col-lg-2"><img src='/resources/g_logo_title_invert.png' /></div>
</a>
<?php 
session_start();
if(!isset($_SESSION['User']) && empty($_SESSION['User']))   { ?>
 <button type="button" class="btn btn-primary btn-lg " id="facebook" >Facebook Login</button>
<!-- <img src="resources/facebook.png"  id="facebook"  style="cursor:pointer;" />-->
<?php  }  else{?>
	<p class="navbar-text pull-right"><?php echo '<img src="https://graph.facebook.com/'. $_SESSION['User']['id'] .'/picture" width="50" height="50"/>';?> <?php  echo $_SESSION['User']['name'];?></br><a href="<?php echo $_SESSION['logout'] ?>" class="navbar-link">Logout</a></p>
 <?php // echo '<img src="https://graph.facebook.com/'. $_SESSION['User']['id'] .'/picture" width="50" height="50"/>'.$_SESSION['User']['name'].'';	
// 	echo '<a href="'.$_SESSION['logout'].'">Logout</a>';


}
	?>
</div>


<div class="profile_wrapper">

	<div class="profile_details">
	<?php 	
		session_start();
		?>
		<div class="picture" style="margin:20px;width:200px;height:200px; float:left;">
	 	<?php echo '<img src="https://graph.facebook.com/'. $_SESSION['User']['id'] .'/picture?type=large" />';?>
	 	</div>
	 	<div class="info" style="margin:20px;width:400px;height:200px; margin-left:240px;">
	 	<?php echo $_SESSION['User']['id'];?><br>
	 	<?php echo $_SESSION['User']['name'];?><br>
	 	<?php echo $_SESSION['User']['email'];?><br>
	 	<?php echo $_SESSION['User']['birthday'];?><br>
	 	<?php echo $_SESSION['User']['user_work_history'];?><br>
	 	
	 	</div>
	 	
	
	</div>
	
	<div class="network">
		<h2 style="margin:auto;">Network</h2>
		<?php 
			$con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
   				 if (mysqli_connect_errno($con)) {
       				 echo "Failed to onnect to MySQL: " . mysqli_connect_error();
   				 } else {
				
     	 	 	 $query2 = "SELECT * FROM user_friends WHERE user_id=19";
       			 $result2 = mysqli_query($con, $query2);
      	
      		   }
      		     
      		   while ($entry2 = mysqli_fetch_array($result2)) {
      		   	$entries2[]=$entry2;
      		   }
      		      		   
      		   foreach ($entries2 as $row) {
			
				$fb_user_id=$row['fb_user_id'];
				$fb_user_name=$row['fb_user_name'];
				
				
				?>
				<div class="network_friends" style="float:left; width:60px;height:60px;  text-align:center; margin:20px; " >
				
				<?php echo '<img src="https://graph.facebook.com/'. $fb_user_id .'/picture" width="50" height="50"/>';?><br>
				<?php echo $fb_user_name;?>
				</div>
				<?php 
				mysqli_close($con);
				}

      		   ?>

	</div>
	
</div>

<div class="profile_items_wrapper" >

	<div class="profile_items_videos" id="accordion" >
	<div class="panel panel-primary" >
  <div class="panel-body">
   <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
          Videos Created
        </a>
    
  </div>
  <div id="collapseOne" class="panel-collapse collapse ">
  <div class="panel-footer"  >
  
  <?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else { 
		$query =" SELECT * FROM gigreplay.media_master JOIN thesmos.user on gigreplay.media_master.user_id=thesmos.user.id WHERE thesmos.user.fb_user_id=".$fb_user;
        $result = mysqli_query($con, $query);

    }
    
  
while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;

        
}
if(mysqli_num_rows($result) == 0){?>
                	
                    
                    <p>No videos created by <?php echo $_SESSION['User']['name']?></p>
               
                
                <?php 
                }
    
    //Initialise the row count
   
    foreach ($entries as $row) {
        $session_name = $row['title'];
        $master_id=$row['master_id'];
        $default_thumb=$row['default_thumb'];
        $media_url = $row['media_url'];
        $user_name=$row['user_name'];
        $last_modified=$row['date_modified'];
        $append_url ="http://www.gigreplay.com/myVideos.php?vid=".$master_id;
        
        
        
   
    ?>
    <div class="thumbnail" style="margin-bottom:20px;">
    <a href="<?=$append_url ?>" >
    	<img  src="<?=$default_thumb ?>" style="display:block; width:640px;height:360px; margin:auto; padding:5px;" >
    	</a>
    	<?php for ($i = 4; $i < 11; $i+=3) {
    		$thumbnail_url = dirname($media_url)."/thumb_".$i.".png";	?>
    		
    		<img src="<?=$thumbnail_url ?>" style="display:inline; width:300px;height:150px; padding:5px;">
    	<?php }?>
        
       
       <div class="caption" style="text-align:center;">
        <a href="<?=$append_url ?>"> <h3><?=$session_name ?></h3></a>
        <p>Created by <?=$user_name ?><br>
        <small>Created at <?=$last_modified ?></small></p>
       </div>
     </div>
     <?php 
			mysqli_close($con);
	}?>
  </div>
</div>
</div>
</div>

	<div class="profile_items_friends_videos" id="accordion" >
	<div class="panel panel-primary" >
  <div class="panel-body">
   <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
          My Friends Videos
        </a>
    
  </div>
  <div id="collapseTwo" class="panel-collapse collapse ">
  <div class="panel-footer"  >
  
  <?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else { 
		$query3="SELECT * from gigreplay.media_master,thesmos.user_friends,thesmos.user where gigreplay.media_master.user_id=thesmos.user_friends.user_friend_id AND thesmos.user.id=thesmos.user_friends.user_friend_id  ORDER BY gigreplay.media_master.session_id DESC limit 25 ";
        $result3 = mysqli_query($con, $query3);

    }
    
  
while ($entry3 = mysqli_fetch_array($result3)) {
        $entries3[]=$entry3;

        
}
if(mysqli_num_rows($result3) == 0){?>
                	
                    
                    <p>No videos by friends</p>
               
                
                <?php 
                }
    
    //Initialise the row count
   
    foreach ($entries3 as $row) {
        $session_name = $row['title'];
        $master_id=$row['master_id'];
        $default_thumb=$row['default_thumb'];
        $media_url = $row['media_url'];
        $user_name=$row['user_name'];
        $last_modified=$row['date_modified'];
        $append_url ="http://www.gigreplay.com/myVideos.php?vid=".$master_id;
        
        
        
   
    ?>
    <div class="thumbnail" style="margin-bottom:20px;">
    <a href="<?=$append_url ?>" >
    	<img  src="<?=$default_thumb ?>" style="display:block; width:640px;height:360px; margin:auto; padding:5px;" >
    	</a>
    	<?php for ($i = 4; $i < 11; $i+=3) {
    		$thumbnail_url = dirname($media_url)."/thumb_".$i.".png";	?>
    		
    		<img src="<?=$thumbnail_url ?>" style="display:inline; width:300px;height:150px; padding:5px;">
    	<?php }?>
        
       
       <div class="caption" style="text-align:center;">
        <a href="<?=$append_url ?>"> <h3><?=$session_name ?></h3></a>
        <p>Created by <?=$user_name ?><br>
        <small>Created at <?=$last_modified ?></small></p>
       </div>
     </div>
     <?php 
			mysqli_close($con);
	}?>
  </div>
</div>
</div>
</div>

<div class="profile_items_comments" id="accordion">
	<div class="profile_items_comments">
	<div class="panel panel-primary">
  <div class="panel-body">
    <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
          Comments
        </a>
  </div>
  <div id="collapseThree" class="panel-collapse collapse ">
  <div class="panel-footer">
  <p>No comments for <?php echo $_SESSION['User']['name']?></p>
  </div>
</div>
	
	</div>
</div>

</div>
</div>

<!-- <div class="footer"> -->
<!--  <div class="navbar navbar-inverse"> -->
<!-- <a class="navbar-brand" href="http://www.gigreplay.com"> -->
<!-- <div class="col-2 col-lg-2"><img src='/resources/g_logo_title_invert.png' /></div> -->
<!-- </a> -->
<!-- </div> -->
 
<!--  </div> -->

</body>


<?php }
?>
</html>