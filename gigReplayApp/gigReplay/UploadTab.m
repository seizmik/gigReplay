//
//  UploadTab.m
//  gigReplay
//
//  Created by User on 18/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "UploadTab.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "UploadCell.h"
#import "SettingsViewController.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <CoreMedia/CoreMedia.h>


@interface UploadTab ()

@end

@implementation UploadTab
@synthesize uploadTable, uploadArray, dbObject,uploadProgress;
@synthesize detailsToDelete,movieplayer,uploadVideoFilePath,progressIndicator;

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
    // Do any additional setup after loading the view from its nib.
   
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.uploadTable addGestureRecognizer:lpgr];
        
}
- (void)viewWillAppear:(BOOL)animated
{
    progressIndicator.hidden =YES;
    [super viewWillAppear:animated];
    [self refreshDatabaseObjects];
    [uploadTable reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    UILabel *message=[[UILabel alloc]initWithFrame:CGRectMake(50, 200, 220, 50)];
    message.text=@"NO VIDEOS FOR UPLOAD!";
    
    [self.view addSubview:message];
    message.hidden=YES;
    if([uploadArray count]==0){
        NSLog(@"NO VIDEOS FOR UPLOAD");
        message.hidden=NO;
    }
    else if([uploadArray count]>0){
        message.hidden=YES;
        
    }
  
    return [uploadArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString* CellIdentifier = @"UploadCell";
	
	
	UploadCell *cell = (UploadCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
	if (cell == nil)
	{
		
		NSArray *topLevelObjects;
		
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UploadCell" owner:self options:nil];
		for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (UploadCell *) currentObject;
				break;
			}
		}
	}

  
    videoInfo = [uploadArray objectAtIndex:indexPath.row];
    NSLog(@"files details %d",videoInfo.userid);
    //change to nsdictionary for performance issue. NSDICT caches info in app. Similar to NSCACHE
    NSMutableDictionary *myValues =[[NSMutableDictionary alloc] init];
    [myValues setObject:videoInfo.sessionName forKey:@"sessionName"];
    if (videoInfo.thumbnailPath) {
        [myValues setObject:videoInfo.thumbnailPath forKey:@"image"];
    }
    
    [cell.uploadButton setTag:indexPath.row];
    [cell.uploadButton addTarget:self action:@selector(uploadSuccess:) forControlEvents:UIControlEventTouchUpInside];
if(videoInfo.uploadStatus==0)
    {
        [cell.uploadedTick setImage:[UIImage imageNamed:@"no.png"]];
        [cell.uploadButton setEnabled:YES];
    }else if(videoInfo.uploadStatus==1){
        [cell.uploadedTick setImage:[UIImage imageNamed:@"yes.png"]];
        [cell.uploadButton setEnabled:NO];
        
    }
    
    [cell.customButton setTag:indexPath.row];
    [cell.customButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDate *fileDate = [NSDate dateWithTimeIntervalSince1970:(videoInfo.startTime + 28800)]; //This should be time difference between current locale and GMT
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   
    
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [myValues setValue:[dateFormatter stringFromDate:fileDate] forKey:@"date"];
    
    
    //cell.sessionName.text = [NSString stringWithFormat:@"From %@", fileDetails.sessionName];
    cell.sessionName.text=[myValues objectForKey:@"sessionName"]    ;
    if (videoInfo.contentType == 2) {
       // cell.thumbnail.image = [UIImage imageWithContentsOfFile:fileDetails.thumbnailPath];
        [cell.thumbnail setImageWithURL:[NSURL fileURLWithPath:videoInfo.thumbnailPath] placeholderImage:[UIImage imageNamed:@"placeholder" ]];
    } else {
        [cell.thumbnail setImage:[UIImage imageNamed:@"Audio.png"]];
    }
  // cell.dateTaken.text = [dateFormatter stringFromDate:fileDate];
    cell.dateTaken.text=[myValues objectForKey:@"date"] ;
        
    return cell;
}
-(void)uploadSuccess:(UIButton*)sender{
    int entryNumber = sender.tag;
    videoInfo=[uploadArray objectAtIndex:entryNumber];
    [self uploadThisFile:videoInfo];
    
}
-(void)callAction:(UIButton *)sender
{
    //CustomBUtton.tags == filedetails uploadarray index:custombutton.tag
    int entryNumber = sender.tag;
    UploadObject *fileDetails = [uploadArray objectAtIndex:entryNumber];
    
    movieplayer=  [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:fileDetails.filePath]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = YES;
    [self.view addSubview:movieplayer.view];
    [self shouldAutorotate];
    [movieplayer setFullscreen:YES animated:YES];
        

    
}



- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
}

- (void)refreshDatabaseObjects
{
    //Initialise this entire thing by calling upon all the files that have not been uploaded
    dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = @"SELECT * FROM upload_tracker WHERE upload_status=0 OR upload_status=1 ORDER BY id DESC";
    uploadArray = nil;
    uploadArray = [NSMutableArray array];
    
    //Check if the file exists at that URL/path. You'll need a separate array for that
    NSMutableArray *dummyArray = [NSMutableArray arrayWithArray:[dbObject uploadCheck:strQuery]];
    for (UploadObject *uploadObject in dummyArray) {
       NSURL *fileCheck = [NSURL URLWithString:uploadObject.filePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileCheck path]]) {
            //If it exists, put it into uploadArray; this will be fed into the cells
            [uploadArray addObject:uploadObject];
        } else {
            //Update the database that the file is missing. Status changed to -1
            [self updateTrackerWithFileDetails:uploadObject toStatus:-1];
        }
    }
    
}

