//
//  SettingsViewController.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    self.title=@"Settings";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLogOut:(id)sender {
    [appDelegateObject closeFacebookSession];
    NSString *Query=[NSString stringWithFormat:@"DELETE FROM users"];
    [appDelegateObject.databaseObject deleteFromDatabase:Query];
    
    [appDelegateObject goToLogin];
    
}

- (IBAction)syncTrial:(UIButton *)sender {
    double timeNow = [[NSDate date] timeIntervalSince1970];
    //timeNow += appDelegateObject.timeRelationship;
    double serverTime = timeNow + appDelegateObject.timeRelationship;
    UIAlertView *syncTime = [[UIAlertView alloc] initWithTitle:@"Time Now" message:[NSString stringWithFormat:@"Time now is %f", serverTime] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [syncTime show];
}

- (IBAction)reSync:(UIButton *)sender {
    if (!appDelegateObject.stillSynching) {
    dispatch_queue_t syncQueue = dispatch_queue_create(NULL, 0);
    dispatch_async(syncQueue, ^{
        //Set still synching as yes to prevent the GCD from dispatching another queue if the app goes out
        [appDelegateObject syncWithServer]; //This sets up the time relationship
        //NSLog(@"%f", [[NSDate date] timeIntervalSince1970]);
    });}
}
@end
