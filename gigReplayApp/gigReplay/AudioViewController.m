//
//  AudioViewController.m
//  TimeSync2
//
//  Created by User on 25/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import "AudioViewController.h"
#import "AppDelegate.h"
#import "ConnectToDatabase.h"
#import "UploadTab.h"
#import "AEPlaythroughChannel.h"

@interface AudioViewController ()

@end

@implementation AudioViewController
@synthesize timeLabel;
@synthesize recordButton, playButton, uploadButton, volumeLabel;
@synthesize peakPowerGraph;
@synthesize recorder, audioController;

double startTime;
float currentTime;

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
        
    self.title = @"Audio Record";
    [self checkRecording];
    [self checkPlaying];
    
    self.audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:YES];
    [audioController enableBluetoothInput];
    [audioController start:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //NSLog(@"%@", appDelegateObject.CurrentSessionID);
    [self updateAudioRoute];
    levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [levelTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions

- (IBAction)recordPressed:(UIButton *)sender
{
    if (recorder) {
        //[self getStartTime]; //Somehow not consistent
        [recorder finishRecording];
        //[audioController removeOutputReceiver:recorder];
        [audioController removeInputReceiver:recorder];
        
        //Once it completes recording
        [self insertIntoDatabasewithPath:soundFileURL withStartTime:startTime fromSession:appDelegateObject.CurrentSessionID sessionNamed:appDelegateObject.CurrentSession_Name];
        
        //End the background task
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        
        //Reset the variables
        [peakPowerGraph setProgress:0.0];
        self.recorder = nil;
    } else {
        self.recorder = [[AERecorder alloc] initWithAudioController:audioController];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        
        //Create a new directory, if one is not there already
        NSString *newDir = [docsDir stringByAppendingPathComponent:@"GIGREPLAY_AUDIO"];
        [fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *soundFileName = [NSString stringWithFormat:@"/GIGREPLAY_AUDIO/%@.m4a", [self generateRandomString]];
        NSLog(@"Original audio path: %@", soundFileName);
        NSString *soundFilePath = [docsDir stringByAppendingPathComponent:soundFileName];
        soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError *error = nil;
        
        //Start the recording here. If it is successful, then place a start time.
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            //End the recording and input into the database if the background task expires
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            [recorder finishRecording];
            //[audioController removeOutputReceiver:recorder];
            [audioController removeInputReceiver:recorder];
            
            //Once it completes recording
            [self insertIntoDatabasewithPath:soundFileURL withStartTime:startTime fromSession:appDelegateObject.CurrentSessionID sessionNamed:appDelegateObject.CurrentSession_Name];
            
            bgTask = UIBackgroundTaskInvalid;
        }];
        if ( [recorder beginRecordingToFileAtPath:soundFilePath fileType:kAudioFileM4AType error:&error] ) {
            [self getStartTime];
        } else {
            //If there are no errors, get the start time of the audio
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            self.recorder = nil;
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
            return;
        }
        
        //[audioController addOutputReceiver:recorder];
        [audioController addInputReceiver:recorder];
    }
    [self checkRecording];
    [self timerStartStop];
    [self updateAudioRoute];
}

- (IBAction)playPressed:(UIButton *)sender {
    if (!audioPlayer.playing) {
        NSError *error;
        //Initialise the audio player. soundFileURL updates itself when the user records a new piece of audio
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        audioPlayer.delegate = self;
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            [audioPlayer play];
            [self timerStartStop];
        }
    } else {
        [audioPlayer stop];
    }
    [self checkPlaying];
    [self updateAudioRoute];
}

