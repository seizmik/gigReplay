//
//  ReplaysDetailViewController.h
//  gigReplay
//
//  Created by Leon Ng on 20/6/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIProgressDelegate.h"
#import  "ASINetworkQueue.h"
#import "AppDelegate.h"


@interface ReplaysDetailViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,ASIHTTPRequestDelegate>
   
@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property(strong,nonatomic)NSURL *videoURL;
@property(strong,nonatomic)NSString  *master_media_id;
@property (strong, nonatomic) IBOutlet UIView *ReplaysDetailView;
- (IBAction)startPlay:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *playButtonPressed;

- (IBAction)sharePressed:(id)sender;
- (IBAction)commentPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *likeImage;
- (IBAction)likePressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *socialShareView;
- (IBAction)SocialBackButton:(id)sender;


//Comment integration
@property (strong, nonatomic) IBOutlet UIView *commentView;


- (IBAction)commentSendButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *commentTextField;


@end
