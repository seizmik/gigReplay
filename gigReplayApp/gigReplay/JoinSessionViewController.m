//
//  JoinSessionViewController.m
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "JoinSessionViewController.h"
#import "CustomCell.h"
#import "MediaRecordViewController.h"
#import "SettingsViewController.h"

@interface JoinSessionViewController ()

@end

@implementation JoinSessionViewController
@synthesize tableViewScenes,apiWrapperObject,usernameSearchTextField,SceneNameSearchTextField,sessionDetailsHolder,cellObject;


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
    self.title=@"Join";
    [mediaObject.view removeFromSuperview];
    mediaObject=[[MediaRecordViewController alloc]initWithNibName:@"MediaRecordViewController" bundle:nil];
    cellObject=[[CustomCell alloc]init];
    apiWrapperObject=[[ApiObject alloc]init];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RemoveLoadingViewFinal:)
												 name:@"JoinDetailsParsingCompleted"
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RemoveLoadingView:)
												 name:@"JoinSearchParsingCompleted"
											   object:nil];
    [self loadSettingsButton];
    
}

-(void)RemoveLoadingView:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *status=[dict objectForKey:@"Status"];
    
    if ([status isEqualToString:@"Success"])
    {

        [self LoadSessionDetailsFromDB];
        
    }
    else //bgBLwrplyCkJYtG3
    {
       [self ShowAlertMessage:@"Warning" Message:@" SessionCode doesnot exist" ];

    }
    
}


-(void)RemoveLoadingViewFinal:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *status=[dict objectForKey:@"Status"];
    
    if ([status isEqualToString:@"Success"])
    {
//        [mediaObject setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
//        [self presentViewController:mediaObject animated:YES completion:nil];
        mediaObject.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:mediaObject animated:YES];
        
       
        
    }
    else 
    {
        [self ShowAlertMessage:@"Warning" Message:@" SessionCode doesnot exist" ];
        
    }
    
       
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}
- (IBAction)textDidEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)textDidEnd2:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)searchButton:(id)sender {
    //[self searchIndicatorView];
    
    tableViewScenes.hidden=NO;
    {
        //if Search is pressed but nil inputs in fields
        
        if ([usernameSearchTextField.text isEqualToString:@""]&&[SceneNameSearchTextField.text isEqualToString:@""])
        {
            [self ShowAlertMessage:@"Error" Message:@"enter a search field"]    ;
            return;
        }
        else
        {
            //searchsessiondetails is a post method so posting the two input fields to search for sessions in web.
            //Search the details of sessions in database and parse back to app. Check up on XMLparser to know more
            [apiWrapperObject SearchSessionDetails:usernameSearchTextField.text SessionName:SceneNameSearchTextField.text APIIdentifier:API_IDENTIFIER_SEARCH_FOR_JOIN_SESSION];
            
        }

        [self resignTextField:self];
}
}


-(void)searchIndicatorView
{
    overlay=[[UIView alloc]initWithFrame:CGRectMake(240, 20, 300, 80)];
    overlay.backgroundColor=[UIColor greenColor  ];
    [self.view addSubview:overlay];
       
    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    // Position the spinner
    myIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [myIndicator setCenter:CGPointMake(270, 60)];
    myIndicator.color=[UIColor blackColor];
    // Start the animation
    [myIndicator startAnimating];
    [self.view addSubview:myIndicator];
    [self.view bringSubviewToFront:myIndicator];
    
    
   
    
}
///////////////////////////////////////TableViewCell Implementation////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString* CellIdentifier = @"CustomCell";
	
	//custom cell initilisation
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
   
    NSArray *Details=[self.sessionDetailsHolder objectAtIndex:indexPath.row];
        
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     
                     cell.fbProfilePictureView.profileID = user.id;
                 }
             }];
        }
    
       
    cell.SceneName.text=[Details objectAtIndex:4];
    cell.directorName.text=[Details objectAtIndex:3];
    cell.SceneTake.text=[Details objectAtIndex:2];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.sessionDetailsHolder count];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *Details=[sessionDetailsHolder objectAtIndex:indexPath.row];
    NSString *Session_Code= [Details objectAtIndex:5];
    NSString *userID=[Details objectAtIndex:1];
    NSString *SessionName=[Details objectAtIndex:4];
    NSString  *createdby=[Details objectAtIndex:0];
    appDelegateObject.CurrentSession_Code=Session_Code;
    appDelegateObject.CurrentSession_Name=SessionName;
    
    [apiWrapperObject postJoinSessionDetails:userID SesssionName:SessionName SessionID:Session_Code Created_User_Id:createdby APIIdentifier:API_IDENTIFIER_SESSION_JOIN];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 107;
}





#pragma mark End of join session methods
#pragma mark -


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

- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    set.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:set animated:YES];
}

-(void) ShowAlertMessage:(NSString*)Title Message:(NSString*)message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Title message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}


-(void)LoadSessionDetailsFromDB
{
    NSString *query=@"select * from Searchsession_Details";
    self.sessionDetailsHolder=[appDelegateObject.databaseObject readFromDatabaseSearchSessionDetails:query];

    [tableViewScenes reloadData];
  
    
}

- (void)resignTextField:(id)sender {
    [usernameSearchTextField resignFirstResponder];
    [SceneNameSearchTextField resignFirstResponder];
}









@end
