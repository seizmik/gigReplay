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

@interface AudioViewController ()

@end

@implementation AudioViewController
@synthesize timeLabel;
@synthesize recordButton, playButton, uploadButton, volumeLabel;
@synthesize peakPowerGraph;

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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Audio Record";
    [self checkRecording];
    [self checkPlaying];
    
    
    //NSLog(@"%@", appDelegateObject.CurrentSessionID);
    //levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions

- (IBAction)recordPressed:(UIButton *)sender {
    
    if (!audioRecorder.recording) {
        NSError *error = nil;
        error = [self setupAudioRecorder];
        
        //Audio recorder now initialised. Time to prepare the audio recorder
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Continue"
                                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            [audioRecorder prepareToRecord];
            [audioRecorder record];
            [self getStartTime];
            [self checkRecording];
            levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo: nil repeats: YES];
        }
    } else {
        //We get the stop time here to make it the same as video sync
        //[self getStartTime];
        [audioRecorder stop];
        
        //Convert the file to aac
        lowResURL = [self getLocalFilePathToSave];
        //Using TPAACAudioConverter to convert file to AAC format
        audioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self
                                                                source:[soundFileURL path]
                                                           destination:[lowResURL path]];
        [audioConverter start];
        //Here, we rely on the delegates to update the recording status. As long as the conversion is not complete, or has not faulted, the record button will not trigger. Hence, you cannot reset the soundFileURL, startTime, or back out and change the session.
        [levelTimer invalidate];
    }
    [self timerStartStop];
    
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
}

- (IBAction)uploadPressed:(UIButton *)sender {
    UploadTab *uploadVC = [[UploadTab alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
}

#pragma mark - Updating methods

- (void)checkRecording
{
    if (audioRecorder.recording) {
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

- (void)levelTimerCallback:(NSTimer *)timer {
	[audioRecorder updateMeters];
	//NSLog(@"Average input: %f Peak input: %f", [audioRecorder averagePowerForChannel:0], [audioRecorder peakPowerForChannel:0]);
    float peakPower, averagePower;
    peakPower = [audioRecorder peakPowerForChannel:0]/160 + 1;
    averagePower = [audioRecorder averagePowerForChannel:0]/60 + 1;
    volumeLabel.text = [NSString stringWithFormat:@"Sound level: %.2fdb", [audioRecorder peakPowerForChannel:0]];
    peakPowerGraph.progress = peakPower;
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

#pragma mark

- (NSError *)setupAudioRecorder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    //Create a new directory, if one is not there already
    NSString *newDir = [docsDir stringByAppendingPathComponent:@"GIGREPLAY_AUDIO"];
    [fileManager createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *soundFileName = [NSString stringWithFormat:@"/GIGREPLAY_AUDIO/%@.caf", [self generateRandomString]];
    NSLog(@"Original audio path: %@", soundFileName);
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:soundFileName];
    soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    
    return error;
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

- (void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter*)converter {
    NSLog(@"So, by right, we should be adding it into the database at this point");
    [self insertIntoDatabasewithPath:lowResURL withStartTime:startTime fromSession:appDelegateObject.CurrentSessionID sessionNamed:appDelegateObject.CurrentSession_Name];
    [self removeFile:soundFileURL];
    //Must change the soundFileURL because it's going to be deleted, then the player can't play it
    soundFileURL = lowResURL;
    //Only once the conversion is complete, then you let the user take another audio
    [self checkRecording];
    
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didFailWithError:(NSError*)error {
    NSLog(@"Error converting audio file");
    //In this case, we stick to the original file
    [self insertIntoDatabasewithPath:soundFileURL withStartTime:startTime fromSession:appDelegateObject.CurrentSessionID sessionNamed:appDelegateObject.CurrentSession_Name];
    [self checkRecording];
}

#pragma  mark

@end
