//
//  CustomCell.h
//  gigReplay
//
//  Created by Leon Ng on 10/4/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import<FacebookSDK/FacebookSDK.h>
#import "SQLdatabase.h"
#import "ApiObject.h"



@interface CustomCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *SceneName;
@property (strong, nonatomic) IBOutlet UILabel *SceneTake;
@property (strong, nonatomic) IBOutlet UILabel *directorName;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *fbProfilePictureView;

@property (strong, nonatomic) IBOutlet UIButton *sceneSelectionButton;
- (IBAction)pressedButton:(id)sender;



@end
