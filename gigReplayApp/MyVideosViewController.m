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
    [self obtainDataFromURL];
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
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lipsync.sg/api/myVideos.php?uid=%d",appDelegateObject.CurrentUserID]]];
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
    videoImage=[info objectForKey:@"thumb_1_url"];
    [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.userName.text=@"GigReplay Presents..";
   // cell.fbProfileImageView=[UIImage imageNamed:@"replayvid.png"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSMutableDictionary *info = [myVideosArray objectAtIndex:indexPath.row];
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
    
    return [myVideosArray count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 177;
}



@end
