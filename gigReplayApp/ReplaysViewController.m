//
//  ReplaysViewController.m
//  gigReplay
//
//  Created by Leon Ng on 15/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "ReplaysViewController.h"
#import <MediaPlayer/MediaPlayer.h>


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
    self.title=@"Replays";
    [self.view addSubview:img1];
    [img1 setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Applications/79421FB7-C6E4-4DF5-9229-E7F8583833EC/Documents/leon"]];
    
 

  
}

-(void)viewDidAppear:(BOOL)animated{
    SQLdatabase *sql = [[SQLdatabase alloc] initDatabase];
    NSString *strQuery = @"SELECT * FROM Video_Details ORDER BY id DESC";
    videoDetails = [sql readFromDatabaseVideos:strQuery];
    NSLog(@"%@",videoDetails);
    //NSArray *firstItem=[videoDetails objectAtIndex:3];
    [self.view addSubview:img2];
    //[img2 setImage:[UIImage imageWithContentsOfFile:[firstItem objectAtIndex:0]]];
     NSLog(@"%d",[videoDetails count]);
    [tableviewVideos reloadData];
    NSArray *items=[NSArray array];
    for (items in videoDetails){
    details=[[NSDictionary alloc]initWithObjectsAndKeys:[items objectAtIndex:0],@"image",
                                                                    [items objectAtIndex:1],@"video",
                                                                    [items objectAtIndex:2],@"name",
                                                                                                nil];
        NSLog(@"%@",details ) ;
    }
   
     
    
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [videoDetails count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    static NSString* CellIdentifier = @"CustomCell";
	
	
	ReplaysCustomCell *cell = (ReplaysCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    
    
      
    NSArray *info = [videoDetails objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageWithContentsOfFile:[info objectAtIndex:0]];
    //cell.imageView.image=[UIImage imageNamed:[info objectAtIndex:0]];
    cell.Videos_name.text=[info objectAtIndex:2];
    // Set the data for this cell:
    

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //place moive player here to play
    //place detailviewcontroller to show more details of file
    NSArray *info = [videoDetails objectAtIndex:indexPath.row];
     url=[NSURL URLWithString:[info objectAtIndex:1]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self playMovie];
   
    }

-(void)playMovie{
    
    movieplayer=  [[MPMoviePlayerController alloc]
                    initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:movieplayer];
    
    movieplayer.controlStyle = MPMovieControlStyleDefault;
    movieplayer.shouldAutoplay = YES;
    [self.view addSubview:movieplayer.view];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    
    
    [self playMovie];
}
@end
