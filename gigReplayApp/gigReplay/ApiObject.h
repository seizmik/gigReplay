//
//  ApiObject.h
//  gigReplay
//
//  Created by Leon Ng on 31/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiObject.h"
#import "Common.h"
#import "AppDelegate.h"
#import "SQLdatabase.h"
#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIProgressDelegate.h"
#import  "ASINetworkQueue.h"


@interface ApiObject : NSObject<ASIHTTPRequestDelegate,UIAlertViewDelegate,ASIProgressDelegate,ASICacheDelegate,NSURLConnectionDelegate,NSXMLParserDelegate>{
        int              ResponseIdentifier;
       
        BOOL  IsUserID;
        BOOL  IsFbId;
        int   User_ID;
     BOOL   IsSessionId;
     ASIHTTPRequest   *ASIHTTPrequest;
        NSString *Session_Name;
    /******* SESSION CREATION DETAILS ********************************/
    BOOL IsId;
    BOOL IsCode;
    BOOL IsCreatedDetails;
    BOOL ISCreatedUser;
    BOOL IssessionExpirationElement;
    BOOL IssessionExpirationDate;
    BOOL IssessionHasExpired;
    BOOL IsSessionCreatedDetails;
    
    NSString *Scene_Name;
    NSString *SessionCode;
    NSString *CreatedDetailsInfo;
    NSString *CreatedUserName;
    NSString *sessionExpirationDetails;
    NSString *sessionExpirationStatus;
     NSMutableData    *ResponseTimeData;
    
    /******* SESSION CREATION DETAILS ********************************/
    
    /******* SEARCH  SESSION DETAILS ************************************/
    
   
    BOOL                 IsCodeFoundInSearch;
    BOOL                 IsSessionNameFoundInSearch;
    BOOL                 IsSessionCreatedInfoInSearch;
    BOOL                 IsSessionCreatedDateFoundInSearch;
    BOOL                 IsSessionCreatedUserIDInSearch;
    BOOL                 IsSessionCreatedUserNameInSearch;
    BOOL                 isSessionExpiryElementInSearch;
    BOOL                 isSessionExpiryDateAndTimeInSearch;
    BOOL                 isSessionExpiryStatusInSearch;
    
    NSString             *SessionCodeFromSearch;
    NSString             *SessionNameFromSearch;
    NSString             *SessionCreatedDetailsFromSearch;
    NSString             *SessionCreatedUserNameFromSearch;
    NSString             *SessionCreatedDateFromSearch;
    NSString             *SessionCreatedUserIDFromSearch;
    NSString             *SessionExpiryDetailsFromSearch;
    NSString             *SessionExpiryStatusFromSearch;
    
    
    
    //******* SEARCH  SESSION DETAILS ************************************/
    /******* OPEN SESSION DETAILS ************************************/
    
    BOOL                SessionPrefixFound;
    BOOL                OpenSessionId;
    BOOL                CodeFound;
    BOOL                DateFound;
    BOOL                Issession_name;
    BOOL                Iscreated_user_Name;
    BOOL                Iscreated_user_id;
    BOOL                IsCreated_timeandDate;
    
    BOOL                Iscreated_Date;
    
    
    BOOL                isSessionExpiryElement;
    BOOL                isSessionExpiryDateAndTime;
    BOOL                isSessionExpiryStatus;
    
    NSString            *SessionExpiryDateAndTime;
    NSString            *SessionExpiryStatus;
    
    NSString            *SessionCreatedDateForOpen;
    NSString            *created_useridFor_Open;
    NSString            *Created_UserName_Open;
    NSString            *Created_SessionCode_Open;
    NSString            *Created_SessionName_Open;
    
    NSMutableArray      *OpenSessionDetailsHolder;
    NSMutableArray      *SearchSessionDetailsHolder;
    
    NSString            *task;
    
    /******* OPEN SESSION DETAILS ***********************************/
}
@property (nonatomic, retain) NSString  *Session_Name;
@property (nonatomic, retain)  NSString *SessionCode;
@property (nonatomic, retain)  NSString *Session_Id;
@property (nonatomic, retain)  NSString *CreatedUserName;
@property(nonatomic,strong)ApiObject *apiWrapperObject;
@property (nonatomic, retain) NSString       *Scene_Name;
@property (nonatomic, assign) int User_ID;
@property (nonatomic, assign) int facebook_id;
@property (nonatomic, retain)  NSString *CreatedDetailsInfo;
@property (nonatomic, retain)  NSString *sessionExpirationDetails;
@property (nonatomic, retain)  NSString *sessionExpirationStatus;
@property (nonatomic, retain)  NSString *SessionExpiryDateAndTime;
@property (nonatomic, retain)  NSString *SessionExpiryStatus;
@property (nonatomic, retain)  NSString *hasExpiredString;
@property (nonatomic, retain)NSMutableArray *SearchSessionDetailsHolder;
@property (nonatomic, retain)NSMutableArray *OpenSessionDetailsHolder;

@property (nonatomic, retain)NSString             *SessionCodeFromSearch;
@property (nonatomic, retain)NSString             *SessionNameFromSearch;
@property (nonatomic, retain)NSString             *SessionCreatedDetailsFromSearch;
@property (nonatomic, retain)NSString             *SessionCreatedDateFromSearch;
@property (nonatomic, retain)NSString             *SessionCreatedUserIDFromSearch;
@property (nonatomic, retain)NSString             *SessionExpiryDetailsFromSearch;
@property (nonatomic, retain)NSString             *SessionExpiryStatusFromSearch;
@property (nonatomic, retain)NSString             *SessionCreatedUserNameFromSearch;

@property (nonatomic, strong)NSString            *openSessionIdData;
@property (nonatomic, retain)NSString            *SessionCreatedDateForOpen;
@property (nonatomic, retain)NSString            *created_useridFor_Open;
@property (nonatomic, retain)NSString            *Created_UserName_Open;
@property (nonatomic, retain)NSString            *Created_SessionCode_Open;
@property (nonatomic, retain)NSString            *Created_SessionName_Open;

//for join session_id
@property (nonatomic, retain)NSString            *JoinSessionId;

-(void)SendNotificationsAfterUserRegistration:(NSString*)Status;
-(void)SendNotificationsAfterJoinSearchAPI:(NSString*)Status;
-(void)SendNotificationsAfterJoinAPI:(NSString*)Status;

-(void)postUserDetails:(NSString *)facebookId userEmail:(NSString *)email userName:(NSString *)Username facebookToken:(NSString *)fbtoken APIIdentifier:(int)Identifier;

-(void)postCreateSessionDetails:(NSString *)userid SessionName:(NSString *)sessioname APILink:(NSString *)Link APIIdentifier:(int)Identifier;
-(void)postJoinSessionDetails:(NSString *)userid SesssionName:(NSString *)sessionname  SessionID:(NSString *)sessionid Created_User_Id:(NSString *)Created_User_ID APIIdentifier:(int)Identifier;
-(void)SearchSessionDetails:(NSString *)Username  SessionName:(NSString *)sessionName APIIdentifier:(int)Identifier;
-(void)OpenSessionDetails:(int)Userid WithSession:(NSString*)SessionID APIIdentifier:(int)Identifier;
@end
