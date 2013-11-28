//
//  SettingsViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface SettingsViewController : UIViewController

- (IBAction)facebookLogOut:(id)sender;
- (IBAction)syncTrial:(UIButton *)sender;


- (IBAction)reSync:(UIButton *)sender;




@end
