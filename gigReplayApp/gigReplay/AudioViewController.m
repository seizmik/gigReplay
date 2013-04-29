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
@synthesize audioPlayer, audioRecorder;
@synthesize audioTimer, timeLabel;
@synthesize recordButton, playButton, uploadButton;
@synthesize soundFileURL;

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
    //[self setupAudioRecorder];
    [self checkRecording];
    [self checkPlaying];
    
    NSLog(@"%i", appDelegateObject.CurrentSessionID);
    
    [self.navigationItem.backBarButtonItem setTitle:@"Back"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationItem.backBarButtonItem setTitle:@"Back"];
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
            //[self getStartTime];
            [audioRecorder record];
            [self getStartTime];
        }        
    } else {
        //We get the stop time here to make it the same as video sync
        //[self getStartTime];
        [audioRecorder stop];
        [self insertIntoDatabase];
    }
    [self checkRecording];
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

- (void)insertIntoDatabase
{
    ConnectToDatabase *dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO upload_tracker (user_id,session_id,file_path,start_time,content_type,upload_status) VALUES (%i, %i, '%@', %f, 1, 0)", appDelegateObject.CurrentUserID, appDelegateObject.CurrentSessionID, soundFileURL, startTime];
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
    
    NSString *soundFileName = [NSString stringWithFormat:@"/GIGREPLAY_AUDIO/%@.caf", [self generateUniqueFilename]];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:soundFileName];
    soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey, nil];
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    audioRecorder.delegate = self;
    
    return error;
}

- (void)timerStartStop {
    if (![audioTimer isValid]) {
        currentTime = 0;
        self.audioTimer = [NSTimer
                           scheduledTimerWithTimeInterval:0.1
                           target:self
                           selector:@selector(timeUpdate:)
                           userInfo:nil
                           repeats:YES];
    } else {
        [self.audioTimer invalidate];
        self.audioTimer = nil;
    }
}

- (void)getStartTime {
    startTime = [[NSDate date] timeIntervalSince1970] + appDelegateObject.timeRelationship;
}

- (void)timeUpdate:(NSTimer *)theTimer {
    currentTime += 0.1;
    self.timeLabel.text = [NSString stringWithFormat:@"%.1f", currentTime];
}

- (NSString *)generateUniqueFilename
{
    NSString *prefixString = [NSString stringWithFormat:@"%i", appDelegateObject.CurrentSessionID];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    return uniqueFileName;
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
