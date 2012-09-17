//
//  SignInViewController.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "SignInViewController.h"
#import "MBProgressHUD.h"
#import "MenuViewController.h"
#import "SessionStore.h"
#import "SignInViewControllerDelegate.h"
#import "SignUpViewController.h"
#import "User.h"

@interface SignInViewController () <UITextFieldDelegate>
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
    
    if ([self.usernameBox.text length]>0 && [self.passwordBox.text length]>0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[SessionStore sharedStore] createSessionWithEmail:self.usernameBox.text withPassword:self.passwordBox.text withBlock:^(BOOL successful){
            if (successful) {
                [self.delegate signInViewController:self signInSuccessfull:YES];
            } else {
                self.errorBox.text = @"Invalid username or password";
                [self.delegate signInViewController:self signInSuccessfull:NO];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
    } else {
        if ([self.usernameBox.text length] ==0)
            self.errorBox.text = @"Please enter username";
        else
            self.errorBox.text = @"Please enter password";
    }
}

- (IBAction)signupPressed:(UIButton *)sender {
    SignUpViewController *signUpVC = [SignUpViewController new];
    signUpVC.modalPresentationStyle = UIModalPresentationFormSheet;
    signUpVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    signUpVC.completionBlock = ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if ([[SessionStore sharedStore] currentUser] != nil) {
                [delegate signInViewController:self signInSuccessfull:YES];
            }
        }];
    };
    [self presentViewController:signUpVC animated:YES completion:nil];
}

//uitextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self signinPressed:nil];
    return NO;
}

@end
