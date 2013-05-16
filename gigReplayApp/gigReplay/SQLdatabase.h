//
//  SQLdatabase.h
//  gigReplay
//
//  Created by Leon Ng on 30/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface SQLdatabase : NSObject

@property(strong,nonatomic)NSString *databaseName;
@property(strong,nonatomic)NSString *databasePath;


-(id)initDatabase;
-(void)checkDatabaseExists;
-(BOOL)insertIntoDatabase:(NSString *)sqlCommand;
-(void) updateDatabase:(NSString *)strQuery;
-(NSMutableArray*)readFromDatabaseUsers:(NSString*)sqlCommand;
-(NSMutableArray *)readFromDatabaseSessionDetails:(NSString *)sqlCommand;
-(NSMutableArray *)readFromDatabaseOpenDetails:(NSString *)sqlCommand;
-(NSMutableArray*)readFromDatabaseSearchSessionDetails:(NSString*)strQuery;
-(NSMutableArray*)readFromDatabaseVideos:(NSString*)strQuery;
-(void) deleteFromDatabase:(NSString*)query;
@end
