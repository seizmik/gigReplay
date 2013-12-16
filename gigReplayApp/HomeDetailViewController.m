//
//  HomeDetailViewController.m
//  gigReplay
//
//  Created by Leon Ng on 5/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "HomeDetailViewCustomCell.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define VIDEO_INFO_UIVIEW_HEIGHT 225.0f
#define VIDEOPLAYER_UIVIEW_HEIGHT 225.0f
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)


@interface HomeDetailViewController ()

@end

@implementation HomeDetailViewController
@synthesize indVideoTitle,loadingView,loadingImage;

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
    [self obtainLike];
    [self obtainDataFromURL];
    [self.moviePlayer prepareToPlay];
    [self playMovie];// Do any additional setup after loading the view from its nib.
    processLabels=YES;
    [self.loadingImage startAnimating];
   }
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"LEONISM %@",like)   ;
    if([like isEqualToString:@"1"]){
    
        [self.likeButtonImage setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
    }
    

  


    CGFloat UIScreenBottom=self.view.bounds.size.height-VIDEOPLAYER_UIVIEW_HEIGHT;
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 250, 320, UIScreenBottom)];
    scrollView.contentSize=CGSizeMake(320.0,(self.commentTableVIew.contentSize.height+VIDEO_INFO_UIVIEW_HEIGHT));
    scrollView.bounces=NO;
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.commentUIView];
    [scrollView addSubview:self.commentTableVIew];
    [self.commentTableVIew setFrame:CGRectMake(0, 180, 320, self.commentTableVIew.contentSize.height)];
//    NSLog(@"scrollview contentsize %f",scrollView.contentSize.height);
//    NSLog(@"%f",self.commentTableVIew.contentSize.height);
//    NSLog(@"%f",self.commentTableVIew.contentSize.width);
    if(processLabels){
        self.loadingView.hidden=NO;
        indVideoTitle.text=self.videoTitle;
        self.indDate.text=self.videoDate;
        self.videoUser.text=self.videoUserInfo;
        //obtain fb_user_id from homeviewcontroller
        fb_user_id=self.obtainFb_id;
        NSString *profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=77&height=66", fb_user_id];
        [self.fb_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicURL]]]];
        processLabels=NO;
    }
    else{
        self.loadingView.hidden=YES;
    }
}
-(void) fetchedData:(NSData*) data{
    
    
    self.commentArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    [self.commentTableVIew reloadData];
    
    NSLog(@"THIS IS IN COMMENT VIEW %@",self.commentArray);
}

