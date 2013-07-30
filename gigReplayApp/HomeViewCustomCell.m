//
//  HomeViewCustomCell.m
//  gigReplay
//
//  Created by Leon Ng on 29/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeViewCustomCell.h"

@implementation HomeViewCustomCell
@synthesize imageView,VideoView,videoImageView,imageView1,imageView2,imageView3,playButton,movieplayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        movieplayer.controlStyle = MPMovieControlStyleDefault;
        movieplayer.shouldAutoplay = NO;
        [VideoView addSubview:movieplayer.view];
        [movieplayer.view setFrame:VideoView.bounds];
        
        [movieplayer setFullscreen:YES animated:YES];

        
            }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
