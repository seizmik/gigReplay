//
//  HomeViewCustomCell2.m
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "MyVideosCustomCell.h"

@implementation MyVideosCustomCell
@synthesize fbProfileImageView,videoImageView,userName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
