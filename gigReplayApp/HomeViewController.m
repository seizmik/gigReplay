//
//  HomeViewController.m
//  gigReplay
//
//  Created by Leon Ng on 29/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "CaptureViewController.h"
#import "Reachability.h"


@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize tableViewRequests,videoImage,image1,image2,image3,movieplayer,videoURL,refreshButton,apiWrapperObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] init];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
    //If there's no internet connection, don't load up, otherwise, the app will crash.
    if (netStatus == NotReachable) {
        //Load up a button that will allow to relaod the page
    } else {
        [self obtainDataFromURL];
        [self.tableViewRequests reloadData];
        
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    apiWrapperObject=[[ApiObject alloc]init];
    [self SyncUserDetails];
    NSLog(@"%d get from web current user id",appDelegateObject.CurrentUserID);
}

-(void) fetchFeaturedVideosData:(NSData*) data{
    
    
    videoArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    [self.tableViewRequests reloadData];
    
    
}
-(void) obtainDataFromURL{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:getURL2];
        [self performSelectorOnMainThread:@selector(fetchFeaturedVideosData:)
                               withObject:data waitUntilDone:YES];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
            static NSString* CellIdentifier = @"HomeViewCustomCell";
        
        //custom cell initilisation
        HomeViewCustomCell *cell = (HomeViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            NSArray *topLevelObjects;
            
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeViewCustomCell" owner:self options:nil];
            for (id currentObject in topLevelObjects)
            {
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (HomeViewCustomCell *) currentObject;
                    break;
                }
            }
        }

        NSDictionary *info=[videoArray objectAtIndex:indexPath.row];
        videoImage=[info objectForKey:@"default_thumb"];
        [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.videoTitle.text=[info objectForKey:@"title"];
    
    return cell;
    }
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%d",indexPath.row);
        NSMutableDictionary *info = [videoArray objectAtIndex:indexPath.row];
        NSString *videoTitle=[info objectForKey:@"title"];
        NSString *media_master_id=[info objectForKey:@"master_id"];
        url=[NSURL URLWithString:[info objectForKey:@"media_hls"]];
        HomeDetailViewController *homeDetailVC=[[HomeDetailViewController alloc]init];
        [homeDetailVC setVideoURL:url];
        [homeDetailVC setObtainFb_id:[info objectForKey:@"fb_user_id"]];
        [homeDetailVC setVideoUserInfo:[info objectForKey:@"user_name"]];
        [homeDetailVC setMedia_id:media_master_id];
        videoImage=[info objectForKey:@"default_thumb"];
        [homeDetailVC setVideoTitle:videoTitle];
        [homeDetailVC setVideoImage:videoImage];
        [homeDetailVC setVideoDate:[info objectForKey:@"date_modified"]];
        [self presentViewController:homeDetailVC animated:YES completion:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return [videoArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.interfaceOrientation==UIDeviceOrientationPortrait){
        return 180;
    }else{
        return 250;
    }
    
   
}


-(void)callAction:(UIButton *)sender
{
    
    
    //CustomBUtton.tags == filedetails uploadarray index:custombutton.tag
    int entryNumber = sender.tag;
    NSDictionary *this = [[NSDictionary alloc] init];
    this = [videoArray objectAtIndex:entryNumber];
    movieplayer=  [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:[this objectForKey:@"media_hls"]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = YES;
    
    [movieplayer prepareToPlay];
    [movieplayer play];

}

//-------------------------------------------MOVIEPLAYER------------------------------------------//
-(void)playMovie{
    
    movieplayer=  [[MPMoviePlayerController alloc]
                   initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = NO;
    HomeViewCustomCell *customCell=[[HomeViewCustomCell alloc]init];
    [self.view addSubview:customCell.videoImageView];
    [customCell.videoImageView addSubview:movieplayer.view];
    [movieplayer.view setFrame:customCell.videoImageView.bounds];
    
    
    
    
    
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

/////////////////////////////////////////////// Sync up with online DB for userid to parse in ///////////////////////////////


-(NSMutableArray*)ReadFromDataBase:(NSString*)TableName
{
    NSString *sqlQuery=[NSString stringWithFormat:@"Select * from %@",TableName];
    NSMutableArray *UserDetails;
    if ([TableName isEqualToString:@"Users"])
    {
        UserDetails = [appDelegateObject.databaseObject readFromDatabaseUsers:sqlQuery];
        
        
    }
    else if ([TableName isEqualToString:@"Session_Details"])
    {
        UserDetails = [appDelegateObject.databaseObject readFromDatabaseSessionDetails:sqlQuery];
        
    }
    
    
    return UserDetails;
}

-(void)SyncUserDetails
{
    
    
    NSMutableArray *UserDetails= [self ReadFromDataBase:@"Users"];
    NSArray *details=[UserDetails objectAtIndex:0];
    appDelegateObject.CurrentUserName=[details objectAtIndex:0];
    [apiWrapperObject postUserDetails:[details objectAtIndex:2]  userEmail:[details objectAtIndex:4] userName:[details objectAtIndex:0] facebookToken:[details objectAtIndex:3] APIIdentifier:API_IDENTIFIER_USER_REG];
}




@end
