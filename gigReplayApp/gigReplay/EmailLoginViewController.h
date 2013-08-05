//
//  EmailLoginViewController.h
//  gigReplay
//
//  Created by Leon Ng on 19/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailLoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *emailOutlet;
@property (strong, nonatomic) IBOutlet UITextField *passwordOutlet;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassOutlet;
- (IBAction)signUpButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

@end
