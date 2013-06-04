<?php
    set_include_path('../api/PHPMailer');
    require 'class.phpmailer.php';
    
    $user_email = "fadilaris@gmail.com";
    $user_name = "Fadil Aris";
    
    //Finally, email the user the final video
    $mail = new PHPMailer;
    $mail->SetFrom('info@gigreplay.com', 'GigReplay');
    $address = $user_email;
    $mail->AddAddress($address);
    
    $mail->Subject = 'Your Video Has Been Completed';
    $body = "<br><hr><br>
    Dear ".$user_name.",<br>
    <br>
    This is just a test mail.<br><br>
    
    GigReplay. Performances with a different angle.
    
    <br><hr><br>This is an automatically generated email. Please do not reply.";
    $mail->AltBody = "To view the message, please use an HTML compatible email viewer.";
    $mail->MsgHTML($body);
    if(!$mail->Send()) {
        echo "Mailer Error: " . $mail->ErrorInfo;
    }
    
    
?>
