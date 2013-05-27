//
//  ReplaysViewController.h
//  gigReplay
//
//  Created by Leon Ng on 15/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLdatabase.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import "ReplaysCustomCell.h"
//#define kGETUrl @""

#define kGetURL [NSURL URLWithString: @"http://lipsync.sg/api/replaysvideos.php"]
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)


@interface ReplaysViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *videoDetails;
    NSURL *url;
    NSMutableArray *videoArray;
    NSString *fullPathImage;
    NSString *videoImage;
    UIImage *image1;
    
}
@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property (strong, nonatomic) IBOutlet UIImageView *img1;
@property (strong, nonatomic) IBOutlet UILabel *text1;
@property (strong, nonatomic) IBOutlet UIImageView *img2;
@property (strong, nonatomic) IBOutlet UITableView *tableviewVideos;
- (IBAction)play:(id)sender;


@end
