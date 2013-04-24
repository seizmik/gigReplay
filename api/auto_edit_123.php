<?php

    function generate_filepath($path)
    {
        //Since we are in the api folder, need to back out.
        $file = basename($path);
        $filepath = "../uploads/original/".$file;
        return $filepath;
    }

    function find_end_time($start_time, $length)
    {
        $end_time = $start_time + $length;
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
    
    function check_for_content($content_details) //$content_details is an array
    {
        global $current_time;
        if ($current_time >= $content_details['start_time'] && $current_time < $content_details['end_time'])
        {
            //Content exists at the current time. Check how much time left, then enter a duration
            return TRUE;
        } else {
            //Pick another video to feed it into this
            return FALSE;
        }
    }
    
    function seek_to_check($content_details)
    {
        global $current_time;
        $seek_to = rand(750, 1500)/100;
        $check_time = $current_time + $seek_to;
        if ($content_details['end_time'] >= $check_time) {
            return $seek_to;
        } else {
            //Return another seek to time (if it's enough)
            $new_seek_to = $content_details['end_time'] - $current_time;
            return $new_seek_to;
        }
    }
    
    function remove_useless_details($array)
    {
        global $current_time, $first_start;
        $new_array = array();
        for ($i = 0; $i < count($array); $i++) {
            if ($array[$i]['end_time'] > $current_time) {
                //Add these details into a new array
                $new_array[] = $array[$i];
            }
        }
        //Return the new array
        return $new_array;
    }
    
    function deleteDirectory($dir) {
        if (!file_exists($dir)) return true;
        if (!is_dir($dir) || is_link($dir)) return unlink($dir);
        foreach (scandir($dir) as $item) {
            if ($item == '.' || $item == '..') continue;
            if (!deleteDirectory($dir . "/" . $item)) {
                chmod($dir . "/" . $item, 0777);
                if (!deleteDirectory($dir . "/" . $item)) return false;
            };
        }
        return rmdir($dir);
    }

//End function list-------------------------------------------
    
    //Establish the session that we want to make the video for
    $session_id = 123; //This should be a POST-ed object. Otherwise, we can make this one giant function and have the input to be the session_id, and return a link to the master file
    $video_array = array();
    
    //First query the database and get all the details
    $con = mysql_connect("localhost", "mik", "rivalries");
    if (!$con) {
        die(mysql_error());
    } else {
        mysql_select_db("gigreplay", $con);
        //First, select all the videos from the table
        $query = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=2";
        $result = mysql_query($query);
        mysql_close($con);
    }
    
    //These two variables will define the length of the video generated. These are to be used as constants
    $first_start = 999999999999999;
    $last_end = 0;
    
    //Load up the video details in the video array, and get the first and last times
    while ($row = mysql_fetch_array($result)) {
        if ($row['start_time'] < $first_start) {
            $first_start = round($row['start_time'], 2);
        }
        $this_videos_end_time = round($row['start_time'], 2) + $row['media_length'];
        if ($this_videos_end_time > $last_end) {
            $last_end = $this_videos_end_time;
        }
        
        //Add end time to the row array, then add row into the video array;
        $row['end_time'] = $this_videos_end_time;
        $video_array[] = $row;
        
    }
    
    //Create a temp folder and master folder
    $temp_path = "../uploads/temp/".$session_id."/";
    if (!is_dir($temp_path)) {
        mkdir ($temp_path);
    } //Please remember to delete it later
    $master_path = "../uploads/master/".$session_id."/";
    if (!is_dir($master_path)) {
        mkdir ($master_path);
    }
    
    //OK, now we know the when the first video is, and when the last video is.
    //Global variable $current_time will track where we are in the time continuum.
    $current_time = $first_start; //Current time starts with the $first_start
    $i = 0;
    $temp_trim_array = array();
    
    while ($current_time < $last_end) {
        
        $video_url = FALSE;
        while ($video_url == FALSE) {
            //Take a random video and cut it up
            $random_number = rand(1, count($video_array)) - 1;
            $current_vid = $video_array[$random_number];
            //Check if content exists at this point
            if (check_for_content($current_vid)) {
                $video_url = $current_vid['media_url'];
            }
            //Seek to time is. Also, get a duration for the video
            $ss_time = fftime($current_time - $current_vid['start_time']);
            $duration_check = seek_to_check($current_vid); //We did the check because we need to get back something to update $current_time at the end of the loop
            $duration = fftime($duration_check);
        
        }
        echo generate_filepath($video_url), "<br/>";
        echo $ss_time, "<br/>"; //This is the current time
        
        //Create temp file name, then we can for-each each entry to stitch the videos together
        //At this point, we should get the extension of the file and feed it into the trimpath
        $temp_trimpath = $temp_path."trim".$i.".mpg";
        //This creates the trim for the videos. Uncomment this when we get the loop running properly
        exec("ffmpeg -i " . generate_filepath($video_url) . " -vcodec libx264 -vprofile high -preset slow -b:v 5000k -maxrate 5000k -bufsize 10000k -vf scale=-1:480 -threads 0 -acodec copy -ss " . $ss_time . " -t " . $duration . " " . $temp_trimpath);
        //Include -an to take out the audio from the video.
        
        /*
        //Create the intermediates. Convert them to .mpg
        $temp_intpath = $temp_path."int".$i.".mpg";
        exec("ffmpeg -i ".$temp_trimpath." ".$temp_intpath);
        */
        
        //Convert to mpeg transport stream first. No use
        //$temp_intpath = $temp_path."int".$i.".ts";
        //exec("ffmpeg -i ".$temp_trimpath." -c copy -bsf:v h264_mp4toannexb -f mpegts ".$temp_intpath);
        
        //Add the new file to the trimmed video array
        //$temp_trim_array[] = $temp_intpath;
        $temp_trim_array[] = $temp_trimpath;
        echo $temp_trim_array[$i], "<br/>";
        
        //Next check if the videos are still valid and update $current_time
        $current_time = $current_time + $duration_check;
        $video_array = remove_useless_details($video_array);
        $i++; //To update the filename later
        
        echo $current_time, " | ", count($video_array), "<br/>";
        
    }//End of while loop that controls the random edits
    
    
    $concat_files = "concat:\"";
    $j = 1;//Time to concatenate all the files. First, generate the command list
    foreach ($temp_trim_array as &$value) {
        $concat_files .= $value;
        if ($j < count($temp_trim_array)) {
            $concat_files .= "|";
        }
        $j++;
    }
    $concat_files .= "\"";
    echo $concat_files;
    
    //This is one way of concatenating files
    //exec("ffmpeg -i ".$concat_files." -c copy -bsf:a aac_adtstoasc ".$master_path."output.mp4");
    exec("ffmpeg -i ".$concat_files." -c copy ".$master_path."output.mpg");
    
    //Then convert back to mp4 format
    exec("ffmpeg -i ".$master_path."output.mpg ".$master_path."output.mp4");
    
    
    //Now that the video has been completed, let's head to make the audio for the video.
    
    deleteDirectory($temp_path);
?>
