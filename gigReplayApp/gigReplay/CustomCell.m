//
//  CustomCell.m
//  gigReplay
//
//  Created by Leon Ng on 10/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "CustomCell.h"
#import "JoinSessionViewController.h"
#import "AppDelegate.h"



@implementation CustomCell
@synthesize sceneSelectionButton,fbProfilePictureView,SceneName,SceneTake,directorName,facebookimageview,dateLabel;
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
