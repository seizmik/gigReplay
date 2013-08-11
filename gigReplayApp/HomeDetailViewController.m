//
//  HomeDetailViewController.m
//  gigReplay
//
//  Created by Leon Ng on 5/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "HomeDetailViewCustomCell.h"

@interface HomeDetailViewController ()

@end

@implementation HomeDetailViewController

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
    [self.moviePlayer prepareToPlay];
    [self playMovie];// Do any additional setup after loading the view from its nib.
}
-(void) fetchedData:(NSData*) data{
    
    
    self.commentArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    [self.commentTableVIew reloadData];
}

-(void) obtainDataFromURL{
    
    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://lipsync.sg/api/commentAPI.php?mediaid=%@",self.media_id]]];
    
    [self fetchedData:data];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    static NSString *CellIdentifier = @"Cell";
    //
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    }
    static NSString* CellIdentifier = @"HomeDetailViewCustomCell";
	
	
	HomeDetailViewCustomCell *cell = (HomeDetailViewCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
	if (cell == nil)
	{
		
		NSArray *topLevelObjects;
		
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeDetailViewCustomCell" owner:self options:nil];
		for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (HomeDetailViewCustomCell *) currentObject;
				break;
			}
		}
	}
    
    
    
    NSMutableDictionary *info=[self.commentArray objectAtIndex:indexPath.row];
    cell.userComment.text=[info objectForKey:@"comment"];
    cell.userName.text=[info objectForKey:@"user_name"];
  
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.commentArray count];
}


- (IBAction)backToHome:(id)sender {
    [self.moviePlayer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
