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
    timeNow += appDelegateObject.timeRelationship;
    UIAlertView *syncTime = [[UIAlertView alloc] initWithTitle:@"Time Now" message:[NSString stringWithFormat:@"%f", timeNow] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [syncTime show];
}
@end
