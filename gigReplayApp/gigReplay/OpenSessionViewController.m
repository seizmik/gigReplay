//
//  OpenSessionViewController.h
//  GigReplay
//
//  Created by User on 25/3/13.
//  Copyright (c) 2013 Thesmos Inc. All rights reserved.
//

#import "OpenSessionViewController.h"
#import "SettingsViewController.h"

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
    self.title=@"Open";

    apiWrapperObject=[[ApiObject alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(removeLoadingView:)
												 name:@"OpenSessionDetailsCompleted"
											   object:nil];
    [self loadSettingsButton];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [self OpenSessionDetailsFromAPI];
}


 
-(void)OpenSessionDetailsFromAPI
{
    
    [apiWrapperObject OpenSessionDetails:appDelegateObject.CurrentUserID WithSession:appDelegateObject.CurrentSession_Code APIIdentifier:API_IDENTIFIER_OPEN_SESSION];
    
}

//////////////////////////////////TableViewCell OpenSessions Implementation////////////////////////////////////

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
    NSLog(@"leonism %@",Details);
    cell.SceneName.text=[Details objectAtIndex:5];
    cell.directorName.text=[Details objectAtIndex:6];
    cell.SceneTake.text=[Details objectAtIndex:4];
    
    
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
    NSLog(@"%@",Details );
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
    mediaObject=[[MediaRecordViewController alloc]initWithNibName:@"MediaRecordViewController" bundle:nil];
    [mediaObject setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal  ];
    //[self presentViewController:mediaObject animated:YES completion:nil];
    [self.navigationController pushViewController:mediaObject animated:YES];
    
}


-(void)LoadSessionDetailsFromDB
{
    NSString *query=@"select * from OpenSession_Details";
    self.OpenedSessionDetailsHolder=[appDelegateObject.databaseObject readFromDatabaseOpenDetails:query];
    NSLog(@"%d count of open details",[self.OpenedSessionDetailsHolder count]);
    
    [openedSessionListTable reloadData];
    
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
