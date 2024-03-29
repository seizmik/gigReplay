//
//  LoginViewController.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)getDeviceID
{

    UIDevice *myDevice=[UIDevice currentDevice];
    self.deviceUDID = [[myDevice identifierForVendor] UUIDString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        [self getDeviceID];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [self playMovie];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbLoginButton:(id)sender {
    
    [self LoadLoadingViewForFacebookSignUp];
    [self openSessionWithAllowLoginUI:YES];
    
    
}

/*
 <------------------FACEBOOK AUTHENTICATION METHODS DEFINED HERE-------------------->
 */
 
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    
    if (FBSession.activeSession.isOpen)
    {
        
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                           id<FBGraphUser> user,
                                           NSError *error)
         {
             if (!error)
             {
                 NSString *userInfo = @"";
                 
                 // Example: typed access (name)
                 // - no special permissions required
                 self.FirstName = user.first_name;
                 self.LastName = user.last_name;
                 self.UserName = user.name;
                 self.Email=[user objectForKey:@"email"];
                 self.FB_UserID=user.id;
                 self.FB_AuthorizationToken=session.accessToken;
               
                 
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"userId: %@\n\n",user.id]];
                 
                 // Example: typed access, (birthday)
                 // - requires user_birthday permission
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Birthday: %@\n\n",
                              user.birthday]];
                 
                 // Example: partially typed access, to location field,
                 // name key (location)
                 // - requires user_location permission
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Location: %@\n\n",
                              [user.location objectForKey:@"name"]]];
                 
                 // Example: access via key (locale)
                 // - no special permissions required
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"Locale: %@\n\n",
                              [user objectForKey:@"locale"]]];
                 
                 
                 
                 userInfo = [userInfo
                             stringByAppendingString:
                             [NSString stringWithFormat:@"email: %@\n\n",
                              [user objectForKey:@"email"]]];
                 
                 self.Email=[user objectForKey:@"email"];
                 
                 // Example: access via key for array (languages)
                 // - requires user_likes permission
                 //language? whats is for?
                 if ([user objectForKey:@"languages"]) {
                     NSArray *languages = [user objectForKey:@"languages"];
                     NSMutableArray *languageNames = [[NSMutableArray alloc] init];
                     for (int i = 0; i < [languages count]; i++) {
                         [languageNames addObject:[[languages
                                                    objectAtIndex:i]
                                                   objectForKey:@"name"]];
                     }
                     userInfo = [userInfo
                                 stringByAppendingString:
                                 [NSString stringWithFormat:@"Languages: %@\n\n",
                                  languageNames]];
                 } else {
                     NSLog(@"FB Error: %@", [error localizedDescription]);
                 }
                 
                 // Display the user info
                 NSLog(@"user info: %@",userInfo);
             }
             
             
            [self InputDetailsToDatabase];
         }];
    }
   
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

-(void)LoadLoadingViewForFacebookSignUp
{
       UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    // Position the spinner
    [myIndicator setCenter:CGPointMake(160.0, 200.0)];
    myIndicator.color=[UIColor whiteColor];
  
    
    
   
    
    // Start the animation
    [myIndicator startAnimating];
    
    [self.view addSubview:myIndicator];
    [self.view bringSubviewToFront:myIndicator];
    
}

/*
 
<--------------------End of Facebook Login Implementation------------------>
 */

-(void)InputDetailsToDatabase
{
   self.Password=@"no";
    NSString *sqlCommand=[NSString stringWithFormat:@"insert into Users (username,fb_user_id,fb_authorization_token,email,password,firstname,lastname,unique_device_id,fb_connected,email_signup,user_ID)values('%@','%@','%@','%@','%@','%@','%@','%@','1','1',1)",self.UserName,self.FB_UserID,self.FB_AuthorizationToken,self.Email,self.Password,self.FirstName,self.LastName,self.deviceUDID];

  
    
    BOOL Result=[appDelegateObject.databaseObject insertIntoDatabase:sqlCommand];
    if (Result)
    {
        
        [appDelegateObject loadApplicationHome];
    }
    else
    {
        return;
    }

  
}
-(BOOL)shouldAutorotate{
    return NO;
}

-(void) playMovie
{
    
    NSString*thePath=[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mp4"];
    NSURL*theurl=[NSURL fileURLWithPath:thePath];
    self.moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:theurl];
    self.moviePlayer.controlStyle=MPMovieControlStyleNone;
    [self.view addSubview:self.movieView];
    [self.movieView addSubview:self.moviePlayer.view];
    [self.moviePlayer.view setFrame:self.movieView.bounds];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
    self.moviePlayer.repeatMode=MPMovieRepeatModeOne;
    
}


@end
