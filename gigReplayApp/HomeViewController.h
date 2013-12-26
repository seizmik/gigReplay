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
#import "AppDelegate.h"
#import "ApiObject.h"



#define getURL2 [NSURL URLWithString: @"http://www.lipsync.sg/api/HomePageFeatured.php"]

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)


@interface HomeViewController : UIViewController<UITableViewDelegate,UITabBarDelegate>{
    NSMutableArray *videoArray;
     NSURL *url;
    UITabBar *myTabBar;
}

@property (strong, nonatomic) IBOutlet UITableView *tableViewRequests;
@property(strong,nonatomic) NSString *videoImage;
@property(strong,nonatomic) NSString *image1;
@property(strong,nonatomic) NSString *image2;
@property(strong,nonatomic) NSString *image3;

@property (strong,nonatomic) ApiObject *apiWrapperObject;

@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property(strong,nonatomic)NSURL *videoURL;

@property (strong, nonatomic) IBOutlet UIButton *refreshButton;


//HomeViewCustomCell2


@end
