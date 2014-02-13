//
//  InfoViewController.m
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "SocialViewController.h"
#import "SocialCustomCell.h"
#import "UIImageView+WebCache.h"

@interface SocialViewController ()

@end

@implementation SocialViewController
@synthesize videoImage,movieplayer;

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
    [self obtainDataFromURL];
   // [self.moviePlayerView addGestureRecognizer: singleTap];
    
    
    
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
    
    [self.tableView reloadData];
    
    
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
    static NSString* CellIdentifier = @"SocialCustomCell";
    
    //custom cell initilisation
    SocialCustomCell *cell = (SocialCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SocialCustomCell" owner:self options:nil];
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SocialCustomCell *) currentObject;
                break;
            }
        }
       
    }
    
    NSDictionary *info=[videoArray objectAtIndex:indexPath.row];
    videoImage=[info objectForKey:@"default_thumb"];
    [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.username.text=@"GigReplay Presents..";
    cell.profilePicImageView.image=[UIImage imageNamed:@"new_logo.png"];
   
    [cell.playButton setTag:indexPath.row];
    [cell.playButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
   
            return cell;
}
-(void)callAction:(UIButton *)sender
{
    int entryNumber = sender.tag;
    NSDictionary *info=[videoArray objectAtIndex:entryNumber];
    url=[NSURL URLWithString:[info objectForKey:@"media_url_lo"]];
    movieplayer=  [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:@"http://www.lipsync.sg/uploads/master/301-Maricelle_Sunday_Morning_II/19-Leon_Ng/playlist.m3u8"]];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = YES;
    
    
    [self.view addSubview:movieplayer.view];
    [movieplayer play];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    

    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [videoArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 600;
}


- (IBAction)playButton:(id)sender {
    
    avAsset = [AVAsset assetWithURL:[NSURL URLWithString:@"http://lipsync.sg/api/test/output.m3u8"]];
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
    //[liked setImage:[UIImage imageNamed:@"like_on.png"] forState:UIControlStateNormal];
}

- (IBAction)commentButton:(id)sender {
}
@end
