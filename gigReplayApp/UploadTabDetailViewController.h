//
//  UploadTabDetailViewController.h
//  gigReplay
//
//  Created by Leon Ng on 4/6/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface UploadTabDetailViewController : UIViewController{
    MPMoviePlayerController *moviePlayer;
   
}

@property(strong,nonatomic)NSString *videoPath;
@property(strong,nonatomic)NSString *videoURL;
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UIView *videoPlayer;

 

@end
