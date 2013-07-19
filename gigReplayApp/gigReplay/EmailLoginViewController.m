//
//  EmailLoginViewController.m
//  gigReplay
//
//  Created by Leon Ng on 19/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "EmailLoginViewController.h"

@interface EmailLoginViewController ()

@end

@implementation EmailLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButton:(id)sender {
    
    //Post email address, password to database. Qn is online db or local db. Security?
    
    
    
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
