//
//  HomeDetailViewController.m
//  gigReplay
//
//  Created by Leon Ng on 5/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "HomeDetailViewCustomCell.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)


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
[self obtainDataFromURL];
    [super viewDidLoad];
    
    
    
   
    [self.moviePlayer prepareToPlay];
    [self playMovie];// Do any additional setup after loading the view from its nib.
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 226, 320, 322)];
    scrollView.contentSize=CGSizeMake(320,(self.commentTableVIew.contentSize.height+225+10*[self.commentArray count]));
    scrollView.bounces=NO;
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.commentUIView];
    
    [self.commentTableVIew setFrame:CGRectMake(0, 226, 320, scrollView.contentSize.height)];
    [scrollView addSubview:self.commentTableVIew];
    NSLog(@"%f",self.commentTableVIew.contentSize.height);
    NSLog(@"%f",self.commentTableVIew.contentSize.width);
}
-(void) fetchedData:(NSData*) data{
    
    
    self.commentArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    [self.commentTableVIew reloadData];
}

-(void) obtainDataFromURL{
    
   // NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lipsync.sg/api/commentAPI.php?mediaid=165"]];
    
   // [self fetchedData:data];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lipsync.sg/api/commentAPI.php?mediaid=165"]];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });

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
    [cell.userName setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN,  CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 40)];
    [cell.userComment setFrame:CGRectMake(CELL_CONTENT_MARGIN, 40, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    
    return cell;
    
}



@end
