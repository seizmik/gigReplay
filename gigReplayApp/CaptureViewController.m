//
//  CaptureViewController.m
//  gigReplay
//
//  Created by Leon Ng on 13/8/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "CaptureViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

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
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButton:(id)sender {
    
    CreateSessionViewController *createVC=[[CreateSessionViewController alloc]init];
    [self.navigationController pushViewController:createVC animated:YES];
}

- (IBAction)joinButton:(id)sender {
    JoinSessionViewController *joinVC=[[JoinSessionViewController alloc]init];
    [self.navigationController pushViewController:joinVC animated:YES];
}

- (IBAction)openButton:(id)sender {
    OpenSessionViewController *openVC=[[OpenSessionViewController alloc]init];
    [self.navigationController pushViewController:openVC animated:YES];
}

- (IBAction)uploadButton:(id)sender {
    UploadTab *uploadVC=[[UploadTab alloc]init];
    [self.navigationController pushViewController:uploadVC animated:YES];
    
}

- (IBAction)settingsButton:(id)sender {
}
@end
