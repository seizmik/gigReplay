<?php
    
    function replace_extension($filename, $new_extension)
    {
        $info = pathinfo($filename);
        return $info['filename'] . '.' . $new_extension;
    }
    
    function create_random_name ($filename)
    {
        $random_string = generate_random_string();
        $info = pathinfo($filename);
        return $info['filename'] . '_' . $random_string . '.' . $info['extension'];
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
    
    function generate_random_string($length = 10) {
        //Can set length by making length a fixed number
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $randomString = '';
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, strlen($characters) - 1)];
        }
        return $randomString;
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
        
        $caf = create_random_name(basename($_FILES['uploadedfile']['name']));
        $mp3 = replace_extension($caf, mp3);
        
        //Variables to feed into ffmpeg commands
        $original_target_path = $target_path . $caf;
        $low_res_path = "../uploads/low_res/" . $mp3;
        
        //To feed into the database
        $file_url = "http://www.lipsync.sg/uploads/original/".$caf;
        $low_res_url = "http://www.lipsync.sg/uploads/low_res/".$mp3;
        
    } else if ($media_type==2) {
        
        $video = create_random_name(basename($_FILES['uploadedfile']['name']));
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
        
        //Execute the command to run another script from command line. Fork
        exec("php upload_two.php $user_id $session_id $start_time $media_type $original_target_path $file_url $low_res_path $low_res_url > /dev/null 2>&1");
    } else{
        echo "FAIL";
    }
    
    ?>