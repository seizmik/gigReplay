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
#import "UploadTabDetailViewController.h"

@interface UploadTab ()

@end

@implementation UploadTab
@synthesize uploadTable, uploadArray, dbObject,uploadProgress;
@synthesize detailsToDelete,movieplayer,uploadVideoFilePath;

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
    self.title = @"Upload";
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.uploadTable addGestureRecognizer:lpgr];
    [self loadSettingsButton];
        
}


- (void)viewDidAppear:(BOOL)animated {
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
    return [uploadArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UploadObject *fileDetails = [[UploadObject alloc] init];
    fileDetails = [uploadArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Session Entry: %d_%d", fileDetails.sessionid, fileDetails.entryNumber];
    */
    
    static NSString *UploadTableIdentifier = @"UploadTableCell";
    UploadCell *cell = (UploadCell *)[tableView dequeueReusableCellWithIdentifier:UploadTableIdentifier];
    
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
    
    UploadObject *fileDetails = [[UploadObject alloc] init];
  
    fileDetails = [uploadArray objectAtIndex:indexPath.row];
    
    cell.customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.customButton setImage:[UIImage imageNamed:@"playicon.png"] forState:UIControlStateNormal];
    [cell.customButton setFrame:CGRectMake(260, 5, 50, 50)];
    [cell.contentView addSubview:cell.customButton];
    [cell.customButton setTag:indexPath.row];
    [cell.customButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDate *fileDate = [NSDate dateWithTimeIntervalSince1970:(fileDetails.startTime + 28800)]; //This should be time difference between current locale and GMT
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //placed a custom button action for playing videos
        
   
    
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    
    cell.sessionName.text = [NSString stringWithFormat:@"From %@", fileDetails.sessionName];
    if (fileDetails.contentType == 2) {
        cell.thumbnail.image = [UIImage imageWithContentsOfFile:fileDetails.thumbnailPath];
    } else {
        cell.thumbnail.image = [UIImage imageNamed:@"audio_thumbnail.png"];
    }
    cell.dateTaken.text = [dateFormatter stringFromDate:fileDate];
    
    
    return cell;
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



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
//      UploadTabDetailViewController *detailViewController = [[UploadTabDetailViewController alloc] initWithNibName:@"UploadTabDetailViewController" bundle:[NSBundle mainBundle]];
     // ...
     // Pass the selected object to the new view controller.
    UploadObject *fileDetails = [[UploadObject alloc] init];
    fileDetails = [uploadArray objectAtIndex:indexPath.row];
    
//    [detailViewController setVideoURL:fileDetails.thumbnailPath];
//    [detailViewController setVideoPath:fileDetails.filePath];
//     [self.navigationController pushViewController:detailViewController animated:YES];
    
    
    //Call the upload object to get the fileDetails
    
//    
//    //Remove the data from the table and reload the data
//    //Status 9 means uploading. I've set this in case the app was closed halfway. When the app loads up again, if checks if there were any that were still uploading when the app crashed, and will change upload status back to 0
    [self updateTrackerWithFileDetails:fileDetails toStatus:9];
    [self refreshDatabaseObjects];
    [tableView reloadData];
    
    [self uploadThisFile:fileDetails];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)refreshDatabaseObjects
{
    //Initialise this entire thing by calling upon all the files that have not been uploaded
    dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = @"SELECT * FROM upload_tracker WHERE upload_status=0";
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
    NSURL *uploadCheckURL = [NSURL URLWithString:GIGREPLAY_API_URL@"upload_yesno.php"];
    ASIFormDataRequest *uploadRequest = [ASIFormDataRequest requestWithURL:uploadCheckURL];
    [uploadRequest addPostValue:uploadFileName forKey:@"file_name"];
    [uploadRequest addPostValue:[NSString stringWithFormat:@"%i", fileDetails.sessionid] forKey:@"session_id"];
    [uploadRequest setRequestMethod:@"POST"];
    [uploadRequest setDelegate:self];
    [uploadRequest startSynchronous];
    
    NSString *yesNoReply = [uploadRequest responseString];
    NSLog(@"Upload Check Reply: %@", yesNoReply);
    if ([yesNoReply isEqualToString:@"UPLOAD"]) {
        //Commence upload of file
        NSURL *uploadURL = [NSURL URLWithString:GIGREPLAY_API_URL@"upload_one.php"];
        
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
        [request setData:fileToUpload withFileName:uploadFileName andContentType:uploadFileType forKey:@"uploadedfile"];
        //Now add the metadata
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.userid] forKey:@"user_id"];
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.sessionid] forKey:@"session_id"];
        [request addPostValue:[NSString stringWithFormat:@"%@", fileDetails.sessionName] forKey:@"session_name"];
        [request addPostValue:[NSString stringWithFormat:@"%f", fileDetails.startTime] forKey:@"start_time"];
        [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.contentType] forKey:@"content_type"];
        //upload indicator progress bar
        uploadProgress.hidden=NO;
        [request setUploadProgressDelegate:uploadProgress];
                
        NSLog(@"%@", fileDetails.sessionName);
        
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        
        //This will allow the request to continue even upon entering the background
        [request setShouldContinueWhenAppEntersBackground:YES];
        
        //The following block will run the background
        
        [request setCompletionBlock:^{
            // Use when fetching text data
            //If returnString is TRUE, then update the database
            uploadProgress.hidden=YES;
            if ([[request responseString] isEqualToString:@"SUCCESS"]) {
                UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload was successful." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                
                [alertUpload show];
                
                [self updateTrackerWithFileDetails:fileDetails toStatus:1];
                [self refreshDatabaseObjects];
                [uploadTable reloadData];
                
                [self removeFile:fileDetails];
                
            } else {
                NSLog(@"%@", [request responseString]);
                UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload is not successful. Please try again." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alertUpload show];
                
                //If the uplaod was not successful, then have to update the upload tracker that the file has not been sent
                [self updateTrackerWithFileDetails:fileDetails toStatus:0];
                [self refreshDatabaseObjects];
                [uploadTable reloadData];
                
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            if (error) {
                [self updateTrackerWithFileDetails:fileDetails toStatus:0];
                [self refreshDatabaseObjects];
                [uploadTable reloadData];
            }
        }];
        
        //[request setUploadProgressDelegate:self];
        //request.showAccurateProgress = YES;
        [request startAsynchronous];
        
        //NSLog(@"responseStatusCode %i",[request responseStatusCode]);
        //NSLog(@"responseString %@",[request responseString]);
    } else if ([[uploadRequest responseString] isEqualToString:@"COMPLETED"]){
        //Update the database for that object to say that it has already been uploaded
        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload was successful." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertUpload show];
        
        [self updateTrackerWithFileDetails:fileDetails toStatus:1];
        [self refreshDatabaseObjects];
        [uploadTable reloadData];
        
        [self removeFile:fileDetails];
    } else {
        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload is not successful. Please try again." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertUpload show];
        
        //If the uplaod was not successful, then have to update the upload tracker that the file has not been sent
        [self updateTrackerWithFileDetails:fileDetails toStatus:0];
        [self refreshDatabaseObjects];
        [uploadTable reloadData];
    }
    
}




#pragma mark - Delete file methods

- (void)removeFile:(UploadObject *)fileDetails {
    //NSLog(@"%@", fileDetails.filePath);
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

@end
