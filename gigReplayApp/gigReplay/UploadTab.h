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

@interface UploadTab : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *uploadTable;
@property (strong, nonatomic) NSMutableArray *uploadArray;
@property (strong, nonatomic) ConnectToDatabase *dbObject;

- (void)uploadThisFile:(UploadObject *)fileDetails;


@end
