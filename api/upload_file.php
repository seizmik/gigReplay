<?php

    function replace_extension($filename, $new_extension)
    {
        $info = pathinfo($filename);
        return $info['filename'] . '.' . $new_extension;
    }

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
    
    
    
    //End of function list--------------------------------------------------

    //Retrieve the POST-ed metadata
    $user_id = $_POST['user_id'];
    $session_id = $_POST['session_id'];
    $start_time = round($_POST['start_time'], 2);
    $media_type = $_POST['content_type'];
    
    $target_path = "../uploads/original/";
    //Declare some variables here
    $original_target_path = nil;
    $low_res_path = nil;
    $file_url = nil;
    $low_res_url = nil;
    
    //If audio, rename into mp3. If video, rename into mp4.
    if ($media_type==1) {
        
        $caf = basename($_FILES['uploadedfile']['name']);
        $mp3 = replace_extension($caf, mp3);
        
        //Variables to feed into ffmpeg commands
        $original_target_path = $target_path . $caf;
        $low_res_path = "../uploads/low_res/" . $mp3;
        
        //To feed into the database
        $file_url = "http://www.lipsync.sg/uploads/original/".$caf;
        $low_res_url = "http://www.lipsync.sg/uploads/low_res/".$mp3;
        
    } else if ($media_type==2) {
        
        $video = basename($_FILES['uploadedfile']['name']);
        //$ext = end(explode(".", $video));
        $mp4 = replace_extension($video, mp4);

        //Variables to feed into ffmpeg commands
        $original_target_path = $target_path . $video;
        $low_res_path = "../uploads/low_res/" . $mp4;
        
        //To feed into the database
        $file_url = "http://www.lipsync.sg/uploads/original/".$video;
        $low_res_url = "http://www.lipsync.sg/uploads/low_res/".$mp4;
        
    }
    
    if (move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $original_target_path)) {
        //If the file has been moved and created, update the database
        //I believe that this is the part where we would be putting it into a queue using RabbitMQ
        echo "SUCCESS";
        
        //Convert the uploaded file.
        //If it's audio, convert to mp3. If it's video, convert to 640x360 mp4.
        if ($media_type==1) {
            exec("ffmpeg -i " . $original_target_path . " " . $low_res_path);
        } else if ($media_type==2) {
            //This command creates the low res video file. I'm not sure why we need it now, but...
            exec("ffmpeg -i " . $original_target_path . " -s 640x360 " . $low_res_path);
            
            //This command strips the audio from the video
            $audio_only = pathinfo($original_target_path);
            $audio_only_path = $target_path . $audio_only['filename'] . "_audio.aac";
            $file_audio_url = "http://www.lipsync.sg/uploads/original/".$audio_only['filename'] . "_audio.aac";
            exec("ffmpeg -i " . $original_target_path . " -ab 512k -ac 2 -acodec libvo_aacenc -vn " . $audio_only_path);
            
        }
        
        $media_length = calculate_content_length($low_res_path);
        if ($media_type==2) {
            $start_time = $start_time - $media_length;
        }
        //Now that the length of the media has been calculated
        
        if ($_POST['session_id']) {
            $con = mysql_connect("localhost","mik","rivalries");
            if (!$con) {
                die('Could not connect: ' . mysql_error());
            } else {
                mysql_select_db("gigreplay", $con);
                $query = "INSERT INTO media_original (user_id, session_id, start_time, media_type, media_url, low_res_url, media_length) VALUES ('$user_id', '$session_id', '$start_time', '$media_type', '$file_url', '$low_res_url', '$media_length')";
                mysql_query($query);
            }
            
            //If it was a video, you'd need to make another entry for the audio file that was created
            if ($media_type==2) {
                //Difference is that media_type is now 3, and there is no low_res_url
                $query = "INSERT INTO media_original (user_id, session_id, start_time, media_type, media_url, media_length) VALUES ('$user_id', '$session_id', '$start_time', 3, '$file_audio_url', '$media_length')";
                mysql_query($query);
            }
            
            mysql_close($con);
        }
    } else{
        echo "FAIL";
    }
    
?>