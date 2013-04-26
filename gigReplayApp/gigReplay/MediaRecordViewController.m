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

@interface MediaRecordViewController ()

@end

@implementation MediaRecordViewController
@synthesize sceneTitleDisplay, sceneCodeDisplay;
@synthesize cameraUI, movieURL;

double startTime;
float currentTime;
bool isRecording;

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
    self.title = appDelegateObject.CurrentSession_Name;
    isRecording = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    sceneTitleDisplay.text=appDelegateObject.CurrentSession_Name;
    sceneCodeDisplay.text=appDelegateObject.CurrentSession_Code;
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
    //cameraUI.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeMedium;
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
    double thisVideoStartTime = startTime;
    
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSURL *capturedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        /*
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Saving In Progress"
                                                            message:@"Do not close app until save is complete. This may take several minutes"
                                                           delegate:self
                                                  cancelButtonTitle:@"Continue"
                                                  otherButtonTitles:nil];
        [saveAlert show];
        //Save the video
        NSURL *capturedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        self.movieURL = capturedVideoURL;
        //NSURL *outputURL = [self getLocalFilePathToSave]; //Getting Document Directory Path
        
        [self convertVideoToLowQuailtyWithInputURL:capturedVideoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted)
             {
                 //UIAlertView *compressComplete = [[UIAlertView alloc] initWithTitle:@"Save Completed" message:@"File has been saved and is ready for upload." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                 //[compressComplete show];
                 //Save the details into the database
                 [self insertIntoDatabaseWithPath:outputURL withStartTime:thisVideoStartTime];
                 [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
                 cameraRecButton.enabled = YES;
                 
                 //[self RemoveRecordedVideoFromHD];
                 //NSLog(@"local path %@",[outputURL path]);
             }
             else
             {
                 UIAlertView *compressError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not save file properly" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                 [compressError show];
                 //[self RemoveRecordedVideoFromHD];
             }
         }];*/
        [self insertIntoDatabaseWithPath:capturedVideoURL withStartTime:thisVideoStartTime];
        UISaveVideoAtPathToSavedPhotosAlbum([capturedVideoURL relativePath], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Failed to save video"
                                                       delegate:nil
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:nil];
        [alert show];
        [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
        cameraRecButton.enabled = YES;
    } else {
        NSLog(@"Successfully saved to the camera roll");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
                                                        message:@"Video saved to your camera roll"
                                                       delegate:self
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:nil];
        [alert show];
        [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
        cameraRecButton.enabled = YES;
    }
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler   //Used to compress the video
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}



- (NSURL*)getLocalFilePathToSave   //Calls when recorded video saved to document library
{
    NSString *todayString = [[NSDate date] description];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    // NSString *currentPath;
    // currentPath = [filemgr currentDirectoryPath];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *newDir = [docsDir stringByAppendingPathComponent:@"LIPSYNC_VIDEO"];
    // NSLog(@"%@",newDir);
    
    NSString *m_strFilepath  = [[NSString alloc]initWithString:newDir];
    
    if ([filemgr fileExistsAtPath:m_strFilepath])
    {
        // NSLog(@"hai");
    }
    
    else
    {
        [filemgr createDirectoryAtPath:m_strFilepath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *videoFilePath = [NSString stringWithFormat:@"/%@/%@.MOV",newDir,todayString];
    
    if (m_strFilepath!=Nil)
    {
        m_strFilepath=Nil;
    }
    
    NSURL *videopath=[NSURL fileURLWithPath:videoFilePath];
    return videopath;
}

-(void)createOverlay{
    //Determine size of screen in case of iPhone 5
    float setY = self.view.bounds.size.height - 50;
    float setX = self.view.bounds.size.width;
    
    //overlay = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 430, setX, 50)];
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
    [helpButton setFrame:CGRectMake((setX - 45.0), 0.0, 40.0, 40.0)];
    [helpButton addTarget:self action:@selector(helpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    helpButton.enabled = YES;
    [overlay addSubview:helpButton];
    
    //Recording button
    cameraRecButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cameraRecButton setTitle:@"Record" forState:UIControlStateNormal];
    [cameraRecButton setFrame:CGRectMake((setX/2 - 60.0), 0, 120.0, 50.0)];
    [cameraRecButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cameraRecButton.enabled = YES;
    [overlay addSubview:cameraRecButton];
}

- (void)recordButtonPressed
{
    
    if (isRecording == NO) {
        //Start recording
        isRecording = YES;
        [backButton setHidden:YES];
        [cameraRecButton setTitle:@"STOP" forState:UIControlStateNormal];
        [cameraUI startVideoCapture];

    } else {
        [self getStartTime];
        //Stop recording
        [cameraUI stopVideoCapture];
        //[self getStartTime];
        isRecording = NO;
        [backButton setHidden:NO];
        [cameraRecButton setTitle:@"Saving" forState:UIControlStateNormal];
        cameraRecButton.enabled = NO;
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)helpButtonPressed {
    NSLog(@"HELP!!!");
}

- (void)getStartTime {
    startTime = [[NSDate date] timeIntervalSince1970] + appDelegateObject.timeRelationship;
    NSLog(@"Start video! %f", startTime);
}


#pragma mark - Upload tracking methods

- (void)insertIntoDatabaseWithPath:(NSURL *)videoURL withStartTime:(double)videoStartTime
{
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status) VALUES (%i, %i, '%@', %f, 2, 0)", appDelegateObject.CurrentUserID, appDelegateObject.CurrentSessionID, videoURL, videoStartTime];
    while (![dbObject insertToDatabase:strQuery]) {
        NSLog(@"Unable to update the database");
    }
}

@end
