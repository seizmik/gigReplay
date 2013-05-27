//
//  MediaRecordViewController.h
//  gigReplay
//
//  Created by Leon Ng on 8/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//
//This viewcontroller specifys the record video or record audio features.
//Record video goes to camera mode record
//Record audio goes to audio mode record
//decide on a place to store these media files. Either in appbundle or in photogallery or in stand alone docuument file
//
//
//
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SQLdatabase.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

@interface MediaRecordViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    UIButton    *cameraRecButton;
    UIButton    *backButton;
    UIButton    *helpButton;
    UIView      *overlay;
    UILabel     *timerLabel;
    UIBackgroundTaskIdentifier bgTask;
    double startTime;
    int currentTime;
    bool isRecording;
}
@property (strong, nonatomic) IBOutlet UILabel *sceneCodeDisplay;
@property (strong, nonatomic) IBOutlet UILabel *sceneTitleDisplay;

- (IBAction)videoRecordPressed:(UIButton *)sender;
- (IBAction)audioRecordPressed:(UIButton *)sender;
- (IBAction)uploadButtonPressed:(UIButton *)sender;
- (IBAction)generateVideo:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *videoRecordButton;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordButton;

//StartingVideoCameraMethods
//Delegates send messages, and you have to say where you want the messages to go. Very typically, you want them to go to "you," so in that case you simply say x.delegate=self.
//x.delegate=self is exactly the same as [x setDelegate:self]
//SO in usingDelegate:self the camera is saying i am done with something and i send the message when i m done messaging to myself and implement other methods.
-(BOOL)startCameraController:(UIViewController*)controller usingDelegate:(id )delegate;
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@property (strong, nonatomic) UIImagePickerController *cameraUI;
@property (strong, nonatomic) UIAlertView *saveAlert;
@property (strong, nonatomic) NSTimer *videoTimer;

@end
