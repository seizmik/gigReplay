//
//  UploadTab.h
//  gigReplay
//
//  Created by User on 18/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectToDatabase.h"
#import "UploadObject.h"
#import "Common.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface UploadTab : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSArray *videopath;
    UIImage *tempImage;
    UIView * aProgressView ;
    UIProgressView *progressIndicator;
     MBProgressHUD *aMBProgressHUD;
    UploadObject *videoInfo;

}
@property (strong,nonatomic) IBOutlet UILabel *progressLabel;
//@property(strong,nonatomic)IBOutlet  UIProgressView *progressIndicator;

@property (strong, nonatomic) IBOutlet UITableView *uploadTable;
@property (strong, nonatomic) NSMutableArray *uploadArray;
@property (strong, nonatomic) ConnectToDatabase *dbObject;
@property (strong, nonatomic) UploadObject *detailsToDelete;
@property (strong, nonatomic) MPMoviePlayerController *movieplayer;
@property(strong,nonatomic) NSMutableArray *uploadVideoFilePath;


- (void)uploadThisFile:(UploadObject *)fileDetails;
@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgress;





@end
