//
//  AppDelegate.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ViewController.h"
#import "CreateSessionViewController.h"
#import "JoinSessionViewController.h"
#import "SettingsViewController.h"
#import "OpenSessionViewController.h"
#import "UploadTab.h"
#import "MediaRecordViewController.h"
#import "AudioViewController.h"
#import "HomeViewController.h"
#import "SocialViewController.h"
#import "CaptureViewController.h"
#import "MyVideosViewController.h"

@implementation AppDelegate
@synthesize  tabBarController,databaseObject,CurrentSession_Code,CurrentSession_Created_Date,CurrentSession_Expiring_Date,CurrentSession_Expiring_Time,CurrentSession_Name,CurrentSession_NameExpired,CurrentUserName,CurrentUserID, CurrentSessionID;
@synthesize navController;
@synthesize lagArray, diffArray, timeRelationship, syncObject, stillSynching;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [FBProfilePictureView class];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [self SetDataBaseForLoginPurpose];
    [self LoadUser];
    [self checkExistingUser];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    //Update files that were cancelled during upload, if any
    NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET upload_status=0 WHERE upload_status=9"];
    while (![dbObject updateDatabase:strQuery]) {
        NSLog(@"Retrying...");
    }

    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)SetDataBaseForLoginPurpose
{
    databaseObject=[[SQLdatabase alloc]initDatabase];
    [databaseObject checkDatabaseExists];
    
    //Load up the second database as well
    dbObject = [[ConnectToDatabase alloc] initDB];
    [dbObject checkAndCreateDatabase];
    //Clear out the upload tracker
    if(![dbObject delFromDatabase:@"DELETE FROM upload_tracker WHERE upload_status=-1"]){
        NSLog(@"Error occurred clearing out upload_tracker");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //Need to stop any recordings and take the time stamp
    MediaRecordViewController *cameraObject = [[MediaRecordViewController alloc] init];
    //AudioViewController *audioObject = [[AudioViewController alloc] init];
    if (cameraObject.isRecording) {
        [cameraObject recordButtonPressed];
    }
    /*
    if (audioObject.recorder) {
        [audioObject recordPressed:nil];
    }*/
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    
    LoginViewController *loginVC=[[LoginViewController alloc]init];
    [loginVC playMovie];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //At this point of time, we should retrieve the last sync and when it was taken to determine if another sync is needed. KIV
//    dbObject = [[ConnectToDatabase alloc] initDB];
//    syncObject = [dbObject syncCheck];
//    
//    //NSLog(stillSynching ? @"It's still synching" : @"It's not synching");
//    NSLog(syncObject.expiredSync ? @"Sync is outdated" : @"Sync is still valid"); //Sync expires every 2 hours
//    
//    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] init];
//    [internetReach startNotifier];
//    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
//    
//    /*if(!syncObject.expiredSync) {
//        timeRelationship = syncObject.previousTimeRelationship;
//        NSLog(@"Using previous time relationship of %f", timeRelationship);
//    } else */if (netStatus == NotReachable) {
//        [self showSyncAlert];
//    }else if (!stillSynching) {
//        //Only when still synching is NO, another queue will be dispatched
//        dispatch_queue_t syncQueue = dispatch_queue_create(NULL, 0);
//        dispatch_async(syncQueue, ^{
//            //Set still synching as yes to prevent the GCD from dispatching another queue if the app goes out
//            [self syncWithServer]; //This sets up the time relationship
//            //NSLog(@"%f", [[NSDate date] timeIntervalSince1970]);
//        });
//    }
//    
//    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)LoadUser
{
    NSString *sqlCommand=[NSString stringWithFormat:@"Select * from Users"];
    NSMutableArray *UserDetails= [databaseObject readFromDatabaseUsers:sqlCommand];
    
    if ([UserDetails count]>0){
        userexists=TRUE;
    } else {
        userexists=FALSE;
    }
}

- (BOOL)checkFBSessionOpen{
    if(FBSession.activeSession.isOpen){
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)checkExistingUser
{
    
    if(userexists==TRUE){
        [self loadApplicationHome];
    } else if(userexists==FALSE) {
        [self goToLogin];
    }
}
-(void)RemoveLoadingView:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *status=[dict objectForKey:@"Status"];
    if ([status isEqualToString:@"Failed"]) {
        [self ShowAlert:@"Warning" Message:@"You need to be connected to the internet"];
    }
    
    if (userexists) {
        [self loadApplicationHome];
    } else {
        [self goToLogin];
    }
    
}
-(void)ShowAlert:(NSString*)Title Message:(NSString*)Message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Title message:Message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}

-(void)loadApplicationHome
{
    HomeViewController *home=[[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    home.title=@"Featured";
    [home.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"g_logo.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"gig_tab_off.png.png"]];
    
    SocialViewController *socialVC=[[SocialViewController alloc]initWithNibName:@"SocialViewController" bundle:nil];
    socialVC.title=@"Events";
    [socialVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_create_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_create_button_off.png"]];
    
    MyVideosViewController *friendVideos=[[MyVideosViewController alloc]initWithNibName:@"MyVideosViewController" bundle:nil];
    friendVideos.title=@"Friends";
    [friendVideos.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_join_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_join_button_off.png"]];
    
    CaptureViewController *captureVC=[[CaptureViewController alloc]init];
    UINavigationController *captureNav=[[UINavigationController alloc]initWithRootViewController:captureVC];
    captureNav.title=@"Capture";
    [captureNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"capture_off.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"capture_off.png"]];

    
    CreateSessionViewController *create=[[CreateSessionViewController alloc]init];
    UINavigationController *createSession=[[UINavigationController alloc]initWithRootViewController:create];
    createSession.title=@"Create";
    [createSession.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_create_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_create_button_off.png"]];
    
    JoinSessionViewController *join=[[JoinSessionViewController alloc]init];
    UINavigationController *joinSession=[[UINavigationController alloc]initWithRootViewController:join];
    joinSession.title=@"Join";
    [joinSession.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_join_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_join_button_off.png"]];
    
    OpenSessionViewController *open=[[OpenSessionViewController alloc]initWithNibName:@"OpenSessionViewController" bundle:nil];
    UINavigationController *openSession=[[UINavigationController alloc]initWithRootViewController:open];
    openSession.title =@"Open";
    [openSession.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_open_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_open_button_off.png"]];
    
   
    UploadTab *uploadVC=[[UploadTab alloc]initWithNibName:@"UploadTab" bundle:nil];
    uploadVC.title=@"myFeeds";
    [uploadVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_upload_button_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_upload_button_off.png"]];
    
    SettingsViewController *settingsVC=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    settingsVC.title=@"Settings";
     [settingsVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"navigation_settings_button.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"navigation_settings_button.png"]];
    
    tabBarController=[[UITabBarController alloc]init];
    tabBarController.tabBar.tintColor=[UIColor clearColor];
    tabBarController.tabBar.backgroundImage=[UIImage imageNamed:@"bar.png"];
    tabBarController.tabBar.backgroundColor=[UIColor whiteColor];
   // tabBarController.tabBar.selectedImageTintColor=[UIColor blackColor];
    //tabBarController.tabBar.selectionIndicatorImage=[UIImage imageNamed:@"selectionTab.png"];
    //tabBarController.tabBar.selectionIndicatorImage=[UIImage imageNamed:@"color5.png"];
   
    NSArray *viewArray=[NSArray arrayWithObjects:home,friendVideos,captureNav,uploadVC,settingsVC,nil];
    
    //set tab bar controller array
    [tabBarController setViewControllers:viewArray];
    [self customiseAppearance];

    //push stack onto canvas
    //[self.window addSubview:tabBarController.view];
    //removing tabbarontroller as rootview enables other views to rotate as appropiate.. strange
    [self.window setRootViewController:tabBarController];
    
    [self.window makeKeyAndVisible];
    
}

- (void)customiseAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"realwhite.png"] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor darkGrayColor],UITextAttributeTextColor,
                                                nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    }

-(void)goToLogin
{
    UIViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
}

- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc]init];
    [navController pushViewController:set animated:YES];
}

-(void)closeFacebookSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - Synching methods

- (void)syncWithServer
{
    
    stillSynching = YES;
    
    //Reset the arrays
    [lagArray removeAllObjects];
    [diffArray removeAllObjects];
    
    double meanLag, meanTravelTime, meanDiffWithServer, meanServerTime, variance, serverVariance;
    double jitter;
    int count;
    
    //Need to make a retry loop. Only 10 tries allowed before a warning shows up
    for (count=0; count<10 && (jitter>0.015 || [diffArray count]<5); count++) {
        NSLog(@"Sync attempt %i", count);
        //Reset the array. NB: emptying the array is not enough apparently.
        lagArray = nil;
        lagArray = [NSMutableArray array];
        diffArray = nil;
        diffArray = [NSMutableArray array];
        
        //Reset all variables
        meanLag = 0; meanTravelTime = 0; meanDiffWithServer = 0;
        meanServerTime = 0; variance = 0, serverVariance = 0;
        
        double backTime, travelTime, lag, startTime;
        
        //The request to ping the API page
        NSURL *url = [NSURL URLWithString:@"http://www.gigreplay.com/api/get_time.php"];
        //ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        //Will calculate jitter based on 7 pings. We will remove a max of 2 outliers.
        for (int i=0; i<7; i++) {

            //Get the local time
            startTime = [[NSDate date] timeIntervalSince1970];
            //NSLog(@"%f", localTime);

            
            //Initialise the request
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            
            
            //Start the request
            [request startSynchronous];
            NSString *response = [request responseString];
            NSScanner *scanner = [NSScanner scannerWithString:response];
            double serverTime;
            double diffWithServer;
            [scanner scanDouble:&serverTime];

            //Get the local time when the signal comes back
            backTime = [[NSDate date] timeIntervalSince1970];
            //NSLog(@"%f", backTime - localTime);
            
            NSError *error = [request error];
            if (!error) {
                
                //NSLog(@"%@", response);
                
                //Converting it to a double
                
                //Calculating the traveltimes and latency
                travelTime = backTime - startTime;
                lag = travelTime / 2;
                meanTravelTime += travelTime;
                meanLag += lag;
                meanDiffWithServer += serverTime - startTime - lag;
                diffWithServer = serverTime - startTime - lag;
                meanServerTime += serverTime - startTime;
                
                //Figure out the difference and store it in an array
                [lagArray addObject:[NSNumber numberWithDouble:lag]];
                [diffArray addObject:[NSNumber numberWithDouble:diffWithServer]];
                
                //Debug line
                //NSLog(@"%@", timeDiff);
                //NSLog(@"%f", serverTime);
                
            }
        }
        
        //Calculating the means
        //meanTravelTime = meanTravelTime/[diffArray count];
        meanLag = meanLag/[lagArray count];
        meanDiffWithServer = meanDiffWithServer/[lagArray count];
        //meanServerTime = meanServerTime/[diffArray count];
        
        //Calculating jitter (latency)
        for (int i=0; i<[lagArray count]; i++) {
            double lag = [[lagArray objectAtIndex:i] floatValue];
            double delta = lag - meanLag;
            double deltaSquare = delta*delta;
            variance += deltaSquare;
        }
        
        //Calculating variance in difference with server
        for (int k=0; k<[diffArray count]; k++) {
            double diffWithServer = [[diffArray objectAtIndex:k] floatValue];
            double delta = diffWithServer - meanDiffWithServer;
            double deltaSquare = delta*delta;
            serverVariance += deltaSquare;
        }
        
        jitter = sqrt(variance/[diffArray count]);
        //jitter = variance/[lagArray count];
        serverVariance = sqrt(serverVariance/[diffArray count]);
        //serverVariance = serverVariance/[diffArray count];
        NSLog(@"%f %f %f %f %i", meanLag, jitter, meanDiffWithServer, serverVariance, [lagArray count]);
        
        //At this point, we take out the outliers from the group
        NSMutableArray *newLagArray, *newDiffArray;
        newLagArray = [NSMutableArray array];
        double newJitter = 0.0, newMeanLag = 0.0, newLag, newVariance = 0.0;
        for (int i=0; i<[lagArray count]; i++) {
            newLag = [[lagArray objectAtIndex:i] floatValue];
            if (newLag>(meanLag-jitter) && newLag<(meanLag+jitter)) {
                [newLagArray addObject:[NSNumber numberWithDouble:newLag]];
                newMeanLag += newLag;
            }
        }
        
        //Now, get the newMeanLag and newJitter
        newMeanLag = newMeanLag/[newLagArray count];
        newDiffArray = [NSMutableArray array];
        for (int k=0; k<[newLagArray count]; k++) {
            double lag = [[newLagArray objectAtIndex:k] floatValue];
            double diff = lag - newMeanLag;
            double diffSquare = diff*diff;
            newVariance += diffSquare;
        }
        newJitter = sqrt(newVariance/[newLagArray count]);
        //NSLog(@"The old array had %i data points, but this new array has %i data points", [lagArray count], [newLagArray count]);
    }
    
    if (count == 10) {
        [self showSyncAlert];
    } else {
        timeRelationship = meanDiffWithServer;
        NSLog(@"Time relationship is %f", timeRelationship);
        
        //Once a time relationship is established, input/update the database
        if (syncObject.entryid == 1) {
            [dbObject updateDatabase:[NSString stringWithFormat:@"UPDATE last_sync SET time_relationship=%f,last_sync=%f WHERE id=1", timeRelationship, [[NSDate date] timeIntervalSince1970]]];
        } else {
            [dbObject insertToDatabase:[NSString stringWithFormat:@"INSERT INTO last_sync (time_relationship,last_sync) VALUES (%f,%f)", timeRelationship, [[NSDate date] timeIntervalSince1970]]];
        }
    }
    
    stillSynching = NO;
}

#pragma mark - Sync error functions

- (void)showSyncAlert
{
    UIAlertView *syncError = [[UIAlertView alloc] initWithTitle:@"Sync Error" message:@"Unable to create a stable sync. Please check your settings to ensure there is an internet connection." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Retry", @"Ignore", nil];
    [syncError performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        dispatch_queue_t syncQueue = dispatch_queue_create(NULL, 0);
        dispatch_async(syncQueue, ^{
            //Set still synching as yes to prevent the GCD from dispatching another queue if the app goes out
            [self syncWithServer]; //This sets up the time relationship
            //NSLog(@"%f", [[NSDate date] timeIntervalSince1970]);
        });
    } else if (buttonIndex == 1) {
        //Let's try to avoid the cancel button. Instead lead them out with the settings button
        //exit(0);
        timeRelationship = syncObject.previousTimeRelationship;
        NSLog(@"Using previous time relationship of %f", timeRelationship);
    }
}

@end
