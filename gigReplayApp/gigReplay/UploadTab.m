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

@interface UploadTab ()

@end

@implementation UploadTab
@synthesize uploadTable;
@synthesize uploadArray;
@synthesize dbObject;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UploadObject *fileDetails = [[UploadObject alloc] init];
    fileDetails = [uploadArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Session Entry: %d_%d", fileDetails.sessionid, fileDetails.entryNumber];
    
    return cell;
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //Call the upload object to get the fileDetails
    UploadObject *fileDetails = [[UploadObject alloc] init];
    fileDetails = [uploadArray objectAtIndex:indexPath.row];
    NSString *returnString = [NSString string];
    
    returnString = [self uploadThisFile:fileDetails];
    
    NSLog(@"%@", returnString);
    //NSLog(@"%f", fileDetails.startTime);
    
    //If returnString is TRUE, then update the database
    if ([returnString isEqual: @"SUCCESS"]) {
        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload was successful." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertUpload show];
        
        NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET upload_status=1 WHERE id=%i", fileDetails.entryNumber];
        while (![dbObject updateDatabase:strQuery]) {
            NSLog(@"Retrying...");
        }
        
        //Then, refresh the table
        [self refreshDatabaseObjects];
        [tableView reloadData];
        
        //Now delete the file from the folder
        //First, check from the database the file path
        [self removeFile:fileDetails];
        
    } else {
        UIAlertView *alertUpload = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload is not successful. Please try again." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertUpload show];
    }
    
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)refreshDatabaseObjects
{
    //Initialise this entire thing by calling upon all the files that have not been uploaded
    dbObject = [[ConnectToDatabase alloc] initDB];
    NSString *strQuery = @"SELECT * FROM upload_tracker WHERE upload_status=0";
    uploadArray = [NSMutableArray array];
    uploadArray = [dbObject uploadCheck:strQuery];
    
    /*We'll exclude this until we can get it right
    //Check if the file exists at that URL/path. You'll need a separate array for that
    NSMutableArray *dummyArray = [NSMutableArray arrayWithArray:[dbObject uploadCheck:strQuery]];
    for (UploadObject *uploadObject in dummyArray) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:uploadObject.filePath]) {
            //If it exists, put it into uploadArray; this will be fed into the cells
            [uploadArray addObject:uploadObject];
        } else {
            //Update the database that the file is missing. Status changed to -1
            NSString *strQuery = [NSString stringWithFormat:@"UPDATE upload_tracker SET upload_status=-1 WHERE id=%i", uploadObject.entryNumber];
            while (![dbObject updateDatabase:strQuery]) {
                NSLog(@"Retrying...");
            }
        }
    }
    */
}

- (NSString *)uploadThisFile:(UploadObject *)fileDetails
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // First, turn the file into an NSData object
    NSData *fileToUpload = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileDetails.filePath]];
    //Create a filename
    NSString *uploadFileName = [NSString string];
    NSString *uploadFileType = [NSString string];
    if (fileDetails.contentType == 1) {
        uploadFileName = [NSString stringWithFormat:@"%i_%i_%i.caf", fileDetails.sessionid, fileDetails.userid, fileDetails.entryNumber];
        uploadFileType = @"audio/caf";
    } else if (fileDetails.contentType == 2) {
        uploadFileName = [NSString stringWithFormat:@"%i_%i_%i.mp4", fileDetails.sessionid, fileDetails.userid, fileDetails.entryNumber];
        uploadFileType = @"video/mp4";
    } else {
        //File is corrupted. Need to do something with the file when returned this.
        return 0;
    }
    
    NSURL *uploadURL = [NSURL URLWithString:@"http://www.lipsync.sg/api/upload_file.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
    [request setData:fileToUpload withFileName:uploadFileName andContentType:uploadFileType forKey:@"uploadedfile"];
    //Now add the metadata
    [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.userid] forKey:@"user_id"];
    [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.sessionid] forKey:@"session_id"];
    [request addPostValue:[NSString stringWithFormat:@"%f", fileDetails.startTime] forKey:@"start_time"];
    [request addPostValue:[NSString stringWithFormat:@"%i", fileDetails.contentType] forKey:@"content_type"];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    //This will allow the request to continue even upon entering the background
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    //UIProgressView *myProgressIndicator = [[UIProgressView alloc] init];
    //[request setUploadProgressDelegate:myProgressIndicator];
    [request startSynchronous];
    
    //NSLog(@"responseStatusCode %i",[request responseStatusCode]);
    //NSLog(@"responseString %@",[request responseString]);
    //NSLog(@"Value: %f",[myProgressIndicator progress]);
    
    if (request.responseString == 0) {
        return nil;
    } else {
        return [request responseString];
    }
}

- (void)removeFile:(UploadObject *)fileDetails {
    NSLog(@"%@", fileDetails.filePath);
    NSURL *fileURL = [NSURL URLWithString:fileDetails.filePath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:fileURL error:&error];
    if (error) {
        NSLog(@"Error occured: %@", [error localizedDescription]);
    } else {
        NSLog(@"It's gone!!!");
    }
}

@end
