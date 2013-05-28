//
//  ConnectToDatabase.m
//  TimeSync2
//
//  Created by User on 26/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import "ConnectToDatabase.h"
#import "UploadObject.h"

@implementation ConnectToDatabase
@synthesize databaseName, databasePath;

- (id)initDB
{
    //Setup some global variables
    databaseName = @"gigreplay.sqlite";
    //Get the path to the documents directory and append the databaseName
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:databaseName];
    
    return self;
}

- (void)checkAndCreateDatabase
{
    BOOL success;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    success = [filemanager fileExistsAtPath:databasePath];
    if (success) return; //If the file exists, then return
    //Otherwise add that database
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [filemanager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

- (NSMutableArray *)uploadCheck:(NSString *)strQuery
{
    //Setup the database object
    sqlite3 *database;
    //Initialise the array that you will be returning
    NSMutableArray *uploadDetails = [NSMutableArray array];
    //Open database from the users filesystem
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        //NSLog(@"Database opened");
        //Setup the SQL statement and compile
        const char *sqlStatement = (const char *)[strQuery UTF8String];
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            //Loop through the results and add them to the uploadDetails array
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                int entryid = sqlite3_column_int(compiledStatement, 0);
                int userid = sqlite3_column_int(compiledStatement, 1);
                int sessionid = sqlite3_column_int(compiledStatement, 2);
                NSString *filePath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                double startTime = sqlite3_column_double(compiledStatement, 4);
                int contentType = sqlite3_column_int(compiledStatement, 5);
                int uploadStatus = sqlite3_column_int(compiledStatement, 6);
                NSString *thumbnailPath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                NSString *sessionName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
                
                UploadObject *uploadObject = [[UploadObject alloc] initWithFilePath:filePath entryid:entryid sessionid:sessionid startTime:startTime contentType:contentType uploadStatus:uploadStatus fromUser:userid thumbnail:thumbnailPath fromSession:sessionName];
                [uploadDetails addObject:uploadObject];
                //NSLog(@"Upload object added to array");
            }
        }
        //Release the compiled statement
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return uploadDetails;
}

- (SyncObject *)syncCheck
{
    sqlite3 *database;
    NSString *strQuery = @"SELECT * FROM last_sync";
    SyncObject *syncObject = [[SyncObject alloc] init];
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = (const char *)[strQuery UTF8String];
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            //Loop through the results and add them to the uploadDetails array
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                int entryid = sqlite3_column_int(compiledStatement, 0);
                double lastRelationship = sqlite3_column_double(compiledStatement, 1);
                double lastSync = sqlite3_column_double(compiledStatement, 2);
                
                syncObject.entryid = entryid;
                syncObject.previousTimeRelationship = lastRelationship;
                syncObject.previousSync = lastSync;
                double currentTime = [[NSDate date] timeIntervalSince1970];
                double timeDiff = currentTime - lastSync;
                if (timeDiff > 3600) { //Edit this number to lengthen the period of synching
                    syncObject.expiredSync = YES;
                } else {
                    syncObject.expiredSync = NO;
                }
                NSLog(@"SyncCheck details: %i %f %f %f %f", entryid, lastRelationship, lastSync, currentTime, timeDiff);
            }
        }
        //Release the compiled statement
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return syncObject;
}

- (BOOL)insertToDatabase:(NSString *)strQuery
{
    sqlite3 *database;
    
    //Open the database from the users filesystem
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        static sqlite3_stmt *compiledStatement;
        sqlite3_exec(database, [[NSString stringWithFormat:@"%@", strQuery] UTF8String], NULL, NULL, NULL);
        sqlite3_finalize(compiledStatement);
        NSLog(@"Database entry executed");
        return TRUE;
    } else {
        return FALSE;
    }
    sqlite3_close(database);
}

- (BOOL)updateDatabase:(NSString *)strQuery
{
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        static sqlite3_stmt *compiledStatement;
        sqlite3_exec(database, [[NSString stringWithFormat:@"%@", strQuery] UTF8String], NULL, NULL, NULL);
        sqlite3_finalize(compiledStatement);
        NSLog(@"Database updated");
        return TRUE;
    } else {
        NSLog(@"Database update failed");
        return FALSE;
    }
    sqlite3_close(database);
}

@end
