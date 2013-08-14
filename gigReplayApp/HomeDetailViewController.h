//
//  HomeDetailViewController.h
//  gigReplay
//
//  Created by Leon Ng on 5/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface HomeDetailViewController : UIViewController<UITableViewDelegate,UIScrollViewDelegate>{
    UIScrollView *scrollView;

}
@property (strong,nonatomic)MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;
@property (strong, nonatomic) IBOutlet UITableView *commentTableVIew;
@property (strong,nonatomic) NSURL *videoURL;
@property (strong,nonatomic) NSString *media_id;
@property (strong,nonatomic) NSMutableArray *commentArray;
- (IBAction)backToHome:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *commentUIView;

@property (assign,nonatomic)CGFloat newHeight;

@property(strong,nonatomic)NSMutableArray *array;

@end
