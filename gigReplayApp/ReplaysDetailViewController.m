//
//  ReplaysDetailViewController.m
//  gigReplay
//
//  Created by Leon Ng on 20/6/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "ReplaysDetailViewController.h"


@interface ReplaysDetailViewController ()

@end

@implementation ReplaysDetailViewController
@synthesize movieplayer,videoURL,ReplaysDetailView,likeImage,socialShareView,master_media_id;
@synthesize commentView,commentTextField;

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
    [self playMovie];
    
       // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playMovie{
    
    movieplayer=  [[MPMoviePlayerController alloc]
                   initWithContentURL:videoURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = NO;
    [self.view addSubview:ReplaysDetailView];
    [self.ReplaysDetailView addSubview:movieplayer.view];
    [movieplayer.view setFrame:ReplaysDetailView.bounds];
    
    [movieplayer setFullscreen:YES animated:YES];
    
    
    
}
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player setCurrentPlaybackTime:0];
    }
}
- (IBAction)startPlay:(id)sender {
}
- (IBAction)likePressed:(id)sender {
    [likeImage setImage:[UIImage imageNamed:@"like_on"]];
     
}
- (IBAction)sharePressed:(id)sender {
    [self.view addSubview:socialShareView];
    
}

- (IBAction)commentPressed:(id)sender {
    [self.view addSubview:commentView];
    
}
- (IBAction)SocialBackButton:(id)sender {
    [socialShareView removeFromSuperview];
}
- (IBAction)commentSendButton:(id)sender {
    
    
    NSURL *url = [NSURL URLWithString:@"http://lipsync.sg/api/SocialMediaAPI.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
   
    [request setPostValue:appDelegateObject.CurrentUserName forKey:@"user_name"];
    NSLog(@"currentusername %@",appDelegateObject.CurrentUserName);
//    [request setPostValue:appDelegateObject.CurrentSessionID forKey:@"session_id"];
//    NSLog(@"currnetsessionid %@",appDelegateObject.CurrentSession_Code);
    [request setPostValue:commentTextField.text forKey:@"comments"];
    NSLog(@"%@",commentTextField.text);
    [request setPostValue:master_media_id forKey:@"media_id"];
    NSLog(@"%@",master_media_id);

    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];

    
  
}
@end
