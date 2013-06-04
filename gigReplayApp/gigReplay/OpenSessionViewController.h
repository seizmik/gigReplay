//
//  OpenSessionViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "ApiObject.h"
#import "AppDelegate.h"
#import "SQLdatabase.h"
#import "Common.h"
#import "MediaRecordViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface OpenSessionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray      *OpenedSessionDetailsHolder;
    BOOL                 ViewWillAppeared;
    MediaRecordViewController *mediaObject;
    NSString *fb_user_ID;
    
}

@property(strong,nonatomic) NSMutableArray  *OpenedSessionDetailsHolder;
@property (strong, nonatomic) IBOutlet UITableView *openedSessionListTable;
@property(strong,nonatomic)ApiObject *apiWrapperObject;




@end
