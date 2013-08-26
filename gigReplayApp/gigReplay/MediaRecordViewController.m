//
//  MediaRecordViewController.m
//  gigReplay
//
//  Created by Leon Ng on 8/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "MediaRecordViewController.h"
#import "AudioViewController.h"
#import "UploadTab.h"
#import "ConnectToDatabase.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "SettingsViewController.h"

@interface MediaRecordViewController ()

@end

@implementation MediaRecordViewController
@synthesize sceneTitleDisplay, sceneCodeDisplay, videoTimer;
@synthesize cameraUI, saveAlert, isRecording;
@synthesize videoRecordButton, audioRecordButton;

double startTime;
int currentTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImageView *divider=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1, 320, 1)];
    divider.image=[UIImage imageNamed:@"color.png"];
    [self.view addSubview:divider];

    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    isRecording = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self loadSettingsButton];
    //Grab the expiration time and start counting down
    
}

-(void)viewDidAppear:(BOOL)animated
{
    sceneTitleDisplay.text=appDelegateObject.CurrentSession_Name;
    sceneCodeDisplay.text=appDelegateObject.CurrentSession_Code;
    self.title = appDelegateObject.CurrentSession_Name;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button actions

- (IBAction)videoRecordPressed:(UIButton *)sender {
    [self startCameraController:self usingDelegate:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (IBAction)audioRecordPressed:(UIButton *)sender {
    AudioViewController *audioVC = [[AudioViewController alloc] init];
    [self.navigationController pushViewController:audioVC animated:YES];
}

- (IBAction)uploadButtonPressed:(UIButton *)sender {
    UploadTab *uploadVC = [[UploadTab alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
    
    
}

- (IBAction)generateVideo:(UIButton *)sender
{
    UIAlertView *videoGenerating = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This will generate a new video that will replace any previous versions. An email will be sent to you once the video is ready for viewing." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [videoGenerating show];
}

//This is the alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        //Getting the user's email here
        SQLdatabase *sql = [[SQLdatabase alloc] initDatabase];
        NSString *strQuery = @"SELECT * FROM Users";
        NSMutableArray *userDetails = [sql readFromDatabaseUsers:strQuery];
        
        if ([userDetails count] == 1) {
            /*
            //Create the form and post it to the API
            NSURL *postURL = [NSURL URLWithString:GIGREPLAY_API_URL@"auto_edit_user.php"];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:postURL];
            //Now, add the data. In this case, we only send the user id, email and session number
            [request addPostValue:appDelegateObject.CurrentSessionID forKey:@"session_id"];
            [request addPostValue:appDelegateObject.CurrentSession_Name forKey:@"session_name"];
            [request addPostValue:[NSString stringWithFormat:@"%i", appDelegateObject.CurrentUserID] forKey:@"user_id"];
            NSString *userEmail = [NSString stringWithFormat:@"%@", [[userDetails objectAtIndex:0] objectAtIndex:4]];
            [request addPostValue:userEmail forKey:@"user_email"];
            [request addPostValue:appDelegateObject.CurrentUserName forKey:@"user_name"];
            [request setRequestMethod:@"POST"];
            [request setDelegate:self];
            [request setShouldContinueWhenAppEntersBackground:YES];
            NSLog(@"%@, %@, %i, %@, %@", appDelegateObject.CurrentSessionID, appDelegateObject.CurrentSession_Name, appDelegateObject.CurrentUserID, userEmail, appDelegateObject.CurrentUserName);
            [request startAsynchronous];
            */
            [self postToGenerateVideo];
        } else {
            UIAlertView *generateError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unexpected error has occured." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [generateError show];
        }
    }
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)postToGenerateVideo
{
    //Getting the user's email here
    SQLdatabase *sql = [[SQLdatabase alloc] initDatabase];
    NSString *strQuery = @"SELECT * FROM Users";
    NSMutableArray *userDetails = [sql readFromDatabaseUsers:strQuery];
    
    if ([userDetails count] == 1) {
        //Create the form and post it to the API
        NSURL *postURL = [NSURL URLWithString:GIGREPLAY_API_URL@"auto_edit_user.php"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:postURL];
        //Now, add the data. In this case, we only send the user id, email and session number
        [request addPostValue:appDelegateObject.CurrentSessionID forKey:@"session_id"];
        [request addPostValue:appDelegateObject.CurrentSession_Name forKey:@"session_name"];
        [request addPostValue:[NSString stringWithFormat:@"%i", appDelegateObject.CurrentUserID] forKey:@"user_id"];
        NSString *userEmail = [NSString stringWithFormat:@"%@", [[userDetails objectAtIndex:0] objectAtIndex:4]];
        [request addPostValue:userEmail forKey:@"user_email"];
        [request addPostValue:appDelegateObject.CurrentUserName forKey:@"user_name"];
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        [request setShouldContinueWhenAppEntersBackground:YES];
        NSLog(@"%@, %@, %i, %@, %@", appDelegateObject.CurrentSessionID, appDelegateObject.CurrentSession_Name, appDelegateObject.CurrentUserID, userEmail, appDelegateObject.CurrentUserName);
        [request startAsynchronous];
    }
}

- (void)loadSettingsButton
{
    UIImage *image = [UIImage imageNamed:@"navigation_settings_button.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(0, 0, 23, 23)];
    [settingsButton setImage:image forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    set.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:set animated:YES];
}

#pragma mark - Generating a thumbnail

- (NSString *)generateImageFromURL:(NSURL *)videoURL{
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
    //NSLog(@"%@", videoURL);
    UIImage *thumbnail = [[UIImage alloc] init];
    thumbnail = [player thumbnailImageAtTime:3.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    CGFloat compression = 0.9f;
    NSData *imageData = UIImageJPEGRepresentation(thumbnail, compression);
    
    //Generate a unique name for the image and folder
    NSString *imageName = [self generateRandomString];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePathFull = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]];
    [fileManager createFileAtPath:imagePathFull contents:imageData attributes:nil];
    [player stop];
    
    return imagePathFull;

}

#pragma mark - Video Recorder Methods

- (BOOL)startCameraController:(UIViewController *)controller usingDelegate:(id)delegate
{
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    //Call create overlay method to be implemented
    [self createOverlay];
    // 2 - Get image picker
    cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.showsCameraControls = NO;
    cameraUI.toolbarHidden=YES;
    cameraUI.navigationBarHidden = YES;
    [cameraUI setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    
    //At this point, it should be taken from the options
    cameraUI.videoQuality=UIImagePickerControllerQualityTypeIFrame960x540 ;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:cameraUI animated:YES completion:nil];
    //4 -overlay added to cameraui
    cameraUI.cameraOverlayView = overlay;
    
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //This is in case the user becomes snap happy, so we need to record the URL and the startTime of the last video
    NSURL *capturedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    //First, save a version of it here. So, if the app crashes, it will still have a video to upload later
    //Then, once it is done converting, update with the new URL based on the capturedVideoURL
    [self insertIntoDatabaseWithPath:capturedVideoURL withStartTime:startTime forSession:appDelegateObject.CurrentSessionID sessionNamed:appDelegateObject.CurrentSession_Name];
    
    //Save a copy to the camera roll
    //UISaveVideoAtPathToSavedPhotosAlbum([capturedVideoURL relativePath], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    //Save the video
    
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
    }];
    //Put this entire process into the background
    //Dispatch async should be here
    dispatch_async(dispatch_get_main_queue(), ^{
        [self convertVideoToLowQuailtyFromURL:capturedVideoURL];
    });
}


- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Failed to save video"
                                                       delegate:nil
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:nil];
        [alert show];
    } //Don't need to do anything if the video was successfully saved
    
}


