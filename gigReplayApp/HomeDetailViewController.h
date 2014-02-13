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


@interface HomeDetailViewController : UIViewController<UITableViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate,ASIHTTPRequestDelegate>{
    UIScrollView *scrollView;
    NSString *fb_user_id;
    BOOL processLabels;
    UIView *loadingView;
    NSString *like;
    UIActionSheet *moreOptions;

}

@property (strong,nonatomic)MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;
@property (strong, nonatomic) IBOutlet UITableView *commentTableVIew;
@property (strong,nonatomic) NSURL *videoURL;
@property (strong,nonatomic)NSString *videoImage;
@property (strong,nonatomic) NSString *media_id;
@property (strong,nonatomic) NSString *videoTitle;
@property (strong,nonatomic) NSString *videoDate;
@property ( strong,nonatomic)NSString *videoUserInfo;
@property(strong,nonatomic)NSString *obtainFb_id;
@property (strong,nonatomic) NSMutableArray *commentArray;
@property (strong,nonatomic)NSMutableArray *likeArray;
- (IBAction)backToHome:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *commentUIView;
@property (strong, nonatomic) IBOutlet UIView *commentPopOver;

@property (assign,nonatomic)CGFloat newHeight;

@property(strong,nonatomic)NSMutableArray *array;
- (IBAction)commentButton:(id)sender;
- (IBAction)commentPost:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *theComments;
@property (strong, nonatomic) IBOutlet UILabel *videoUser;
@property (strong, nonatomic) IBOutlet UIImageView *fb_profile_pic;
- (IBAction)commentCancel:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *indVideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *indDate;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage;
- (IBAction)shareButton:(id)sender;

- (IBAction)likeButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *likeButtonImage;
- (IBAction)moreOptions:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *reportImage;

@end
