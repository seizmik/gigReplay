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
@synthesize movieplayer,videoURL,ReplaysDetailView,likeImage;

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
@end
