//
//  OpenSessionViewController.h
//  GigReplay
//
//  Created by User on 25/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import "OpenSessionViewController.h"
#import "SettingsViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface OpenSessionViewController ()

@end

@implementation OpenSessionViewController
@synthesize OpenedSessionDetailsHolder,openedSessionListTable,apiWrapperObject;
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
    [self.navigationController setNavigationBarHidden:NO];

    //load values obtained from last connection to online database
    [self LoadSessionDetailsFromDB];
    
    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(getOpenArray) forControlEvents:UIControlEventValueChanged];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl=refresh;
    refresh.tintColor=[UIColor whiteColor];
 
    
    self.title=@"Open";

    apiWrapperObject=[[ApiObject alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(removeLoadingView:)
												 name:@"OpenSessionDetailsCompleted"
											   object:nil];
   // [self loadSettingsButton];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)getOpenArray{

    
    NSLog(@"fetcheddatachagend");
    // connect to online database and retrieve new data when pulled to refresh
    [self performSelector:@selector(updatingTable) withObject:nil afterDelay:3];
   self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Updating.."];
    [self performSelector:@selector(OpenSessionDetailsFromAPI) withObject:nil afterDelay:3];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
         NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    self.navigationItem.hidesBackButton = YES;
}
-(void)updatingTable{
   
    [self.refreshControl endRefreshing];
    self.navigationItem.hidesBackButton = NO;

}

 
-(void)OpenSessionDetailsFromAPI
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [apiWrapperObject OpenSessionDetails:appDelegateObject.CurrentUserID WithSession:appDelegateObject.CurrentSession_Code APIIdentifier:API_IDENTIFIER_OPEN_SESSION];
    });
    
}

////////////////////////////TableViewCell OpenSessions Implementation////////////////////////////



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString* CellIdentifier = @"CustomCell";
    	
	CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
        
		NSArray *topLevelObjects;
		
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
		for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (CustomCell *) currentObject;
				break;
			}
		}
	}

    NSArray *Details=[self.OpenedSessionDetailsHolder objectAtIndex:indexPath.row];
    cell.SceneName.text=[Details objectAtIndex:5];
    cell.directorName.text=[Details objectAtIndex:6];
    cell.SceneTake.text=[Details objectAtIndex:4];
     fb_user_ID=[Details objectAtIndex:11];
    [cell.dateLabel setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    cell.dateLabel.text=[Details objectAtIndex:3];
        //obtain by using a string with the facebook profile pic id
    NSString *profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=77&height=66", fb_user_ID];

    
    [cell.facebookimageview setImageWithURL:[NSURL URLWithString:profilePicURL] placeholderImage:[UIImage animatedImageNamed:@"tab_generate_button_on_" duration:1.5] options:SDWebImageCacheMemoryOnly];
   
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.OpenedSessionDetailsHolder count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 107;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *Details=[self.OpenedSessionDetailsHolder objectAtIndex:indexPath.row];
    //NSLog(@"%@",Details );
    appDelegateObject.CurrentSession_Code=[Details objectAtIndex:4];
    appDelegateObject.CurrentSession_Name=[Details objectAtIndex:5];
    appDelegateObject.CurrentSessionID=[Details objectAtIndex:10];
    NSLog(@" OPENED SESSION SESSION ID IS %@",appDelegateObject.CurrentSessionID);
    
    appDelegateObject.CurrentSession_NameExpired=[Details objectAtIndex:9];
    appDelegateObject.CurrentSession_Expiring_Time=[Details objectAtIndex:8];
    [self showRecorderView];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   

    
}
-(void)removeLoadingView:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *status=[dict objectForKey:@"Status"];
    //NSLog(@"%@",status);
    if ([status isEqualToString:@"Success"])
    {
        
        [self LoadSessionDetailsFromDB];
        NSLog(@"open sessions success");
    }
    else if ([status isEqualToString:@"warning"])
    {
        [self ShowAlertMessage:@"Warning" Message:@"No Sessions Exist"];
    }
    else
    {
        [self LoadSessionDetailsFromDB];
        [self ShowAlertMessage:@"Warning" Message:@"Problem While Opening Your New Sessions"];
    }
    
    
}

-(void) ShowAlertMessage:(NSString*)Title Message:(NSString*)message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Title message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}

-(void)showRecorderView{
    mediaObject=[[MediaRecordViewController alloc]init];
     mediaObject.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:mediaObject animated:YES];
   
}


-(void)LoadSessionDetailsFromDB
{

    NSString *query=@"select * from OpenSession_Details";
    self.OpenedSessionDetailsHolder=[appDelegateObject.databaseObject readFromDatabaseOpenDetails:query];
    //NSLog(@"%d count of open details",[self.OpenedSessionDetailsHolder count]);

    [openedSessionListTable reloadData];
}


- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    set.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:set animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
