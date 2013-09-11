//
//  InfoViewController.m
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize bandImageView,moviePlayerView,moviePlayer;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playMovie{
//    NSString *movieFile= [[NSBundle mainBundle] pathForResource:@"linkin" ofType:@"mp4"];
//    NSURL *videoURL=[[NSURL alloc] initFileURLWithPath:movieFile];
    NSURL *stream=[NSURL URLWithString:@"http://www.lipsync.sg/api/test/prog_index.m3u8"];
    
    self.moviePlayer=  [[MPMoviePlayerController alloc]
                        initWithContentURL:stream];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
     
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = NO;
    [self.view addSubview:self.moviePlayerView];
    [self.moviePlayerView addSubview:self.moviePlayer.view];
    [self.moviePlayer.view setFrame:moviePlayerView.bounds];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
  
    
}
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    bandImageView.hidden=NO;
    [moviePlayerView addSubview:bandImageView];
  

    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player setCurrentPlaybackTime:0];
    }
}

- (IBAction)playButton:(id)sender {
    bandImageView.hidden=YES;
    [self playMovie];

}
@end
