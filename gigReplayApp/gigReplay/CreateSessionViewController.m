//
//  CreateSessionViewController.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "CreateSessionViewController.h"

@interface CreateSessionViewController ()

@end

@implementation CreateSessionViewController
@synthesize sceneCodeDisplay, sceneTitleDisplay, apiWrapperObject, usernameDisplay, loadingView, sceneNameTextField, dateDisplay;
//@synthesize userProfileImage;
@synthesize timeDisplay;

-(void)SyncUserDetails
{
   

    NSMutableArray *UserDetails= [self ReadFromDataBase:@"Users"];
    NSArray *details=[UserDetails objectAtIndex:0];
    appDelegateObject.CurrentUserName=[details objectAtIndex:0];
    [apiWrapperObject postUserDetails:[details objectAtIndex:2]  userEmail:[details objectAtIndex:4] userName:[details objectAtIndex:0] facebookToken:[details objectAtIndex:3] APIIdentifier:API_IDENTIFIER_USER_REG];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
    apiWrapperObject=[[ApiObject alloc] init];
    [self SyncUserDetails];
    RespondsReached=FALSE;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RemoveLoadingView:)
												 name:@"SessionCreateParsingCompleted"
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RemoveLoadingViewAfterRegistration:)
												 name:@"UserRegistrationCompleted"
											   object:nil];
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextField:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    // Do any additional setup after loading the view from its nib.
    [self loadSettingsButton];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Button actions

- (IBAction)createScene:(id)sender {
    if ([sceneNameTextField.text isEqualToString:@""])
    {
        [self ShowAlertMessage:@"Oopsy" Message:@"Please enter a scene name"];
        return;
        
    }
    //userProfileImage.hidden=NO;
    NSMutableArray *UserDetails= [self ReadFromDataBase:@"Users"];
    if ([UserDetails count]>0)
    {
        sessionname = sceneNameTextField.text;
        
        NSArray *details = [UserDetails objectAtIndex:0];
      
        //leave out currentusername first that is to get settings details of current user like phone resolution etc
        appDelegateObject.CurrentUserName=[details objectAtIndex:0];
        NSString *userID = [details objectAtIndex:10];
        [apiWrapperObject postCreateSessionDetails:userID SessionName:sessionname APILink:@"session" APIIdentifier:API_IDENTIFIER_SESSION_CREATION];
         
        
        
    }
    [sceneNameTextField resignFirstResponder];
}

- (IBAction)prepareMediaRecord:(id)sender {
    
    if(RespondsReached){
        
        recordObj =[[MediaRecordViewController alloc]initWithNibName:@"MediaRecordViewController" bundle:nil];
        [self.navigationController pushViewController:recordObj animated:YES];
    } else {
        [self ShowAlertMessage:@"Warning" Message:@"Scene was not set up properly!"];
    }
    
}

//Resign the textfield
- (IBAction)resignTextField:(id)sender {
    [sceneNameTextField resignFirstResponder];
}

- (void)loadSettingsButton
{
    UIImage *image = [UIImage imageNamed:@"settings_icon.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(0, 0, 25, 24)];
    [settingsButton setImage:image forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    [self.navigationController pushViewController:set animated:YES];
}

#pragma mark -

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                
                 //self.userProfileImage.profileID = user.id;
             }
         }];
    }
}
    -(void)RemoveLoadingView:(NSNotification *)notification
    {
        NSDictionary *dict = [notification userInfo];
        NSString *status=[dict objectForKey:@"Status"];
        
        if ([status isEqualToString:@"Success"])
        {
            RespondsReached=TRUE;
            
            NSMutableArray *UserDetails=[self ReadFromDataBase:@"Session_Details"];

            if ([UserDetails count]>0)
            {
                NSArray *details=[UserDetails objectAtIndex:[UserDetails count]-1];
                sceneTitleDisplay.text=[details objectAtIndex:6];
                sceneCodeDisplay.text=[details objectAtIndex:1];
                usernameDisplay.text= [details objectAtIndex:0];
                dateDisplay.text=[details objectAtIndex:9];
                timeDisplay.text=[details objectAtIndex:8];
                
                
                
                appDelegateObject.CurrentSession_Code = [details objectAtIndex:1];
                appDelegateObject.CurrentSession_Name = [details objectAtIndex:6];
                appDelegateObject.CurrentSession_NameExpired = [details objectAtIndex:7];
                appDelegateObject.CurrentSession_Expiring_Time = [details objectAtIndex:8];
                appDelegateObject.CurrentUserID = [[details objectAtIndex:5]intValue];
                appDelegateObject.CurrentUserName = [details objectAtIndex:0];

            
                
            }
            else
            {
                [self ShowAlertMessage:@"Warning" Message:@"No item to display"];
            }
            
            
            
            
        }
        else
        {
            RespondsReached=FALSE;
            
        }
        loadingView.hidden=TRUE;
        
        
    }

    -(void)RemoveLoadingViewAfterRegistration:(NSNotification*)Notification
    {
        NSDictionary *dict = [Notification userInfo];
        NSString *status=[dict objectForKey:@"Status"];
        
        if ([status isEqualToString:@"Success"])
        {
            
        }
        else
        {
            
        }
        loadingView.hidden=TRUE;
        
    }

    
    

-(void) ShowAlertMessage:(NSString*)Title Message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Title message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}
-(NSMutableArray*)ReadFromDataBase:(NSString*)TableName
{
    NSString *sqlQuery=[NSString stringWithFormat:@"Select * from %@",TableName];
    NSMutableArray *UserDetails;
    if ([TableName isEqualToString:@"Users"])
    {
        UserDetails = [appDelegateObject.databaseObject readFromDatabaseUsers:sqlQuery];
   
        
    }
    else if ([TableName isEqualToString:@"Session_Details"])
    {
        UserDetails = [appDelegateObject.databaseObject readFromDatabaseSessionDetails:sqlQuery];
         
    }
    
    
    return UserDetails;
}


@end
