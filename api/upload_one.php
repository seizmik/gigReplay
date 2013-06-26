<?php
    
    function replace_extension($filename, $new_extension)
    {
        $info = pathinfo($filename);
        return $info['filename'] . '.' . $new_extension;
    }
    
    function create_name ($filename)
    {
        $info = pathinfo($filename);
        return $info['filename'] . '.' . $info['extension'];
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
    $session_name = $_POST['session_name'];
    //set unlimited time limit for request else when timed-out response not sent.
    set_time_limit(0);
    
    
    if (!empty($_FILES['uploadedfile']['name']) && !empty($_POST['session_id']) && !empty($_POST['start_time'])) {
        
        $session_add_on = implode("_", array_filter(explode(" ", preg_replace("/[^a-zA-Z0-9]+/", " ", $session_name)), 'strlen'));
        $target_path = "../uploads/original/".$session_id."-".$session_add_on."/";
        $target_low_res = "../uploads/low_res/".$session_id."-".$session_add_on."/";
        //Declare some variables here
        $original_target_path = nil;
        $low_res_path = nil;
        $file_url = nil;
        $low_res_url = nil;
        
        //Create the directories if they aren't created yet
        if (!is_dir($target_path)) {
            mkdir($target_path);
        }
        if (!is_dir($target_low_res)) {
            mkdir($target_low_res);
        }
        
        //If audio, rename into mp3. If video, rename into mp4.
        if ($media_type==1) {
            
            $caf = create_name(basename($_FILES['uploadedfile']['name']));
            $mp3 = replace_extension($caf, mp3);
            
            //Variables to feed into ffmpeg commands
            $original_target_path = $target_path . $caf;
            $low_res_path = "../uploads/low_res/".$session_id."-".$session_add_on."/".$mp3;
            
            //To feed into the database
            $file_url = "http://www.lipsync.sg/uploads/original/".$session_id."-".$session_add_on."/".$caf;
            $low_res_url = "http://www.lipsync.sg/uploads/low_res/".$session_id."-".$session_add_on."/".$mp3;
            
        } else if ($media_type==2) {
            
            $video = create_name(basename($_FILES['uploadedfile']['name']));
            //$ext = end(explode(".", $video));
            $mp4 = replace_extension($video, mp4);
            
            //Variables to feed into ffmpeg commands
            $original_target_path = $target_path . $video;
            $low_res_path = "../uploads/low_res/".$session_id."-".$session_add_on."/".$mp4;
            
            //To feed into the database
            $file_url = "http://www.lipsync.sg/uploads/original/".$session_id."-".$session_add_on."/".$video;
            $low_res_url = "http://www.lipsync.sg/uploads/low_res/".$session_id."-".$session_add_on."/".$mp4;
            
        }
        
        if (move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $original_target_path)) {
            //If the file has been moved and created, update the database
            //I believe that this is the part where we would be putting it into a queue using RabbitMQ
            $code="200";
            $message="Success";
            $responseArray=array();
            $responseArray['code']=$code;
            $responseArray['message']=$message;
            echo $responseArray['code'];
            echo $responseArray['message'];
            
            return json_encode($responseArray);
            
            
            //Execute the command to run another script from command line. Fork
            exec("php upload_two.php $user_id $session_id $start_time $media_type $original_target_path $file_url $low_res_path $low_res_url $session_add_on > /dev/null 2>&1");
        } else{
            echo "FAIL";
        }
    } else {
        echo "INITIAL FAIL";
    }
    
    ?>