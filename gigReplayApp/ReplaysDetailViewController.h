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


@interface ReplaysDetailViewController : UIViewController
   
@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property(strong,nonatomic)NSURL *videoURL;
@property (strong, nonatomic) IBOutlet UIView *ReplaysDetailView;
- (IBAction)startPlay:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *playButtonPressed;

@property (strong, nonatomic) IBOutlet UIImageView *likeImage;
- (IBAction)likePressed:(id)sender;


@end
