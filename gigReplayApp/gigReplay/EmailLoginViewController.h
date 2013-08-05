//
//  EmailLoginViewController.h
//  gigReplay
//
//  Created by Leon Ng on 19/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import<FacebookSDK/FacebookSDK.h>
#import "SQLdatabase.h"
#import "ASIHTTPRequest.h"

@interface EmailLoginViewController : UIViewController<ASIHTTPRequestDelegate,UITextFieldDelegate,UIApplicationDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailOutlet;
@property (strong, nonatomic) IBOutlet UITextField *passwordOutlet;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassOutlet;
- (IBAction)signUpButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)resignTextField:(id)sender;

@end
