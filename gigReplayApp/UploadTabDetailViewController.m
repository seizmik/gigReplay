//
//  UploadTabDetailViewController.m
//  gigReplay
//
//  Created by Leon Ng on 4/6/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "UploadTabDetailViewController.h"

@interface UploadTabDetailViewController ()

@end

@implementation UploadTabDetailViewController
@synthesize videoURL,videoPlayer,imageview,videoPath;

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
    [self.view addSubview:imageview];
    [self.view addSubview:videoPlayer];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"upload" style:UIBarButtonItemStyleBordered target:self action:@selector(StopMoviePlayer)];
    self.navigationController.navigationItem.leftBarButtonItem=backButton;
   
    
    NSLog(@"videopath is at url:%@",videoPath);
    NSLog(@"video is at url: %@",videoURL);
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated{
    [imageview setImage:[UIImage imageWithContentsOfFile:videoURL]];
    moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:videoPath]];
    [[moviePlayer view]setFrame:videoPlayer.bounds  ];
    [self.videoPlayer addSubview:moviePlayer.view    ];
    [moviePlayer prepareToPlay];
    [moviePlayer pause];
    
}

-(void)StopMoviePlayer{
    [moviePlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
