<?php
    
    function calculate_content_length($media_path)
    {
        //Calculate the length
        $time = exec("ffmpeg -i ". $media_path . " 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//");
        list($hms, $milli) = explode('.', $time);
        list($hours, $minutes, $seconds) = explode(':', $hms);
        $total_seconds = ($hours * 3600) + ($minutes * 60) + $seconds;
        $total_seconds .= ".".$milli;
        $media_length = strval($total_seconds);
        return $media_length;
    }
    
    function fftime($time_in_sec)
    {
        $time_in_sec = round($time_in_sec, 2);
        list($whole, $milli) = explode('.', $time_in_sec);
        $minutes = str_pad(floor($whole/60), 2, '0', STR_PAD_LEFT);
        $seconds = str_pad($whole%60, 2, '0', STR_PAD_LEFT);
        $milli = str_pad($milli, 2, '0', STR_PAD_LEFT);
        $ffmpeg_time = "00:".$minutes.":".$seconds.".".$milli;
        return $ffmpeg_time;
    }
    
    function generate_random_string($length = 7) {
        //Can set length by making length a fixed number
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $randomString = '';
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, strlen($characters) - 1)];
        }
        return $randomString;
    }
    
    function create_thumbnail($input_path, $time)
    {
        $pathinfo = pathinfo($input_path);
        $output_path = $pathinfo['dirname'];
        $output_path .= "/".generate_random_string().".png";
        $seek_to = fftime($time);
        exec("ffmpeg -i ".$input_path." -ss ".$seek_to." -f image2 -vframes 1 ".$output_path);
        
        //Create the URL
        global $video_url;
        $url_pathinfo = pathinfo($video_url);
        $output_pathinfo = pathinfo($output_path);
        $output_url = $url_pathinfo['dirname']."/".$output_pathinfo['basename'];
        echo "Thumbnail created at " . $output_url, "<br/>";
        
        return $output_url;
    }
    
    //End of function list------------------------------------------
    
    //Trying to create a thumbnail of a video, then update the database
    $video_path = "../uploads/master/217/12/output.mp4"; //In reality, this is either posted or a variable from another place
    $video_url = "http://www.lipsync.sg/uploads/master/217/12/output.mp4";
    $session_id = 217;
    $user_id = 12;
    
    $video_pathinfo = pathinfo($video_path);
    
    //Create 3 thumbnails based on the videos length
    $video_length = calculate_content_length($video_path);
    $thumb_1 = create_thumbnail($video_path, ($video_length * 0.2));
    $thumb_2 = create_thumbnail($video_path, ($video_length * 0.5));
    $thumb_3 = create_thumbnail($video_path, ($video_length * 0.8));
    
    //Update the database
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    }
    
    $query = "INSERT INTO media_master (session_id, user_id, media_url, thumb_1_url, thumb_2_url, thumb_3_url) VALUES (".$session_id.",".$user_id.",'".$video_url."','".$thumb_1."','".$thumb_2."','".$thumb_3."')";
    mysqli_query($con, $query);
    
    $entry_id = mysqli_insert_id($con);
    mysqli_close($con);
    
?>