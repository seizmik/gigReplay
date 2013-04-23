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
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextField:)];
    [self.view addGestureRecognizer:tapToDismiss];
    // Do any additional setup after loading the view from its nib.
}
-(void)RemoveLoadingView:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *status=[dict objectForKey:@"Status"];
    
    if ([status isEqualToString:@"Success"])
    {
//        [self ShowAlertMessage:@"Warning" Message:@"Do you want to Reset the Search result....?" Identifier:3];
//        [self.view addSubview:DisplayView];
       // DisplayView.backgroundColor=[UIColor colorWithPatternImage: [UIImage imageNamed:@"body-bg.png"]];
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
        //[mediaObject setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        //[self presentViewController:mediaObject animated:YES completion:nil];
        MediaRecordViewController *recordVC = [[MediaRecordViewController alloc] init];
        [self.navigationController pushViewController:recordVC animated:YES];
       
        
    }
    else //bgBLwrplyCkJYtG3
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
    cell.sceneSelectionButton.tag=indexPath.row;
     [cell.sceneSelectionButton addTarget:self action:@selector(ClickedButtonForSelection:) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void)ClickedButtonForSelection:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    [tableViewScenes reloadData];
    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    CustomCell *cell=[tableViewScenes cellForRowAtIndexPath:myIndexPath];
    
    if(SelectionButtonSeleted)
    {
        [cell.sceneSelectionButton setBackgroundImage:[UIImage imageNamed:@"File-Unselect.png"]  forState:UIControlStateNormal];
        SelectionButtonSeleted=FALSE;
        
    }
    else
    {
        [cell.sceneSelectionButton setBackgroundImage:[UIImage imageNamed:@"tick.png"]  forState:UIControlStateNormal];
        SelectionButtonSeleted=TRUE;
        currentSelectedSession=btn.tag;
        
    }
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.sessionDetailsHolder count];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do some stuff when the row is selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}


/////////////////////End of TableViewCell Implementation////////////////////////

//////////////// Joining Sessions Implementation methods////////////////////////
-(void)JoinToSessions:(NSString *)session_pass
{
    
  
    NSArray *Details=[sessionDetailsHolder objectAtIndex:currentSelectedSession];
    NSString *Session_Code= [Details objectAtIndex:5];
    
    //PROBLEM LIES HERE WHEN POSTING TO SERVER USERID CANT BE 0!
    ////////////// //////////// //////////// /////////// ////////////
    
    NSString *userID=[Details objectAtIndex:1];
    NSString *SessionName=[Details objectAtIndex:4];
    NSString  *createdby=[Details objectAtIndex:0];
    
    if ([Session_Code isEqualToString:session_pass]) {
        appDelegateObject.CurrentSession_Code=Session_Code;
        appDelegateObject.CurrentSession_Name=SessionName;
        [apiWrapperObject postJoinSessionDetails:userID SesssionName:SessionName SessionID:Session_Code Created_User_Id:createdby APIIdentifier:API_IDENTIFIER_SESSION_JOIN];
        
    }
    
    else
    {
        [self ShowAlertMessage:@"Error" Message:@"Session Code Doesn't Match"];
    }
}
-(IBAction)start:(id)sender
{
    if (!SelectionButtonSeleted)
    {
        [self ShowAlertMessage:@"Warning" Message:@"Please select a session to start"];
        return;
    }
    else
    {
        [self CheckPasswordAndJoinToSession];
    }
    
    
}
-(void)CheckPasswordAndJoinToSession
{
    
    [self showAlertWithTextField];
    
    
}
-(void)showAlertWithTextField{
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"SessionCode Needed" message:@"Enter SessionCode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    
    [dialog show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
            if (buttonIndex == 1)
        {
            
            NSString *UserTypedSessioncode=[[alertView textFieldAtIndex:0]text];
            [self JoinToSessions:UserTypedSessioncode];
        }
        
        
    
    
    
}


#pragma mark End of join session methods
#pragma mark -
////////////////////////////end of joining Sessions methods/////////////////////////

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
