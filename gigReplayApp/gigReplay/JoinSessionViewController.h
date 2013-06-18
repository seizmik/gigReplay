//
//  JoinSessionViewController.h
//  gigReplay
//
//  Created by Leon Ng on 25/3/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "AppDelegate.h" 
#import "ApiObject.h"
#import "MediaRecordViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JoinSessionViewController : UIViewController<UITableViewDelegate,UIAlertViewDelegate>{
    UIView *overlay;
    int currentSelectedSession;
    NSMutableArray *sessionDetailsHolder;
      BOOL    SelectionButtonSeleted;
    MediaRecordViewController *mediaObject;
   
    
}

@property (strong, nonatomic) IBOutlet UITextField *usernameSearchTextField;
@property (strong, nonatomic) IBOutlet UITextField *SceneNameSearchTextField;
@property(strong,nonatomic)ApiObject *apiWrapperObject;
@property(strong,nonatomic)CustomCell *cellObject;
- (IBAction)textDidEnd:(id)sender;
- (IBAction)textDidEnd2:(id)sender;
- (IBAction)searchButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableViewScenes;
@property(strong,nonatomic)NSMutableArray *sessionDetailsHolder;


//- (IBAction)start:(id)sender;
//- (void)JoinToSessions:(NSString *)session_pass;

@end
