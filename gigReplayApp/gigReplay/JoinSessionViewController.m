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
#import "UIImageView+WebCache.h"

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
 
 UIImageView *divider=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1, 320, 1)];
 divider.image=[UIImage imageNamed:@"color.png"];
 [self.view addSubview:divider];

 
    [self.navigationController setNavigationBarHidden:NO];

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
//    [self loadSettingsButton];
    
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
    NSLog(@"%@ serach details read from DB...",Details);
        
    

    cell.SceneName.text=[Details objectAtIndex:4];
    cell.directorName.text=[Details objectAtIndex:3];
    cell.SceneTake.text=[Details objectAtIndex:2];
    [cell.dateLabel setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    cell.dateLabel.text=[Details objectAtIndex:7];
    NSString  *fb_user_ID=[Details objectAtIndex:11 ];
    
    NSString *profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=77&height=66", fb_user_ID];
    
    //    dispatch_async(kBgQueue, ^{
    
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //           cell.fbProfilePictureView.profileID=fb_user_ID;
    [cell.facebookimageview setImageWithURL:[NSURL URLWithString:profilePicURL]];

    
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
