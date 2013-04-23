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

@interface AudioViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) NSTimer *audioTimer;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;

- (IBAction)recordPressed:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)uploadPressed:(UIButton *)sender;

@property (strong, nonatomic) NSURL *soundFileURL;

@end
