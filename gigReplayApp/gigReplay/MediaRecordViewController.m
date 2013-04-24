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

- (IBAction)videoRecord:(id)sender {
    [self startCameraController:self usingDelegate:self];
}

- (IBAction)audioRecord:(UIButton *)sender {
    AudioViewController *audioVC = [[AudioViewController alloc] init];
    [self.navigationController pushViewController:audioVC animated:YES];
}

- (IBAction)uploadButtonPressed:(UIButton *)sender {
    UploadTab *uploadVC = [[UploadTab alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
}


#pragma mark - Video Recorder Methods

//StartVideoCaptureMethods
-(BOOL)startCameraController:(UIViewController *)controller usingDelegate:(id)delegate{
    
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
    //At this point, it should be taken from the options
    //cameraUI.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeLow;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:cameraUI animated:YES completion:nil];
    //4 -overlay added to cameraui
    cameraUI.cameraOverlayView=overlay;
    return YES;
}

//This method is required as it is a callback method when videoController is done with videoRecording else it doesnt know
//what to do with the recorded video
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    movieURL = [info valueForKey:UIImagePickerControllerMediaURL];
    
    //What if you don't dismiss? Can still take more videos?
    [self dismissViewControllerAnimated:YES completion:nil];
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self,
                                                @selector(video:didFinishSavingWithError:contextInfo:), nil);
            //Updates movieURL so that we can update the database with it
            //movieURL = [NSURL URLWithString:moviePath];
            NSLog(@"Movie path is %@. Start time is %f.", movieURL, startTime);
        } 
    }
    
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Failed to save video"
                                                       delegate:nil
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
                                                        message:@"Video saved to your camera roll"
                                                       delegate:self
                                              cancelButtonTitle:@"Continue"
                                              otherButtonTitles:nil];
        [self saveVideo];
        [alert show];
        //Only insert it into the database here, because the user hasn't said yes
        //Might move it as a UIAlertView delegate method to improve performance
        //[self insertIntoDatabase];
    }
}

-(void) saveVideo
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    // NSString *currentPath;
    // currentPath = [filemgr currentDirectoryPath];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *newDir = [docsDir stringByAppendingPathComponent:@"GIGREPLAY_VIDEO"];
    NSLog(@"%@",newDir);
    if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:nil attributes:nil error:nil])
    {
        // Failed to create directory
    }
    NSString *aName = [NSString stringWithFormat:@"/GIGREPLAY_VIDEO/%@.mp4",[[NSDate date] description]];
    NSString *videoFilePath = [docsDir stringByAppendingPathComponent:aName];
    NSData *videoData = [NSData dataWithContentsOfURL:movieURL];
    [videoData writeToFile:videoFilePath atomically:YES];
    NSLog(@"%@",videoFilePath);
    movieURL = [NSURL fileURLWithPath:videoFilePath];
    [self insertIntoDatabase];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)createOverlay{
    //overlay = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    overlay = [[UIView alloc] initWithFrame:CGRectMake(270,430,320,480)];
    overlay.backgroundColor = [UIColor clearColor];
    overlay.opaque = NO;
    
    /*
    miksButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage * saveButtonImage = [UIImage imageNamed:@"mik.png"];
    [miksButton setBackgroundImage:saveButtonImage forState:UIControlStateNormal];
    [miksButton setFrame:CGRectMake(0, 0, 60, 40)];
    [miksButton addTarget:self action:@selector(miksButtonMethod) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:miksButton];
     */
    
    //Record Button
    //cameraRecButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIImage *recButtonImage = [UIImage imageNamed:@"record-button.png"];
    //[cameraRecButton setBackgroundImage:recButtonImage forState:UIControlStateNormal];
    //[cameraRecButton setTitle:@"Rec" forState:UIControlStateNormal];
    //[cameraRecButton setFrame:CGRectMake(110.0, 8.0, 90.0, 40.0)];
    
    cameraRecButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[cameraRecButton setAlpha:1.0];
    [cameraRecButton setFrame:CGRectMake(0, 0, 120.0, 50.0)];
    cameraRecButton.enabled = YES;
    [cameraRecButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:cameraRecButton];
}

-(void)recordButtonPressed {
    
    if (isRecording == NO) {
        //Start recording
        isRecording = YES;
        [cameraUI startVideoCapture];

    } else {
        //cameraRecButton.hidden = YES;
        //Stop recording
        [cameraUI stopVideoCapture];
        [self getStartTime];
        isRecording = NO;
    }
    
}

- (void)getStartTime {
    startTime = [[NSDate date] timeIntervalSince1970] + appDelegateObject.timeRelationship;
    NSLog(@"Start video! %f", startTime);
}


#pragma mark - Upload tracking methods

- (void)insertIntoDatabase
{
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status) VALUES (%i, %i, '%@', %f, 2, 0)", appDelegateObject.CurrentUserID, appDelegateObject.CurrentSessionID, movieURL, startTime];
    while (![dbObject insertToDatabase:strQuery]) {
        NSLog(@"Unable to update the database");
    }
}

@end