- (IBAction)uploadPressed:(UIButton *)sender {
    UploadTab *uploadVC = [[UploadTab alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
}

#pragma mark - Updating methods

- (void)checkRecording
{
    if (recorder) {
        //Prevents phone from sleeping
        [recordButton setTitle:@"STOP" forState:UIControlStateNormal];
        playButton.enabled = NO;
        uploadButton.enabled = NO;
        [self.navigationItem setHidesBackButton: YES animated: YES];
    } else {
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
        playButton.enabled = YES;
        uploadButton.enabled = YES;
        [self.navigationItem setHidesBackButton: NO animated: YES];
    }
}

- (void)checkPlaying
{
    if (audioPlayer.playing) {
        [playButton setTitle:@"STOP" forState:UIControlStateNormal];
        recordButton.enabled = NO;
        uploadButton.enabled = NO;
        [self.navigationItem setHidesBackButton: YES animated: YES];
    } else {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
        recordButton.enabled = YES;
        uploadButton.enabled = YES;
        [self.navigationItem setHidesBackButton: NO animated: YES];
        if ([audioTimer isValid]) {
            [audioTimer invalidate];
        }
    }
}

- (void)updateAudioRoute
{
    volumeLabel.text = [NSString stringWithFormat:@"Audio route: %@", audioController.audioRoute];
}


- (void)levelTimerCallback:(NSTimer *)timer {
    Float32 peakPower, averagePower;
    [audioController inputAveragePowerLevel:&averagePower peakHoldLevel:&peakPower];
    //NSLog(@"Average: %.2fdb, Peak: %.2fdb", averagePower, peakPower);
    
    peakPower = peakPower/160 + 1;
    averagePower = averagePower/60 + 1;
    peakPowerGraph.progress = averagePower;
    
}

- (void)insertIntoDatabasewithPath:(NSURL *)soundFilePath withStartTime:(double)start fromSession:(NSString *)sessionid sessionNamed:(NSString *)sessionName
{
    NSLog(@"Saving file: %@", soundFilePath);
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status, session_name) VALUES (%i, %@, '%@', %f, 1, 0, '%@')", appDelegateObject.CurrentUserID, sessionid, soundFilePath, start, sessionName];
    while (![dbObject insertToDatabase:strQuery]) {
        NSLog(@"Unable to update the database");
    }
}


- (void)timerStartStop
{
    if (![audioTimer isValid]) {
        currentTime = 0;
        self->audioTimer = [NSTimer
                           scheduledTimerWithTimeInterval:0.1
                           target:self
                           selector:@selector(timeUpdate:)
                           userInfo:nil
                           repeats:YES];
    } else {
        [self->audioTimer invalidate];
        self->audioTimer = nil;
    }
}

- (void)timeUpdate:(NSTimer *)theTimer
{
    currentTime += 0.1;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1f", currentTime];
}

- (void)getStartTime
{
    startTime = [[NSDate date] timeIntervalSince1970] + appDelegateObject.timeRelationship;
}

- (NSString *)generateRandomString
{
    NSMutableString *randomString = [NSMutableString string];
    randomString = [NSMutableString stringWithFormat:@"%@_%d_", appDelegateObject.CurrentSessionID, appDelegateObject.CurrentUserID];
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (NSURL *)getLocalFilePathToSave   //Calls when recorded video saved to document library
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //NSString *currentPath;
    //currentPath = [filemgr currentDirectoryPath];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *newDir = [docsDir stringByAppendingPathComponent:@"GIGREPLAY_AUDIO"];
    // NSLog(@"%@",newDir);
    
    NSString *m_strFilepath  = [[NSString alloc]initWithString:newDir];
    
    if ([filemgr fileExistsAtPath:m_strFilepath]) {
        // NSLog(@"hai");
    } else {
        [filemgr createDirectoryAtPath:m_strFilepath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *audioFilePath = [NSString stringWithFormat:@"/%@/%@.aac", newDir, [self generateRandomString]];
    if (m_strFilepath!=Nil) {
        m_strFilepath=Nil;
    }
    
    NSURL *audiopath = [NSURL fileURLWithPath:audioFilePath];
    NSLog(@"Get file path to save returns: %@", audioFilePath);
    return audiopath;
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

#pragma mark - Delegate methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self checkPlaying];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self checkRecording];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occurred");
}

#pragma  mark

@end
