//
//  AppDelegate.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLdatabase.h"
#import<FacebookSDK/FacebookSDK.h>
#import "Reachability.h"
#define appDelegateObject ((AppDelegate *)[[UIApplication sharedApplication] delegate])


@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
{

    BOOL    userexists;
    int     CurrentUserID;
    BOOL    stillSynching;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) int CurrentUserID;
@property (assign, nonatomic) NSString *CurrentSessionID;


@property(strong,nonatomic)UITabBarController *tabBarController;

@property(strong,nonatomic)SQLdatabase *databaseObject;

@property (strong, nonatomic)  NSString *CurrentSession_Code;
@property (strong, nonatomic)  NSString *CurrentUserName;
@property (strong, nonatomic)  NSString *CurrentSession_Name;
@property (strong, nonatomic)  NSString *CurrentSession_NameExpired;
@property (strong, nonatomic)  NSString *CurrentSession_Expiring_Date;
@property (strong, nonatomic)  NSString *CurrentSession_Expiring_Time;
@property (strong, nonatomic)  NSString *CurrentSession_Created_Date;

-(void)SetDataBaseForLoginPurpose;
-(void)loadApplicationHome;
-(void)goToLogin;
-(void)closeFacebookSession;
-(void)checkExistingUser;
-(BOOL)checkFBSessionOpen;

//These are needed for synching method
@property (strong, nonatomic) NSMutableArray *lagArray;
@property (strong, nonatomic) NSMutableArray *diffArray;
@property double timeRelationship;
@property (strong, nonatomic) UINavigationController *navController;

@end
