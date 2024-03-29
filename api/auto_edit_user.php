<?php
    set_include_path('../api/PHPMailer');
    require 'class.phpmailer.php';
    
    function generate_filepath($path)
    {
        global $session_add_on, $session_id;
        //Since we are in the api folder, need to back out.
        $file = basename($path);
        $filepath = "../uploads/original/".$session_id."-".$session_add_on."/".$file;
        return $filepath;
    }
    
    function compare_start($a, $b)
    {
        //Sorting by ascending start time
        return ($a['start_time'] > $b['start_time']);
    }
    
    function compare_length($a, $b)
    {
        //Sorting by descending order of media length
        return ($a['media_length'] < $b['media_length']);
        //BTW, that's what she said...
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
    
    function fftime($time_in_sec)
    {
        $time_in_sec = round($time_in_sec, 3);
        list($whole, $milli) = explode('.', $time_in_sec);
        $minutes = str_pad(floor($whole/60), 2, '0', STR_PAD_LEFT);
        $seconds = str_pad($whole%60, 2, '0', STR_PAD_LEFT);
        $milli = str_pad($milli, 3, '0', STR_PAD_RIGHT);
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
        //return rand(300, 600)/100;
        //Creates the duration for a set number of frames.
        //This should be posted up as part of the options. To be done in the near future.
        global $cut_length, $cut_var;
        //If these variables are nil, switch to default
        if (!empty($cut_length)) {
            $cut_length = 120;
        }
        if (!empty($cut_var)) {
            $cut_var = 1.5;
        }
        $cut_end = $cut_length * $cut_var;
        $frames = rand($cut_length, $cut_end);
        $time = $frames * (1/29.97);
        return round($time, 3);
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
        global $first_start, $last_end, $current_time;
        $new_array = array();
                
        while ($current_time < $last_end) {
            //As long as the current time is less than the last_end, it will continue cutting
            //First, sort the videos and check if there is a gap in the videos
            $blank_check = 0;
            usort($array, 'compare_start');
            foreach ($array as $video_details) {
                if (check_for_content($video_details)) {
                    $blank_check++;
                }
            }
            
            if ($blank_check == 0) {
                //Means that there are videos before last_end, but no content here
                //Create a blank video that starts at current time and ends at the next videos start_time
                //There is a blank video in the api folder called empty_vid.mpeg. 720p
                //In fact, we can just make b-roll here. Randomly pick a video and cut something from it
                echo "There's a blank here.<br/>";
                
                $cut_details['src'] = "empty_vid.mpeg";
                $cut_details['seek_to'] = "00:00:00.00";
                
                //Update the current time. Since the array has been sorted, you can just pick the first entries start time as the next closest time
                $duration_check = $array[0]['start_time'] - $current_time;
                echo "Duration of blank is ", $duration_check, "<br/>";
                $cut_details['duration'] = $duration_check;
                
            } else {
                //Reset the video URL
                $video_url = FALSE;
                while ($video_url == FALSE) {
                    //Take a random video and cut it up
                    $random_number = rand(1, count($array)) - 1;
                    $current_vid = $array[$random_number];
                    //Check if content exists at this point
                    if (check_for_content($current_vid)) {
                        $video_url = $current_vid['media_url'];
                        //If it doesn't, $video_url will not update itself, and will loop again
                    }
                    //Seek to time generated. Also, get a duration for the video
                    $ss_time = fftime($current_time - $current_vid['start_time']);
                    $duration_check = seek_to_check($current_vid, generate_duration()); //We did the check because we need to get back something to update $current_time at the end of the loop
                }
                //Now add it into the $new_array
                $cut_details = array();
                $cut_details['src'] = generate_filepath($video_url); //path
                $cut_details['seek_to'] = $ss_time;
                //We put in duration_check here as we might need to add some numbers later
                $cut_details['duration'] = $duration_check;
                
            }
            //Add the cut details into new array
            $new_array[] = $cut_details;
            //Update the current time
            $current_time += $duration_check;
            //Remove video details that don't exist
            $array = remove_useless_details($array);
        } //This ends the while loop to generate the details for cutting
        
        //Now, a function that will reduce the number of cuts
        $return_array = array();
        $count = 0;
        for ($i =0; $i < count($new_array); $i++) {
            echo "New array source: ", $new_array[$i]['src'], "<br/>";
            echo "Return array source: ", $return_array[$count]['src'], "<br/>";
            if ($i == 0) {
                //First case, just add it into the returning array
                $return_array[] = $new_array[$i];
            } else if ($new_array[$i]['src'] == $return_array[$count]['src']) {
                //If they come from the same source, add the duration to that
                $return_array[$count]['duration'] += $new_array[$i]['duration'];
                //Do not update the count since no new entry was added into $return_array
            } else {
                $return_array[] = $new_array[$i];
                $count++;
            }
        }
        
        //A foreach loop does not work here. Converting duration check which is a float to something that ffmpeg can read later
        for ($i = 0; $i < count($return_array); $i++) {
            $return_array[$i]['duration'] = fftime($return_array[$i]['duration']);
        }
        
        return $return_array;
        
    }
    
    function make_audio_cut_array($main_audio, $backup_audio_tracks, $the_end)
    {
        //$main_audio is the audio that we are using for the primary track
        //$backup_audio is the array audio that we are using to supplement the main audio if there are sections missing
        
        $cut_details = array(); //This will feed into $cut_audio_array
        
        usort($backup_audio_tracks, 'compare_start');
        
        global $current_time, $first_start, $cut_audio_array;
        
        //First check if there are any pieces of audio at the start
        //If there is any audio1 file at the start, this will return false
        while ($current_time < $main_audio['start_time']) {
            //So, if the main_audio does not start at this current time, it will enter this loop
            echo "The audio started late!<br/>";
            
            $backup_audio_tracks = remove_useless_details($backup_audio_tracks);
            usort($backup_audio_tracks, 'compare_start');
            
            echo "After cleaning up, backup audio array still has ", count($backup_audio_tracks), "<br/>";
            
            $blank_check = 0;
            foreach ($backup_audio_tracks as $entry) {
                if (check_for_content($entry)) {
                    $blank_check++;
                }
            }
            echo "Blank check: ", $blank_check, "<br/>";
            
            if ($blank_check == 0) {
                $cut_details['src'] = "empty_audio.aac";
                $cut_details['seek_to'] = "00:00:00.00";
                if ($backup_audio_tracks[0]['start_time'] < $main_audio['start_time']) {
                    $duration = $backup_audio_tracks[0]['start_time'] - $current_time;
                } else {
                    $duration = $main_audio['start_time'] - $current_time;
                }
                $cut_details['duration'] = fftime($duration);
            } else {
                for ($j=0; $j < count($backup_audio_tracks); $j++) {
                    if (check_for_content($backup_audio_tracks[$j])) {
                        //If there is content there, take note of it
                        $backup_audio_exists = $backup_audio_tracks[$j];
                    }
                }
                $duration_check = $main_audio['start_time'] - $current_time;
                $duration = seek_to_check($backup_audio_exists, $duration_check);
                
                echo "Duration is ", $duration, "<br/>";
                
                //Create the cut_array
                $cut_details['src'] = generate_filepath($backup_audio_exists['media_url']);
                $cut_details['seek_to'] = fftime($current_time - $backup_audio_exists['start_time']);
                $cut_details['duration'] = fftime($duration);
            }
            
            $cut_audio_array[] = $cut_details;
            //Lastly, update the current time
            $current_time += $duration;
            echo $current_time, " | ", $the_end, "<br/>";
            //$backup_audio_tracks = remove_useless_details($backup_audio_tracks);
        } //This marks the end of the audio before the main audio
        
        
        
        if (check_for_content($main_audio)) {
            echo "Cutting the main audio<br/>";
            //Next, cut the main audio into the whole thing
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
                echo $current_time, " | ", $the_end, "<br/>";
            }
        } //This ends the loop for the main audio
        
        
        
        while ($current_time < $the_end) {
            echo "The audio ended early<br/>";
            //echo "Backup audio array still has ", count($backup_audio_tracks), "<br/>";
            //First, remove content from the backup array that is no longer valid
            $backup_audio_tracks = remove_useless_details($backup_audio_tracks);
            usort($backup_audio_tracks, 'compare_start');
            
            echo "After cleaning up, backup audio array still has ", count($backup_audio_tracks), "<br/>";
            
            $blank_check = 0;
            foreach ($backup_audio_tracks as $entry) {
                if (check_for_content($entry)) {
                    $blank_check++;
                }
            }
            echo "Blank check: ", $blank_check, "<br/>";
            
            if ($blank_check == 0) {
                $cut_details['src'] = "empty_audio.aac";
                $cut_details['seek_to'] = "00:00:00.00";
                if ($backup_audio_tracks[0]['start_time'] < $the_end) {
                    $duration = $backup_audio_tracks[0]['start_time'] - $current_time;
                } else {
                    $duration = $the_end - $current_time;
                }
                $cut_details['duration'] = fftime($duration);
            } else {
                //Choose a video that exists at this point of time, then check if it exists all the way to the start_time
                //If it does, then stop at the start_time. Otherwise, add the length and repeat the process
                for ($j=0; $j < count($backup_audio_tracks); $j++) {
                    if (check_for_content($backup_audio_tracks[$j])) {
                        //If there is content there, take note of it
                        $backup_audio_exists = $backup_audio_tracks[$j];
                    }
                }
                $duration_check = $the_end - $current_time;
                $duration = seek_to_check($backup_audio_exists, $duration_check);
                
                //Create the cut_array
                $cut_details['src'] = generate_filepath($backup_audio_exists['media_url']);
                $cut_details['seek_to'] = fftime($current_time - $backup_audio_exists['start_time']);
                $cut_details['duration'] = fftime($duration);
            }
            echo "Cut duration was ", $duration, "<br/>";
            
            //Add to the cut_audio_array
            $cut_audio_array[] = $cut_details;
            //Lastly, update the current time
            $current_time += $duration;
            echo $current_time, " | ", $the_end, "<br/>";
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
           // exec("ffmpeg -i " . $original_path . " -vn -ss ".$ss_time." -t ".$duration." -ab 64k -ac 2 -acodec libvo_aacenc " . $temp_out_path);
           exec("ffmpeg -i " . $original_path . " -vn -ss ".$ss_time." -t ".$duration." -ab 64k -ac 2 -c:a libfdk_aac -profile:a aac_he " . $temp_out_path);
	 $outpath_array[] = $temp_out_path;
            $i++;
        }
        //Now, concatenate each audio file, even if there is only 1 file
        $concat_files = "concat:\"" . implode("|", $outpath_array) . "\"";
        echo $concat_files, "</br>";
        $output_audio_path = $temp_path."combined_audio.aac";
        exec("ffmpeg -i ".$concat_files." ".$output_audio_path);
        
        return $output_audio_path;
    }
    
    function create_thumbnail($input_path, $time, $video_url)
    {
        $pathinfo = pathinfo($input_path);
        $output_path = $pathinfo['dirname'];
        $output_path .= "/".generate_random_string().".png";
        $seek_to = fftime($time);
        exec("ffmpeg -i ".$input_path." -ss ".$seek_to." -f image2 -s 640x360 -vframes 1 ".$output_path);
        
        //Create the URL
        $url_pathinfo = pathinfo($video_url);
        $output_pathinfo = pathinfo($output_path);
        $output_url = $url_pathinfo['dirname']."/".$output_pathinfo['basename'];
        
        return $output_url;
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
    $session_id = $_POST['session_id']; //This should be a POST-ed object. Otherwise, we can make this one giant function and have the input to be the session_id, and return a link to the master file
    $session_name = $_POST['session_name'];
    $user_id = $_POST['user_id'];
    $user_email = $_POST['user_email'];
    $user_name = $_POST['user_name'];
    $cut_length = $_POST['cutLength'];
    $cut_var = $_POST['cutVar'];
    
    $video_array = array();
    
    //First query the database and get all the details
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        //First, select all the videos from the table
        $query_2 = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=2";
        $query_1 = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=1";
        $query_3 = "SELECT * FROM media_original WHERE session_id='$session_id' AND media_type=3";
        //These are the results for all the videos for this session
        $result_2 = mysqli_query($con, $query_2);
        $num_videos = mysqli_num_rows($result_2);
        //These are the results for all the audio for this session
        $result_1 = mysqli_query($con, $query_1);
        $result_3 = mysqli_query($con, $query_3);
        mysqli_close($con);
    }
    
    //These two variables will define the length of the video generated. These are to be used as constants
    $first_start = 999999999999999;
    $last_end = 0;
    
    //Load up the video details in the video array, and get the first and last times
    while ($row = mysqli_fetch_array($result_2)) {
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
    
    //Now, we make duplicates of the details into the array
    //This will allow the system to select these shorter clips more often than not
    $total_length = $last_end - $first_start;
    
    foreach ($video_array as $row) {
        $multiplier = intval($total_length/$row['media_length']);
        for ($i=1; $i<$multiplier; $i++) {
            //$i starts from 1 because the multiplier starts from 1. If it does start from 1, then don't multiply the entry
            $video_array[] = $row;
            //This should put multiple entries in the auto editing so that it'll be selected more often
        }
    }
    
    //Create a temp folder and master folder
    $session_add_on = implode("_", array_filter(explode(" ", preg_replace("/[^a-zA-Z0-9]+/", " ", $session_name)), 'strlen'));
    $user_add_on = implode("_", array_filter(explode(" ", preg_replace("/[^a-zA-Z0-9]+/", " ", $user_name)), 'strlen'));
    $temp_path = "../uploads/temp/".$session_id."-".$session_add_on."/";
    if (!is_dir($temp_path)) {
        mkdir($temp_path);
    }
    $temp_path .= $user_id."-".$user_add_on."/";
    if (!is_dir($temp_path)) {
        mkdir($temp_path);
    }
    
    $master_path = "../uploads/master/".$session_id."-".$session_add_on."/";
    if (!is_dir($master_path)) {
        mkdir($master_path);
    }
    $master_path .= $user_id."-".$user_add_on."/";
    //We will delete the master path right before creating the new video
    
    //OK, now we know when the first video is, and when the last video is.
    //Global variable $current_time will track where we are in the time continuum.
    $current_time = $first_start; //Current time starts with the $first_start
    //$i = 0;
    //$temp_trim_array = array();
    
    $trim_cmd_array = array();
    $temp_trim_array = array();
    $trim_cmd_array = make_video_cut_array($video_array);
    
    //Now that you have the trim commands, you can start making the trims
    for ($i = 0; $i < count($trim_cmd_array); $i++) {
        
        $temp_trim_path = $temp_path . "trim".$i.".mpg";
        exec("ffmpeg -i " . $trim_cmd_array[$i]['src'] . " -b:v 1500k -maxrate 1500k -bufsize 800k  -s 850x480 -an -ss " . $trim_cmd_array[$i]['seek_to'] . " -t " . $trim_cmd_array[$i]['duration'] . " " . $temp_trim_path);
       
	 //leon's implementation, changes to original as encoding every so often removes information and loses quality
	//exec("ffmpeg -i " . $trim_cmd_array[$i]['src'] . "-vcodec libx264 -profile high -q 1 -s 850x480 -threads 0 -an -ss " . $trim_cmd_array[$i]['seek_to'] . " -t " . $trim_cmd_array[$i]['duration'] . " " . $temp_trim_path);
	
	//-vf scale is to determine the height proportion. scale=-1:480 fixes height to 480 and adjusts width proportionately 
        $temp_trim_array[] = $temp_trim_path;
    }
    
    $concat_files = "concat:\"" . implode("|", $temp_trim_array) . "\"";
    echo $concat_files, "<br/><br/>";
    
    //This is one way of concatenating files
    $combined_video_path = $temp_path."combined_video.mpg";
    exec("ffmpeg -i ".$concat_files." -c copy ".$combined_video_path);
    
    //Video edit complete---------------------------------------------------
    
    
    
    //Now that the video has been completed, let's head to make the audio for the video.
    //Audio results were grabbed earlier already
    $audio_1_array = array(); //This is dedicated audio
    $audio_3_array = array(); //This is audio from video
    while ($row = mysqli_fetch_array($result_1)) {
        $row['end_time'] = $row['start_time'] + $row['media_length'];
        $audio_1_array[] = $row;
        echo "Audio 1 end time is ", $row['end_time'], "<br/>";
    }
    while ($row = mysqli_fetch_array($result_3)) {
        $row['end_time'] = $row['start_time'] + $row['media_length'];
        $audio_3_array[] = $row;
        echo "Audio 3 end time is ", $row['end_time'], "<br/>";
    }
    
    echo "Audio 1 array count:", count($audio_1_array), "<br/>";
    echo "Audio 3 array count:", count($audio_3_array), "<br/>";
    
    //Create a global audio_cut_array for the function to add to
    $cut_audio_array = array();
    //Reset the current time to keep track of audio
    $current_time = $first_start;
    //Now remove the empty audio tracks from audio_1_array that exist before the start and after the end
    $audio_1_array = remove_useless_details($audio_1_array);
    
    //First, check how many of the dedicated audio
    //In each case, we are feeding into the
    if (count($audio_1_array) == 0) {
        //Nothing? Then choose a track that came from audio 3
        echo "No dedicated audio<br/>";
        
        //Choose the longest track from audio_3_array as the main_audio
        usort($audio_3_array, 'compare_length');
        make_audio_cut_array($audio_3_array[0], $audio_3_array, $last_end);
        
    } else if (count($audio_1_array) == 1) {
        //Since there's already one dedicated audio, use it
        echo "1 dedicated audio<br/>";
        make_audio_cut_array($audio_1_array[0], $audio_3_array, $last_end);
        
    } else {
        //This is the case where there is more than 1 dedicated audio files
        //FUCK YOU! Why are you recording more than 1 dedicated audio???
        //Ok la, maybe the audio cut out in between or something...
        
        //First sort the array to make sure they are all in order
        usort($audio_1_array, 'compare_start');
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
    
    if (!is_dir($master_path)) {
        //If master_path is already present, delete everything that is there
        mkdir($master_path);
    } else {
        deleteDirectory($master_path);
        mkdir($master_path);
    }
    
    //Here's where we combine the video with the audio
    $final_video_path = $master_path . "output_hi.mp4";
    exec("ffmpeg -i " . $combined_audio_path . " -i " . $combined_video_path . " -profile:v baseline -level 3.0 -preset slower  -b:v 1500k -maxrate 1500k -bufsize 800k  -vf  curves=vintage  -pix_fmt yuv420p -s 850x480  -b:a 64k -ac 2 -c:a libfdk_aac -profile:a aac_he " . $final_video_path);
//leon's     
//exec("ffmpeg -i " . $combined_audio_path . " -i " . $combined_video_path . " -vcodec libx264 -b:v 1500k -maxrate 1500k -bufsize 800k  -vf \"movie=g_overlay.png [watermark]; [in][watermark] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]\" -b:a 64k -ac 2 " . $final_video_path);
    $final_video_path_lo = $master_path . "output_lo.mp4";
    exec("ffmpeg -i $final_video_path  -b:v 1000k -maxrate 1000k -bufsize 500k -s 640x360  -b:a 64k -ac 2 $final_video_path_lo");
    
    $final_video_url = "http://www.lipsync.sg/uploads/master/".$session_id."-".$session_add_on."/".$user_id."-".$user_add_on."/".basename($final_video_path);
    $final_video_url_lo = "http://www.lipsync.sg/uploads/master/".$session_id."-".$session_add_on."/".$user_id."-".$user_add_on."/".basename($final_video_path_lo);
    //echo $final_video_url, "<br>";
    
    //Create 10 thumbnails based on the videos length
    //Because all of the thumbnails will have similar naming, ie thumb_X.png, we can then extract it later by using the final video url and tagging on the number.
    $video_length = $last_end - $first_start;
    $thumb_length = $video_length/10;
    exec("ffmpeg -i ".$final_video_path." -f image2 -s 640x360 -vf fps=fps=1/".$thumb_length." ".$master_path."thumb_%d.png");
    
    //Update the database
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        //Find out if the video has already been created once before
        $query = "SELECT * FROM media_master WHERE session_id=".$session_id." AND user_id=".$user_id;
        $result_master = mysqli_query($con, $query);
  $image = "http://www.lipsync.sg/uploads/master/".$session_id."-".$session_add_on."/".$user_id."-".$user_add_on."/thumb_4.png";              
       if (mysqli_num_rows($result_master) == 0) {
 
            $query = "INSERT INTO media_master (session_id, user_id, media_url, media_url_lo, start_time, default_thumb) VALUES (".$session_id.",".$user_id.",'".$final_video_url."','".$final_video_url_lo."',".$first_start.",'".$image."')";
            mysqli_query($con, $query);
            $entry_id = mysqli_insert_id($con);
        } else {
            $row_master = mysqli_fetch_array($result_master);
            $entry_id = $row_master['master_id'];
 
            $query = "UPDATE media_master SET media_url='".$final_video_url."', media_url_lo='".$final_video_url_lo."', start_time=".$first_start.",default_thumb='".$image."' WHERE session_id=".$session_id." AND user_id=".$user_id;
            mysqli_query($con, $query);
        }
    }
    mysqli_close($con);
    
    //Now, delete the temp directory
    deleteDirectory($temp_path);
    
    //Prepare some things for the email
    $thumbnail_path = "../uploads/master/".$session_id."-".$session_add_on."/".$user_id."-".$user_add_on."/thumb_4.png";
    $final_video_url = "http://www.gigreplay.com/watch.php?vid=".$entry_id;
    
    if ($num_videos == 0) {
        //There was no video. Please warn the user
        $mail = new PHPMailer;
        $mail->SetFrom('info@gigreplay.com', 'GigReplay');
        $address = $user_email;
        $mail->AddAddress($address);
        
        $mail->Subject = 'Error Creating Video';
        $body = "<br><hr><br>
        Dear ".$user_name.",<br>
        <br>
        There was an error creating your video for session $session_name. Please ensure that some videos have been uploaded to the server before generating a new video.<br>
            Remember, keep those videos rolling in.<br><br>
            
            GigReplay.
            
            <br><hr><br>This is an automatically generated email. Please do not reply.";
                $mail->AltBody = "To view the message, please use an HTML compatible email viewer.";
        $mail->MsgHTML($body);
        if(!$mail->Send()) {
            echo "Mailer Error: " . $mail->ErrorInfo;
        }
    } else {
        //Finally, email the user the final video
        $mail = new PHPMailer;
        $mail->SetFrom('info@gigreplay.com', 'GigReplay');
        $address = $user_email;
        $mail->AddAddress($address);
        $mail->AddEmbeddedImage($thumbnail_path, 'thumbnail');
        
        $mail->Subject = 'Your Video Has Been Completed';
        $body = "<br><hr><br>
        Dear ".$user_name.",<br>
        <br>
        Your video for session $session_name has been completed. You can watch your video at the following address: <br>
            <a href=\"".$final_video_url."\" target=\"_blank\">".$final_video_url."</a><br><br>
            <a href=\"".$final_video_url."\" target=\"_blank\"><img src='cid:thumbnail' /></a><br><br>
            Remember, keep those videos rolling in.<br><br>
            
            GigReplay.
            
            <br><hr><br>This is an automatically generated email. Please do not reply.";
                $mail->AltBody = "To view the message, please use an HTML compatible email viewer.";
        $mail->MsgHTML($body);
        if(!$mail->Send()) {
            echo "Mailer Error: " . $mail->ErrorInfo;
        }
    }
    
    
    
?>
