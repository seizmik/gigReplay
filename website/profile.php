<html>
<head>
<?php require 'php-sdk/facebook.php';
session_start();
if(isset($_SESSION['User'])) {
	$fb_user=$_SESSION['User']['id'];
}

?>
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
	height:400px;
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

<div class="profile_items_wrapper">

	<div class="profile_items_videos">
	<div class="panel panel-primary">
  <div class="panel-body">
    Videos Created
  </div>
  <div class="panel-footer">
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
<div class="profile_items_comments">
	<div class="profile_items_comments">
	<div class="panel panel-primary">
  <div class="panel-body">
    Comment
  </div>
  <div class="panel-footer">Panel footer</div>
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