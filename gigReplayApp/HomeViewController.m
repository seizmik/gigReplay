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


@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize tableViewRequests,videoImage,image1,image2,image3,movieplayer,videoURL;

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
//    [refresh addTarget:self action:@selector(leon) forControlEvents:UIControlEventValueChanged];
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    self.refreshControl=refresh;
//    refresh.tintColor=[UIColor redColor];
    
    [super viewDidLoad];
    [self obtainDataFromURL];
    [self obtainDataFromURL2];
    
    
    myTabBar=[[UITabBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [myTabBar setDelegate:self];
    UIImage *imageForTabItem1=[UIImage imageNamed:@"redstar.png"];
    
    UITabBarItem *firstItem = [[UITabBarItem alloc]initWithTitle:@"Featured" image:imageForTabItem1 tag:1];
    [firstItem setFinishedSelectedImage:imageForTabItem1 withFinishedUnselectedImage:[UIImage imageNamed:@"redstar_off.png"]];
    UITabBarItem *secondItem = [[UITabBarItem alloc]initWithTitle:@"myVideos" image:nil tag:2 ];
    [secondItem setFinishedSelectedImage:[UIImage imageNamed:@"myvideos_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"myvideos_off.png"]];

    NSArray *itemsArray = [NSArray arrayWithObjects:firstItem, secondItem, nil];
    
    [myTabBar setItems:itemsArray animated:NO];
    
    [self.view addSubview:myTabBar];
    myTabBar.selectedItem=firstItem;

    // Do any additional setup after loading the view from its nib.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"tab selected: %@", item.title);
    if(item.tag==2){
        
        [self.view addSubview:self.myVideosView];
        [self.myVideosView addSubview:myTabBar];

        
    }else if(item.tag==1){
        [self.myVideosView removeFromSuperview];
        [self.view addSubview:tabBar];
        
    }
}

//-(void)leon{
//    self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Updating.."];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMM d, h:mm a"];
//    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
//}
-(void) fetchedData:(NSData*) data{
    
    
    videoArray=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    [self.tableViewRequests reloadData];
    NSLog(@"%@",videoArray);
    
}
-(void) obtainDataFromURL{
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://lipsync.sg/api/replaysvideos.php?uid=%d",appDelegateObject.CurrentUserID]]];
            [self performSelectorOnMainThread:@selector(fetchedData:)
                                   withObject:data waitUntilDone:YES];
        });
    

//    dispatch_async(kBgQueue, ^{
//        NSData* data = [NSData dataWithContentsOfURL:getURL];
//        [self performSelectorOnMainThread:@selector(fetchedData:)
//                               withObject:data waitUntilDone:YES];
//    });
}
-(void) fetchedData2:(NSData*) data{
    
    
    videoArray2=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    [self.tableViewRequests reloadData];
    NSLog(@"%@",videoArray);
    
}
-(void) obtainDataFromURL2{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:getURL2];
        [self performSelectorOnMainThread:@selector(fetchedData2:)
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
    if(tableView.tag==1){
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

        NSDictionary *info=[videoArray2 objectAtIndex:indexPath.row];
        videoImage=[info objectForKey:@"thumb_1_url"];
        [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell.username.text=@"GigReplay Presents..";
        cell.profilePic.image=[UIImage imageNamed:@"tab_generate_button_on_30.png"];
        
        return cell;
    }else 
   
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
 
        NSMutableDictionary *info=[videoArray objectAtIndex:indexPath.row];
        
        videoImage=[info objectForKey:@"thumb_1_url"];
        image1=[info objectForKey:@"thumb_2_url"];
        image2=[info objectForKey:@"thumb_3_url"];
        image3=[info objectForKey:@"thumb_1_url"];
        NSString *fb_user_ID=[info objectForKey:@"fb_user_id"];
        [cell.videoImageView setImageWithURL:[NSURL URLWithString:videoImage]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        NSString *profilePicURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=77&height=66", fb_user_ID];
        cell.username.text =[info objectForKey:@"user_name"];
        //    [cell.imageView1 setImageWithURL:[NSURL URLWithString:image2]
        //                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        //    [cell.imageView2 setImageWithURL:[NSURL URLWithString:image3]
        //                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        //    [cell.imageView3 setImageWithURL:[NSURL URLWithString:image1]
        //                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [cell.profilePic setImageWithURL:[NSURL URLWithString:profilePicURL]];
        
        
       return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView.tag==2){
    NSMutableDictionary *info = [videoArray objectAtIndex:indexPath.row];
    NSString *media_master_id=[info objectForKey:@"master_id"];
    url=[NSURL URLWithString:[info objectForKey:@"media_url"]];
    HomeDetailViewController *homeDetailVC=[[HomeDetailViewController alloc]init];
    [homeDetailVC setVideoURL:url];
    [homeDetailVC setMedia_id:media_master_id];
    [self presentViewController:homeDetailVC animated:YES completion:nil];
    NSLog(@"%@",url);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }else{
        NSMutableDictionary *info = [videoArray2 objectAtIndex:indexPath.row];
        NSString *media_master_id=[info objectForKey:@"master_id"];
        url=[NSURL URLWithString:[info objectForKey:@"media_url"]];
        HomeDetailViewController *homeDetailVC=[[HomeDetailViewController alloc]init];
        [homeDetailVC setVideoURL:url];
        [homeDetailVC setMedia_id:media_master_id];
        [self presentViewController:homeDetailVC animated:YES completion:nil];
        NSLog(@"%@",url);
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==2){
        return [videoArray count];
    }
    else{
        return [videoArray2 count];
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==2){
        return 177;}
    else{
        return 177;
    }
}
-(void)callAction:(UIButton *)sender
{
    
    
    //CustomBUtton.tags == filedetails uploadarray index:custombutton.tag
    int entryNumber = sender.tag;
    NSDictionary *this = [[NSDictionary alloc] init];
    this = [videoArray objectAtIndex:entryNumber];
    movieplayer=  [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:[this objectForKey:@"media_url"]]];
    
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
        [player setCurrentPlaybackTime:0];
    }
}

@end