- (void)uploadThisFile:(UploadObject *)fileDetails
{
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // First, turn the file into an NSData object
    NSData *fileToUpload = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileDetails.filePath]];
    //Create a filename
    NSString *uploadFileName = [NSString string];
    NSString *uploadFileType = [NSString string];
    if (fileDetails.contentType == 1) {
        uploadFileName = [NSString stringWithFormat:@"%@", [fileDetails.filePath lastPathComponent]];
        uploadFileType = [NSString stringWithFormat:@"audio/%@", [fileDetails.filePath pathExtension]];
    } else if (fileDetails.contentType == 2) {
        uploadFileName = [NSString stringWithFormat:@"%@", [fileDetails.filePath lastPathComponent]];
        uploadFileType = [NSString stringWithFormat:@"video/%@", [fileDetails.filePath pathExtension]];
    } else {
        //File is corrupted. Need to do something with the file when returned this.
        [self updateTrackerWithFileDetails:fileDetails toStatus:-1];
    }
    
    //This part, it should ask the server whether the file had been uploaded already. Just upload the filename and check if it is already there
//    NSURL *uploadCheckURL = [NSURL URLWithString:GIGREPLAY_API_URL@"upload_yesno.php"];
//    ASIFormDataRequest *uploadRequest = [ASIFormDataRequest requestWithURL:uploadCheckURL];
//    [uploadRequest addPostValue:uploadFileName forKey:@"file_name"];
//    [uploadRequest addPostValue:[NSString stringWithFormat:@"%i", fileDetails.sessionid] forKey:@"session_id"];
//    [uploadRequest setRequestMethod:@"POST"];
//    [uploadRequest setDelegate:self];
//    [uploadRequest startSynchronous];
    
//    NSString *yesNoReply = [uploadRequest responseString];
//    NSLog(@"Upload Check Reply: %@", yesNoReply);
//    if ([yesNoReply isEqualToString:@"UPLOAD"]){
        //Commence upload of file
        NSURL *uploadURL = [NSURL URLWithString:GIGREPLAY_API_URL@"upload.php"];
    
    
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
    
        [request setData:fileToUpload withFileName:uploadFileName andContentType:uploadFileType forKey:@"uploadedfile"];
        //Now add the metadata
    
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.userid] forKey:@"user_id"];
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.sessionid] forKey:@"session_id"];
        [request addPostValue:[NSString stringWithFormat:@"%@", fileDetails.sessionName] forKey:@"session_name"];
        [request addPostValue:[NSString stringWithFormat:@"%f", fileDetails.startTime] forKey:@"start_time"];
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.contentType] forKey:@"content_type"];
    
        
                
        NSLog(@"%@", fileDetails.sessionName);
        NSLog(@"%@",uploadFileName);
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        [request setUploadProgressDelegate:self];
        [request setDidStartSelector:@selector(requestStarted:)];
        [request setDidFinishSelector:@selector(requestFinished:)];
        [request setDidFailSelector:@selector(requestFailed:)];
    
        progressIndicator.hidden=NO;
        [self progressIndicatorView:fileDetails];
    
        //This will allow the request to continue even upon entering the background
        [request setShouldContinueWhenAppEntersBackground:YES];
        [request startAsynchronous];
        //The following block will run the background
        
    
            // Use when fetching text data
            //If returnString is TRUE, then update the database
