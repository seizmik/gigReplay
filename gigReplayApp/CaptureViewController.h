//
//  CaptureViewController.h
//  gigReplay
//
//  Created by Leon Ng on 13/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateSessionViewController.h"
#import "JoinSessionViewController.h"
#import "SettingsViewController.h"
#import "OpenSessionViewController.h"
#import "UploadTab.h"


@interface CaptureViewController : UIViewController
- (IBAction)createButton:(id)sender;
- (IBAction)joinButton:(id)sender;
- (IBAction)openButton:(id)sender;
- (IBAction)uploadButton:(id)sender;
- (IBAction)settingsButton:(id)sender;

@end
