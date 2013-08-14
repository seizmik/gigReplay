//
//  MyVideosViewController.h
//  gigReplay
//
//  Created by Leon Ng on 14/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define getVideosUrl [NSURL URLWithString: @"http://lipsync.sg/api/myVideos.php"]

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface MyVideosViewController : UIViewController<UITableViewDelegate>{
     NSURL *url;
    NSArray *myVideosArray;
}
@property (strong, nonatomic) IBOutlet UITableView *myVideosTableView;
@property(strong,nonatomic) NSString *videoImage;
@end
