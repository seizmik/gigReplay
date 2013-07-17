//
//  CreateSessionViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"AppDelegate.h"
#import "ApiObject.h"
#import "SQLdatabase.h"
#import<FacebookSDK/FacebookSDK.h>
#import "MediaRecordViewController.h"
#import "SettingsViewController.h"

@interface CreateSessionViewController : UIViewController{
    NSString *sessionname;
    BOOL   RespondsReached;
    MediaRecordViewController *recordObj;
    BOOL pressed;
}
@property (strong, nonatomic) IBOutlet UITextField *sceneNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *sceneTitleDisplay;
//@property (strong, nonatomic) IBOutlet UILabel *sceneCodeDisplay;
@property (strong, nonatomic) IBOutlet UILabel *usernameDisplay;
@property (strong, nonatomic) IBOutlet UIButton *createSceneButton;
@property (strong,nonatomic)ApiObject *apiWrapperObject;
//@property (strong,nonatomic)IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *dateDisplay;
@property (strong, nonatomic) IBOutlet UILabel *timeDisplay;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
- (IBAction)prepareMediaRecord:(id)sender;
- (void)populateUserDetails;
- (IBAction)resignTextField:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *start_button;
- (IBAction)helpInfoButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *helpButtonView;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;

@end
