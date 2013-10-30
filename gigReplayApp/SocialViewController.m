//
//  InfoViewController.m
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "SocialViewController.h"
#import "HomeViewCustomCell.h"
#import "HomeDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface SocialViewController ()

@end

@implementation SocialViewController
@synthesize liked,videoImage;

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
    tapped=YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.moviePlayerView addGestureRecognizer: singleTap];
    
    
    
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) handleSingleTap:(UITapGestureRecognizer *)gr {
        if(tapped){
        
        [avPlayer pause];
        tapped=NO;
    }else{
        [avPlayer play];
        tapped=YES;
    }
    
}

-(void) fetchFeaturedVideosData:(NSData*) data{
    
    
    videoArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
   // [self.tableViewRequests reloadData];
    
    
}
-(void) obtainDataFromURL{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:getURL2];
        [self performSelectorOnMainThread:@selector(fetchFeaturedVideosData:)
                               withObject:data waitUntilDone:YES];
    });
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
    cell.username.text=@"GigReplay Presents..";
    cell.profilePic.image=[UIImage imageNamed:@"new_logo.png"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSMutableDictionary *info = [videoArray objectAtIndex:indexPath.row];
    NSString *media_master_id=[info objectForKey:@"master_id"];
    url=[NSURL URLWithString:[info objectForKey:@"media_url"]];
    HomeDetailViewController *homeDetailVC=[[HomeDetailViewController alloc]init];
    [homeDetailVC setVideoURL:url];
    [homeDetailVC setMedia_id:media_master_id];
    [self presentViewController:homeDetailVC animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [videoArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 177;
}


- (IBAction)playButton:(id)sender {
    avAsset = [AVAsset assetWithURL:[NSURL URLWithString:@"http://www.lipsync.sg/api/test/output.mp4"]];
    avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
    [avPlayerLayer setFrame:self.view.frame];
    [self.view addSubview:self.moviePlayerView];
    [self.moviePlayerView.layer addSublayer:avPlayerLayer];
    [avPlayerLayer setFrame:CGRectMake(0, 0, 310, 320)];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [avPlayer seekToTime:kCMTimeZero];
    [avPlayer play];
   

}
- (IBAction)likeButton:(id)sender {
    [liked setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
}

- (IBAction)commentButton:(id)sender {
}
@end
