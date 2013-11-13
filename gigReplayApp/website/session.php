<?php
    
    $get_session_id= $_GET['vid'];
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        
        $query = "SELECT * FROM media_original WHERE session_id=".$get_session_id." AND media_type=2";
       $result = mysqli_query($con, $query);
        
	
    }
    
   
while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
        $media_url = $row['media_url'];
        $media_id = $row['media_id'];
        //$append_url = "http://www.gigreplay.com/videos.php?vid=".$media_id;
	?><?php echo "<a href= $media_url > $media_id</a>";?></br> <?php
	

}


   mysqli_close($con);
    ?>

 <head>
  <title><?=$title?></title>

<?php include 'header.php'; ?>

  <meta property="og:image" content="<?=$default_thumb?>"/>
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
    </div>
    <div class="col-lg-1 hidden-sm">
    </div>
   </div>
  </div>
 </body>
</html>

