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
    
    $target_path = "../uploads/original/";
    //Declare some variables here
    
    //Create the path for the filename and check it
    $target_path .= $file_name;
    
    if (file_exists($target_path)) {
        echo "COMPLETED";
    } else {
        echo "UPLOAD";
    }
    
?>