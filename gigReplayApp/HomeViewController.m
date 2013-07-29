//
//  HomeViewController.m
//  gigReplay
//
//  Created by Leon Ng on 29/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{   UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(leon) forControlEvents:UIControlEventValueChanged];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl=refresh;
    refresh.tintColor=[UIColor redColor];
    [super viewDidLoad];
   
    
    // Do any additional setup after loading the view from its nib.
}
-(void)leon{
    self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Updating.."];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString* CellIdentifier = @"HomeViewCustomCell";
	
	//custom cell initilisation
	HomeViewCustomCell *cell = (HomeViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
	{
		
		NSArray *topLevelObjects;
		
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeViewCustomCell" owner:self options:nil];
		for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (HomeViewCustomCell *) currentObject;
				break;
			}
		}
	}
    
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 10;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 495;
}

@end
