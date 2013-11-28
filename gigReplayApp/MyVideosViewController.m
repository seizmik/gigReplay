//
//  MyVideosViewController.m
//  gigReplay
//
//  Created by Leon Ng on 14/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "MyVideosViewController.h"
#import "MyVideosCustomCell.h"
#import "HomeDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"


@interface MyVideosViewController ()

@end

@implementation MyVideosViewController
@synthesize myVideosTableView,videoImage;

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
}

-(void)viewDidAppear:(BOOL)animated{
    
    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] init];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
    //If no internet access, do not load.
    if (netStatus == NotReachable) {
        //Load the button to retry
    } else {
        [self obtainDataFromURL];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) fetchMyVideosData:(NSData*) data{
    
    
    myVideosArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    [self.myVideosTableView reloadData];
    
    
}
-(void) obtainDataFromURL{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lipsync.sg/api/myVideos.php"]]];
        //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lipsync.sg/api/myVideos.php?uid=%d",appDelegateObject.CurrentUserID]]];
        [self performSelectorOnMainThread:@selector(fetchMyVideosData:)
                               withObject:data waitUntilDone:YES];
    });
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString* CellIdentifier = @"HomeViewCustomCell";
    
    //custom cell initilisation
    MyVideosCustomCell *cell = (MyVideosCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyVideosCustomCell" owner:self options:nil];
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (MyVideosCustomCell *) currentObject;
                break;
            }
        }
    }
    
    NSDictionary *info=[myVideosArray objectAtIndex:indexPath.row];
    videoImage=[info objectForKey:@"default_thumb"];
    [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.userName.text=[info objectForKey:@"user_name"];
    NSString *fb_user_id=[info objectForKey:@"fb_user_id"];
    NSString *profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=77&height=66", fb_user_id];
    [cell.fbProfileImageView setImageWithURL:[NSURL URLWithString:profilePicURL]];
    cell.videoDesc.text=[info objectForKey:@"title"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSMutableDictionary *info = [myVideosArray objectAtIndex:indexPath.row];
    NSString *media_master_id=[info objectForKey:@"master_id"];
    url=[NSURL URLWithString:[info objectForKey:@"media_url_lo"]];
    HomeDetailViewController *homeDetailVC=[[HomeDetailViewController alloc]init];
    [homeDetailVC setVideoURL:url];
    [homeDetailVC setMedia_id:media_master_id];
    [homeDetailVC setObtainFb_id:[info objectForKey:@"fb_user_id"]];
    [homeDetailVC setVideoUserInfo:[info objectForKey:@"user_name"]];
    [homeDetailVC setVideoTitle:[info objectForKey:@"title"]];
    [homeDetailVC setVideoDate:[info objectForKey:@"date_modified"]];
    
    homeDetailVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:homeDetailVC animated:YES completion:nil];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [myVideosArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 220;
}



@end
