//
//  SignInViewController.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "CurrentUser.h"
#import "SignInViewController.h"
#import "MBProgressHUD.h"
#import "MenuViewController.h"
#import "SignInViewControllerDelegate.h"
#import "RestKit.h"
#import "User.h"

@interface SignInViewController () <RKRequestDelegate,UITextFieldDelegate>
extern NSString* applicationURL;
@property (weak, nonatomic) IBOutlet UITextField *usernameBox;
@property (weak, nonatomic) IBOutlet UITextField *passwordBox;
@property (weak, nonatomic) IBOutlet UILabel *errorBox;
@end

@implementation SignInViewController 
@synthesize usernameBox;
@synthesize passwordBox;
@synthesize errorBox;
@synthesize delegate;

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
    [RKClient clientWithBaseURLString:applicationURL];
    [self.usernameBox setDelegate:self];
    [self.passwordBox setDelegate:self];
}

- (void)viewDidUnload
{
    [self setUsernameBox:nil];
    [self setPasswordBox:nil];
    [self setErrorBox:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)signinPressed:(UIButton *)sender {
    [self.usernameBox resignFirstResponder];
    [self.passwordBox resignFirstResponder];
    
    RKClient *client = [RKClient sharedClient];
    if ([self.usernameBox.text length]>0 && [self.passwordBox.text length]>0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *userNamePassword = [NSDictionary dictionaryWithKeysAndObjects:
                                              @"email",self.usernameBox.text,
                                              @"password",self.passwordBox.text, nil];
            NSDictionary *params = [NSDictionary dictionaryWithObject:userNamePassword forKey:@"session"];
            [client post:@"sessions.json" params:params delegate:self];
        });
        
    } else {
        if ([self.usernameBox.text length] ==0)
            self.errorBox.text = @"Please enter username";
        else
            self.errorBox.text = @"Please enter password";
    }
}

- (IBAction)signupPressed:(UIButton *)sender {
}

//uitextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

//RKRequestDelegate
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    if ([response isSuccessful]) {
        CurrentUser *currentUser = [CurrentUser currentUser];
        currentUser.cookies = [response cookies];
        
        id parsedObject = [response parsedBody:nil];
        currentUser.username = [parsedObject objectForKey:@"email"];
        currentUser.userId = [[parsedObject objectForKey:@"id"] integerValue];
        
        [delegate signInViewController:self signInSuccessfull:YES];
    } else {
        self.errorBox.text = @"Invalid username or password";
        [delegate signInViewController:self signInSuccessfull:NO];
    }

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
