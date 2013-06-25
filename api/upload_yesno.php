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
    
    
    //End of function list--------------------------------------------------
    
    //Retrieve the POST-ed metadata
    $file_name = $_POST['file_name'];
    $session_id = $_POST['session_id'];
    
    if (!empty($_POST['file_name']) && !empty($_POST['session_id'])) {
        $con = mysqli_connect("localhost", "default", "thesmosinc", "thesmos");
        if (mysqli_connect_errno($con)) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        } else {
            //Find out if the video has already been created once before
            $query = "SELECT * FROM session WHERE id=".$session_id;
            $result = mysqli_query($con, $query);
            $row = mysqli_fetch_array($result);
        }
        $session_name = $row['session_name'];
        $session_add_on = implode("_", array_filter(explode(" ", preg_replace("/[^a-zA-Z0-9]+/", " ", $session_name)), 'strlen'));
        
        //Create the path for the filename and check it
        $target_path = "../uploads/original/".$session_id."-".$session_add_on."/";
        $target_path .= $file_name;
        
        if (file_exists($target_path)) {
            echo "COMPLETED";
        } else {
            echo "UPLOAD";
        }
        
    } else {
        echo "ERROR";
    }
    
    
    
?>