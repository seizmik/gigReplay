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

@interface MediaRecordViewController ()

@end

@implementation MediaRecordViewController
@synthesize sceneTitleDisplay, sceneCodeDisplay, videoTimer;
@synthesize cameraUI, saveAlert;
@synthesize videoRecordButton, audioRecordButton;

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
    
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    isRecording = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    //Grab the expiration time
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
            [request startAsynchronous];
        } else {
            UIAlertView *generateError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unexpected error has occured." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [generateError show];
        }
    }
}

#pragma mark - Generating a thumbnail

-(NSString *)generateImageFromURL:(NSURL *)videoURL{
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
    //NSLog(@"%@", videoURL);
    UIImage *thumbnail = [[UIImage alloc] init];
    thumbnail = [player thumbnailImageAtTime:3.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    NSData *imageData = UIImagePNGRepresentation(thumbnail);
    
    //Generate a unique name for the image and folder
    NSString *imageName = [self generateUniqueFilename];
    
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
    cameraUI.videoMaximumDuration = 900;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.showsCameraControls = NO;
    cameraUI.navigationBarHidden = YES;
    
    //At this point, it should be taken from the options
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeIFrame960x540;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:cameraUI animated:YES completion:nil];
    //4 -overlay added to cameraui
    cameraUI.cameraOverlayView = overlay;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //This is in case the user becomes snap happy, so we need to record the URL and the startTime of the last video
    double thisVideoStartTime = startTime;
    NSString *thisVideoSession = appDelegateObject.CurrentSessionID;
    NSString *thisSessionName = appDelegateObject.CurrentSession_Name;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSURL *capturedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        
        //Save the video
        //capturedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSURL *outputURL = [self getLocalFilePathToSave]; //Getting Document Directory Path, There's a problem here
        
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        //Put this entire process into the background
        dispatch_queue_t compressQueue = dispatch_queue_create(NULL, 0);
        dispatch_async(compressQueue, ^{
            [self convertVideoToLowQuailtyWithInputURL:capturedVideoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
             {
                 if (exportSession.status == AVAssetExportSessionStatusCompleted)
                 {
                     //At this point, it should reveal that the video has stopped processing and has been saved
                     [self insertIntoDatabaseWithPath:outputURL withStartTime:thisVideoStartTime forSession:thisVideoSession sessionNamed:thisSessionName];
                     //If the conversion was successful, delete the original
                     [self removeFile:capturedVideoURL];
                 }
                 else
                 {
                     UIAlertView *compressError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not compress file properly." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                     [compressError dismissWithClickedButtonIndex:0 animated:YES];
                     [compressError show];
                     //Since it failed, we save the original video path instead
                     [self insertIntoDatabaseWithPath:capturedVideoURL withStartTime:thisVideoStartTime forSession:thisVideoSession sessionNamed:thisSessionName];
                 }
                 //Save a copy to the camera roll
                 UISaveVideoAtPathToSavedPhotosAlbum([capturedVideoURL relativePath], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                 [[UIApplication sharedApplication] endBackgroundTask:bgTask];
             }];
        });
        
    }
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

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)videoOutputURL
                                     handler:(void (^)(AVAssetExportSession *))handler  //Used to compress the video
{
    [[NSFileManager defaultManager] removeItemAtURL:videoOutputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    //AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //CGAffineTransform txf = [videoTrack preferredTransform];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = videoOutputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    NSLog (@"%@", exportSession.supportedFileTypes);
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

/*
- (void)fixOrientation
{
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    AVAssetTrack *FirstAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
    BOOL  isFirstAssetPortrait_  = NO;
    CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
    if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
    if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
    if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
    if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
    CGFloat FirstAssetScaleToFitRatio = 1.0;
    if(isFirstAssetPortrait_){
        FirstAssetScaleToFitRatio = 1.0;
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
    }
    
    [FirstlayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:AudioTrack];
    
    
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,nil];;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(360.0, 480.0);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"orientationFixedVideo-%d.mov",arc4random() % 1000]];
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.videoComposition = MainCompositionInst;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:exporter];
         });
     }];
}
*/

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
    
    NSString *videoFilePath = [NSString stringWithFormat:@"/%@/%@.mp4", newDir, [self generateUniqueFilename]];
    if (m_strFilepath!=Nil) {
        m_strFilepath=Nil;
    }
    
    NSURL *videopath = [NSURL fileURLWithPath:videoFilePath];
    NSLog(@"Get file path to save returns: %@", videoFilePath);
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
    overlay.backgroundColor = [UIColor clearColor];
    overlay.opaque = NO;
    
    //Back button
    backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5.0, 0.0, 60.0, 50.0)];
    [backButton addTarget:self action:@selector(imagePickerControllerDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    backButton.enabled = YES;
    [overlay addSubview:backButton];
    
    //Help button
    helpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [helpButton setTitle:@"Help" forState:UIControlStateNormal];
    [helpButton setFrame:CGRectMake((screenWidth - 45.0), 0.0, 40.0, 40.0)];
    [helpButton addTarget:self action:@selector(helpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    helpButton.enabled = YES;
    [overlay addSubview:helpButton];
    
    //Recording button
    cameraRecButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
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

- (void)recordButtonPressed
{
    
    if (isRecording == NO) {
        //Start recording
        isRecording = YES;
        [backButton setHidden:YES];
        [cameraRecButton setTitle:@"STOP" forState:UIControlStateNormal];
        [self timerStartStop];
        [cameraUI startVideoCapture];
        
    } else {
        [self timerStartStop];
        [self getStartTime];
        //Stop recording
        [cameraUI stopVideoCapture];
        isRecording = NO;
        [backButton setHidden:NO];
        [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    //NSLog(@"Start video! %f", startTime);
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
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status,thumbnail_path, session_name) VALUES (%i, %@, '%@', %f, 2, 0, '%@', '%@')", appDelegateObject.CurrentUserID, sessionID, videoURL, videoStartTime, thumbnailPath, sessionName];
    while (![dbObject insertToDatabase:strQuery]) {
        NSLog(@"Unable to update the database");
    }
}

/* To input into the thesmos.rdb database
-(void) insertIntoDatabaseVideoDetails:(NSURL*)videoURL image:(NSString*)videoThumb name:(NSString*)videoName{
    
    NSString *query=[NSString stringWithFormat:@"insert into Video_Details ('Video_URL','Video_Thumb','Video_Name') values ('%@','%@','%@')",videoURL,videoThumb,videoName];
    [appDelegateObject.databaseObject insertIntoDatabase:query];
    
}*/

- (NSString *)generateUniqueFilename
{
    NSString *prefixString = [NSString stringWithFormat:@"%@_%d_", appDelegateObject.CurrentSessionID, appDelegateObject.CurrentUserID];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    return uniqueFileName;
}

@end
