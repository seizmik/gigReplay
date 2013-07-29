//
//  CreateSessionViewController.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "CreateSessionViewController.h"

@interface CreateSessionViewController ()

@property (nonatomic, strong) NSArray *accountItems;

@end

@implementation CreateSessionViewController
@synthesize sceneTitleDisplay, apiWrapperObject, usernameDisplay, loadingView, sceneNameTextField, dateDisplay,start_button;
//@synthesize userProfileImage, sceneCodeDisplay
@synthesize timeDisplay,profileViewOutlet,profileName,profileAccount,accountItems;


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
    pressed =YES;
    
    self.title=@"Create";
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
    [self loadProfileButton];
    
    [self.start_button setBackgroundImage:[UIImage animatedImageNamed:@"start_" duration:4.0] forState:UIControlStateNormal];
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToSettings)];
    UISwipeGestureRecognizer *profileRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goToProfile)];
    [profileRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:profileRecognizer];
    [self.view addGestureRecognizer:recognizer];
    
    //implementing profile page menu items
    accountItems=[NSArray arrayWithObjects:@"Invite",@"Messages",@"MyCrew",@"Find Crew", nil];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
}

-(void)handlePan:(UIPanGestureRecognizer *)gesture{
    
    CGPoint translate = [gesture translationInView:gesture.view];CGPoint velocity = [gesture velocityInView:gesture.view];
    if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (gesture.view.bounds.size.width / 2.0) && profileViewOutlet)
    {
        // moving right (and/or flicked right)
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             profileViewOutlet.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                             self.view.frame = [self frameForNextViewWithTranslate:CGPointZero];
                         }
                         completion:^(BOOL finished) {
                             // do whatever you want upon completion to reflect that everything has slid to the right
                             
                             // this redefines "next" to be the old "current",
                             // "current" to be the old "previous", and recycles
                             // the old "next" to be the new "previous" (you'd presumably.
                             // want to update the content for the new "previous" to reflect whatever should be there
                             
                             UIView *tempView = profileViewOutlet;
                             profileViewOutlet=self.view;
                             self.view =tempView;
                             self.view.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                         }];
    }
    
}

- (CGRect)frameForPreviousViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(-self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForCurrentViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForNextViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}


-(void)SyncUserDetails
{
    
    NSMutableArray *UserDetails= [self ReadFromDataBase:@"Users"];
    NSArray *details=[UserDetails objectAtIndex:0];
    appDelegateObject.CurrentUserName=[details objectAtIndex:0];
    
    //post is required when awake from background else usersync is lost and cant get open/join etc
    [apiWrapperObject postUserDetails:[details objectAtIndex:2]  userEmail:[details objectAtIndex:4] userName:[details objectAtIndex:0] facebookToken:[details objectAtIndex:3] APIIdentifier:API_IDENTIFIER_USER_REG];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Button actions

- (IBAction)createScene:(id)sender {
    
    //Reset the RespondsReached, disable the sync and go buttons
    
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
        recordObj.hidesBottomBarWhenPushed = YES;
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
    UIImage *image = [UIImage imageNamed:@"navigation_settings_button.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(0, 0, 23, 23)];
    [settingsButton setImage:image forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}
-(void)loadProfileButton
{
    UIImage *image = [UIImage imageNamed:@"profile.png"];
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileButton setFrame:CGRectMake(0, 0, 23, 23)];
    [profileButton setImage:image forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.leftBarButtonItem = leftButton;

}

- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    set.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:set animated:YES];
}
-(void)goToProfile{
    
    profileViewOutlet.frame=CGRectMake(0, 0, 250, 480);
    UISwipeGestureRecognizer *dismissProfileView=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dimissProfile)];
    [dismissProfileView setDirection:UISwipeGestureRecognizerDirectionLeft];
    [profileViewOutlet addGestureRecognizer:dismissProfileView];
    [self.view addSubview:profileViewOutlet];
    
    profileName.text=appDelegateObject.CurrentUserName;
    
}

-(void)dimissProfile{
    [profileViewOutlet removeFromSuperview];
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
                //sceneCodeDisplay.text=[details objectAtIndex:1];
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
