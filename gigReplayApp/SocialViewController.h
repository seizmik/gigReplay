//
//  InfoViewController.h
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerController.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define getURL2 [NSURL URLWithString: @"http://www.lipsync.sg/api/HomePageFeatured.php"]

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface SocialViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    AVAsset *avAsset;
    AVPlayerItem *avPlayerItem;
    BOOL tapped;
    NSMutableArray *videoArray;
    NSURL *url;
  
}
//- (IBAction)playButton:(id)sender;
//@property(strong,nonatomic)MPMoviePlayerController   *moviePlayer;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;
//- (IBAction)likeButton:(id)sender;
//@property (strong, nonatomic) IBOutlet UIButton *liked;
@property (strong, nonatomic) MPMoviePlayerController *movieplayer;

@property(strong,nonatomic) NSString *videoImage;
//- (IBAction)commentButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
