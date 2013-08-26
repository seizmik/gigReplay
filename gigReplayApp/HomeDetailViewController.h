//
//  HomeDetailViewController.h
//  gigReplay
//
//  Created by Leon Ng on 5/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"


@interface HomeDetailViewController : UIViewController<UITableViewDelegate,UIScrollViewDelegate,ASIHTTPRequestDelegate>{
    UIScrollView *scrollView;

}
@property (strong,nonatomic)MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;
@property (strong, nonatomic) IBOutlet UITableView *commentTableVIew;
@property (strong,nonatomic) NSURL *videoURL;
@property (strong,nonatomic) NSString *media_id;
@property (strong,nonatomic) NSMutableArray *commentArray;
- (IBAction)backToHome:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *commentUIView;
@property (strong, nonatomic) IBOutlet UIView *commentPopOver;

@property (assign,nonatomic)CGFloat newHeight;

@property(strong,nonatomic)NSMutableArray *array;
- (IBAction)commentButton:(id)sender;
- (IBAction)commentPost:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *theComments;
- (IBAction)commentCancel:(id)sender;

@end