//            uploadProgress.hidden=NO;
//                if ([request.responseString isEqualToString:@"SUCCESS"])  {
//                UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload was successful." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//                
//                [alertUpload show];
//                
//                [self updateTrackerWithFileDetails:fileDetails toStatus:1];
//                [self refreshDatabaseObjects];
//                [uploadTable reloadData];
//                
//                [self removeFile:fileDetails];
//                
//            } else if([request.responseString isEqualToString:@"FAIL"]){
//                NSLog(@"%@", [request responseString]);
//                UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload is not successful. Please try again." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//                [alertUpload show];
//                
//                //If the uplaod was not successful, then have to update the upload tracker that the file has not been sent
//                [self updateTrackerWithFileDetails:fileDetails toStatus:0];
//                [self refreshDatabaseObjects];
//                [uploadTable reloadData];
//                
//            }
//            else{
//                NSLog(@"no response received!");
//            }
    
        
//        [weakRequest setFailedBlock:^{
//            NSError *error = [weakRequest error];
//            if (error) {
//                [self updateTrackerWithFileDetails:fileDetails toStatus:0];
//                [self refreshDatabaseObjects];
//                [uploadTable reloadData];
//            }
//        }];
    
        //[request setUploadProgressDelegate:self];
        //request.showAccurateProgress = YES;
    
        
        //NSLog(@"responseStatusCode %i",[request responseStatusCode]);
        //NSLog(@"responseString %@",[request responseString]);
//      if ([[weakRequest responseString] isEqualToString:@"COMPLETED"]){
//        //Update the database for that object to say that it has already been uploaded
//        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload was successful." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//        [alertUpload show];
//        
//        //Reset the progress bar
//        uploadProgress.hidden = YES;
//        uploadProgress.progress = 0.0;
//        
//        [self updateTrackerWithFileDetails:fileDetails toStatus:1];
//        [self refreshDatabaseObjects];
//        [uploadTable reloadData];
//        
//        [self removeFile:fileDetails];
//    } else {
//        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload is not successful. Please try again." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//        [alertUpload show];
//        
//        //If the uplaod was not successful, then have to update the upload tracker that the file has not been sent
//        [self updateTrackerWithFileDetails:fileDetails toStatus:0];
//        [self refreshDatabaseObjects];
//        [uploadTable reloadData];
//    }
    
}
-(void)fileHasBeenUploaded{
    NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET upload_status=%i WHERE id=%i", 1, videoInfo.entryNumber];
    while (![dbObject updateDatabase:strQuery]) {
        NSLog(@"Retrying...");
    }
        [self refreshDatabaseObjects];
        [uploadTable reloadData];
    
}

- (void)requestStarted:(ASIHTTPRequest *)theRequest {
        NSLog(@"request started ");

    
}

- (void)requestFinished:(ASIHTTPRequest *)theRequest{
    NSLog(@"response :%@",[theRequest responseString]);
    progressIndicator.hidden = YES;
    [aProgressView removeFromSuperview];
    NSLog(@"%d",theRequest.responseStatusCode);
    if([theRequest.responseString isEqualToString:@"Upload Success!"]){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[theRequest responseString]  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [self fileHasBeenUploaded];
        
    }
    else if([theRequest.responseString isEqualToString:@"Request Error"]){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[theRequest responseString]  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
        
    }else{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Unexpected Error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];

    }
}


- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    NSLog(@"response Failed new ::%@, Error:%@",[theRequest responseString],[theRequest error]);
    progressIndicator.hidden = YES;
    [aProgressView removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Video Upload to server failed, please try again"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
   
    
}





#pragma mark - Delete file methods

