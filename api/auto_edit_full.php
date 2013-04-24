<?php

    function generate_filepath($path)
    {
        //Since we are in the api folder, need to back out.
        $file = basename($path);
        $filepath = "../uploads/original/".$file;
        return $filepath;
    }
    
    function cmp($a, $b) {
        //Sorting by ascending start time
        return $a['start_time'] < $b['start_time'];
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
    
    function generate_duration() {
        return rand(750, 900)/100;
    }
    
    function seek_to_check($content_details, $seek_to)
    {
        global $current_time;
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
        global $current_time, $first_start, $last_end;
        $new_array = array();
        for ($i = 0; $i < count($array); $i++) {
            if (($array[$i]['end_time'] > $current_time) && ($array[$i]['start_time'] < $last_end)) {
                //Add these details into a new array
                $new_array[] = $array[$i];
            }
        }
        //Return the new array
        return $new_array;
    }
    
    function make_video_cut_array($array)
    {
        global $first_start, $last_end;
        //Initialise the current time
        $current_time = $first_start;
        
        while ($current_time < $last_end) {
            //As long as the current time is less than the last_end, it will continue cutting
            //First, sort the videos and check if there is a gap in the videos
            usort($array, "cmp");
            $blank_check = 0;
            foreach ($array as $video_details) {
                if (check_for_content($video_details)) {
                    $blank_check++;
                }
            }
            
            if ($blank_check == 0) {
                //Means that there are videos before last_end, but no content here
                //Create a blank video 
            } else {
                
            }
        }
    }
    
    function join_all_audio($cmd_array)
    {
        //Feeding it an array with arrays
        $outpath_array = array();
        $i = 0;
        global $temp_path;
        
        //Convert all to the same format
        foreach ($cmd_array as $entry) {
            $original_path = $entry['src'];
            $ss_time = $entry['seek_to'];
            $duration = $entry['duration'];
            echo $original_path, "<br/>";
            echo $ss_time, "<br/>";
            echo $duration, "<br/>";
            $temp_out_path = $temp_path."audio_trim".$i.".aac";
            exec("ffmpeg -i " . $original_path . " -vn -ss ".$ss_time." -t ".$duration." -ab 512k -ac 2 -acodec libvo_aacenc " . $temp_out_path);
            $outpath_array[] = $temp_out_path;
            $i++;
        }
        //Now, concatenate each audio file, even if there is only 1 file
        $concat_files = "concat:\"" . implode("|", $outpath_array) . "\"";
        echo $concat_files;
        $output_audio_path = $temp_path."combined_audio.aac";
        exec("ffmpeg -i ".$concat_files." ".$output_audio_path);
        
        return $output_audio_path;
    }
    
    function make_audio_cut_array($main_audio, $backup_audio_tracks, $the_end)
    {
        //$main_audio is the audio that we are using for the primary track
        //$backup_audio is the audio that we are using to supplement the main audio if there are sections missing
        
        $cut_details = array(); //This will feed into $cut_audio_array
        
        global $current_time, $first_start, $cut_audio_array;
        
        //First check if there are any pieces of audio at the start
        //If there is any audio1 file at the start, this will return false
        while ($current_time < $main_audio['start_time']) {
            //Choose a video that exists at this point of time, then check if it exists all the way to the start_time
            //If it does, then stop at the start_time. Otherwise, add the length and repeat the process
            echo "The audio started late!<br/>";
            for ($j=0; $j < count($backup_audio_tracks); $j++) {
                if (check_for_content($backup_audio_tracks[$j])) {
                    //If there is content there, take note of it
                    $backup_audio_exists = $backup_audio_tracks[$j];
                }
            }
            $duration_check = $main_audio_details['start_time'] - $current_time;
            $duration = seek_to_check($backup_audio_exists, $duration_check);
            
            //Create the cut_array
            $cut_details['src'] = generate_filepath($backup_audio_exists['media_url']);
            $cut_details['seek_to'] = fftime($current_time - $backup_audio_exists['start_time']);
            $cut_details['duration'] = fftime($duration);
            $cut_audio_array[] = $cut_details;
            //Lastly, update the current time
            $current_time += $duration;
            echo $current_time, " | ", $the_end;
        }
        
        if (check_for_content($main_audio)) {
            echo "Cutting the main audio<br/>";
            //Next, cut the dedicated audio into the whole thing
            $duration_check = $the_end - $current_time;
            $duration = seek_to_check($main_audio, $duration_check);
            
            if ($duration > 0) {
                $cut_details['src'] = generate_filepath($main_audio['media_url']);
                $cut_details['seek_to'] = fftime($current_time - $main_audio['start_time']);
                $cut_details['duration'] = fftime($duration);
                $cut_audio_array[] = $cut_details;
                
                //Update the current time here
                $current_time += $duration;
                echo $duration, "<br/>";
                echo $current_time, " | ", $the_end;
            }
        }
        
        while ($current_time < $the_end) {
            //Choose a video that exists at this point of time, then check if it exists all the way to the start_time
            //If it does, then stop at the start_time. Otherwise, add the length and repeat the process
            echo "The audio ended early<br/>";
            for ($j=0; $j < count($backup_audio_tracks); $j++) {
                if (check_for_content($backup_audio_tracks[$j])) {
                    //If there is content there, take note of it
                    $backup_audio_exists = $backup_audio_tracks[$j];
                }
            }
            $duration_check = $the_end - $main_audio['end_time'];
            $duration = seek_to_check($backup_audio_exists, $duration_check);
            
            //Create the cut_array
            $cut_details['src'] = generate_filepath($backup_audio_exists['media_url']);
            $cut_details['seek_to'] = fftime($current_time - $backup_audio_exists['start_time']);
            $cut_details['duration'] = fftime($seek_to);
            $cut_audio_array[] = $cut_details;
            //Lastly, update the current time
            $current_time += $duration;
            echo $current_time, " | ", $the_end, "<br/>";
        }
        return $cut_audio_array;
    }
    
    function deleteDirectory($dir)
    {
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

//End function list--------------------------------------------------------
    
    //Establish the session that we want to make the video for
    $session_id = 102; //This should be a POST-ed object. Otherwise, we can make this one giant function and have the input to be the session_id, and return a link to the master file
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
            $first_start = $row['start_time'];
        }
        $this_videos_end_time = $row['start_time'] + $row['media_length'];
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
            $duration_check = seek_to_check($current_vid, generate_duration()); //We did the check because we need to get back something to update $current_time at the end of the loop
            $duration = fftime($duration_check);
        
        }
        echo generate_filepath($video_url), "<br/>";
        echo $ss_time, "<br/>"; //This is the current time
        
        //Create temp file name, then we can for-each each entry to stitch the videos together
        //At this point, we should get the extension of the file and feed it into the trimpath
        $temp_trimpath = $temp_path."trim".$i.".mpg";
        //This creates the trim for the videos. Uncomment this when we get the loop running properly
        exec("ffmpeg -i " . generate_filepath($video_url) . " -vcodec libx264 -vprofile high -preset slow -b:v 5000k -maxrate 5000k -bufsize 10000k -vf scale=-1:480 -threads 0 -an -ss " . $ss_time . " -t " . $duration . " " . $temp_trimpath);
        //Include -an to take out the audio from the video.
        
        //Add the new file to the trimmed video array
        //$temp_trim_array[] = $temp_intpath;
        $temp_trim_array[] = $temp_trimpath;
        echo $temp_trim_array[$i], "<br/>";
        
        //Next check if the videos are still valid and update $current_time
        $current_time = $current_time + $duration_check;
        $video_array = remove_useless_details($video_array);
        $i++; //To update the filename later
        
        echo $current_time, " | ", count($video_array), "<br/>";
        
    }//End of while loop that controls the random video edits
    
    
    $concat_files = "concat:\"" . implode("|", $temp_trim_array) . "\"";
    echo $concat_files, "<br/><br/>";
    
    //This is one way of concatenating files
    $combined_video_path = $temp_path."combined_video.mpg";
    exec("ffmpeg -i ".$concat_files." -c copy ".$combined_video_path);
    
    //Then convert back to mp4 format
    //$combined_video_path = $temp_path."combined_video.mp4";
    //exec("ffmpeg -i ".$temp_path."combined_video.mpg ".$combined_video_path);
    
    
    //Video edit complete---------------------------------------------------
    
    
    
    //Now that the video has been completed, let's head to make the audio for the video.
    //First, boot up an audio array
    $con = mysql_connect("localhost", "mik", "rivalries");
    if (!$con) {
        die(mysql_error());
    } else {
        mysql_select_db("gigreplay", $con);
        //First, select all the videos from the table
        $query_1 = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=1";
        $query_3 = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=3";
        $result_1 = mysql_query($query_1);
        $result_3 = mysql_query($query_3);
        mysql_close($con);
    }
    
    $audio_1_array = array(); //This is dedicated audio
    $audio_3_array = array(); //This is audio from video
    while ($row = mysql_fetch_array($result_1)) {
        $row['end_time'] = $row['start_time'] + $row['media_length'];
        $audio_1_array[] = $row;
    }
    while ($row = mysql_fetch_array($result_3)) {
        $row['end_time'] = $row['start_time'] + $row['media_length'];
        $audio_3_array[] = $row;
    }
    
    echo "Audio 1 array:", count($audio_1_array), "<br/>";
    echo "Audio 3 array:", count($audio_3_array), "<br/>";
    
    //Create a global audio_cut_array for the function to add to
    $cut_audio_array = array();
    //Reset the current time to keep track of audio
    $current_time = $first_start;
    //Now remove the empty audio tracks from audio_1_array
    $audio_1_array = remove_useless_details($audio_1_array);
    
    //First, check how many of the dedicated audio
    //In each case, we are feeding into the 
    if (count($audio_1_array) == 0) {
        //Nothing? Then choose a track that came from audio 3
        echo "No dedicated audio<br/>";
        
        //Choose the longest track from audio_3_array as the main_audio
        $length_check = 0;
        foreach ($audio_3_array as $entry) {
            if ($entry['media_length'] > $length_check) {
                //If the media length of this track is a larger value, take note of it
                $audio_3_main = $entry;
            }
        }
        make_audio_cut_array($audio_3_main, $audio_3_array, $last_end);
        
    } else if (count($audio_1_array) == 1) {
        //Since there's already one dedicated audio, use it
        echo "1 dedicated audio<br/>";
        make_audio_cut_array($audio_1_array[0], $audio_3_array, $last_end);
        
    } else {
        //This is the case where there is more than 1 dedicated audio files
        //FUCK YOU! Why are you recording more than 1 dedicated audio???
        //Ok la, maybe the audio cut out in between or something...
        
        //First sort the array to make sure they are all in order
        usort($audio_1_array, "cmp");
        //For each of the audio_1 entries, make the audio_cut_array with the next entry's start_time
        for ($i=0; $i < count($audio_1_array); $i++) {
            $k = $i+1;
            if (($audio_array[$k]['start_time'] >= $last_end) or ($i == count($audio_1_array))) {
                //If the start of the next audio is beyond the last end, or this is the last entry in the array
                //Instead, use the $last_end as the end time
                make_audio_cut_array($audio_1_array[$i], $audio_3_array, $last_end);
            } else {
                make_audio_cut_array($audio_1_array[$i], $audio_3_array, $audio_1_array[$k]['start_time']);
            }
        }
    }
    
    $combined_audio_path = join_all_audio($cut_audio_array);
    
    //Audio edit complete-----------------------------------------------------
    
    
    
    //Here's where we combine the video with the audio
    $final_video_path = $master_path . "output.mp4";
    exec("ffmpeg -i " . $combined_audio_path . " -i " . $combined_video_path . " -vcodec libx264 -vprofile high -preset slow -b:v 5000k -maxrate 5000k -bufsize 10000k -vf scale=-1:480 -threads 0 -acodec libvo_aacenc -b:a 128k -ac 2 " . $final_video_path);
    
    //Update into the database that the video has been completed
    
    //Then email those who were in that session about where to find this file
    $final_video_url = "http://www.lipsync.sg/uploads/master/".$session_id."/".basename($final_video_path);
    echo $final_video_url;
    
    deleteDirectory($temp_path);
    
?>
