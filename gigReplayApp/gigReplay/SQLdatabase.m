//
//  SQLdatabase.m
//  gigReplay
//
//  Created by Leon Ng on 30/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "SQLdatabase.h"
#import <sqlite3.h>


@implementation SQLdatabase
@synthesize databaseName,databasePath;
-(id)initDatabase
{
    // Setup some globals
	databaseName = @"thesmos.rdb";
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	self.databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	return self;
}

-(void)checkDatabaseExists
{
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    if(!success){
        NSLog(@"failed to copy database");
    }
//    [fileManager release];
	
}

-(BOOL)insertIntoDatabase:(NSString *)sqlCommand;
{
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		static sqlite3_stmt *compiledStatement;
        //sqlite3_exec(database, [[NSString stringWithFormat:@"insert into Favourites (recipeId,id, image,name,rating) values ('%d','%d', '%@', '%@', '%@')", RID,ID,Image,Name,Rate] UTF8String], NULL, NULL, NULL);
		sqlite3_exec(database, [[NSString stringWithFormat:@"%@",sqlCommand] UTF8String], NULL, NULL, NULL);
		sqlite3_finalize(compiledStatement);
        return TRUE;
	}
    else
    {
        return FALSE;
    }
	sqlite3_close(database);
	
    
}
-(void) updateDatabase:(NSString *)strQuery
{
	sqlite3 *database;
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		static sqlite3_stmt *compiledStatement;
		//sqlite3_exec(database, [[NSString stringWithFormat:@"update Favourites Set id ='%d' Where key = %d",ID,key] UTF8String], NULL, NULL, NULL);
        sqlite3_exec(database, [[NSString stringWithFormat:@"%@",strQuery] UTF8String], NULL, NULL, NULL);
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
}

-(void) deleteFromDatabase:(NSString*)query
{
	sqlite3 *database;
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		
        sqlite3_exec(database, [query UTF8String], NULL, NULL, NULL);
		
		
        sqlite3_close(database);
		
	}
	
}

-(NSMutableArray *)readFromDatabaseUsers:(NSString *)sqlCommand
{
    sqlite3 *database;
	
	// Init the Favourites Array
    NSMutableArray *UserDetails=[[NSMutableArray alloc] init];	// Init the  Array
	
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from Favourites";
        NSString *statement = sqlCommand;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
		
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{				// Read the data from the result row
                
                NSString *Username =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSString *ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                NSString *FB_UserID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
                NSString *FB_AuthorizationID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
                
                NSString *email =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
                NSString *Password =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
                NSString *FirstName =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)];
                NSString *LastName =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,7)];
                NSString *DeviceID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,8)];
                NSString *FB_Connected =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,9)];
                NSString *User_ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,11)];
                
                
				
                NSArray *Details = [[NSArray alloc]initWithObjects:Username,ID,FB_UserID,FB_AuthorizationID,email,Password,FirstName,LastName,DeviceID,FB_Connected,User_ID,nil];
                
                
                [UserDetails addObject:Details];
                
                // NSString *delete_ID=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    //NSLog(@"%d",[ArrFavourites count]);
    return UserDetails;
	
}

-(NSMutableArray*)readFromDatabaseSessionDetails:(NSString*)strQuery
{
    sqlite3 *database;
	
	// Init the Favourites Array
    NSMutableArray *UserDetails=[[NSMutableArray alloc] init];	// Init the  Array
	
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from Favourites";
        NSString *statement = strQuery;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
		
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{
                // Read the data from the result row
                
                NSString *ExpirationStatus =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSString *ExpirationTime =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                NSString *ExpirationDate =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
                
                NSString *UserName =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
                NSString *Session_Code =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
                NSString *Time =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
                NSString *Date =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)];
                
                NSString *ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,7)];
                NSString *User_ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,8)];
                NSString *Session_Name =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,9)];
                
                
                
				
                NSArray *Details = [[NSArray alloc]initWithObjects:UserName,Session_Code,Time,Date,ID,User_ID,Session_Name,ExpirationStatus,ExpirationTime,ExpirationDate,nil];
                
                
                [UserDetails addObject:Details];
                
                // NSString *delete_ID=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    //NSLog(@"%d",[ArrFavourites count]);
    return UserDetails;
}
-(NSMutableArray*)readFromDatabaseSearchSessionDetails:(NSString*)strQuery
{
    
    sqlite3 *database;
	
	// Init the Favourites Array
    NSMutableArray *UserDetails=[[NSMutableArray alloc] init];	// Init the  Array
	
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from Favourites";
        NSString *statement = strQuery;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
		
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
                
			{				// Read the data from the result row
                NSString *SessionExpiryStatus =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSString *SessionExpiryDate =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                NSString *SessionExpiryTime =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
                
                NSString *createdID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
                NSString *ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
                NSString *User_ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
                NSString *Session_Code =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)];
                NSString *Session_name =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,7)];
                NSString *User_Name =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,8)];
                NSString *Time =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,9)];
                NSString *Date =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,10)];
                
                
                
                NSArray *Details = [[NSArray alloc]initWithObjects:createdID,ID,User_ID,User_Name,Session_name,Session_Code,Time,Date,SessionExpiryDate,SessionExpiryTime,SessionExpiryStatus,nil];
                
                
                [UserDetails addObject:Details];
                
                
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    //NSLog(@"%d sql",[UserDetails count]);
    return UserDetails;
    
}
-(NSMutableArray*)readFromDatabaseOpenDetails:(NSString*)strQuery
{
    
    sqlite3 *database;
	
	// Init the Favourites Array
    NSMutableArray *UserDetails=[[NSMutableArray alloc] init];	// Init the  Array
	
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from Favourites";
        NSString *statement = strQuery;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
		
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{				// Read the data from the result row
                
                NSString *session_Id=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSString *sessionExpiredStatus=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                NSString *sessionExpiredTime=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];
                NSString *sessionExpiredDate=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,3)];
                
                
                NSString *Created_Name =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,4)];
                NSString *Session_Name =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,5)];
                NSString *ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)];
                NSString *User_ID =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,7)];
                
                
                NSString *Time =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,8)];
                NSString *Date =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,9)];
                NSString *Session_Code =[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,10)];
                
                
                NSArray *Details = [[NSArray alloc]initWithObjects:ID,User_ID,Time,Date,Session_Code,Session_Name,Created_Name,sessionExpiredDate,sessionExpiredTime,sessionExpiredStatus,session_Id,nil];
                
                
                [UserDetails addObject:Details];
                
                
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    //NSLog(@"%d sql",[UserDetails count]);
    return UserDetails;
    
}


-(NSMutableArray*)readFromDatabaseVideos:(NSString*)strQuery
{
    
    sqlite3 *database;
	
	// Init the Favourites Array
    NSMutableArray *videoDetails=[[NSMutableArray alloc] init];	// Init the  Array
	
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
	{
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from Favourites";
        NSString *statement = strQuery;
		const char *sqlStatement = (const char *) [statement UTF8String];
        sqlite3_stmt *compiledStatement;
		
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{				// Read the data from the result row
                
                NSString *video_url=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                NSString *video_thumb=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)];
                NSString *video_name=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,2)];

                
                
                NSArray *Details = [[NSArray alloc]initWithObjects:video_thumb,video_url,video_name ,nil];
                
                
                [videoDetails addObject:Details];
                
                
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    //NSLog(@"%d sql",[UserDetails count]);
    return videoDetails;
    
}


@end
