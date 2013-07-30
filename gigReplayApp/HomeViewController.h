//
//  HomeViewController.h
//  gigReplay
//
//  Created by Leon Ng on 29/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HomeViewCustomCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


#define getURL [NSURL URLWithString: @"http://lipsync.sg/api/HomePageRequests.php"]
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)


@interface HomeViewController : UITableViewController{
      NSMutableArray *videoArray;
     NSURL *url;
}
@property (strong, nonatomic) IBOutlet UITableView *tableViewRequests;
@property(strong,nonatomic) NSString *videoImage;
@property(strong,nonatomic) NSString *image1;
@property(strong,nonatomic) NSString *image2;
@property(strong,nonatomic) NSString *image3;

@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property(strong,nonatomic)NSURL *videoURL;

@end
