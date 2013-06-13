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

@interface UploadTab : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSArray *videopath;
}

@property (strong, nonatomic) IBOutlet UITableView *uploadTable;
@property (strong, nonatomic) NSMutableArray *uploadArray;
@property (strong, nonatomic) ConnectToDatabase *dbObject;
@property (strong, nonatomic) UploadObject *detailsToDelete;
@property (strong, nonatomic) MPMoviePlayerController *movieplayer;
@property(strong,nonatomic) NSMutableArray *uploadVideoFilePath;

- (void)uploadThisFile:(UploadObject *)fileDetails;




@end