- (void)convertVideoToLowQuailtyFromURL:(NSURL*)capturedVideoURL
{
    NSLog(@"Enabling camera again");
    //End off by having the buttons being enabled again
    //[backButton setHidden:NO];
    //[cameraRecButton setEnabled:YES];
    //[cameraRecButton setImage:[UIImage imageNamed:@"recording_overlay_off_icon"] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self startCameraController:self usingDelegate:self];
    
    NSLog(@"Converting video");
    NSURL *videoOutputURL = [self getLocalFilePathToSave];
    [[NSFileManager defaultManager] removeItemAtURL:videoOutputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:capturedVideoURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                      presetName:AVAssetExportPreset960x540];
    exporter.outputURL=videoOutputURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        [self exportDidFinish:exporter input:capturedVideoURL];
    }];

   
}

-(void)exportDidFinish:(AVAssetExportSession*)session input:(NSURL*)inputURL
{
    if ( session.status== AVAssetExportSessionStatusCompleted){
        NSLog(@"Export and compression done!");
        //At this point, it should reveal that the video has stopped processing and has been saved
        NSURL *compressedVideo=session.outputURL;
        
        //So here, update the database with the new details
        [self updateDatabaseWithNewPath:compressedVideo fromOldPath:inputURL];
        
        //If the conversion was successful, delete the original
        [self removeFile:inputURL];
    } else {
        UIAlertView *compressError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not compress file properly." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [compressError dismissWithClickedButtonIndex:0 animated:YES];
        [compressError show];
        //Since the original data was saved into the database, don't have to do anything anymore
    }
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
 
}



