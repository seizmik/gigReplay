//
//  ConnectToDatabase.h
//  TimeSync2
//
//  Created by User on 26/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SyncObject.h"

@interface ConnectToDatabase : NSObject

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *databaseName;

- (id)initDB;
- (void)checkAndCreateDatabase;
- (NSMutableArray *)uploadCheck:(NSString *)strQuery;
- (SyncObject *)syncCheck;
- (BOOL)insertToDatabase:(NSString *)strQuery;
- (BOOL)updateDatabase:(NSString *)strQuery;
- (int)preliminaryInsertToDatabase:(NSString *)strQuery;

@end