-(void) obtainDataFromURL{
    
   // NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lipsync.sg/api/commentAPI.php?mediaid=165"]];
    
   // [self fetchedData:data];
    dispatch_async(kBgQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString  stringWithFormat:@"http://www.lipsync.sg/api/commentAPI.php?mediaid=%@",self.media_id]]];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });

}
-(void)obtainLike{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString  stringWithFormat:@"http://www.lipsync.sg/api/get_like.php?mediaid=%@",self.media_id]]];
        [self performSelectorOnMainThread:@selector(fetchedLikeData:)
                               withObject:data waitUntilDone:YES];
        
    });

    
}
-(void) fetchedLikeData:(NSData*) data{
    
    
    self.likeArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if([self.likeArray count]==0){
        return ;
        
    }else{
        
    
    NSDictionary *info=[self.likeArray objectAtIndex:0];
    like=[info objectForKey:@"individual_like"];
    
    NSLog(@"THIS IS IN Like Array %@",self.likeArray);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)playMovie{
    
    self.moviePlayer=  [[MPMoviePlayerController alloc]
                   initWithContentURL:self.videoURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = NO;
    [self.view addSubview:self.moviePlayerView];
    [self.moviePlayerView addSubview:self.moviePlayer.view];
    [self.moviePlayer.view setFrame:self.moviePlayerView.bounds];
    
    [self.moviePlayer setFullscreen:YES animated:YES];
    
    
    
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
        [player setCurrentPlaybackTime:0];
    }
}
- (IBAction)backToHome:(id)sender {
    [self.moviePlayer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	        return [self.commentArray count];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    self.array = [NSMutableArray array];
    //iterate through each dictionary to extract key-value pairs
    for (NSDictionary *dict in self.commentArray) {
        [self.array addObject:[dict objectForKey:@"comment"]];
    }
    NSString *text = [self.array objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping
                   ];
    
    CGFloat height = MAX(size.height, 44.0f);
    self.newHeight=height+(CELL_CONTENT_MARGIN * 2)+40;
//    NSLog(@"the oringinal height without +40 is %.2f",height+(CELL_CONTENT_MARGIN * 2));
//    NSLog(@"self.newheight is %.2f",self.newHeight);
    return self.newHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeDetailViewCustomCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[HomeDetailViewCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.userComment = [[UILabel alloc] initWithFrame:CGRectZero];
        cell.userName=[[UILabel alloc]initWithFrame:CGRectZero];
        [cell.userComment setLineBreakMode:NSLineBreakByWordWrapping];
        
        [cell.userComment setNumberOfLines:0];
        [cell.userComment setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [[cell contentView] addSubview:cell.userName];
        [[cell contentView] addSubview:cell.userComment];
        
    }
    
        NSDictionary *info=[self.commentArray objectAtIndex:indexPath.row];
    
    cell.userName.text=[info objectForKey:@"user_name"];
    
    NSString *text = [self.array objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    [cell.userComment setText:text];
    [cell.userName setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN,  CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 30)];
    [cell.userComment setFrame:CGRectMake(CELL_CONTENT_MARGIN, 40, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    
    return cell;
    
}

- (IBAction)commentButton:(id)sender {
        [self.view addSubview:self.commentPopOver];
    [self.commentPopOver setFrame:CGRectMake(0, 44, 320, 180)];
    [self.theComments becomeFirstResponder];
}

- (IBAction)commentPost:(id)sender {
    if([self.theComments.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Empty Comment Field" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show ];
    }
    else{
    NSURL *url = [NSURL URLWithString:@"http://www.lipsync.sg/api/SocialMediaAPI.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:appDelegateObject.CurrentUserName forKey:@"user_name"];
    [request setPostValue:self.theComments.text forKey:@"comments"];
    [request setPostValue:self.media_id forKey:@"media_id"];
    //NSString *user_id=[NSString stringWithFormat: @"%d", appDelegateObject.CurrentUserID];
    [request setPostValue:fb_user_id forKey:@"user_id"];
    [request setDidFinishSelector:@selector(requestFinished:)];
    
//    NSLog(@"currentusername %@",appDelegateObject.CurrentUserName);
//    NSLog(@"%@",self.theComments.text);
//    NSLog(@"%d",self.appDelegateObject.CurrentUserID);
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    
    
    //Remove subview from superview after post is completed
    [self.commentPopOver removeFromSuperview];
    }
    
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    return   NSLog(@"request success");
   
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        [self.loadingView setNeedsDisplay];
        [self obtainDataFromURL];
        NSLog(@"%@",self.commentArray);
        
        

    });
    
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    return  NSLog(@"request failed")    ;
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    
    
}
- (IBAction)commentCancel:(id)sender {
    [self.commentPopOver removeFromSuperview];
}

- (IBAction)shareButton:(id)sender {
    UIImage *anImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.videoImage]]];
    NSString *videoLink=[NSString stringWithFormat:@"%@ -- ",self.videoURL];
    NSArray *Items   = [NSArray arrayWithObjects:
                        videoLink,
                        anImage, nil];

    
    
    UIActivityViewController *acitivityController=[[UIActivityViewController alloc]initWithActivityItems:Items applicationActivities:nil];
    acitivityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypePrint,
                                        UIActivityTypeAirDrop,
                                        nil];

    [self presentViewController:acitivityController animated:YES completion:nil];
}

- (IBAction)likeButton:(id)sender {
    int liked=1;
    [self.likeButtonImage setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
    NSURL *url = [NSURL URLWithString:@"http://www.lipsync.sg/api/SocialMediaAPI.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:appDelegateObject.CurrentUserName forKey:@"user_name"];
    [request setPostValue:self.media_id forKey:@"media_id"];
    //NSString *user_id=[NSString stringWithFormat: @"%d", appDelegateObject.CurrentUserID];
    [request setPostValue:fb_user_id forKey:@"user_id"];
    [request setPostValue:[NSString stringWithFormat:@"%d",liked] forKey:@"ind_like"];
    
    //    NSLog(@"currentusername %@",appDelegateObject.CurrentUserName);
    //    NSLog(@"%@",self.theComments.text);
    //    NSLog(@"%d",self.appDelegateObject.CurrentUserID);
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];

    
}
@end
