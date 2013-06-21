//
//  ReplaysViewController.m
//  gigReplay
//
//  Created by Leon Ng on 15/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "ReplaysViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ASIHTTPRequest.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "SDWebImageCompat.h"
#import "ReplaysDetailViewController.h"



@interface ReplaysViewController ()


@end

@implementation ReplaysViewController
@synthesize img1,text1,img2,tableviewVideos,movieplayer;

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
    [self obtainDataFromURL];
    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(leon) forControlEvents:UIControlEventValueChanged];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl=refresh;
    refresh.tintColor=[UIColor redColor];

    
    self.title=@"Replays";
    [self.view addSubview:img1];
    [img1 setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Applications/79421FB7-C6E4-4DF5-9229-E7F8583833EC/Documents/leon"]];
    

}
-(void)leon{
    NSLog(@"fetcheddatachagend");
    // connect to online database and retrieve new data when pulled to refresh
    [self performSelector:@selector(updatingTable) withObject:nil afterDelay:3];
    self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Updating.."];
    [self performSelector:@selector(obtainDataFromURL) withObject:nil afterDelay:3];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
}
-(void)updatingTable{
    
    [self.refreshControl endRefreshing];
}


-(void) fetchedData:(NSData*) data{
    
    
    videoArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
      [self.tableviewVideos reloadData];
    
    
}
-(void) obtainDataFromURL{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kGetURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}



-(void)viewDidAppear:(BOOL)animated{
    

    
  
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [videoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    static NSString* CellIdentifier = @"ReplaysCustomCell";
	
	
	ReplaysCustomCell *cell = (ReplaysCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
	if (cell == nil)
	{
		
		NSArray *topLevelObjects;
		
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReplaysCustomCell" owner:self options:nil];
		for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (ReplaysCustomCell *) currentObject;
				break;
			}
		}
	}
   
        
            
    NSMutableDictionary *info=[videoArray objectAtIndex:indexPath.row];
    cell.media_url.text=[info objectForKey:@"media_url"];
    cell.thumb_url .text=[info objectForKey:@"thumb_1_url"];
//    dispatch_async(kBgQueue, ^{
         videoImage=[info objectForKey:@"thumb_1_url"];
        // UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoImage]]];
//       
//        
//        dispatch_async(dispatch_get_main_queue(),^{
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//            cell.imageView.image=image;
//            
//          });
//    });
//    
//    cell.imageView.image =[UIImage imageNamed:@"placeholder.png"];

    [cell.imageView setImageWithURL:[NSURL URLWithString:videoImage]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //place moive player here to play
    //place detailviewcontroller to show more details of file
    NSMutableDictionary *info = [videoArray objectAtIndex:indexPath.row];
     url=[NSURL URLWithString:[info objectForKey:@"media_url"]];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self playMovie];
    
    //new detailviewcontroller for social network integration
    
    ReplaysDetailViewController *replaysDetailVC=[[ReplaysDetailViewController alloc]init];
    [replaysDetailVC setVideoURL:url];
    [self.navigationController pushViewController:replaysDetailVC animated:YES];
    
   
    }

-(void)playMovie{
    
    movieplayer=  [[MPMoviePlayerController alloc]
                   initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
   movieplayer.controlStyle = MPMovieControlStyleFullscreen;
    movieplayer.shouldAutoplay = YES;
   [self.view addSubview:movieplayer.view];

   [movieplayer setFullscreen:YES animated:YES];
    
    

}
-(BOOL)shouldAutorotate{
    return  YES;
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    
    
    [self playMovie];
    
    
    
}
@end
