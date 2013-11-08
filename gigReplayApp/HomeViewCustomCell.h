//
//  HomeViewCustomCell.h
//  gigReplay
//
//  Created by Leon Ng on 29/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HomeViewCustomCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *VideoView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView1;
@property (strong, nonatomic) IBOutlet UIImageView *imageView2;

@property (strong, nonatomic) IBOutlet UIImageView *imageView3;
@property (strong, nonatomic) IBOutlet UIView *moviePlayer;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;

@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property(strong,nonatomic)MPMoviePlayerController *movieplayer;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *username;

@property (strong, nonatomic) IBOutlet UILabel *videoTitle;




@end
