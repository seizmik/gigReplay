<!DOCTYPE html>
<html>

 <head>
  <title>GigReplay Video List</title>
 </head>

 <body>
  <table>
   <thead></thead>
   <tbody>

<?php
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to onnect to MySQL: " . mysqli_connect_error();
    } else {
        $query = "SELECT * FROM media_master ORDER BY date_modified DESC LIMIT 0,50";
        $result = mysqli_query($con, $query);
        $num = mysqli_num_rows($result);
        //echo $num;
    }
    
    while ($entry = mysqli_fetch_array($result)) {
        $entries[]=$entry;
    }
    
    foreach ($entries as $row) {
        $media_id = $row['master_id'];
        $user_id = $row['user_id'];
        $session_id = $row['session_id'];
        $media_url = $row['media_url'];
        $thumb_1 = $row['thumb_1_url'];
        $thumb_2 = $row['thumb_2_url'];
        $thumb_3 = $row['thumb_3_url'];
        $default_thumb = $row['default_thumb'];
        $last_modified = $row['date_modified'];
        $append_url = "http://www.gigreplay.com/watch.php?vid=".$media_id;
        
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
            if ($default_thumb==1) {
                $thumbnail_url = $thumb_1;
            } else if ($default_thumb==2) {
                $thumbnail_url = $thumb_2;
            } else if ($default_thumb==3) {
                $thumbnail_url = $thumb_3;
            }
        }
        
?>

     <tr>
      <td class="table_thumbnail"><a href="<?php echo $append_url ?>">
       <img class="thumbnail" src="<?php echo $thumbnail_url ?>" /></a></td>
      <td class="description">
       <span><h3><a href="<?php echo $append_url ?>"><?php echo $session_name ?></a></h3></span><br>
       <span id="created_by">Created by <?php echo $user_name ?></span><br>
       <p>Created at <?php echo $last_modified ?></p>
      </td>
     </tr>

<?php
    
    }
?>

   </tbody>
  </table>
 </body>

</html>