//
//  InfoViewController.h
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
- (IBAction)playButton:(id)sender;
@property(strong,nonatomic)MPMoviePlayerController   *moviePlayer;
@property (strong, nonatomic) IBOutlet UIImageView *bandImageView;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;


@end
