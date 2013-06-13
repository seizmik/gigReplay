//
//  UploadCell.m
//  gigReplay
//
//  Created by User on 22/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "UploadCell.h"

@implementation UploadCell

@synthesize thumbnail = _thumbnail;
@synthesize sessionName = _sessionName;
@synthesize dateTaken = _dateTaken;
@synthesize customButton;

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
