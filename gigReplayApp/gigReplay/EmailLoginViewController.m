//
//  EmailLoginViewController.m
//  gigReplay
//
//  Created by Leon Ng on 19/7/13.
//  Copyright (c) 2013 Leon Ng. All rights reserved.
//

#import "EmailLoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "SQLdatabase.h"



@interface EmailLoginViewController ()

@end

@implementation EmailLoginViewController
@synthesize emailOutlet,passwordOutlet,confirmPassOutlet;

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
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextField:)];
    [self.view addGestureRecognizer:tapToDismiss];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)resignTextField:(id)sender {
    [passwordOutlet resignFirstResponder];
    [confirmPassOutlet resignFirstResponder];
    [emailOutlet  resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButton:(id)sender {
    
    //Post email address, password to database. Qn is online db or local db. Security?
    
    if([emailOutlet.text isEqualToString:@"" ] && [passwordOutlet.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"Email and password field are empty"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];}

        else if ([emailOutlet.text isEqualToString:@"" ]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"Email field is empty"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];}
       else if( [passwordOutlet.text isEqualToString:@""]) {
           UIAlertView *alert = [[UIAlertView alloc]
                                 initWithTitle: @"Error"
                                 message: @"Password field is empty"
                                 delegate: nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
           [alert show];}
       else if (![passwordOutlet.text isEqualToString:confirmPassOutlet.text]){
           UIAlertView *alert = [[UIAlertView alloc]
                                 initWithTitle: @"Error"
                                 message: @"Password field do not MATCH"
                                 delegate: nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
           [alert show];
       }
    
       
else  {
    // POST TO DATABASE TO STORE EMAIL N PASSWORD
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://lipsync.sg/api/EmailLogin.php"]];
    

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:emailOutlet.text forKey:@"email"];
    [request setPostValue:passwordOutlet.text forKey:@"password"];
    [request setDelegate:self];
    [request startSynchronous];
  NSLog(@"%@",request.responseString);
    if([request.responseString isEqualToString:@"success"]){
        NSLog(@"load homepage");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Account Created"
                              message:[NSString stringWithFormat:@"Email %@    Password:%@",emailOutlet.text,passwordOutlet.text]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
        
            }
}
}



//- (void)requestCompleted:(ASIHTTPRequest *)request
//{
//    NSString *responseString = [request responseString];
//    NSLog(@"ResponseString:%@",responseString);
//}
//
//- (void)requestError:(ASIHTTPRequest *)request
//{
//    NSError *error = [request error];
//    NSLog(@"Error:%@",[error description]);
//}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
