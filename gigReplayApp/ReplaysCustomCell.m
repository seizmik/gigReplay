//
//  ReplaysCustomCell.m
//  gigReplay
//
//  Created by Leon Ng on 15/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "ReplaysCustomCell.h"

@implementation ReplaysCustomCell
@synthesize Videos_name,imageView;

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