- (void)removeFile:(UploadObject *)fileDetails {
    
    NSURL *fileURL = [NSURL URLWithString:fileDetails.filePath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:fileURL error:&error];
    if (error) {
        NSLog(@"Error occured: %@", [error localizedDescription]);
    } else {
        NSLog(@"File is gone!!!");
    }
    
    if (fileDetails.contentType == 2) {
        NSURL *thumbnailURL = [NSURL URLWithString:fileDetails.thumbnailPath];
        NSError *thumbEerror;
        [fileManager removeItemAtURL:thumbnailURL error:&thumbEerror];
        if (error) {
            NSLog(@"Error occured: %@", [error localizedDescription]);
        } else {
            NSLog(@"Thumbnail is gone!!!");
        }
    }
}

- (void)updateTrackerWithFileDetails:(UploadObject *)fileDetails toStatus:(int)newStatus
{
    NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET upload_status=%i WHERE id=%i", newStatus, fileDetails.entryNumber];
    while (![dbObject updateDatabase:strQuery]) {
        NSLog(@"Retrying...");
    }
}

#pragma mark - Deleting files

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.uploadTable];
    
    NSIndexPath *indexPath = [self.uploadTable indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        //Do nothing
    } else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"WARNING"
                                                                  message:@"Are you sure you want to delete this file?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
            [deleteAlert show];
            
            //Set the current details
            detailsToDelete = [uploadArray objectAtIndex:indexPath.row];
        }
        //NSLog(@"long press on table view at row %d", indexPath.row);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //Reset the global parameter
        detailsToDelete = nil;
    } else if (buttonIndex == 1) {
        //Delete the file with those fileDetails
        [self removeFile:detailsToDelete];
        [self updateTrackerWithFileDetails:detailsToDelete toStatus:-1];
        [self refreshDatabaseObjects];
        [uploadTable reloadData];
    }
}


- (void)goToSettings
{
    SettingsViewController *set=[[SettingsViewController alloc] init];
    set.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:set animated:YES];
}
#pragma mark Upload Progress Tracking


- (void)setProgress:(float)newProgress {
    
    [progressIndicator setProgress:newProgress];
    NSString* formattedNumber = [NSString stringWithFormat:@"%.f %@", [progressIndicator progress]*100, @"%"];
    
    self.progressLabel.text = formattedNumber;
    self.progressLabel.textColor = [UIColor blackColor];
    [self.progressLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
    
}


#pragma UserDefined Method:::
-(void)progressIndicatorView:(UploadObject*)fileDetails{
    
    //self.Record_button.hidden =YES;
    UIImageView *gigReplayIcon=[[UIImageView alloc]initWithFrame:CGRectMake(85, 5, 30, 30)];
    [gigReplayIcon setImage:[UIImage animatedImageNamed:@"tab_generate_button_on_" duration:1.5]];
    
    CGRect UploadProgressFrame = CGRectMake(60, 150, 200,120);
    aProgressView = [[UIView alloc] initWithFrame:UploadProgressFrame];
    [aProgressView setBackgroundColor:[UIColor whiteColor]];
    [aProgressView.layer setCornerRadius:10.0f];
    [aProgressView.layer setBorderWidth:1.0f];
    [aProgressView.layer setBorderColor:[UIColor blackColor].CGColor];
    
    UILabel *progressTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 25, 150, 60)];
    progressTitleLabel.backgroundColor = [UIColor whiteColor];
    progressTitleLabel.numberOfLines=3;
    [progressTitleLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
    progressTitleLabel.text = [NSString stringWithFormat:@"Uploading Video: %@",fileDetails.sessionName];
    progressTitleLabel.textColor = [UIColor blackColor];
    
    self.progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 100, 70, 15)];
    [self.progressLabel setBackgroundColor:[UIColor whiteColor]];
    progressIndicator = [[UIProgressView alloc] init];
    progressIndicator.frame = CGRectMake(30,90,140,20);
    [aProgressView addSubview:progressTitleLabel];
    [aProgressView addSubview:gigReplayIcon];
    [aProgressView addSubview:self.progressLabel];
    [aProgressView addSubview:progressIndicator];
    [self.view addSubview:aProgressView];
    
}


#pragma UIProgressBar Method::
-(void)showProgress
{
    if (!aMBProgressHUD)
        aMBProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:aMBProgressHUD];
    aMBProgressHUD.labelText = @"Uploading Video";
    [aMBProgressHUD show:YES];
}

-(void)hideProgress
{
    [aMBProgressHUD hide:YES];
    [aMBProgressHUD removeFromSuperview];
    aMBProgressHUD=nil;
}


- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
