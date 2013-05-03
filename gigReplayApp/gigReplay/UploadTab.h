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

@interface UploadTab : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *uploadTable;
@property (strong, nonatomic) NSMutableArray *uploadArray;
@property (strong, nonatomic) ConnectToDatabase *dbObject;
@property (strong, nonatomic) UploadObject *detailsToDelete;

- (void)uploadThisFile:(UploadObject *)fileDetails;


@end