- (NSURL *)getLocalFilePathToSave   //Calls when recorded video saved to document library
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //NSString *currentPath;
    //currentPath = [filemgr currentDirectoryPath];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *newDir = [docsDir stringByAppendingPathComponent:@"LIPSYNC_VIDEO"];
    // NSLog(@"%@",newDir);
    
    NSString *m_strFilepath  = [[NSString alloc]initWithString:newDir];
    
    if ([filemgr fileExistsAtPath:m_strFilepath]) {
        // NSLog(@"hai");
    } else {
        [filemgr createDirectoryAtPath:m_strFilepath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *videoFilePath = [NSString stringWithFormat:@"/%@/%@.mp4", newDir, [self generateRandomString]];
    if (m_strFilepath!=Nil) {
        m_strFilepath=Nil;
    }
    
    NSURL *videopath = [NSURL fileURLWithPath:videoFilePath];
    //NSLog(@"Get file path to save returns: %@", videoFilePath);
    return videopath;
}

-(void)createOverlay{
    //Determine size of screen in case of iPhone 5
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //overlay = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, (screenHeight - 50), screenWidth, 50.0)];
    //NSLog(@"setX is %f. setY is %f", setX, setY);
    overlay.backgroundColor=[UIColor clearColor];
    overlay.opaque = YES;
    
    //Back button
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor=[UIColor clearColor];
    backButton.highlighted=YES;
    [backButton setImage:[UIImage imageNamed:@"recording_overlay_back_icon"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5.0, 0.0, 60.0, 50.0)];
    [backButton addTarget:self action:@selector(imagePickerControllerDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    backButton.enabled = YES;
    [overlay addSubview:backButton];
    
    //Flash toggle
    flashtoggle=[[UISwitch alloc]initWithFrame:CGRectMake((screenWidth - 80.0), 10.0, 40.0, 40.0)];
    flashtoggle.backgroundColor=[UIColor clearColor];
    flashtoggle.highlighted=YES;
    [flashtoggle addTarget:self action:@selector(flashtoggle) forControlEvents:UIControlEventValueChanged];
    [overlay  addSubview:flashtoggle];
    
    //Recording button
    cameraRecButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraRecButton setImage:[UIImage imageNamed:@"recording_overlay_off_icon"] forState:UIControlStateNormal];
    [cameraRecButton setFrame:CGRectMake((screenWidth/2 - 60.0), 0, 120.0, 50.0)];
    [cameraRecButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cameraRecButton.enabled = YES;
    [overlay addSubview:cameraRecButton];
    
    //Create the timerLabel
    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth - 70.0), -80.0, 75.0, 30.0)];
    timerLabel.numberOfLines = 1;
    timerLabel.backgroundColor = [UIColor lightGrayColor];
    timerLabel.alpha = 0.6;
    timerLabel.textColor = [UIColor whiteColor];
    timerLabel.text = [self timeFormatted:0];
    timerLabel.textAlignment = NSTextAlignmentCenter;
    timerLabel.adjustsFontSizeToFitWidth = YES;
    timerLabel.layer.cornerRadius = 8.0;
    
    //rotate label 90 degrees
    timerLabel.transform = CGAffineTransformMakeRotation( M_PI/2 );
    timerLabel.hidden = YES;
    
    [overlay addSubview:timerLabel];
}

