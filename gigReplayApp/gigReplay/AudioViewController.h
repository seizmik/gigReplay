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
#import "TPAACAudioConverter.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface AudioViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate, TPAACAudioConverterDelegate>
{
    TPAACAudioConverter *audioConverter;
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    AVAudioSession *audioSession;
    NSTimer *audioTimer;
    NSTimer *levelTimer;
    NSURL *lowResURL;
    NSURL *soundFileURL;
}

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *peakPowerGraph;

- (IBAction)recordPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)uploadPressed:(UIButton *)sender;

-(void)levelTimerCallback:(NSTimer *)timer;

@end
