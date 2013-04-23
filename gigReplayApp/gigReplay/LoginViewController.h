//
//  LoginViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import<FacebookSDK/FacebookSDK.h>
#import "SQLdatabase.h"


@interface LoginViewController : UIViewController<FBLoginViewDelegate>

- (IBAction)fbLoginButton:(id)sender;

@property (strong,nonatomic) NSString *FB_UserID;
@property (strong,nonatomic) NSString *FB_AuthorizationToken;
@property (strong,nonatomic) NSString *Email;
@property (strong,nonatomic) NSString *Password;
@property (strong,nonatomic) NSString *FirstName;
@property (strong,nonatomic) NSString *LastName;
@property (strong,nonatomic) NSString *deviceUDID;
@property (strong,nonatomic) NSString *FB_Connected;
@property (strong,nonatomic) NSString *Email_Signup;
@property (strong,nonatomic) NSString *UserName;

-(void)getDeviceID;


@end
