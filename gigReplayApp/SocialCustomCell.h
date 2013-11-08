//
//  SocialCustomCell.h
//  gigReplay
//
//  Created by Leon Ng on 30/10/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UIView *avplayerView;

@end
