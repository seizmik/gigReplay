//
//  MyVideosCustomCell.h
//  gigReplay
//
//  Created by Leon Ng on 6/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVideosCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fbProfileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *videoDesc;

@end
