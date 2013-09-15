<html>
<head>
 <head>
  <meta http-equiv="Expires" CONTENT="0">
<meta http-equiv="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Pragma" CONTENT="no-cache">
<?php include 'header.php'; ?>
</head>
<body>
<div id="fb-root"></div>
<script>
  // Additional JS functions here
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '425449864216352', // App ID
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });

    // Additional init code here

  };

  // Load the SDK asynchronously
  (function(d){
     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement('script'); js.id = id; js.async = true;
     js.src = "//connect.facebook.net/en_US/all.js";
     ref.parentNode.insertBefore(js, ref);
   }(document));

  function logout(){
	  FB.logout(function(response) {
		  window.location.href = 'example.php';
		});
  }

  function login(){
	  FB.getLoginStatus(function(r){
	       if(r.status === 'connected'){
	              
	       }else if(r.status === 'unknown'){

	    	   alert('Please log In with FacebookAccount');
	              window.location.href = 'myAccount_Videos.php';
             FB.login();
	       }

	       else{
	          FB.login(function(response) {
	                  if(response.authResponse) {
	                	 
	                	  window.location.href = 'myAccount_Videos.php';
	              } else {
		              alert('Please log In with FacebookAccount');
		              window.location.href = 'myAccount_Videos.php';
	                FB.login();
	              }
	       },{scope:'email'}); // which data to access from user profile
	   }
	  });
	  }

</script>

<?php include 'top_toolbar.php'; ?>
<div class="col-12 col-lg-12">
<div class="row">
<div class="col-10 col-lg-9">
     <div class="row">
      <div class="col-12 col-lg-12" style="max-width:960px;">
      </div>
     </div>
     <h3>My Generated Videos</h3>
     <div class="row">
<?php 
 $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
	
        $query =" SELECT * FROM gigreplay.media_master JOIN thesmos.user on media_master.user_id=thesmos.user.id WHERE media_master.user_id=19";
        $result = mysqli_query($con, $query);
        
	
    }
    
   
while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    //Initialise the row count
    $row_count=0;
    foreach ($entries as $row) {
        $session_name = $row['title'];
        $master_id=$row['master_id'];
        $default_thumb=$row['default_thumb'];
        $user_name=$row['user_name'];
        $last_modified=$row['date_modified'];
        $append_url ="http://www.gigreplay.com/myVideos.php?vid=".$master_id;
        
	/*?><?php echo "<a href= $append_url > $session_name</a>";?></br> <?php*/

   mysqli_close($con);
    ?>
    
    <div class="col-12 col-lg-4" style="max-width:320px;">
       <a href="<?=$append_url ?>" onclick='login();' class="thumbnail">
        <img data-src="holder.js/100%x100%" alt="100%x100%" src="<?=$default_thumb ?>" style="display:block;">
       </a>
       <div class="caption">
        <a href="<?=$append_url ?>"  onclick="login();"> <h3><?=$session_name ?></h3></a>
        <p>Created by <?=$user_name ?><br>
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