-(void)flashtoggle{
    if (flashtoggle.on){
        [cameraUI setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
        
                              
    }
    else {
        [cameraUI setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        
    }
}


- (void)recordButtonPressed
{
    
    if (isRecording == NO) {
        //Start recording
        isRecording = YES;
        [backButton setHidden:YES];
        [cameraRecButton setImage:[UIImage imageNamed:@"Recording_overlay_on_icon"] forState:UIControlStateNormal];
        [self timerStartStop];
        [cameraUI startVideoCapture];
        //[self getStartTime];
    } else {
        [self getStartTime];
        //Stop recording
        [cameraUI stopVideoCapture];
        [self timerStartStop];
        isRecording = NO;
        [cameraRecButton setEnabled:NO];
        
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)helpButtonPressed {
    NSLog(@"HELP!!!");
}

- (void)removeFile:(NSURL *)fileURL {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:fileURL error:&error];
    if (error) {
        NSLog(@"Error occured: %@", [error localizedDescription]);
    } else {
        NSLog(@"File is gone!!!");
    }
}

#pragma mark - Timer methods

- (void)getStartTime {
    startTime = [[NSDate date] timeIntervalSince1970] + appDelegateObject.timeRelationship;
    NSLog(@"Start video! %f", startTime);
}

- (void)timerStartStop {
    if (![videoTimer isValid]) {
        timerLabel.text = [self timeFormatted:0];
        timerLabel.hidden = NO;
        currentTime = 0;
        self.videoTimer = [NSTimer
                           scheduledTimerWithTimeInterval:1.00
                           target:self
                           selector:@selector(timeUpdate:)
                           userInfo:nil
                           repeats:YES];
    } else {
        [self.videoTimer invalidate];
        self.videoTimer = nil;
        [timerLabel setHidden:YES];
    }
}

- (void)timeUpdate:(NSTimer *)theTimer {
    currentTime += 1;
    self->timerLabel.text = [NSString stringWithFormat:@"%@", [self timeFormatted:currentTime]];
    if (currentTime==900) {
        [self recordButtonPressed];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - Upload tracking methods

- (void)insertIntoDatabaseWithPath:(NSURL *)videoURL withStartTime:(double)videoStartTime forSession:(NSString *)sessionID sessionNamed:(NSString *)sessionName
{
    //Create the thumbnail at this point and store into the database
    NSString *thumbnailPath = [self generateImageFromURL:videoURL];
    
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status,thumbnail_path, session_name) VALUES (%i, '%@', '%@', %f, 2, 9, '%@', '%@')", appDelegateObject.CurrentUserID, sessionID, videoURL, videoStartTime, thumbnailPath, sessionName];
    //Status 8 is converting
    while (![dbObject insertToDatabase:strQuery]) {
        NSLog(@"Unable to insert into the database");
    }
}

- (void)updateDatabaseWithNewPath:(NSURL *)newPath fromOldPath:(NSURL *)oldPath
{
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET file_path='%@',upload_status=0 WHERE file_path='%@'", newPath, [NSString stringWithFormat:@"%@", oldPath]];
    while (![dbObject updateDatabase:strQuery]) {
        NSLog(@"Unable to update database");
    }
}

-(NSString *) generateRandomString
{
    NSMutableString *randomString = [NSMutableString string];
    randomString = [NSMutableString stringWithFormat:@"%@_%d_", appDelegateObject.CurrentSessionID, appDelegateObject.CurrentUserID];
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
