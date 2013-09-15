<html>
<head>
<meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<?php include 'header.php'; ?>
</head>
<body>

<?php include 'top_toolbar.php'; ?>
<div class="col-12 col-lg-12">
<div class="row">
<div class="col-10 col-lg-9">
     <div class="row">
      <div class="col-12 col-lg-12" style="max-width:960px;">
      </div>
     </div>
     <div class="row">
      <div class="col-12 col-lg-12" style="max-width:960px;">
      </div>
     </div>
     <h3>My Sessions Created/Joined</h3>
     <div class="row">
<?php $getSessionId = $_GET['sid'];?>
<?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
	
        
    	//$query =" SELECT * FROM gigreplay.media_master JOIN thesmos.user on media_master.user_id=thesmos.user.id WHERE media_master.user_id=19";
        $query="SELECT DISTINCT media_url,session_name,session_id,user_id FROM gigreplay.media_original INNER JOIN thesmos.session on thesmos.session.id=gigreplay.media_original.session_id WHERE  media_type=2 AND session_id=".$getSessionId;
    	$result = mysqli_query($con, $query);
        
	
    }
    
   
while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
        $session_name = $row['session_name'];
        $user_id= $row['user_id'];
        $session_id	  =$row['session_id'];
        $media_url=$row['media_url'];
        $append_url ="http://www.gigreplay.com/mySession.php?sid=".$session_id;
        
	/*?><?php echo "<a href= $append_url > $session_name</a>";?></br> <?php*/

   mysqli_close($con);
    ?>
    
    <div class="col-12 col-lg-4" style="max-width:320px;">
       <div class="caption">
        <a href="<?=$append_url ?>"><h3><?=$session_name ?></h3></a>
       <video id="video_with_controls" width="320px" height="150px" controls autobuffer poster="<?=$thumbnail_url?>" autoplay> <source src="<?=$media_url?>" type="video/mp4" />
       	Your browser does not support the video tag
        </video>
         <p>Taken by <?=$user_id ?><br>
        <small>Created at <?=$last_modified ?></small></p>-->
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