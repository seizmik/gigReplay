//
//  AudioViewController.h
//  TimeSync2
//
//  Created by User on 25/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AERecorder.h"
#import "TheAmazingAudioEngine.h"

@interface AudioViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    AVAudioPlayer *audioPlayer;
    //AVAudioRecorder *audioRecorder;
    AVAudioSession *audioSession;
    NSTimer *audioTimer;
    NSTimer *levelTimer;
    NSURL *soundFileURL;
}

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *peakPowerGraph;
@property (nonatomic, retain) AERecorder *recorder;
@property (nonatomic, retain) AEAudioController *audioController;

- (IBAction)recordPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)uploadPressed:(UIButton *)sender;

-(void)levelTimerCallback:(NSTimer *)timer;

@end
