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
    
    //Retrieve the arguments from the server
    $user_id = $_SERVER['argv'][1];
    $session_id = $_SERVER['argv'][2];
    $start_time = $_SERVER['argv'][3];
    $media_type = $_SERVER['argv'][4];
    $original_target_path = $_SERVER['argv'][5];
    $file_url = $_SERVER['argv'][6];
    $low_res_path = $_SERVER['argv'][7];
    $low_res_url = $_SERVER['argv'][8];
    $session_add_on = $_SERVER['argv'][9];
    
    $target_path = "../uploads/original/".$session_id."-".$session_add_on."/";
    
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
        $file_audio_url = "http://www.lipsync.sg/uploads/original/".$session_id."-".$session_add_on."/".$audio_only['filename'] . "_audio.aac";
        exec("ffmpeg -i " . $original_target_path . " -ab 512k -ac 2 -acodec libvo_aacenc -vn " . $audio_only_path);
    }
    
    $media_length = calculate_content_length($original_target_path);
    //$start_time = $start_time - $media_length;
    /*
    if ($media_type == 2) {
        //Due to electronic lag, we took the start time of the video to be the end of the video. So need to subtract the media length from it.
        $start_time = $start_time - $media_length;
    }*/
    
    $con = mysqli_connect("localhost", "default", "thesmosinc", "gigreplay");
    if (mysqli_connect_errno($con)) {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    } else {
        $query = "INSERT INTO media_original (user_id, session_id, start_time, media_type, media_url, low_res_url, media_length) VALUES ('$user_id', '$session_id', '$start_time', '$media_type', '$file_url', '$low_res_url', '$media_length')";
        mysqli_query($con, $query);
    }
    
    //If it was a video, you'd need to make another entry for the audio file that was created
    if ($media_type==2) {
        //Difference is that media_type is now 3, and there is no low_res_url
        $query = "INSERT INTO media_original (user_id, session_id, start_time, media_type, media_url, media_length) VALUES ('$user_id', '$session_id', '$start_time', 3, '$file_audio_url', '$media_length')";
        mysqli_query($con, $query);
    }
    mysqli_close($con);
    
?>