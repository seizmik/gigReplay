//
//  SettingsViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface SettingsViewController : UIViewController{
    NSArray *videoResolutionValues;
}

- (IBAction)facebookLogOut:(id)sender;
- (IBAction)syncTrial:(UIButton *)sender;


- (IBAction)reSync:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITableView *videoResolutionTable;
- (IBAction)videoResButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *videoResButtonOutlet;



@end
