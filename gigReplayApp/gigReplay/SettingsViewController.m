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
    [self.videoResolutionTable setFrame:CGRectMake(80, 220, 194, 175)];
    videoResolutionValues=[[NSArray alloc] initWithObjects:@"1280*720p",@"960*540p",@"640*480p",@"480*360p",nil];
    
    
    // Do any additional setup after loading the view from its nib.
    
       }

-(void)viewWillAppear:(BOOL)animated

{
    
    
    [self hideTables];
    
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
    UIAlertView *syncTime = [[UIAlertView alloc] initWithTitle:@"Time Now" message:[NSString stringWithFormat:@"Time now is %1.3lf", serverTime] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
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

-(void)hideTables{
    self.videoResolutionTable.hidden=TRUE;
}




- (IBAction)videoResButton:(id)sender {
    self.videoResolutionTable.hidden=FALSE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor=[UIColor darkGrayColor];
    
    
        cell.textLabel.text=[videoResolutionValues objectAtIndex:indexPath.row];

    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoResolutionValues count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        NSLog(@"720p");
        [self.videoResButtonOutlet setTitle:@"720p" forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SessionCreateParsingCompleted" object:self];
        NSLog(@"posting notifictcation done");
        

    }
    else if(indexPath.row==1){
        NSLog(@"540p");
        [self.videoResButtonOutlet setTitle:@"540p" forState:UIControlStateNormal];
    }
    else if(indexPath.row==2){
        NSLog(@"480p");
        [self.videoResButtonOutlet setTitle:@"480p" forState:UIControlStateNormal];
    }
    else if(indexPath.row==3){
        NSLog(@"360p");
        [self.videoResButtonOutlet setTitle:@"360p" forState:UIControlStateNormal];
    }
        [self hideTables];
    
}


@end
