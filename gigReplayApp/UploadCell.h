//
//  UploadCell.h
//  gigReplay
//
//  Created by User on 22/5/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) IBOutlet UILabel *sessionName;
@property (strong, nonatomic) IBOutlet UILabel *dateTaken;
@property (strong,nonatomic) IBOutlet UIButton *customButton;
@property (strong, nonatomic) IBOutlet UIImageView *uploadedTick;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;


@end
